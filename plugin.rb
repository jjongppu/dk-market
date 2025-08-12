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

after_initialize do
  # Code which should run after Rails has finished booting
end
