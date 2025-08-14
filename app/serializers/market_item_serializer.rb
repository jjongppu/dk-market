# frozen_string_literal: true

class MarketItemSerializer < ApplicationSerializer
  attributes :id, :name, :category, :price_points,
             :is_limited_duration, :duration_days, :duplicate_policy,
             :image_url, :metadata_json, :is_active, :mix_level,
             :owned, :inventory_id, :expires_at, :is_used, :level_image_url
end
