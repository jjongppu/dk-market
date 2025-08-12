# frozen_string_literal: true

class MarketItemSerializer < ApplicationSerializer
  attributes :id,
             :name,
             :category,
             :price_points,
             :is_limited_duration,
             :duration_days,
             :duplicate_policy,
             :image_url,
             :metadata_json,
             :is_active
end
