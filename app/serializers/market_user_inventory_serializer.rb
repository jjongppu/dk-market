# frozen_string_literal: true

class MarketUserInventorySerializer < ApplicationSerializer
  attributes :id, :user_id, :in_use, :expires_at

  has_one :market_item, serializer: MarketItemSerializer
end
