-- MySQL dump 10.13  Distrib 9.0.1, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: flower_shop
-- ------------------------------------------------------
-- Server version	9.0.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `address`
--

DROP TABLE IF EXISTS `address`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `address` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '地址ID',
  `user_id` int NOT NULL COMMENT '用户ID',
  `receiver_name` varchar(50) NOT NULL COMMENT '收货人姓名',
  `receiver_phone` varchar(20) NOT NULL COMMENT '收货人电话',
  `province` varchar(50) NOT NULL COMMENT '省份',
  `city` varchar(50) NOT NULL COMMENT '城市',
  `district` varchar(50) NOT NULL COMMENT '区县',
  `detail_address` varchar(200) NOT NULL COMMENT '详细地址',
  `is_default` tinyint DEFAULT '0' COMMENT '是否默认地址 0-否 1-是',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  CONSTRAINT `address_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='收货地址表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `address`
--

LOCK TABLES `address` WRITE;
/*!40000 ALTER TABLE `address` DISABLE KEYS */;
/*!40000 ALTER TABLE `address` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cart`
--

DROP TABLE IF EXISTS `cart`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cart` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '购物车ID',
  `user_id` int NOT NULL COMMENT '用户ID',
  `product_id` int NOT NULL COMMENT '商品ID',
  `quantity` int NOT NULL DEFAULT '1' COMMENT '购买数量',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_product` (`user_id`,`product_id`) COMMENT '唯一约束：同一用户同一商品只一条记录',
  KEY `idx_user` (`user_id`) COMMENT '用户索引，快速查询用户购物车',
  KEY `idx_product` (`product_id`) COMMENT '商品索引',
  CONSTRAINT `fk_cart_product` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cart_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='购物车表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cart`
--

