# frozen_string_literal: true

module ::DkMarket
  class MarketController < ::ApplicationController
    requires_plugin ::DkMarket::PLUGIN_NAME

    before_action :ensure_logged_in, only: %i[purchase my_items use unuse]

    def index
      render html: "", layout: true
    end

    def items
      items = MarketItem.where(is_active: true).order(:category, :name).to_a
    
      owned_ids =
        if current_user
          MarketUserInventory
            .where(user_id: current_user.id, is_active: true)
            .where("expires_at IS NULL OR expires_at > ?", Time.zone.now)
            .pluck(:item_id)               # ← FK는 item_id
            .uniq
        else
          []
        end
    
      items.each { |it| it.owned = owned_ids.include?(it.id) }
    
      render_json_dump items: serialize_data(items, MarketItemSerializer)
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
