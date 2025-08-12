# frozen_string_literal: true

module ::DkMarket
  class MarketController < ::ApplicationController
    requires_plugin ::DkMarket::PLUGIN_NAME

    def index
      render html: "", layout: true
    end

    def items
      render json: { items: [{ id: 1, name: "Example Item" }] }
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