LOCK TABLES `cart` WRITE;
/*!40000 ALTER TABLE `cart` DISABLE KEYS */;
/*!40000 ALTER TABLE `cart` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `category`
--

DROP TABLE IF EXISTS `category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `category` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `name` varchar(50) NOT NULL COMMENT '分类名称',
  `parent_id` int NOT NULL DEFAULT '0' COMMENT '父分类ID，0表示一级分类',
  `description` varchar(200) DEFAULT NULL COMMENT '分类描述',
  PRIMARY KEY (`id`),
  KEY `idx_parent_id` (`parent_id`) COMMENT '父分类索引，优化查询'
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品分类表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category`
--

LOCK TABLES `category` WRITE;
/*!40000 ALTER TABLE `category` DISABLE KEYS */;
INSERT INTO `category` VALUES (1,'鲜花',0,'新鲜花卉产品'),(2,'绿植盆栽',0,'室内室外绿植'),(3,'花礼盒',0,'精美花艺礼盒'),(4,'永生花',0,'永不凋谢的花艺'),(5,'花束定制',0,'个性化定制服务'),(6,'商务用花',0,'企业商务场合'),(7,'婚庆用花',0,'婚礼庆典花艺'),(8,'节日专题',0,'特定节日花礼'),(9,'干花装饰',0,'天然干花制品'),(10,'花艺配件',0,'花瓶花器等配件'),(11,'玫瑰系列',1,'各类玫瑰花束'),(12,'百合系列',1,'纯洁百合花艺'),(13,'郁金香系列',1,'优雅郁金香'),(14,'康乃馨系列',1,'温馨康乃馨'),(15,'多肉植物',2,'可爱多肉盆栽'),(16,'观叶植物',2,'净化空气绿植'),(17,'开花植物',2,'四季开花盆栽'),(18,'情人节礼盒',3,'浪漫情人礼物'),(19,'生日礼盒',3,'生日祝福花礼'),(20,'感恩礼盒',3,'感谢恩师亲友'),(21,'玻璃罩永生花',4,'精致玻璃罩装'),(22,'相框永生花',4,'创意相框设计'),(23,'音乐盒永生花',4,'浪漫音乐盒款'),(24,'个性定制',5,'专属定制花束'),(25,'主题定制',5,'场景主题搭配'),(26,'开业花篮',6,'商务开业庆贺'),(27,'会议用花',6,'商务会议布置'),(28,'乔迁花礼',6,'新居乔迁祝福'),(29,'新娘手捧',7,'婚礼新娘专用'),(30,'婚车装饰',7,'婚车花艺布置'),(31,'宴会桌花',7,'婚宴餐桌装饰'),(32,'情人节专题',8,'2.14情人节特供'),(33,'母亲节专题',8,'感恩母亲大人'),(34,'教师节专题',8,'谢师恩花礼'),(35,'天然干花',9,'自然风干花材'),(36,'干花花束',9,'精美干花作品'),(37,'陶瓷花瓶',10,'精美陶瓷花器'),(38,'玻璃花瓶',10,'透明玻璃花器'),(39,'花艺工具',10,'花艺制作工具');
/*!40000 ALTER TABLE `category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_item`
--

DROP TABLE IF EXISTS `order_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_item` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '订单明细ID',
  `order_id` int NOT NULL COMMENT '订单ID',
  `product_id` int NOT NULL COMMENT '商品ID',
  `product_name` varchar(100) NOT NULL COMMENT '商品名称（快照）',
  `product_price` decimal(10,2) NOT NULL COMMENT '商品单价（快照）',
  `quantity` int NOT NULL DEFAULT '1' COMMENT '购买数量',
  `subtotal` decimal(10,2) NOT NULL COMMENT '小计金额',
  PRIMARY KEY (`id`),
  KEY `idx_order` (`order_id`) COMMENT '订单索引，查询订单明细',
  KEY `idx_product` (`product_id`) COMMENT '商品索引',
  CONSTRAINT `fk_order_item_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_order_item_product` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='订单明细表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_item`
--

LOCK TABLES `order_item` WRITE;
/*!40000 ALTER TABLE `order_item` DISABLE KEYS */;
INSERT INTO `order_item` VALUES (1,2,2,'粉玫瑰19朵浪漫款',198.00,3,594.00),(2,3,2,'粉玫瑰19朵浪漫款',198.00,7,1386.00),(3,3,3,'香槟玫瑰33朵',358.00,5,1790.00),(4,4,2,'粉玫瑰19朵浪漫款',198.00,1,198.00),(5,5,2,'粉玫瑰19朵浪漫款',198.00,1,198.00),(6,6,2,'粉玫瑰19朵浪漫款',198.00,1,198.00),(7,7,2,'粉玫瑰19朵浪漫款',198.00,5,990.00),(8,7,3,'香槟玫瑰33朵',358.00,1,358.00),(9,8,2,'粉玫瑰19朵浪漫款',198.00,1,198.00),(10,9,2,'粉玫瑰19朵浪漫款',198.00,1,198.00);
/*!40000 ALTER TABLE `order_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_main`
--

DROP TABLE IF EXISTS `order_main`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_main` (
  `order_id` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '订单号（业务主键）',
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '下单用户',
  `receiver_name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '收货人姓名',
  `receiver_phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '收货人电话',
  `receiver_address` varchar(300) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '收货地址',
  `remark` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '订单备注',
  `total_count` int DEFAULT '0' COMMENT '商品总件数',
  `total_amount` decimal(12,2) DEFAULT '0.00' COMMENT '订单总金额',
  `status` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT '待付款' COMMENT '订单状态：待付款/已付款/已发货/已完成',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '下单时间',
  PRIMARY KEY (`order_id`),
  KEY `idx_username` (`username`),
  KEY `idx_status` (`status`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单主表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_main`
--

LOCK TABLES `order_main` WRITE;
/*!40000 ALTER TABLE `order_main` DISABLE KEYS */;
/*!40000 ALTER TABLE `order_main` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_status_history`
--

DROP TABLE IF EXISTS `order_status_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_status_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `old_status` varchar(20) DEFAULT NULL,
  `new_status` varchar(20) NOT NULL,
  `change_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  CONSTRAINT `order_status_history_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_status_history`
--

LOCK TABLES `order_status_history` WRITE;
/*!40000 ALTER TABLE `order_status_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `order_status_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_no` varchar(50) NOT NULL COMMENT '订单编号（业务单号）',
  `user_id` int NOT NULL COMMENT '用户ID',
  `total_amount` decimal(10,2) NOT NULL COMMENT '订单总金额',
  `actual_amount` decimal(10,2) NOT NULL COMMENT '实际支付金额',
  `status` varchar(20) DEFAULT '待付款' COMMENT '订单状态',
  `receiver_name` varchar(50) DEFAULT NULL COMMENT '收货人姓名',
  `receiver_phone` varchar(20) DEFAULT NULL COMMENT '收货人电话',
  `receiver_address` varchar(200) DEFAULT NULL COMMENT '收货地址',
  `remark` varchar(500) DEFAULT NULL COMMENT '订单备注',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '下单时间',
  `pay_time` timestamp NULL DEFAULT NULL COMMENT '支付时间',
  `delivery_time` timestamp NULL DEFAULT NULL COMMENT '发货时间',
  `finish_time` timestamp NULL DEFAULT NULL COMMENT '完成时间',
  `total_count` int DEFAULT '0' COMMENT '订单商品总数量',
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_no` (`order_no`),
  KEY `idx_user` (`user_id`) COMMENT '用户索引，查询用户订单',
  KEY `idx_order_no` (`order_no`) COMMENT '订单号索引，快速查询订单',
  KEY `idx_status` (`status`) COMMENT '状态索引，按状态筛选订单',
  CONSTRAINT `fk_orders_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='订单表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (2,'ORD1778948515105',2,594.00,594.00,'待付款','111','18023154203','1','','2026-05-16 16:21:55',NULL,NULL,NULL,3),(3,'ORD1778948829796',2,3176.00,3176.00,'已付款','111','18023154203','1','','2026-05-16 16:27:10',NULL,NULL,NULL,12),(4,'ORD1778989757712',2,198.00,198.00,'已取消','111','18023154203','1','','2026-05-17 03:49:18',NULL,NULL,NULL,1),(5,'ORD1778989856006',2,198.00,198.00,'已取消','111','18023154203','1','','2026-05-17 03:50:56',NULL,NULL,NULL,1),(6,'ORD1778989907499',2,198.00,198.00,'已付款','111','18023154203','1','','2026-05-17 03:51:47',NULL,NULL,NULL,1),(7,'ORD1778990141185',2,1348.00,1348.00,'已付款','111','18023154203','1','','2026-05-17 03:55:41',NULL,NULL,NULL,6),(8,'ORD1778991598569',2,198.00,198.00,'已取消','111','18023154203','111','','2026-05-17 04:19:59',NULL,NULL,NULL,1),(9,'ORD1778996019617',2,198.00,198.00,'待付款','111','18023154203','11111','','2026-05-17 05:33:40',NULL,NULL,NULL,1);
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product`
--

DROP TABLE IF EXISTS `product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '商品ID',
  `name` varchar(100) NOT NULL COMMENT '商品名称',
  `intro` varchar(500) DEFAULT NULL COMMENT '商品简介/关键词',
  `price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '商品价格',
  `stock` int NOT NULL DEFAULT '0' COMMENT '库存数量',
  `pic` varchar(500) DEFAULT NULL COMMENT '商品图片URL',
  `category_id` int NOT NULL DEFAULT '1' COMMENT '分类ID（外键关联category表）',
  `sales` int NOT NULL DEFAULT '0' COMMENT '销量',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `status` int NOT NULL DEFAULT '1' COMMENT '状态：0-下架 1-上架',
  `merchant_id` int DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `idx_category` (`category_id`) COMMENT '分类索引，优化分类查询',
  KEY `idx_status` (`status`) COMMENT '状态索引，优化上架商品查询',
  CONSTRAINT `fk_product_category` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=142 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product`
--

LOCK TABLES `product` WRITE;
/*!40000 ALTER TABLE `product` DISABLE KEYS */;
INSERT INTO `product` VALUES (1,'经典红玫瑰11朵','11朵精选A级红玫瑰，象征一心一意的爱，经典永不过时',128.00,50,'https://www.168hua.com/photo/51920510.jpg',11,156,'2026-05-16 14:17:04',1,1),(2,'粉玫瑰19朵浪漫款','19朵粉玫瑰搭配满天星，温柔浪漫，适合初恋表白',198.00,35,'https://img1.sixflower.com/202488117956432.jpg',11,89,'2026-05-16 14:17:04',1,1),(3,'香槟玫瑰33朵','33朵香槟玫瑰高贵典雅，代表三生三世的爱意承诺',358.00,28,'https://oss.huawa.com/shop/placeorder/06941715984379981.jpg',11,124,'2026-05-16 14:17:04',1,1),(4,'白玫瑰纯净之爱','9朵白玫瑰象征纯洁无瑕的爱，清新淡雅气质出众',108.00,42,'https://images.unsplash.com/photo-1533616688419-b7a585564566?w=400&h=400&fit=crop',11,67,'2026-05-16 14:17:04',1,1),(5,'蓝玫瑰神秘之恋','7朵进口蓝玫瑰，神秘浪漫，独一无二的爱',268.00,15,'https://www.pycu.cn/zb_users/upload/2024/05/20240513113421_14018.jpeg',11,45,'2026-05-16 14:17:04',1,1),(6,'彩虹玫瑰梦幻款','多色玫瑰混搭，色彩斑斓如彩虹，梦幻浪漫',188.00,30,'https://www.pycu.cn/zb_users/upload/2024/04/20240429104943_32778.jpeg',11,78,'2026-05-16 14:17:04',1,1),(7,'99朵红玫瑰豪华版','99朵红玫瑰震撼视觉，天长地久的爱，求婚必备',999.00,10,'https://ts4.tc.mm.bing.net/th/id/OIP-C.bPHCQ6qpeXQVF7HwLl6tYwHaHa?rs=1&pid=ImgDetMain&o=7&rm=3',11,234,'2026-05-16 14:17:04',1,1),(8,'迷你玫瑰小束','5朵精致小玫瑰，简约不简单，日常小惊喜',58.00,80,'https://cbu01.alicdn.com/img/ibank/O1CN01iPRtLO21YDqpk2TTg_!!2212707506996-0-cib.jpg',11,312,'2026-05-16 14:17:04',1,1),(9,'香水百合纯白','5支进口香水百合，香气浓郁，百年好合寓意美好',168.00,40,'https://www.168hua.com/photo/202292139250.jpg',12,98,'2026-05-16 14:17:04',1,1),(10,'粉色百合温柔款','3支粉百合搭配绿叶，温柔甜美，适合送闺蜜',128.00,45,'https://ts2.tc.mm.bing.net/th/id/OIP-C.0OMkOH0idHnMJnXd9YHsIwHaE8?rs=1&pid=ImgDetMain&o=7&rm=3',12,76,'2026-05-16 14:17:04',1,1),(11,'黄色百合阳光','4支黄百合充满活力，阳光灿烂，祝福朋友前程似锦',138.00,38,'https://ts4.tc.mm.bing.net/th/id/OIP-C.K6KziErySygRYtKiTIY9CwHaE7?pid=ImgDet&w=474&h=315&rs=1&o=7&rm=3',12,54,'2026-05-16 14:17:04',1,1),(12,'多头百合奢华','6支多头百合花苞饱满，奢华大气，商务送礼首选',228.00,25,'https://ts3.tc.mm.bing.net/th/id/OIP-C.dg7_DnnjocSdaxqmZs43vgHaEJ?rs=1&pid=ImgDetMain&o=7&rm=3',12,43,'2026-05-16 14:17:04',1,1),(13,'百合玫瑰混搭','百合与玫瑰完美搭配，既有香气又有浪漫，双重祝福',198.00,32,'https://tse2-mm.cn.bing.net/th/id/OIP-C.04GdTSB_Ih4StjplWVST5AHaHa?o=7rm=3&rs=1&pid=ImgDetMain&o=7&rm=3',12,87,'2026-05-16 14:17:04',1,1),(14,'单支百合简装','单支精品百合简约包装，小巧精致，随手礼佳选',38.00,100,'https://cbu01.alicdn.com/img/ibank/2017/382/089/3802980283_831230203.jpg',12,456,'2026-05-16 14:17:04',1,1),(15,'红色郁金香热情','10支红郁金香热情似火，爱的宣言，适合热恋期',158.00,35,'https://ts1.tc.mm.bing.net/th/id/R-C.6a9dcba7ac71124df59aa92907ba2820?rik=42TB%2baullKb0%2fw&riu=http%3a%2f%2fvip-public.people.com.cn%2fphoto%2f2022%2f3%2f11%2f0c15a57073044772b8af175b121dc934lsOo_s.jpg&ehk=VwahQ%2fDCwarFj981fluERKTVJbcaafEBpAPwsaHZ62M%3d&risl=&pid=ImgRaw&r=0',13,65,'2026-05-16 14:17:04',1,1),(16,'粉色郁金香温柔','8支粉郁金香温柔可人，幸福甜蜜，送给可爱的她',128.00,40,'https://ts2.tc.mm.bing.net/th/id/OIP-C.OrU93mj8fi3y_AdnBNNYzgHaE7?rs=1&pid=ImgDetMain&o=7&rm=3',13,52,'2026-05-16 14:17:04',1,1),(17,'黄色郁金香阳光','6支黄郁金香明亮温暖，友谊长存，祝福朋友',108.00,45,'https://www.pycu.cn/zb_users/upload/2023/06/20230602232249_31089.jpeg',13,38,'2026-05-16 14:17:04',1,1),(18,'紫色郁金香高贵','5支紫郁金香高贵典雅，皇室气质，独特品味',138.00,30,'https://www.pycu.cn/zb_users/upload/2025/11/20251129144609_54584.jpeg',13,29,'2026-05-16 14:17:04',1,1),(19,'混色郁金香缤纷','12支多色郁金香混搭，色彩缤纷如画卷，视觉盛宴',188.00,25,'https://bpic.588ku.com/photo_water_img/24/06/15/a5c0663b307a7f1c0335151e36e6b880.jpg!/fw/750/quality/99/unsharp/true/compress/true',13,71,'2026-05-16 14:17:04',1,1),(20,'红色康乃馨感恩','11朵红康乃馨，感恩母爱，母亲节必备花礼',98.00,60,'https://ts1.tc.mm.bing.net/th/id/R-C.6ee77d950756f5765c289b19f010898b?rik=Qe8PJNSGPlXsYQ&riu=http%3a%2f%2fimg.hkwb.net%2fcontent%2f2014-05%2f07%2f4487fc6ef46514d450ec44.jpg&ehk=okebyKsfwxDHXBzZx8PaAXDkvp7T09CiUmozVwbLvJs%3d&risl=&pid=ImgRaw&r=0',14,189,'2026-05-16 14:17:04',1,1),(21,'粉色康乃馨温馨','9朵粉康乃馨温馨甜美，祝福妈妈永远年轻美丽',88.00,65,'https://pic.616pic.com/photoone/00/04/24/618ce701a7a0f2095.jpg',14,145,'2026-05-16 14:17:04',1,1),(22,'白色康乃馨纯洁','7朵白康乃馨纯洁高雅，对母亲的敬爱之情',78.00,55,'https://img.huamu.com/d/file/p/2020/04-23/1587625165547279.jpg',14,98,'2026-05-16 14:17:04',1,1),(23,'康乃馨混搭花束','康乃馨与满天星搭配，层次丰富，温馨感人',118.00,50,'https://imgcdn.nuoder.com/wp-content/uploads/2024/10/20220501183229_10640.jpg',14,167,'2026-05-16 14:17:04',1,1),(24,'单支康乃馨简装','单支精品康乃馨，简约包装，教师节快乐',28.00,120,'https://ts4.tc.mm.bing.net/th/id/OIP-C.08IUmTCi92cMAM6Ancf8aQHaJ4?rs=1&pid=ImgDetMain&o=7&rm=3',14,523,'2026-05-16 14:17:04',1,1),(25,'多肉植物组合盆栽','5种多肉植物组合，形态各异，萌趣十足',68.00,80,'https://ts2.tc.mm.bing.net/th/id/OIP-C.W6rNOTcP9bZe7b8p5j_1fwHaE7?rs=1&pid=ImgDetMain&o=7&rm=3',15,234,'2026-05-16 14:17:04',1,1),(26,'仙人掌迷你盆栽','迷你仙人掌配可爱花盆，易养护，办公桌面好伴侣',38.00,100,'https://ts2.tc.mm.bing.net/th/id/OIP-C.NHvcx9uwC3MfAtu1wNg73gHaHa?rs=1&pid=ImgDetMain&o=7&rm=3',15,345,'2026-05-16 14:17:04',1,1),(27,'景天科多肉拼盘','10种景天科多肉精美拼盘，色彩斑斓，艺术感十足',128.00,45,'https://ts3.tc.mm.bing.net/th/id/OIP-C.L8HqGU17S9XElWY1VD2pggHaFj?rs=1&pid=ImgDetMain&o=7&rm=3',15,156,'2026-05-16 14:17:04',1,1),(28,'玉露多肉精品','精品玉露多肉晶莹剔透，窗面清晰，收藏级别',88.00,35,'https://img.alicdn.com/bao/uploaded/i1/3584623415/O1CN019v0Ihw1b67Ak5eF1O_!!0-item_pic.jpg',15,89,'2026-05-16 14:17:04',1,1),(29,'生石花奇石盆栽','生石花宛如奇石，造型独特，多肉爱好者的珍藏',58.00,50,'https://pic1.zhimg.com/v2-37b817b38b4ca64045a348aefb98af2a_1440w.jpg?source=172ae18b',15,67,'2026-05-16 14:17:04',1,1),(30,'多肉植物大礼包','20种多肉植物大礼包，品种丰富，入门首选',198.00,30,'https://img.alicdn.com/bao/uploaded/i4/642746828/O1CN0178h3kc20JH3fqUdj3_!!642746828.jpg',15,278,'2026-05-16 14:17:04',1,1),(31,'绿萝大盆净化空气','大盆绿萝枝叶茂盛，强力净化空气，新家必备',88.00,60,'https://img.alicdn.com/i4/3375094074/O1CN01ztcQcb1fxwLHHdZAU_!!3375094074.jpg',16,289,'2026-05-16 14:17:04',1,1),(32,'龟背竹北欧风','网红龟背竹ins风，叶片独特，提升家居格调',128.00,40,'https://img.alicdn.com/imgextra/i1/6000000003590/O1CN01fALMy11cOGp9NF26z_!!6000000003590-0-tbvideo.jpg',16,198,'2026-05-16 14:17:04',1,1),(33,'琴叶榕高大盆栽','琴叶榕高1.5米，叶片如琴，客厅镇宅之选',268.00,20,'https://ts1.tc.mm.bing.net/th/id/R-C.d027f546ade2c3d07d23cb1c73c3fcbd?rik=bjxBB7WQ8HsuMA&riu=http%3a%2f%2fn.sinaimg.cn%2fsinacn20190709s%2f400%2fw600h600%2f20190709%2ff2b5-hzrevpz3129153.jpg&ehk=x8p3cnTJmn6NrOEWQ8uXgZsqd4v5zuOEntuCpWIzI5M%3d&risl=&pid=ImgRaw&r=0',16,76,'2026-05-16 14:17:04',1,1),(34,'吊兰垂挂盆栽','垂挂式吊兰清新自然，净化甲醛，悬挂装饰两相宜',58.00,70,'https://cbu01.alicdn.com/img/ibank/O1CN01eBqfWn1RRViSQsUnA_!!3018312108-0-cib.jpg?__r__=1675207914674',16,234,'2026-05-16 14:17:04',1,1),(35,'虎皮兰耐旱盆栽','虎皮兰耐旱易养，夜间释放氧气，卧室好伴侣',68.00,65,'https://img.alicdn.com/imgextra/i3/2121499177/O1CN01joB4Hu2Hf7MKSCCpR_!!2121499177.jpg',16,187,'2026-05-16 14:17:04',1,1),(36,'常春藤垂吊植物','常春藤垂吊生长，四季常青，营造自然氛围',78.00,55,'https://img.alicdn.com/i4/3043508699/O1CN01xCxR302E8C0XvOI81_!!3043508699.jpg',16,145,'2026-05-16 14:17:04',1,1),(37,'蝴蝶兰高贵盆栽','蝴蝶兰花姿优美，高贵典雅，春节年宵花首选',188.00,35,'https://upyun.dinghuale.com/uploads/20200623/202006231159377837.jpg',17,123,'2026-05-16 14:17:04',1,1),(38,'长寿花喜庆盆栽','长寿花花期长，寓意健康长寿，送长辈佳品',68.00,70,'https://materials.cdn.bcebos.com/images/1828792/ce024d464cde98b2a455090012ea1227.jpeg',17,267,'2026-05-16 14:17:04',1,1),(39,'仙客来迎宾花','仙客来花朵艳丽，喜迎宾客，客厅装饰佳选',88.00,50,'https://ts2.tc.mm.bing.net/th/id/OIP-C.WWOn5g_Zj4D6jE4Pv_CQTAHaHa?rs=1&pid=ImgDetMain&o=7&rm=3',17,156,'2026-05-16 14:17:04',1,1),(40,'非洲堇室内花卉','非洲堇小巧玲珑，四季开花，窗台点缀',58.00,60,'https://ts2.tc.mm.bing.net/th/id/OIP-C.Ub5zppBJdE6uNF15SUqsBQHaHa?rs=1&pid=ImgDetMain&o=7&rm=3',17,198,'2026-05-16 14:17:04',1,1),(41,'君子兰雅致盆栽','君子兰叶片挺拔，花色艳丽，君子之风',158.00,30,'https://cbu01.alicdn.com/img/ibank/O1CN01uUavmV2IvtdnF6HrZ_!!2209111969349-0-cib.310x310.jpg',17,89,'2026-05-16 14:17:04',1,1),(42,'心形玫瑰礼盒','心形礼盒装11朵红玫瑰，浪漫爆棚，情人节爆款',228.00,40,'https://www.haohua.net/upload/image/2019-06/20/161f0_b2f4.jpg',18,345,'2026-05-16 14:17:04',1,1),(43,'巧克力花礼盒','玫瑰花搭配费列罗巧克力，甜蜜加倍，味觉视觉双享受',268.00,35,'https://ts1.tc.mm.bing.net/th/id/R-C.80daad7618203b86403668b8e2d87fb4?rik=cUR%2bWOz3RL2Vhw&riu=http%3a%2f%2fimg.yzcdn.cn%2fupload_files%2f2019%2f08%2f01%2fFqz-Uru6eUpHVCYydI1GvkQICJ2d.jpg%3fimageView2%2f2%2fw%2f580%2fh%2f580%2fq%2f75%2fformat%2fjpg&ehk=oJgKCcamljXCfOhrTnq%2fQR5Y8dd%2f1mlSHQ77CqpuJ%2f4%3d&risl=&pid=ImgRaw&r=0',18,289,'2026-05-16 14:17:04',1,1),(44,'香水玫瑰礼盒','玫瑰配品牌香水，浪漫香氛，持久留香',388.00,25,'https://cbu01.alicdn.com/img/ibank/O1CN01UQAU4t1yNk0ISLkzJ_!!2219434136567-0-cib.310x310.jpg',18,167,'2026-05-16 14:17:04',1,1),(45,'口红玫瑰礼盒','精选玫瑰搭配大牌口红，女神必备，宠爱有加',458.00,20,'https://ts1.tc.mm.bing.net/th/id/R-C.3817fccc5f3ce5cb7540b57f8a231c02?rik=DmjH9xNlTW%2fNsg&riu=http%3a%2f%2fimg.thebeastshop.com%2fimage%2f20190418154929326003.png&ehk=tHXcZCLooHAjDSQ%2brDfqkrEz%2fQyzpJZfaDPeLrJrkqU%3d&risl=&pid=ImgRaw&r=0',18,234,'2026-05-16 14:17:04',1,1),(46,'小熊玫瑰礼盒','可爱小熊抱玫瑰，萌趣浪漫，少女心爆棚',198.00,45,'https://cbu01.alicdn.com/img/ibank/4506745645_382364329.310x310.jpg',18,412,'2026-05-16 14:17:04',1,1),(47,'星空玫瑰礼盒','LED灯串环绕玫瑰，如星空般璀璨，梦幻浪漫',298.00,30,'https://cbu01.alicdn.com/img/ibank/O1CN015KmZDl1KvYW9PKh3t_!!2212474301226-0-cib.jpg',18,198,'2026-05-16 14:17:04',1,1),(48,'生日蛋糕花礼盒','花束搭配生日蛋糕造型，双重惊喜，生日必备',288.00,30,'https://cbu01.alicdn.com/img/ibank/2020/994/865/18715568499_1887515306.jpg',19,178,'2026-05-16 14:17:04',1,1),(49,'气球花礼盒','氦气气球配花束，童趣满满，生日派对首选',188.00,40,'https://img.alicdn.com/bao/uploaded/i1/3890285335/O1CN01CCb4cZ1pHTa7dRZ4l_!!0-item_pic.jpg',19,256,'2026-05-16 14:17:04',1,1),(50,'玩偶花礼盒','毛绒玩偶拥抱花束，温暖陪伴，女生最爱',218.00,35,'https://cbu01.alicdn.com/img/ibank/O1CN01CwHFue1SjfGWbaHLA_!!2217180112283-0-cib.310x310.jpg',19,289,'2026-05-16 14:17:04',1,1),(51,'皇冠花礼盒','皇冠装饰花束，公主待遇，尊贵体验',258.00,25,'https://cbu01.alicdn.com/img/ibank/O1CN01UWpPrp1Hkc1MDFFgz_!!2213293450796-0-cib.jpg',19,145,'2026-05-16 14:17:04',1,1),(52,'照片定制花礼盒','可定制照片的花礼盒，回忆满满，独一无二',328.00,20,'https://ts4.tc.mm.bing.net/th/id/OIP-C.hQfVT8D88i1bG8nwBk3HMQHaHa?rs=1&pid=ImgDetMain&o=7&rm=3',19,123,'2026-05-16 14:17:04',1,1),(53,'感恩导师花礼盒','康乃馨配钢笔礼盒，谢师恩，教师节必备',168.00,50,'https://cbu01.alicdn.com/img/ibank/O1CN01vpqvTm1VBigeyvKkR_!!2206758512615-0-cib.310x310.jpg',20,234,'2026-05-16 14:17:04',1,1),(54,'感恩父母花礼盒','康乃馨配茶叶礼盒，孝心满满，感恩父母养育恩',228.00,35,'https://cbu01.alicdn.com/img/ibank/O1CN01B1wdfQ1u1WBeSpRmQ_!!2849755977-0-cib.jpg',20,189,'2026-05-16 14:17:04',1,1),(55,'感恩朋友花礼盒','向日葵配咖啡礼盒，友情万岁，感谢相伴',188.00,40,'https://cbu01.alicdn.com/img/ibank/O1CN01nkjnge21YDczBtWlM_!!2212707506996-0-cib.jpg',20,167,'2026-05-16 14:17:04',1,1),(56,'感恩客户花礼盒','高档花艺配红酒，商务感恩，维系客户关系',388.00,25,'https://cbu01.alicdn.com/img/ibank/O1CN01dVHn7f1Q2URZrC7wC_!!2208148581918-0-cib.jpg',20,98,'2026-05-16 14:17:04',1,1),(57,'红玫瑰玻璃罩小号','单朵红玫瑰玻璃罩，经典款，永不凋谢的爱',128.00,60,'https://cbu01.alicdn.com/img/ibank/O1CN01qRbuWV1xNSCWjOQme_!!2221103816431-0-cib.310x310.jpg',21,456,'2026-05-16 14:17:04',1,1),(58,'红玫瑰玻璃罩中号','3朵红玫瑰玻璃罩配LED灯，浪漫升级',228.00,40,'https://cbu01.alicdn.com/img/ibank/2020/425/108/23153801524_892943239.jpg',21,345,'2026-05-16 14:17:04',1,1),(59,'红玫瑰玻璃罩大号','9朵红玫瑰豪华玻璃罩，震撼视觉，求婚神器',588.00,15,'https://img30.360buyimg.com/sku/jfs/t1/62162/32/11104/308587/5d898a26Edc50fa6c/ecab84403d02853e.jpg',21,189,'2026-05-16 14:17:04',1,1),(60,'粉玫瑰玻璃罩','粉玫瑰玻璃罩温柔浪漫，少女心满满',158.00,50,'https://cbu01.alicdn.com/img/ibank/O1CN017WDJ2q28ahHFRoT9A_!!2660027949-0-cib.310x310.jpg',21,278,'2026-05-16 14:17:04',1,1),(61,'蓝玫瑰玻璃罩','蓝玫瑰玻璃罩神秘独特，稀世珍品',268.00,25,'https://img.alicdn.com/i1/2082097578/O1CN01OVuk1H25qmBqeLn7h_!!2082097578.jpg',21,156,'2026-05-16 14:17:04',1,1),(62,'混色玫瑰玻璃罩','多色玫瑰玻璃罩色彩斑斓，艺术收藏品',298.00,20,'https://www.haohua.net/upload/image/2019-06/20/149ce_3ae6.jpg',21,123,'2026-05-16 14:17:04',1,1),(63,'心形相框永生花','心形相框内嵌永生花，爱意满满，墙面装饰',188.00,45,'https://cbu01.alicdn.com/img/ibank/O1CN01Tad2Is1Iex0PIq9gz_!!2218875390919-0-cib.310x310.jpg',22,234,'2026-05-16 14:17:04',1,1),(64,'方形相框永生花','方形相框永生花简约现代，家居装饰佳品',168.00,50,'https://cbu01.alicdn.com/img/ibank/O1CN0160QjI52Lo3e9PyLrF_!!2212303099738-0-cib.jpg',22,198,'2026-05-16 14:17:04',1,1),(65,'圆形相框永生花','圆形相框永生花圆满美好，中式风格',178.00,40,'https://img.alicdn.com/bao/uploaded/i1/2206517137441/O1CN01cmJrSb24q1vyB5DtI_!!0-item_pic.jpg',22,167,'2026-05-16 14:17:04',1,1),(66,'立体相框永生花','3D立体相框永生花，层次丰富，艺术感强',258.00,30,'https://img.alicdn.com/bao/uploaded/i1/2490940705/O1CN01LHvd1j1H4vy5LsvF2_!!2490940705.jpg',22,145,'2026-05-16 14:17:04',1,1),(67,'双面相框永生花','双面观赏相框永生花，360度无死角',288.00,25,'https://img.alicdn.com/bao/uploaded/i1/4116913168/O1CN01ulEgcQ1ZGzUd5Gpwo_!!0-item_pic.jpg',22,112,'2026-05-16 14:17:04',1,1),(68,'旋转音乐盒永生花','旋转底座配音乐盒永生花，视听双重享受',328.00,30,'https://cbu01.alicdn.com/img/ibank/O1CN01aJnV5H1N0FmyMG59U_!!2200732871507-0-cib.310x310.jpg',23,189,'2026-05-16 14:17:04',1,1),(69,'水晶球音乐盒','水晶球内永生花飘雪效果，梦幻浪漫',388.00,20,'https://ts4.tc.mm.bing.net/th/id/OIP-C.o5OXDSmqN6aS_pcSJGyQ6gHaHa?rs=1&pid=ImgDetMain&o=7&rm=3',23,156,'2026-05-16 14:17:04',1,1),(70,'八音盒永生花','经典八音盒配永生花，怀旧浪漫',298.00,25,'https://cbu01.alicdn.com/img/ibank/O1CN01KrVQeU1KdEaujC8oq_!!2216103521186-0-cib.310x310.jpg',23,134,'2026-05-16 14:17:04',1,1),(71,'蓝牙音箱音乐盒','蓝牙音箱功能音乐盒永生花，实用浪漫兼具',458.00,15,'https://cbu01.alicdn.com/img/ibank/2019/444/137/10719731444_209199168.jpg',23,98,'2026-05-16 14:17:04',1,1),(72,'个性定制花束','根据需求定制花材颜色搭配，独一无二',288.00,50,'https://static.jingjiribao.cn/2022/8/1/20220801090718_9485.JPEG',24,167,'2026-05-16 14:17:04',1,1),(73,'主题定制花束','按主题定制如海洋星空等，创意无限',358.00,35,'https://ts4.tc.mm.bing.net/th/id/OIP-C._MJlXFDK2xh26vMi5DcJsQHaIN?rs=1&pid=ImgDetMain&o=7&rm=3',25,123,'2026-05-16 14:17:04',1,1),(74,'企业定制花束','企业LOGO定制花束，商务活动专属',428.00,30,'https://oss.huawa.com/shop/placeorder/06798526908204713.jpeg',24,89,'2026-05-16 14:17:04',1,1),(75,'婚礼定制花束','婚礼主题色系定制，新娘专属手捧',588.00,20,'https://ts1.tc.mm.bing.net/th/id/OIP-C.EUuNJCB62GlbyhR65cjVOwHaHa?rs=1&pid=ImgDetMain&o=7&rm=3',25,67,'2026-05-16 14:17:04',1,1),(76,'节日定制花束','节日主题定制如圣诞新年，应景应情',328.00,40,'https://news.2500sz.com/uploadfiles/202303/07/2023030709531828559171.jpg',24,145,'2026-05-16 14:17:04',1,1),(77,'单层开业花篮','单层花篮简洁大气，开业庆贺经济实惠',188.00,50,'https://img1.sixflower.com/2020321804754664.jpg',26,234,'2026-05-16 14:17:04',1,1),(78,'双层开业花篮','双层花篮气势恢宏，生意兴隆寓意好',328.00,35,'https://img3.sixflower.com/3-20191201101203.jpg',26,189,'2026-05-16 14:17:04',1,1),(79,'三层豪华花篮','三层豪华花篮震撼登场，盛大开业首选',588.00,20,'https://img1.sixflower.com/201642918512971381.jpg',26,123,'2026-05-16 14:17:04',1,1),(80,'一对开业花篮','成对花篮好事成双，开业标配',358.00,40,'https://img.alicdn.com/imgextra/i4/27806854/O1CN01l7JwbG20VB9CsGBjV_!!27806854.jpg',26,267,'2026-05-16 14:17:04',1,1),(81,'定制开业花篮','可定制贺条内容，个性化开业花篮',288.00,45,'https://oss.huawa.com/shop/placeorder/07121295744508405.png',26,198,'2026-05-16 14:17:04',1,1),(82,'会议桌花简约','简约桌花点缀会议室，提升会议氛围',128.00,60,'https://img.alicdn.com/bao/uploaded/i3/268008839/O1CN01hO5JT62FAJXRNH1BP_!!268008839.jpg',27,178,'2026-05-16 14:17:04',1,1),(83,'会议桌花豪华','豪华桌花彰显档次，重要会议必备',268.00,30,'https://www.haohua.net/upload/image/2019-06/20/19a9a_c5dc.jpg',27,134,'2026-05-16 14:17:04',1,1),(84,'讲台花装饰','讲台花庄重典雅，演讲发布会适用',188.00,40,'https://ts1.tc.mm.bing.net/th/id/R-C.d935fe89af863c7fbffb38f9385f2f13?rik=r5xcTfLv%2bIAceQ&riu=http%3a%2f%2fwww.kaiyehualan.com%2fuploads%2fallimg%2f20230319%2f1-23031Z0221X30.jpg&ehk=DbJXjn7k17Eht1ggwnZWilVGZF%2f8O1%2bAhxb%2f01jRwl4%3d&risl=&pid=ImgRaw&r=0',27,156,'2026-05-16 14:17:04',1,1),(85,'会场背景花墙','大型花墙背景板，活动拍照打卡点',1288.00,10,'https://cbu01.alicdn.com/img/ibank/O1CN019dXfOv20B2AGIvSV5_!!2215834106810-0-cib.jpg',27,45,'2026-05-16 14:17:04',1,1),(86,'乔迁发财树','发财树寓意财源滚滚，乔迁贺礼首选',168.00,45,'https://cbu01.alicdn.com/img/ibank/2018/988/165/8200561889_690009886.jpg',28,234,'2026-05-16 14:17:04',1,1),(87,'乔迁花篮','精美花篮祝贺乔迁，新居新气象',228.00,35,'https://img10.360buyimg.com/n0/g15/M05/03/06/rBEhWFLeBr8IAAAAAAnT5_tRcr0AAIFOAB5XlkACdP_990.jpg',28,189,'2026-05-16 14:17:04',1,1),(88,'乔迁盆栽组合','多盆绿植组合，新家空气净化套餐',288.00,30,'https://img.alicdn.com/i4/2330305613/O1CN01jWDA0l1rKnku6v7LU_!!2330305613.jpg',28,167,'2026-05-16 14:17:04',1,1),(89,'乔迁花艺摆件','艺术花艺摆件，新家装饰点睛之笔',198.00,40,'https://img.alicdn.com/imgextra/i2/1134993244/O1CN01poRj3k1ZpnjjCnpBU_!!1134993244.jpg',28,145,'2026-05-16 14:17:04',1,1),(90,'经典白玫瑰手捧','纯白玫瑰手捧纯洁高雅，西式婚礼经典',288.00,30,'https://oss.huawa.com/shop/placeorder/07105999041057746.jpg',29,178,'2026-05-16 14:17:04',1,1),(91,'粉色系手捧','粉色系花材手捧温柔浪漫，甜美新娘',258.00,35,'https://ts4.tc.mm.bing.net/th/id/OIP-C.2voLXo1B3uJ_0E_C-BwazgHaFS?rs=1&pid=ImgDetMain&o=7&rm=3',29,156,'2026-05-16 14:17:04',1,1),(92,'瀑布型手捧','瀑布型手捧华丽大气，女王范十足',388.00,20,'https://cbu01.alicdn.com/img/ibank/O1CN01Pq5OUW1V9QgdRwCe1_!!2076132610-0-cib.310x310.jpg',29,123,'2026-05-16 14:17:04',1,1),(93,'球形手捧','紧凑球形手捧精致可爱，小巧玲珑',228.00,40,'https://www.suyuanshengtai.com/zb_users/upload/2025/07/20250711032523_78016.jpeg',29,198,'2026-05-16 14:17:04',1,1),(94,'定制色系手捧','按婚礼色系定制手捧，完美搭配',328.00,25,'https://ts1.tc.mm.bing.net/th/id/R-C.7acec1f0902329e4a71be09221d17692?rik=qqPOxkwevb5q3g&riu=http%3a%2f%2fwww.choco.com.cn%2fuploads%2fallimg%2fc191016%2f15G239B201D0-1092043.jpg&ehk=OE2s1kgpjYVH%2bc7GymRmcPnsFIpSU5ueuWsIhy2I8Oo%3d&risl=&pid=ImgRaw&r=0',29,145,'2026-05-16 14:17:04',1,1),(95,'婚车头车花','头车V型花饰浪漫吸睛，婚礼车队亮点',388.00,25,'https://cbu01.alicdn.com/img/ibank/2019/968/198/10823891869_1144477290.jpg',30,167,'2026-05-16 14:17:04',1,1),(96,'婚车全套装饰','头车+跟车全套装饰，统一风格气派',888.00,15,'https://img.alicdn.com/i1/359777697/O1CN01k9u3pv26jHIK5VsOD_!!359777697.jpg',30,89,'2026-05-16 14:17:04',1,1),(97,'婚车把手花','车门把手小花饰精致点缀，细节满分',128.00,50,'https://cbu01.alicdn.com/img/ibank/2019/570/454/10797454075_1144477290.jpg',30,234,'2026-05-16 14:17:04',1,1),(98,'婚车后视镜花','后视镜花饰飘逸灵动，行车风景线',158.00,40,'https://img.alicdn.com/imgextra/i4/74752949/O1CN01mg8Yrd1XegfgVpYwr_!!74752949.jpg',30,189,'2026-05-16 14:17:04',1,1),(99,'高脚杯桌花','高脚杯桌花优雅浪漫，婚宴餐桌装饰',168.00,40,'https://img01.yzcdn.cn/upload_files/2019/05/30/Fju77-mOpEFBNsZRL3Dj5hrsBw_D.jpg!730x0.jpg',31,198,'2026-05-16 14:17:04',1,1),(100,'低矮桌花','低矮桌花不遮挡视线，便于交流',138.00,50,'https://img.alicdn.com/bao/uploaded/i4/268008839/O1CN01MTqcnq2FAJch09SWN_!!268008839.jpg',31,234,'2026-05-16 14:17:04',1,1),(101,'烛台桌花','烛台配花温馨浪漫，晚宴氛围营造',198.00,35,'https://cbu01.alicdn.com/img/ibank/O1CN019LhVZu1CclEWL8rUQ_!!2215662360102-0-cib.jpg',31,167,'2026-05-16 14:17:04',1,1),(102,'主题桌花套装','整套主题桌花统一风格，婚宴标配',1288.00,10,'https://img.alicdn.com/i2/268008839/O1CN01wgBoPQ2FAJjajk6Yt_!!268008839.jpg',31,78,'2026-05-16 14:17:04',1,1),(103,'情人节限定玫瑰','情人节特别款玫瑰包装，限量发售',298.00,50,'https://img.alicdn.com/bao/uploaded/i3/2445977191/O1CN01pEDgNN22zWo0CCAzt_!!2445977191.jpg',32,456,'2026-05-16 14:17:04',1,1),(104,'情人节巧克力花','心形巧克力配玫瑰，甜蜜暴击',258.00,40,'https://img95.699pic.com/photo/60070/7643.jpg_wh300.jpg!/fh/300/quality/90',32,389,'2026-05-16 14:17:04',1,1),(105,'情人节永生花','情人节永生花礼盒，爱永恒不变',388.00,30,'https://img.alicdn.com/i2/3925593388/O1CN01pF2Cgh1atkd5AjMsz_!!3925593388.jpg',32,267,'2026-05-16 14:17:04',1,1),(106,'情人节抱抱桶','超大抱抱桶装满玫瑰，震撼惊喜',588.00,20,'https://cbu01.alicdn.com/img/ibank/O1CN01NJIYrk21w2V4Sm8ww_!!2207941747048-0-cib.310x310.jpg',32,234,'2026-05-16 14:17:04',1,1),(107,'情人节定制款','可刻字定制情人节花礼，专属纪念',458.00,25,'https://img.alicdn.com/bao/uploaded/i1/89726159/O1CN01Xs9liH1vMsB7ZzvzW_!!89726159.jpg',32,198,'2026-05-16 14:17:04',1,1),(108,'母亲节康乃馨','11朵康乃馨感恩母爱，母亲节经典',128.00,80,'https://ts2.tc.mm.bing.net/th/id/OIP-C.zG9S2KeU8vK8PAE5b9kgGwHaEJ?rs=1&pid=ImgDetMain&o=7&rm=3',33,567,'2026-05-16 14:17:04',1,1),(109,'母亲节混搭花束','康乃馨百合混搭，层次丰富寓意好',198.00,60,'https://img.alicdn.com/bao/uploaded/i1/1588832334/O1CN01ZBrdwn1T711EoqlYl_!!1588832334.jpg',33,423,'2026-05-16 14:17:04',1,1),(110,'母亲节盆栽','长寿花盆栽寓意健康长寿，实用贴心',158.00,50,'https://img.alicdn.com/imgextra/i4/692258413/O1CN01X5Hzi52C1D1s5kV3n_!!692258413.jpg',33,345,'2026-05-16 14:17:04',1,1),(111,'母亲节礼盒','康乃馨配丝巾礼盒，高端大气',288.00,35,'https://tse2-mm.cn.bing.net/th/id/OIP-C.Gq5AM8n8n7TsboctSLBLLgHaHa?o=7rm=3&rs=1&pid=ImgDetMain&o=7&rm=3',33,289,'2026-05-16 14:17:04',1,1),(112,'母亲节定制','照片定制母亲节花礼，回忆满满',328.00,30,'https://0.rc.xiniu.com/g5/M00/1A/40/CgAGbGY4gwKAViPTAAL0U6499Tw876.jpg',33,234,'2026-05-16 14:17:04',1,1),(113,'教师节康乃馨','单支康乃馨谢师恩，经济实惠',38.00,150,'https://pic.pngsucai.com/00/92/36/ae8953cba2433d03.webp',34,789,'2026-05-16 14:17:04',1,1),(114,'教师节花束','康乃馨向日葵混搭，感恩祝福',128.00,80,'https://0.rc.xiniu.com/g4/M00/12/6F/CgAG0mE7B4mATAVSAANCsfU5M6E422.jpg',34,456,'2026-05-16 14:17:04',1,1),(115,'教师节盆栽','文竹盆栽清雅高洁，书房点缀',88.00,60,'https://cbu01.alicdn.com/img/ibank/O1CN01bCpiBs1x3IejInRWs_!!2211187966387-0-cib.310x310.jpg',34,345,'2026-05-16 14:17:04',1,1),(116,'教师节礼盒','花束配钢笔礼盒，实用有面子',188.00,50,'https://cbu01.alicdn.com/img/ibank/O1CN019MejnO1jPpWDT33kK_!!2217621774541-0-cib.310x310.jpg',34,289,'2026-05-16 14:17:04',1,1),(117,'满天星干花','天然满天星干花束，清新自然',48.00,100,'https://img.alicdn.com/imgextra/i2/1869293399/O1CN01uWjAc51aymxhrkUC6_!!1869293399.jpg',35,456,'2026-05-16 14:17:04',1,1),(118,'尤加利叶干花','尤加利叶干花北欧风，家居装饰',58.00,80,'https://img.alicdn.com/i3/2084562343/O1CN01oN1r6r1TB8Y7xB848_!!2084562343.jpg',35,389,'2026-05-16 14:17:04',1,1),(119,'薰衣草干花','薰衣草干花香氛助眠，卧室装饰',68.00,70,'https://img.alicdn.com/i2/1638179972/TB2kuPiJXmWBuNjSspdXXbugXXa_!!1638179972.jpg',35,345,'2026-05-16 14:17:04',1,1),(120,'麦穗干花','金色麦穗干花丰收寓意，田园风',38.00,120,'https://cbu01.alicdn.com/img/ibank/2020/323/874/16852478323_665155308.jpg',35,567,'2026-05-16 14:17:04',1,1),(121,'棉花干花','天然棉花干花柔软温暖，ins风',58.00,90,'https://cbu01.alicdn.com/img/ibank/O1CN01dAB9oh1NZW1V3D6iH_!!2206368891584-0-cib.jpg',35,423,'2026-05-16 14:17:04',1,1),(122,'干花混搭花束','多种干花精心搭配，艺术感十足',128.00,60,'https://cbu01.alicdn.com/img/ibank/O1CN01Ma8q7f1RKdv39uUIO_!!2209791762093-0-cib.jpg',36,289,'2026-05-16 14:17:04',1,1),(123,'干花玻璃瓶','干花配玻璃瓶套装，即插即用',88.00,70,'https://img.alicdn.com/imgextra/i1/2206341626574/O1CN01mkhwGc1yQwZjohcl9_!!2206341626574.jpg',36,345,'2026-05-16 14:17:04',1,1),(124,'干花相框','干花装裱相框，墙面装饰艺术品',158.00,40,'https://img.alicdn.com/bao/uploaded/i1/2212524610/O1CN01bkLSim1jvQcIs9uFt_!!0-item_pic.jpg',36,234,'2026-05-16 14:17:04',1,1),(125,'干花花环','干花编织花环，门饰壁挂两用',98.00,50,'https://img1.yiwugou.com/i004/2019/06/02/82/b5a7df160b33f593d5454f87b70431ce.jpg',36,267,'2026-05-16 14:17:04',1,1),(126,'干花礼盒','精美干花礼盒装，送礼佳选',188.00,35,'https://imgservice.suning.cn/uimg1/b2c/image/299EIODqStaCgG5vwDEH7A.jpg_800w_800h_4e',36,198,'2026-05-16 14:17:04',1,1),(127,'白色陶瓷花瓶','简约白色陶瓷花瓶，百搭经典',68.00,80,'https://img.alicdn.com/bao/uploaded/i3/2215016933405/O1CN01lFjgAj1b1XT0TJb3B_!!2215016933405.jpg',37,345,'2026-05-16 14:17:04',1,1),(128,'彩色陶瓷花瓶','彩色釉面陶瓷花瓶，活泼亮丽',88.00,60,'https://tgi1.jia.com/114/829/14829851.jpg',37,267,'2026-05-16 14:17:04',1,1),(129,'复古陶瓷花瓶','复古做旧陶瓷花瓶，文艺气息',128.00,40,'https://cbu01.alicdn.com/img/ibank/O1CN012YYoBE2IsEV63S7gN_!!3044539341-0-cib.jpg?__r__=1687223575908',37,189,'2026-05-16 14:17:04',1,1),(130,'大号陶瓷花瓶','落地大花瓶客厅装饰，气势磅礴',288.00,20,'https://img.alicdn.com/bao/uploaded/i1/2232782021/O1CN01RfuDrV1QnezCMxtjy_!!0-item_pic.jpg',37,123,'2026-05-16 14:17:04',1,1),(131,'迷你陶瓷花瓶','迷你小花瓶桌面点缀，精致可爱',38.00,100,'https://cbu01.alicdn.com/img/ibank/O1CN012EzoNK2KO7hCvEwLz_!!2216003809546-0-cib.jpg',37,456,'2026-05-16 14:17:04',1,1),(132,'透明玻璃花瓶','经典透明玻璃花瓶，简约百搭',48.00,100,'https://img.alicdn.com/bao/uploaded/i3/2177398060/TB2kxPgn4BmpuFjSZFDXXXD8pXa_!!2177398060.jpg',38,567,'2026-05-16 14:17:04',1,1),(133,'彩色玻璃花瓶','彩色玻璃花瓶透光美观',68.00,70,'https://img.alicdn.com/i4/1722652805/TB2hCMccVXXXXXyXXXXXXXXXXXX_!!1722652805.jpg',38,389,'2026-05-16 14:17:04',1,1),(134,'几何玻璃花瓶','几何造型玻璃花瓶现代感强',88.00,50,'https://cbu01.alicdn.com/img/ibank/2018/480/223/8699322084_1741362919.jpg',38,289,'2026-05-16 14:17:04',1,1),(135,'水培玻璃花瓶','带水培架玻璃花瓶，植物观察',78.00,60,'https://imgservice.suning.cn/uimg1/b2c/image/TkJjfo5ut4xU8l_JTZWgBg.jpg_800w_800h_4e',38,345,'2026-05-16 14:17:04',1,1),(136,'艺术玻璃花瓶','手工吹制艺术花瓶，收藏品级',188.00,25,'https://img.redocn.com/sheying/20161214/boliyishupinlabakouhuaping_7620791.jpg',38,156,'2026-05-16 14:17:04',1,1),(137,'花艺剪刀','专业花艺剪刀锋利耐用',38.00,100,'https://cbu01.alicdn.com/img/ibank/O1CN01cYYeTJ1KtGHBZmSiL_!!2731701221-0-cib.jpg',39,456,'2026-05-16 14:17:04',1,1),(138,'花泥','插花用花泥固定花材',18.00,150,'https://img.alicdn.com/bao/uploaded/i2/2200568846235/O1CN01a1Zjlu1vvgGEzt82v_!!0-item_pic.jpg',39,678,'2026-05-16 14:17:04',1,1),(139,'包装纸套装','多色包装纸套装DIY花束',28.00,120,'https://cbu01.alicdn.com/img/ibank/O1CN01OEjmdW2FYavOSMbSb_!!2219624178892-0-cib.jpg',39,567,'2026-05-16 14:17:04',1,1),(140,'丝带彩带','各色丝带彩带装饰花束',15.00,200,'https://img.alicdn.com/bao/uploaded/i2/22353453/O1CN011bNW5VFNwBxo4Hk_!!22353453.jpg',39,789,'2026-05-16 14:17:04',1,1),(141,'花艺教程书','花艺入门教程书籍，自学必备',48.00,80,'https://img.alicdn.com/i3/2406931838/O1CN01L6LLoT1PRqmrxagBP_!!2406931838.jpg',39,234,'2026-05-16 14:17:04',1,1);
/*!40000 ALTER TABLE `product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(50) NOT NULL COMMENT '用户名（登录账号）',
  `pass` varchar(100) NOT NULL COMMENT '密码（MD5加密）',
  `gender` varchar(10) DEFAULT '智能营销' COMMENT '性别',
  `tel` varchar(20) DEFAULT NULL COMMENT '电话号码',
  `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
  `state` varchar(20) DEFAULT '可用' COMMENT '账户状态：可用/禁用',
  `role` varchar(20) DEFAULT '用户' COMMENT '角色：用户/商家/管理员',
  `jf` int DEFAULT '0' COMMENT '积分',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  `last_login_time` timestamp NULL DEFAULT NULL COMMENT '最后登录时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  KEY `idx_username` (`username`) COMMENT '用户名索引，加速登录查询'
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'guitu','e10adc3949ba59abbe56e057f20f883e','智能营销','18023154203','guitu2025@qq.com','可用','管理员',0,'2026-05-16 14:34:36','2026-05-16 15:02:11'),(2,'111','f13ae4b29dd39ddde5e95b65233889f4','智能营销','18023154203','guitu2025@qq.com','可用','用户',0,'2026-05-16 15:04:40','2026-05-17 06:05:48'),(8,'admin','0192023a7bbd73250516f069df18b500','男','13800138000','admin@flowershop.com','可用','管理员',0,'2026-05-17 06:14:52','2026-05-17 09:54:10'),(10,'merchant','a52f2c0dbf38ade4f715e02c7124046e','男','13900139000','merchant@flower.com','可用','商家',0,'2026-05-17 06:36:29','2026-05-17 10:14:59'),(11,'yes','96e79218965eb72c92a549dd5a330112','未知','18023154203','guitu2025@qq.com','可用','用户',0,'2026-05-17 08:49:02','2026-05-17 12:51:20');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-17 21:03:27
