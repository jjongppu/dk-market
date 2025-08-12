# frozen_string_literal: true

class MarketPurchaseHistory < ActiveRecord::Base
  self.table_name = "market_purchase_history"

  belongs_to :user
  belongs_to :market_item

  validates :user_id, presence: true
  validates :market_item_id, presence: true

  scope :recent, -> { order(created_at: :desc) }
end
