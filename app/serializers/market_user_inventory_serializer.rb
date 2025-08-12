# frozen_string_literal: true

class MarketUserInventorySerializer < ApplicationSerializer
  attributes :id,
             :user_id,
             :is_used,
             :is_active,
             :description,
             :notes,
             :expires_at

  has_one :market_item, serializer: MarketItemSerializer
end
