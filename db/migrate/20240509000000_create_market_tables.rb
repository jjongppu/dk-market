class CreateMarketTables < ActiveRecord::Migration[7.0]
  def up
    create_table :market_items, id: :bigserial do |t|
      t.text :name, null: false
      t.text :category, null: false
      t.integer :price_points, null: false
      t.boolean :is_limited_duration, null: false, default: false
      t.integer :duration_days
      t.text :duplicate_policy, null: false, default: 'deny'
      t.text :image_url
      t.jsonb :metadata_json
      t.boolean :is_active, null: false, default: true
      t.timestamps null: false, default: -> { 'CURRENT_TIMESTAMP' }, type: :timestamptz
    end
    add_index :market_items, :is_active, name: 'idx_market_items_active'
    add_index :market_items, :category, name: 'idx_market_items_category'
    add_check_constraint :market_items, '(duration_days IS NULL OR duration_days >= 1)', name: 'market_items_duration_days_check'
    add_check_constraint :market_items, '((is_limited_duration = true AND duration_days IS NOT NULL) OR (is_limited_duration = false))', name: 'market_items_duration_days_required_check'

    create_table :market_user_inventory, id: :bigserial do |t|
      t.integer :user_id, null: false
      t.bigint :item_id, null: false
      t.column :expires_at, :timestamptz
      t.boolean :is_active, null: false, default: true
      t.boolean :is_used, null: false, default: false
      t.text :description
      t.text :notes
      t.timestamps null: false, default: -> { 'CURRENT_TIMESTAMP' }, type: :timestamptz
    end
    add_foreign_key :market_user_inventory, :users, column: :user_id, on_delete: :cascade
    add_foreign_key :market_user_inventory, :market_items, column: :item_id, on_delete: :cascade
    add_index :market_user_inventory, :user_id, name: 'idx_market_user_inventory_user'
    add_index :market_user_inventory, [:is_active, :expires_at], name: 'idx_market_user_inventory_expiry_active'
    add_index :market_user_inventory, [:user_id, :item_id], unique: true, where: 'is_active = true', name: 'uniq_market_inv_user_item_active'

    create_table :market_purchase_history, id: :bigserial do |t|
      t.integer :user_id, null: false
      t.bigint :item_id, null: false
      t.integer :quantity, null: false, default: 1
      t.integer :price_points, null: false
      t.column :purchased_at, :timestamptz, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.text :status, null: false, default: 'completed'
      t.integer :before_points, null: false
      t.integer :after_points, null: false
      t.text :payment_type, null: false, default: 'usable_points'
      t.jsonb :market_snapshot_json
      t.text :memo
      t.timestamps null: false, default: -> { 'CURRENT_TIMESTAMP' }, type: :timestamptz
    end
    add_foreign_key :market_purchase_history, :users, column: :user_id, on_delete: :cascade
    add_foreign_key :market_purchase_history, :market_items, column: :item_id, on_delete: :cascade
    add_index :market_purchase_history, [:user_id, :purchased_at], order: { purchased_at: :desc }, name: 'idx_market_purchase_history_user_time'
  end

  def down
    drop_table :market_purchase_history
    drop_table :market_user_inventory
    drop_table :market_items
  end
end
