# frozen_string_literal: true

module Market
  class PurchaseService
    Result = Struct.new(:success?, :error)

    def initialize(user, item)
      @user = user
      @item = item
    end

    def perform
      inventory = MarketUserInventory.find_by(user_id: @user.id, item_id: @item.id)

      case @item.duplicate_policy
      when "deny"
        return Result.new(false, I18n.t("market.errors.already_owned")) if inventory
        create_inventory
      when "extend"
        inventory ? extend_inventory(inventory) : create_inventory
      else
        create_inventory
      end

      MarketPurchaseHistory.create!(
        user_id: @user.id,
        item_id: @item.id,
        quantity: 1,
        price_points: @item.price_points,
        status: "completed",
        payment_type: "usable_points",
        before_points: 0,
        after_points: 0,
      )

      Result.new(true, nil)
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
      return unless @item.is_limited_duration

      inventory.update!(expires_at: [inventory.expires_at, Time.zone.now].compact.max + duration)
    end

    def duration
      (@item.duration_days || 0).days
    end

    def expiry_time
      @item.is_limited_duration ? Time.zone.now + duration : nil
    end
  end
end
