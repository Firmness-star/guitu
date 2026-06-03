-- ============================================
-- 归途花店 数据库升级脚本
-- 部署前在 MySQL 中执行此文件
-- ============================================

USE flower_shop;

-- 1. 用户头像字段
ALTER TABLE `user` ADD COLUMN `avatar` varchar(500) DEFAULT NULL COMMENT '头像路径' AFTER `jf`;

-- 2. 评论表
DROP TABLE IF EXISTS `comment`;
CREATE TABLE `comment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `user_id` int NOT NULL,
  `username` varchar(50) NOT NULL,
  `content` varchar(500) NOT NULL,
  `rating` int DEFAULT '5',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_product` (`product_id`),
  CONSTRAINT `fk_comment_product` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品评论表';

-- 3. 登录日志表
DROP TABLE IF EXISTS `login_log`;
CREATE TABLE `login_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `username` varchar(50) NOT NULL,
  `login_ip` varchar(45) NOT NULL COMMENT '登录IP',
  `user_agent` varchar(500) DEFAULT NULL COMMENT '浏览器标识',
  `login_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_time` (`login_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户登录日志表';

-- 4. 留言表
DROP TABLE IF EXISTS `message`;
CREATE TABLE `message` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `username` varchar(50) NOT NULL,
  `content` varchar(500) NOT NULL,
  `conversation` text DEFAULT NULL COMMENT '对话记录',
  `is_user_read` int DEFAULT '1' COMMENT '用户侧：0未读 1已读',
  `is_admin_read` int DEFAULT '0' COMMENT '管理员侧：0未读 1已读',
  `unread_admin_replies` int DEFAULT '0' COMMENT '用户侧未读回复条数',
  `unread_user_replies` int DEFAULT '0' COMMENT '管理员侧未读回复条数',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户留言表';

-- 5. 订单物流编号
ALTER TABLE `orders` ADD COLUMN `wl_no` varchar(50) DEFAULT NULL COMMENT '物流编号' AFTER `remark`;

-- 6. 首页海报表
DROP TABLE IF EXISTS `banner_info`;
CREATE TABLE `banner_info` (
  `id` int NOT NULL AUTO_INCREMENT,
  `img_url` varchar(500) NOT NULL COMMENT '图片地址',
  `pro_id` int NOT NULL COMMENT '关联商品ID',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='首页海报轮播表';

ALTER TABLE orders DROP FOREIGN KEY fk_orders_user;
ALTER TABLE orders ADD CONSTRAINT fk_orders_user
    FOREIGN KEY (user_id) REFERENCES user (id) ON DELETE CASCADE ON UPDATE CASCADE;

-- 7. 商品多图字段（存储 JSON 数组 ["url1","url2","url3"]）
ALTER TABLE `product` ADD COLUMN `pics` text DEFAULT NULL COMMENT '多图JSON数组' AFTER `pic`;

-- 8. 积分流水表
DROP TABLE IF EXISTS `jf_log`;
CREATE TABLE `jf_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL COMMENT '用户ID',
  `amount` int NOT NULL COMMENT '变动数量（正=增加，负=扣减）',
  `source` varchar(30) NOT NULL COMMENT '来源：register/browse/login/address/order/usePoints/completeProfile',
  `description` varchar(200) DEFAULT '' COMMENT '说明文字',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_source` (`source`),
  KEY `idx_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='积分流水表';

-- 9. 订单支付方式字段
ALTER TABLE `orders` ADD COLUMN `pay_method` varchar(20) DEFAULT NULL COMMENT '支付方式' AFTER `actual_amount`;

-- 10. 优惠券表
DROP TABLE IF EXISTS `coupon`;
CREATE TABLE `coupon` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL COMMENT '优惠券名称',
  `type` varchar(20) NOT NULL DEFAULT '满减' COMMENT '类型：满减/reduce/折扣/discount',
  `value` decimal(10,2) NOT NULL COMMENT '面值（满减为金额，折扣为百分比）',
  `min_amount` decimal(10,2) DEFAULT '0.00' COMMENT '最低消费金额',
  `stock` int DEFAULT '0' COMMENT '库存（-1不限）',
  `start_date` date DEFAULT NULL COMMENT '有效期开始',
  `end_date` date DEFAULT NULL COMMENT '有效期结束',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='优惠券定义表';

-- 11. 用户优惠券关联表
DROP TABLE IF EXISTS `user_coupon`;
CREATE TABLE `user_coupon` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `coupon_id` int NOT NULL,
  `status` varchar(20) DEFAULT '未使用' COMMENT '未使用/已使用/已过期',
  `get_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `used_time` timestamp NULL DEFAULT NULL,
  `order_no` varchar(50) DEFAULT NULL COMMENT '使用的订单号',
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_coupon` (`coupon_id`),
  CONSTRAINT `fk_uc_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_uc_coupon` FOREIGN KEY (`coupon_id`) REFERENCES `coupon` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户优惠券关联表';
-- 12. 购物车添加选中状态字段
ALTER TABLE `cart` ADD COLUMN `selected` tinyint(1) NOT NULL DEFAULT 1 COMMENT '是否选中：1选中 0未选中' AFTER `quantity`;

-- 13. 商品收藏表
DROP TABLE IF EXISTS `favorite`;
CREATE TABLE `favorite` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `product_id` int NOT NULL,
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_product` (`user_id`,`product_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_product` (`product_id`),
  CONSTRAINT `fk_fav_product` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_fav_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品收藏表';
