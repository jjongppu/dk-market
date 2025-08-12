# frozen_string_literal: true

module ::DkMarket
  class MarketController < ::ApplicationController
    requires_plugin ::DkMarket::PLUGIN_NAME

    before_action :ensure_logged_in, only: %i[purchase my_item use unuse]

    def index
      render html: "", layout: true
    end

    def items
      render_serialized MarketItem.all, MarketItemSerializer
    end

    def show
      item = MarketItem.find(params[:id])
      render_serialized item, MarketItemSerializer
    end

    def purchase
      item = MarketItem.find(params[:item_id])
      result = ::Market::PurchaseService.new(current_user, item).perform
      if result.success?
        render json: success_json
      else
        render_json_error(result.error)
      end
    end

    def my_item
      inventories = MarketUserInventory.where(user_id: current_user.id)
      render_serialized inventories, MarketUserInventorySerializer
    end

    def use
      inventory = MarketUserInventory.find_by(id: params[:inventory_id], user_id: current_user.id)
      raise Discourse::NotFound unless inventory

      ::Market::ApplyService.new(current_user, inventory).use
      render json: success_json
    end

    def unuse
      inventory = MarketUserInventory.find_by(id: params[:inventory_id], user_id: current_user.id)
      raise Discourse::NotFound unless inventory

      ::Market::ApplyService.new(current_user, inventory).unuse
      render json: success_json
    end
  end
end
