# frozen_string_literal: true

module Market
  class PurchaseService
    Result = Struct.new(:success?, :error)

    def initialize(user, item)
      @user = user
      @item = item
    end

    def perform
      inventory = MarketUserInventory.find_by(user_id: @user.id, market_item_id: @item.id)

      case @item.duplicate_policy
      when "deny"
        return Result.new(false, I18n.t("market.errors.already_owned")) if inventory
        create_inventory
      when "extend"
        inventory ? extend_inventory(inventory) : create_inventory
      else
        create_inventory
      end

      MarketPurchaseHistory.create!(user_id: @user.id, market_item_id: @item.id)

      Result.new(true, nil)
    rescue StandardError => e
      Result.new(false, e.message)
    end

    private

    def create_inventory
      MarketUserInventory.create!(
        user_id: @user.id,
        market_item_id: @item.id,
        in_use: false,
        expires_at: expiry_time
      )
    end

    def extend_inventory(inventory)
      inventory.update!(expires_at: [inventory.expires_at, Time.zone.now].compact.max + duration)
    end

    def duration
      (@item.duration || 0).days
    end

    def expiry_time
      @item.duration ? Time.zone.now + duration : nil
    end
  end
end
