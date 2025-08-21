# frozen_string_literal: true

module ::DkMarket
  class MarketController < ::ApplicationController
    requires_plugin ::DkMarket::PLUGIN_NAME

    before_action :ensure_logged_in, only: %i[purchase purchase_info my_items use unuse]

    def index
      render html: "", layout: true
    end

    def items
      items =
        MarketItem
          .where(is_active: true)
          .joins(
            "LEFT JOIN gamification_level_infos ON gamification_level_infos.level = market_items.min_level",
          )
          .select("market_items.*, gamification_level_infos.image_url AS level_image_url, gamification_level_infos.name AS level_name")
          .order(:min_level, :category, :name)
          .to_a

      owned_ids =
        if current_user
          MarketUserInventory
            .where(user_id: current_user.id, is_active: true)
            .where("expires_at IS NULL OR expires_at > ?", Time.zone.now)
            .pluck(:item_id)
            .uniq
        else
          []
        end

      items.each { |it| it.owned = owned_ids.include?(it.id) }

      points = 0
      level = nil
      if current_user
        point_score =
          DB.query_single(
            "SELECT COALESCE(point,0), COALESCE(score,0) FROM gamification_scores WHERE user_id = ?",
            current_user.id,
          )
        points = point_score[0].to_i
        score = point_score[1].to_i
        level =
          DB.query_hash(
            "SELECT id, name, image_url FROM gamification_level_infos WHERE min_score <= ? AND max_score >= ? LIMIT 1",
            score,
            score,
          ).first
      end

      render_json_dump(
        items: serialize_data(items, MarketItemSerializer),
        points: points,
        level: level,
      )
    end

    def show
      render json: { id: params[:id].to_i, name: "Example Item #{params[:id]}" }
    end

    def purchase
      item = MarketItem.find_by(id: params[:item_id], is_active: true)
      raise Discourse::InvalidParameters unless item

      result = Market::PurchaseService.new(current_user, item).perform
      if result.success?
        render_json_dump(
          success: true,
          before_points: result.before_points,
          after_points: result.after_points,
        )
      else
        render_json_error result.error
      end
    end

    def purchase_info
      item = MarketItem.find_by(id: params[:item_id], is_active: true)
      raise Discourse::InvalidParameters unless item

      point_score =
        DB.query_single(
          "SELECT COALESCE(point,0), COALESCE(score,0) FROM gamification_scores WHERE user_id = ?",
          current_user.id,
        )
      before_points = point_score[0].to_i
      score = point_score[1].to_i
      level_id =
        DB.query_single(
          "SELECT id FROM gamification_level_infos WHERE min_score <= ? AND max_score >= ? LIMIT 1",
          score,
          score,
        ).first.to_i
      if level_id < item.min_level
        return render_json_error I18n.t("market.errors.low_level")
      end

      inventory =
        MarketUserInventory.active_current.find_by(
          user_id: current_user.id,
          item_id: item.id,
        )

      render_json_dump(
        points: before_points,
        is_active: inventory.present?,
        price_points: item.price_points,
        duration_days: item.duration_days,
      )
    end

    def my_items
      inventories =
        MarketUserInventory
          .active_current
          .by_user(current_user)
          .joins(:market_item)
          .where(market_items: { is_active: true })
          .includes(:market_item)
          .order("market_items.category ASC, market_items.name ASC")

      items = inventories.map do |inv|
        item = inv.market_item
        item.inventory_id = inv.id
        item.expires_at = inv.expires_at
        item.is_used = inv.is_used
        item.owned = true
        item
      end

      render_json_dump items: serialize_data(items, MarketItemSerializer)
    end

    def use
      inventory =
        MarketUserInventory.includes(:market_item).find_by(
          id: params[:inventory_id],
          user_id: current_user.id,
        )
      raise Discourse::InvalidParameters unless inventory

      MarketUserInventory.transaction do
        category = inventory.market_item.category
        MarketUserInventory
          .joins(:market_item)
          .where(user_id: current_user.id, market_items: { category: category })
          .update_all(is_used: false)

        inventory.update!(is_used: true)
      end

      render_json_dump success: true
    rescue StandardError => e
      render_json_error e.message
    end

    def unuse
      inventory = MarketUserInventory.find_by(
        id: params[:inventory_id],
        user_id: current_user.id,
      )
      raise Discourse::InvalidParameters unless inventory

      inventory.update!(is_used: false)

      render_json_dump success: true
    rescue StandardError => e
      render_json_error e.message
    end
  end
end
