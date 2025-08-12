# frozen_string_literal: true

module ::DkMarket
  class AdminController < ::ApplicationController
    requires_plugin ::DkMarket::PLUGIN_NAME

    before_action :ensure_logged_in
    before_action :ensure_staff

    def index
      render_serialized MarketItem.all, MarketItemSerializer
    end

    def create
      item = MarketItem.new(item_params)
      if item.save
        render_serialized item, MarketItemSerializer
      else
        render_json_error item.errors.full_messages.join("\n")
      end
    end

    def update
      item = MarketItem.find(params[:id])
      if item.update(item_params)
        render_serialized item, MarketItemSerializer
      else
        render_json_error item.errors.full_messages.join("\n")
      end
    end

    def destroy
      item = MarketItem.find(params[:id])
      item.destroy
      render json: success_json
    end

    private

    def item_params
      params.require(:market_item).permit(
        :name,
        :category,
        :price_points,
        :is_limited_duration,
        :duration_days,
        :duplicate_policy,
        :image_url,
        :is_active,
        metadata_json: {}
      )
    end
  end
end
