# frozen_string_literal: true

module ::DkMarket
  class MarketController < ::ApplicationController
    requires_plugin ::DkMarket::PLUGIN_NAME

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
      render json: { success: true }
    end

    def my_item
      render json: { items: [] }
    end

    def use
      render json: { success: true }
    end

    def unuse
      render json: { success: true }
    end
  end
end
