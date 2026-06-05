package com.flower.dao;

import com.flower.entity.SeckillActivity;
import com.flower.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 秒杀活动数据访问层
 * 提供秒杀活动的增删改查、库存扣减（悲观锁）及秒杀订单记录功能
 */
public class SeckillDao {

    /**
     * 查询所有秒杀活动（LEFT JOIN product 拿商品信息）
     */
    public List<SeckillActivity> findAll() {
        String sql = "SELECT sa.*, p.name AS product_name, p.pic AS product_pic, p.price AS product_price, " +
                     "(SELECT COUNT(*) FROM seckill_order so WHERE so.seckill_id = sa.id) AS sold_count " +
                     "FROM seckill_activity sa LEFT JOIN product p ON sa.product_id = p.id ORDER BY sa.id DESC";
        List<SeckillActivity> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return list;
    }

    /**
     * 查询单个秒杀活动详情
     */
    public SeckillActivity findById(int id) {
        if (id <= 0) return null;
        String sql = "SELECT sa.*, p.name AS product_name, p.pic AS product_pic, p.price AS product_price, " +
                     "(SELECT COUNT(*) FROM seckill_order so WHERE so.seckill_id = sa.id) AS sold_count " +
                     "FROM seckill_activity sa LEFT JOIN product p ON sa.product_id = p.id WHERE sa.id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return null;
    }

    /**
     * 查询当前进行中的秒杀活动（status=1 且当前时间在开始和结束之间）
     */
    public List<SeckillActivity> findActive() {
        String sql = "SELECT sa.*, p.name AS product_name, p.pic AS product_pic, p.price AS product_price, " +
                     "(SELECT COUNT(*) FROM seckill_order so WHERE so.seckill_id = sa.id) AS sold_count " +
                     "FROM seckill_activity sa LEFT JOIN product p ON sa.product_id = p.id " +
                     "WHERE sa.status = 1 AND NOW() BETWEEN sa.start_time AND sa.end_time ORDER BY sa.end_time ASC";
        List<SeckillActivity> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return list;
    }

    /**
     * 查询指定商品当前进行中的秒杀活动
     */
    public SeckillActivity findActiveByProductId(int productId) {
        if (productId <= 0) return null;
        String sql = "SELECT sa.*, p.name AS product_name, p.pic AS product_pic, p.price AS product_price, " +
                     "(SELECT COUNT(*) FROM seckill_order so WHERE so.seckill_id = sa.id) AS sold_count " +
                     "FROM seckill_activity sa LEFT JOIN product p ON sa.product_id = p.id " +
                     "WHERE sa.product_id = ? AND sa.status = 1 AND NOW() BETWEEN sa.start_time AND sa.end_time LIMIT 1";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, productId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return null;
    }

    /**
     * 新增秒杀活动
     */
    public boolean save(SeckillActivity activity) {
        if (activity == null) return false;
        String sql = "INSERT INTO seckill_activity (product_id, seckill_price, seckill_stock, per_user_limit, start_time, end_time, status) VALUES (?,?,?,?,?,?,?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, activity.getProductId());
            pstmt.setDouble(2, activity.getSeckillPrice());
            pstmt.setInt(3, activity.getSeckillStock());
            pstmt.setInt(4, activity.getPerUserLimit());
            pstmt.setTimestamp(5, new Timestamp(activity.getStartTime().getTime()));
            pstmt.setTimestamp(6, new Timestamp(activity.getEndTime().getTime()));
            pstmt.setInt(7, activity.getStatus());
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return false;
    }

    /**
     * 更新秒杀活动
     */
    public boolean update(SeckillActivity activity) {
        if (activity == null || activity.getId() <= 0) return false;
        String sql = "UPDATE seckill_activity SET product_id=?, seckill_price=?, seckill_stock=?, per_user_limit=?, start_time=?, end_time=?, status=? WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, activity.getProductId());
            pstmt.setDouble(2, activity.getSeckillPrice());
            pstmt.setInt(3, activity.getSeckillStock());
            pstmt.setInt(4, activity.getPerUserLimit());
            pstmt.setTimestamp(5, new Timestamp(activity.getStartTime().getTime()));
            pstmt.setTimestamp(6, new Timestamp(activity.getEndTime().getTime()));
            pstmt.setInt(7, activity.getStatus());
            pstmt.setInt(8, activity.getId());
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return false;
    }

