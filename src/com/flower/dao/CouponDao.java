package com.flower.dao;

import com.flower.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

/**
 * 优惠券数据访问对象
 */
public class CouponDao {

    // ── 优惠券定义表 CRUD ──

    public List<Map<String, Object>> findAllCoupons() {
        String sql = "SELECT * FROM coupon ORDER BY id DESC";
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) list.add(mapCoupon(rs));
        } catch (SQLException e) { System.err.println("[COUPON] " + e.getMessage()); }
        return list;
    }

    public Map<String, Object> findCouponById(int id) {
        String sql = "SELECT * FROM coupon WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return mapCoupon(rs);
            }
        } catch (SQLException e) { System.err.println("[COUPON] " + e.getMessage()); }
        return null;
    }

    public boolean saveCoupon(String name, String type, double value, double minAmount, int stock, String startDate, String endDate) {
        String sql = "INSERT INTO coupon (name, type, value, min_amount, stock, start_date, end_date) VALUES (?,?,?,?,?,?,?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, name);
            pstmt.setString(2, type);
            pstmt.setDouble(3, value);
            pstmt.setDouble(4, minAmount);
            pstmt.setInt(5, stock);
            pstmt.setString(6, startDate);
            pstmt.setString(7, endDate);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("[COUPON] " + e.getMessage()); }
        return false;
    }

    public boolean deleteCoupon(int id) {
        String sql = "DELETE FROM coupon WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("[COUPON] " + e.getMessage()); }
        return false;
    }

    // ── 用户优惠券领取/使用 ──

    public boolean issueToUser(int userId, int couponId) {
        String sql = "INSERT INTO user_coupon (user_id, coupon_id, status) VALUES (?,?, '未使用')";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setInt(2, couponId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("[COUPON] " + e.getMessage()); }
        return false;
    }

    public boolean issueToAllUsers(int couponId) {
        String sql = "INSERT INTO user_coupon (user_id, coupon_id, status) SELECT id, ?, '未使用' FROM user WHERE role='用户'";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, couponId);
            pstmt.executeUpdate();
            return true;
        } catch (SQLException e) { System.err.println("[COUPON] " + e.getMessage()); }
        return false;
    }

    /**
     * 查询用户可用的优惠券（未使用+有效期内）
     */
    public List<Map<String, Object>> findAvailableByUser(int userId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT uc.id AS uc_id, c.id AS coupon_id, c.name, c.type, c.value, c.min_amount, " +
                     "c.start_date, c.end_date, uc.get_time " +
                     "FROM user_coupon uc JOIN coupon c ON uc.coupon_id = c.id " +
                     "WHERE uc.user_id = ? AND uc.status = '未使用' " +
                     "AND (c.end_date IS NULL OR c.end_date >= CURDATE()) " +
                     "AND (c.stock = -1 OR c.stock > 0) " +
                     "ORDER BY c.value DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("ucId", rs.getInt("uc_id"));
                    row.put("couponId", rs.getInt("coupon_id"));
                    row.put("name", rs.getString("name"));
                    row.put("type", rs.getString("type"));
                    row.put("value", rs.getDouble("value"));
                    row.put("minAmount", rs.getDouble("min_amount"));
                    row.put("startDate", rs.getDate("start_date"));
                    row.put("endDate", rs.getDate("end_date"));
                    row.put("getTime", rs.getTimestamp("get_time"));
                    list.add(row);
                }
            }
        } catch (SQLException e) { System.err.println("[COUPON] " + e.getMessage()); }
        return list;
    }

    public boolean useCoupon(int ucId, String orderNo, Connection conn) {
        String sql = "UPDATE user_coupon SET status = '已使用', used_time = NOW(), order_no = ? WHERE id = ? AND status = '未使用'";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, orderNo);
            pstmt.setInt(2, ucId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("[COUPON] " + e.getMessage()); }
        return false;
    }

    /**
     * 计算优惠券抵扣金额
     */
    public double calcDiscount(Map<String, Object> coupon, double orderAmount) {
        if (coupon == null) return 0;
        String type = (String) coupon.get("type");
        double value = ((Number) coupon.get("value")).doubleValue();
        double minAmount = ((Number) coupon.get("minAmount")).doubleValue();
        if (orderAmount < minAmount) return 0;
        if ("满减".equals(type) || "reduce".equals(type)) {
            return Math.min(value, orderAmount);
        } else if ("折扣".equals(type) || "discount".equals(type)) {
            return Math.round(orderAmount * (100 - value) / 100.0 * 100.0) / 100.0;
        }
        return 0;
    }

    private Map<String, Object> mapCoupon(ResultSet rs) throws SQLException {
        Map<String, Object> row = new HashMap<>();
        row.put("id", rs.getInt("id"));
        row.put("name", rs.getString("name"));
        row.put("type", rs.getString("type"));
        row.put("value", rs.getDouble("value"));
        row.put("minAmount", rs.getDouble("min_amount"));
        row.put("stock", rs.getInt("stock"));
        row.put("startDate", rs.getDate("start_date"));
        row.put("endDate", rs.getDate("end_date"));
        row.put("createTime", rs.getTimestamp("create_time"));
        return row;
    }
}
