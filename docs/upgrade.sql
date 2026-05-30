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