    /**
     * 更新秒杀活动状态
     */
    public boolean updateStatus(int id, int status) {
        if (id <= 0) return false;
        String sql = "UPDATE seckill_activity SET status = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, status);
            pstmt.setInt(2, id);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return false;
    }

    /**
     * 删除秒杀活动
     */
    public boolean deleteById(int id) {
        if (id <= 0) return false;
        String sql = "DELETE FROM seckill_activity WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return false;
    }

    /**
     * 核心方法：使用悲观锁扣减秒杀库存
     * 使用 SELECT ... FOR UPDATE 锁定行，防止超卖
     *
     * @param seckillId 秒杀活动ID
     * @param quantity  购买数量
     * @param conn      事务连接（由调用方传入，确保在同一事务中）
     * @return true 扣减成功，false 库存不足
     */
    public boolean deductStock(int seckillId, int quantity, Connection conn) throws SQLException {
        // 使用 FOR UPDATE 锁定行
        String lockSql = "SELECT seckill_stock FROM seckill_activity WHERE id = ? FOR UPDATE";
        try (PreparedStatement pstmt = conn.prepareStatement(lockSql)) {
            pstmt.setInt(1, seckillId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (!rs.next()) return false;
                int currentStock = rs.getInt("seckill_stock");
                if (currentStock < quantity) return false;
            }
        }

        // 扣减库存
        String updateSql = "UPDATE seckill_activity SET seckill_stock = seckill_stock - ? WHERE id = ? AND seckill_stock >= ?";
        try (PreparedStatement pstmt = conn.prepareStatement(updateSql)) {
            pstmt.setInt(1, quantity);
            pstmt.setInt(2, seckillId);
            pstmt.setInt(3, quantity);
            return pstmt.executeUpdate() > 0;
        }
    }

    /**
     * 记录秒杀订单
     *
     * @param seckillId    秒杀活动ID
     * @param userId       用户ID
     * @param orderId      订单号
     * @param quantity     购买数量
     * @param seckillPrice 秒杀价格快照
     * @param conn         事务连接
     * @return true 记录成功
     */
    public boolean recordSeckillOrder(int seckillId, int userId, String orderId, int quantity, double seckillPrice, Connection conn) throws SQLException {
        String sql = "INSERT INTO seckill_order (seckill_id, user_id, order_id, quantity, seckill_price) VALUES (?,?,?,?,?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, seckillId);
            pstmt.setInt(2, userId);
            pstmt.setString(3, orderId);
            pstmt.setInt(4, quantity);
            pstmt.setDouble(5, seckillPrice);
            return pstmt.executeUpdate() > 0;
        }
    }

    /**
     * 检查用户是否已购买过该秒杀活动
     */
    public boolean hasUserBought(int seckillId, int userId) {
        if (seckillId <= 0 || userId <= 0) return false;
        String sql = "SELECT COUNT(*) FROM seckill_order WHERE seckill_id = ? AND user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, seckillId);
            pstmt.setInt(2, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return false;
    }

    private SeckillActivity mapRow(ResultSet rs) throws SQLException {
        SeckillActivity a = new SeckillActivity();
        a.setId(rs.getInt("id"));
        a.setProductId(rs.getInt("product_id"));
        a.setSeckillPrice(rs.getDouble("seckill_price"));
        a.setSeckillStock(rs.getInt("seckill_stock"));
        a.setPerUserLimit(rs.getInt("per_user_limit"));
        a.setStartTime(rs.getTimestamp("start_time"));
        a.setEndTime(rs.getTimestamp("end_time"));
        a.setStatus(rs.getInt("status"));
        a.setCreateTime(rs.getTimestamp("create_time"));
        try { a.setProductName(rs.getString("product_name")); } catch (SQLException ignored) {}
        try { a.setProductPic(rs.getString("product_pic")); } catch (SQLException ignored) {}
        try { a.setProductPrice(rs.getDouble("product_price")); } catch (SQLException ignored) {}
        try { a.setSoldCount(rs.getInt("sold_count")); } catch (SQLException ignored) {}
        return a;
    }
}
