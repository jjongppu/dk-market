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
  # 🔧 디버깅용: user serializer 확장 임시 비활성화
  Rails.logger.debug("[dk-market] user serializer extensions are temporarily DISABLED for debugging")

  # --- 아래 두 블록 전부 주석 처리 ---

  # add_to_serializer(:basic_user, :market_effects) do
  #   # 사이트 설정 로그
  #   Rails.logger.debug("[dk-market] market_effects invoked user_id=#{object.id} enabled=#{SiteSetting.dk_market_enabled} current_user_id=#{scope&.current_user&.id}")
  #
  #   return [] unless SiteSetting.dk_market_enabled
  #
  #   start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  #
  #   begin
  #     # 로딩 시작 로그
  #     Rails.logger.debug("[dk-market] loading inventories for user_id=#{object.id}")
  #
  #     inventories =
  #       MarketUserInventory
  #         .active_current
  #         .in_use
  #         .by_user(object) # 필요 시 .by_user(object.id) 로 변경
  #         .includes(:market_item)
  #
  #     Rails.logger.debug("[dk-market] inventories loaded count=#{inventories.size} user_id=#{object.id}")
  #
  #     items = inventories.map do |inv|
  #       item = inv.market_item
  #       # 가상 속성 할당 시도 로그 (모델에 attr_accessor 없으면 NoMethodError 가능)
  #       begin
  #         item.inventory_id = inv.id
  #         item.expires_at   = inv.expires_at
  #         item.is_used      = true
  #       rescue => e
  #         Rails.logger.warn("[dk-market] virtual-attr assign failed item_id=#{item&.id} inv_id=#{inv.id} error=#{e.class}: #{e.message}")
  #       end
  #       item
  #     end
  #
  #     serialized = items.map { |it| MarketItemSerializer.new(it, scope: scope, root: false).as_json }
  #
  #     duration_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000).round(1)
  #     Rails.logger.debug("[dk-market] market_effects done user_id=#{object.id} items=#{serialized.size} duration_ms=#{duration_ms}")
  #
  #     serialized
  #   rescue => e
  #     Rails.logger.error("[dk-market] market_effects error user_id=#{object.id} #{e.class}: #{e.message}")
  #     Rails.logger.error("[dk-market] backtrace: #{Array(e.backtrace).first(5).join(' | ')}")
  #     []
  #   end
  # end
  #
  # add_to_serializer(:basic_user, :include_market_effects?) do
  #   enabled = SiteSetting.dk_market_enabled
  #   Rails.logger.debug("[dk-market] include_market_effects? user_id=#{object.id} enabled=#{enabled}")
  #   enabled
  # end
end
