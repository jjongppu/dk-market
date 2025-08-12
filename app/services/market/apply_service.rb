# frozen_string_literal: true

module Market
  class ApplyService
    def initialize(user, inventory)
      @user = user
      @inventory = inventory
    end

    def use
      MarketUserInventory
        .joins(:market_item)
        .where(user_id: @user.id, market_items: { category: @inventory.market_item.category })
        .update_all(is_used: false)

      @inventory.update!(is_used: true)
    end

    def unuse
      @inventory.update!(is_used: false)
    end
  end
end
