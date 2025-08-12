# frozen_string_literal: true

class MarketPurchaseHistory < ActiveRecord::Base
  self.table_name = "market_purchase_history"

  belongs_to :user
  belongs_to :market_item, class_name: "MarketItem", foreign_key: "item_id"

  validates :user_id, presence: true
  validates :item_id, presence: true

  scope :recent, -> { order(created_at: :desc) }
end
