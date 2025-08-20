# frozen_string_literal: true

require "rails_helper"

RSpec.describe "BasicUser serializer market effects" do
  let(:user) { Fabricate(:user) }

  let!(:item) do
    MarketItem.create!(
      name: "Glowy",
      category: "nametag_effect",
      price_points: 1,
      duplicate_policy: "allow",
    )
  end

  let!(:inventory) do
    MarketUserInventory.create!(
      user_id: user.id,
      item_id: item.id,
      is_used: true,
      is_active: true,
    )
  end

  before { SiteSetting.dk_market_enabled = true }

  it "returns equipped effects" do
    json = BasicUserSerializer.new(user, scope: Guardian.new(user), root: false).as_json

    expect(json[:market_effects]).to contain_exactly(
      hash_including(id: item.id, name: "Glowy", category: "nametag_effect"),
    )
  end
end
