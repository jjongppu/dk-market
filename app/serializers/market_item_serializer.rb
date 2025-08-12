# frozen_string_literal: true

class MarketItemSerializer < ApplicationSerializer
  attributes :id, :name, :description, :price, :category, :image_url, :duplicate_policy, :duration
end
