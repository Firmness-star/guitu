package com.flower.dao;

import com.flower.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * 积分流水数据访问对象
 * 记录每次积分变动的来源、数量和时间
 */
public class JfDao {

    /**
     * 插入积分流水记录
     * @param userId 用户ID
     * @param amount 变动数量（正=增加，负=扣减）
     * @param source 来源标识：register/browse/login/address/order/usePoints/completeProfile
     * @param description 说明文字
     */
    public boolean addLog(int userId, int amount, String source, String description) {
        if (userId <= 0 || amount == 0) return false;
        String sql = "INSERT INTO jf_log (user_id, amount, source, description) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setInt(2, amount);
            pstmt.setString(3, source);
            pstmt.setString(4, description != null ? description : "");
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("[JFDAO] " + e.getMessage()); }
        return false;
    }

    /**
     * 与事务共享连接的版本
     */
    public boolean addLog(int userId, int amount, String source, String description, Connection conn) {
        if (userId <= 0 || amount == 0) return false;
        String sql = "INSERT INTO jf_log (user_id, amount, source, description) VALUES (?, ?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setInt(2, amount);
            pstmt.setString(3, source);
            pstmt.setString(4, description != null ? description : "");
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("[JFDAO] " + e.getMessage()); }
        return false;
    }

    /**
     * 查询用户的积分流水（按时间倒序）
     */
    public List<Map<String, Object>> findByUserId(int userId, int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        if (userId <= 0) return list;
        String sql = "SELECT id, amount, source, description, create_time FROM jf_log WHERE user_id = ? ORDER BY create_time DESC LIMIT ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setInt(2, limit > 0 ? limit : 50);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> row = new java.util.HashMap<>();
                    row.put("id", rs.getInt("id"));
                    row.put("amount", rs.getInt("amount"));
                    row.put("source", rs.getString("source"));
                    row.put("description", rs.getString("description"));
                    row.put("createTime", rs.getTimestamp("create_time"));
                    list.add(row);
                }
            }
        } catch (SQLException e) { System.err.println("[JFDAO] " + e.getMessage()); }
        return list;
    }

    /**
     * 检查今日是否已获得某来源的积分（用于每日首次登录等）
     */
    public boolean hasTodaySource(int userId, String source) {
        if (userId <= 0) return true;
        String sql = "SELECT COUNT(*) FROM jf_log WHERE user_id = ? AND source = ? AND DATE(create_time) = CURDATE()";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setString(2, source);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) { System.err.println("[JFDAO] " + e.getMessage()); }
        return true;
    }
}
