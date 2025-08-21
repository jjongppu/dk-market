# frozen_string_literal: true

class MarketItem < ActiveRecord::Base
  self.table_name = "market_items"

  has_many :market_user_inventories, dependent: :destroy
  has_many :market_purchase_histories, dependent: :destroy

  validates :name, presence: true
  validates :category, presence: true
  validates :price_points, presence: true
  validates :duplicate_policy, inclusion: { in: %w[deny extend allow] }, allow_blank: true
  validates :min_level, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :by_category, ->(category) { where(category: category) }

  attr_accessor :owned, :inventory_id, :expires_at, :is_used, :level_image_url, :level_name
end
