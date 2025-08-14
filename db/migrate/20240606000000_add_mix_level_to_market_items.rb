class AddMixLevelToMarketItems < ActiveRecord::Migration[7.0]
  def change
    add_column :market_items, :mix_level, :integer, null: false, default: 0
    add_index :market_items, :mix_level
  end
end
