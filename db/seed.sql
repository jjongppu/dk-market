-- Sample seed data for dk-market plugin

-- Market Items
INSERT INTO market_items (id, name, category, price_points, is_limited_duration, duration_days, duplicate_policy, image_url, metadata_json, is_active) VALUES
  (1, 'Sword', 'weapon', 100, true, 30, 'deny', 'https://example.com/sword.png', '{"description":"A sharp blade"}', true),
  (2, 'Shield', 'armor', 150, true, 30, 'extend', 'https://example.com/shield.png', '{"description":"Protect yourself"}', true),
  (3, 'Potion', 'consumable', 50, false, NULL, 'allow', 'https://example.com/potion.png', '{"description":"Heals 50 HP"}', true),
  (4, 'Helmet', 'armor', 80, true, 30, 'deny', 'https://example.com/helmet.png', '{"description":"Sturdy helmet"}', true),
  (5, 'Boots', 'gear', 70, false, NULL, 'allow', 'https://example.com/boots.png', '{"description":"Run faster"}', true);

-- User Inventory for user_id = 1
INSERT INTO market_user_inventory (id, user_id, item_id, is_used, expires_at, is_active, description, notes, created_at, updated_at) VALUES
  (1, 1, 1, false, NOW() + interval '30 days', true, NULL, NULL, NOW(), NOW()),
  (2, 1, 2, true, NOW() + interval '30 days', true, NULL, NULL, NOW(), NOW()),
  (3, 1, 3, false, NULL, true, NULL, NULL, NOW(), NOW());

-- Purchase History for user_id = 1
INSERT INTO market_purchase_history (id, user_id, item_id, quantity, price_points, status, payment_type, before_points, after_points, market_snapshot_json, created_at, updated_at) VALUES
  (1, 1, 1, 1, 100, 'completed', 'usable_points', 0, 0, '{}', NOW(), NOW()),
  (2, 1, 2, 1, 150, 'completed', 'usable_points', 0, 0, '{}', NOW(), NOW());
