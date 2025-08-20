# frozen_string_literal: true

# name: dk-market
# about: TODO
# meta_topic_id: TODO
# version: 0.0.1
# authors: Discourse
# url: TODO
# required_version: 2.7.0

enabled_site_setting :dk_market_enabled

module ::DkMarket
  PLUGIN_NAME = "dk-market"
end

require_relative "lib/dk_market/engine"
register_asset "stylesheets/common/dk-market.scss"

after_initialize do
  add_to_serializer(:basic_user, :market_effects) do
    inventories =
      MarketUserInventory
        .active_current
        .in_use
        .by_user(object)
        .includes(:market_item)

    items = inventories.map do |inv|
      item = inv.market_item
      item.inventory_id = inv.id
      item.expires_at = inv.expires_at
      item.is_used = true
      item
    end

    items.map { |it| MarketItemSerializer.new(it, scope: scope, root: false).as_json }
  end

  add_to_serializer(:basic_user, :include_market_effects?) do
    SiteSetting.dk_market_enabled
  end
end
