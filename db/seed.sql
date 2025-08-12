-- Sample seed data for dk-market plugin

-- Market Items
INSERT INTO market_items (id, name, description, price, category, image_url, duplicate_policy, duration) VALUES
  (1, 'Sword', 'A sharp blade', 100, 'weapon', 'https://example.com/sword.png', 'deny', 30),
  (2, 'Shield', 'Protect yourself', 150, 'armor', 'https://example.com/shield.png', 'extend', 30),
  (3, 'Potion', 'Heals 50 HP', 50, 'consumable', 'https://example.com/potion.png', 'allow', NULL),
  (4, 'Helmet', 'Sturdy helmet', 80, 'armor', 'https://example.com/helmet.png', 'deny', 30),
  (5, 'Boots', 'Run faster', 70, 'gear', 'https://example.com/boots.png', 'allow', NULL);

-- User Inventory for user_id = 1
INSERT INTO market_user_inventory (id, user_id, market_item_id, in_use, expires_at, created_at, updated_at) VALUES
  (1, 1, 1, false, NOW() + interval '30 days', NOW(), NOW()),
  (2, 1, 2, true, NOW() + interval '30 days', NOW(), NOW()),
  (3, 1, 3, false, NULL, NOW(), NOW());

-- Purchase History for user_id = 1
INSERT INTO market_purchase_history (id, user_id, market_item_id, created_at, updated_at) VALUES
  (1, 1, 1, NOW(), NOW()),
  (2, 1, 2, NOW(), NOW());
