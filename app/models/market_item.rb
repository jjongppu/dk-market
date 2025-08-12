# frozen_string_literal: true

class MarketItem < ActiveRecord::Base
  self.table_name = "market_items"

  has_many :market_user_inventories, dependent: :destroy
  has_many :market_purchase_histories, dependent: :destroy

  validates :name, presence: true
  validates :category, presence: true
  validates :price_points, presence: true
  validates :duplicate_policy, inclusion: { in: %w[deny extend allow] }, allow_blank: true

  scope :by_category, ->(category) { where(category: category) }

  attr_accessor :owned
end
