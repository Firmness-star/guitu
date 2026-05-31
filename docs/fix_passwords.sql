-- ============================================
-- 归途花店 - 密码重置脚本 (MD5加盐后)
-- 在 MySQL 中执行此脚本以修复登录问题
-- ============================================

USE flower_shop;

-- 原始密码: 123456
UPDATE user SET pass = 'bf5fc12490bba419c7fce8ee639a8df1' WHERE username = 'guitu';

-- 原始密码: admin123
UPDATE user SET pass = 'f386730438bafb939a39042abd1b68cd' WHERE username = 'admin';

-- 原始密码: merchant123
UPDATE user SET pass = '95d569118dd58cc7b430379da3caff08' WHERE username = 'merchant';

-- 原始密码：123456
UPDATE user SET pass = 'bf5fc12490bba419c7fce8ee639a8df1' WHERE username = '111';

-- 原始密码: 111111
UPDATE user SET pass = 'e67d46a1f55cc912071f5b91d86e9776' WHERE username = 'yes';

-- 验证更新结果
SELECT username, pass FROM user;
