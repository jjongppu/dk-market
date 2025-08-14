# frozen_string_literal: true

module Market
  class PurchaseService
    Result = Struct.new(:success?, :error, :before_points, :after_points)

    def initialize(user, item)
      @user = user
      @item = item
    end

    def perform
      ActiveRecord::Base.transaction do
        inventory =
          MarketUserInventory.active_current.find_by(
            user_id: @user.id,
            item_id: @item.id,
          )

        point_score =
          DB.query_single(
            "SELECT COALESCE(point,0), COALESCE(score,0) FROM gamification_scores WHERE user_id = ?",
            @user.id,
          )
        before_points = point_score[0].to_i
        score = point_score[1].to_i

        level_id =
          DB.query_single(
            "SELECT id FROM gamification_level_infos WHERE min_score <= ? AND max_score >= ? LIMIT 1",
            score,
            score,
          ).first.to_i
        if level_id < @item.min_level
          return Result.new(false, I18n.t("market.errors.low_level"))
        end

        if before_points < @item.price_points
          return Result.new(false, I18n.t("market.errors.not_enough_points"))
        end
        after_points = before_points - @item.price_points
        DB.exec(
          "UPDATE gamification_scores SET point = ? WHERE user_id = ?",
          after_points,
          @user.id,
        )

        case @item.duplicate_policy
        when "deny"
          return Result.new(false, I18n.t("market.errors.already_owned")) if inventory
          inventory = create_inventory
        when "extend"
          inventory = inventory ? extend_inventory(inventory) : create_inventory
        else
          inventory = create_inventory
        end

        MarketPurchaseHistory.create!(
          user_id: @user.id,
          item_id: @item.id,
          quantity: 1,
          price_points: @item.price_points,
          status: "completed",
          payment_type: "usable_points",
          before_points: before_points,
          after_points: after_points,
          market_snapshot_json: @item.as_json,
        )

        Result.new(true, nil, before_points, after_points)
      end
    rescue StandardError => e
      Result.new(false, e.message)
    end

    private

    def create_inventory
      MarketUserInventory.create!(
        user_id: @user.id,
        item_id: @item.id,
        is_used: false,
        expires_at: expiry_time,
      )
    end

    def extend_inventory(inventory)
      return inventory unless @item.is_limited_duration

      inventory.update!(
        expires_at: [inventory.expires_at, Time.zone.now].compact.max + duration,
      )
      inventory
    end

    def duration
      (@item.duration_days || 0).days
    end

    def expiry_time
      @item.is_limited_duration ? Time.zone.now + duration : nil
    end
  end
end
