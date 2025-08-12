# frozen_string_literal: true

class MarketUserInventory < ActiveRecord::Base
  self.table_name = "market_user_inventory"

  belongs_to :user
  belongs_to :market_item, class_name: "MarketItem", foreign_key: "item_id"

  validates :user_id, presence: true
  validates :item_id, presence: true

  scope :in_use, -> { where(is_used: true) }
  scope :by_user, ->(user) { where(user_id: user.id) }
  scope :active_current, -> {
    where(is_active: true)
      .where("expires_at IS NULL OR expires_at > ?", Time.zone.now)
  }
end
