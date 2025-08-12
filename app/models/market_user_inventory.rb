# frozen_string_literal: true

class MarketUserInventory < ActiveRecord::Base
  self.table_name = "market_user_inventory"

  belongs_to :user
  belongs_to :market_item

  validates :user_id, presence: true
  validates :market_item_id, presence: true

  scope :in_use, -> { where(in_use: true) }
  scope :by_user, ->(user) { where(user_id: user.id) }
end
