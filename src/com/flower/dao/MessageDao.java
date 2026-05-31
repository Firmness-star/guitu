package com.flower.dao;

import com.flower.entity.Message;
import com.flower.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MessageDao {

    // 用户发新留言：管理员侧 1 条未读
    public boolean save(Message msg) {
        if (msg == null) return false;
        String sql = "INSERT INTO message (user_id, username, content, is_admin_read, unread_user_replies) VALUES (?, ?, ?, 0, 1)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, msg.getUserId());
            pstmt.setString(2, msg.getUsername());
            pstmt.setString(3, msg.getContent());
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return false;
    }

    public boolean deleteById(int id) {
        String sql = "DELETE FROM message WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return false;
    }

    // 管理员回复 → unread_admin_replies +1，用户侧标记未读
    public boolean adminReply(int msgId, String reply) {
        String sql = "UPDATE message SET conversation = CONCAT(IFNULL(conversation,''), '[管理员]', ?, '\n')," +
                     " is_user_read = 0, unread_admin_replies = unread_admin_replies + 1 WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, reply);
            pstmt.setInt(2, msgId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return false;
    }

    // 用户回复 → unread_user_replies +1，管理员侧标记未读
    public boolean userReply(int msgId, String reply) {
        String sql = "UPDATE message SET conversation = CONCAT(IFNULL(conversation,''), '[用户]', ?, '\n')," +
                     " is_admin_read = 0, unread_user_replies = unread_user_replies + 1 WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, reply);
            pstmt.setInt(2, msgId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return false;
    }

    // 管理员仪表板：所有未读用户回复的条数
    public int countUnreadForAdmin() {
        String sql = "SELECT COALESCE(SUM(unread_user_replies), 0) FROM message WHERE unread_user_replies > 0";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return 0;
    }

    // 用户个人中心：该用户未读管理员回复的条数
    public int countUnreadByUserId(int userId) {
        String sql = "SELECT COALESCE(SUM(unread_admin_replies), 0) FROM message WHERE user_id = ? AND unread_admin_replies > 0";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return 0;
    }

    // 用户进入留言页 → 清零该用户所有未读管理员回复
    public void markUserRead(int userId) {
        String sql = "UPDATE message SET unread_admin_replies = 0, is_user_read = 1 WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.executeUpdate();
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
    }

    // 管理员进入留言管理 → 清零所有未读用户回复
    public void markAdminRead() {
        String sql = "UPDATE message SET unread_user_replies = 0, is_admin_read = 1 WHERE unread_user_replies > 0";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.executeUpdate();
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
    }

    public List<Message> findByUserId(int userId) {
        String sql = "SELECT * FROM message WHERE user_id = ? ORDER BY create_time DESC";
        List<Message> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return list;
    }

    public List<Message> findAll() {
        String sql = "SELECT * FROM message ORDER BY (unread_user_replies > 0) DESC, create_time DESC";
        List<Message> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return list;
    }

    private Message mapRow(ResultSet rs) throws SQLException {
        Message m = new Message();
        m.setId(rs.getInt("id"));
        m.setUserId(rs.getInt("user_id"));
        m.setUsername(rs.getString("username"));
        m.setContent(rs.getString("content"));
        m.setConversation(rs.getString("conversation"));
        try { m.setIsUserRead(rs.getInt("is_user_read")); } catch (SQLException e) {}
        try { m.setIsAdminRead(rs.getInt("is_admin_read")); } catch (SQLException e) {}
        try { m.setUnreadAdminReplies(rs.getInt("unread_admin_replies")); } catch (SQLException e) {}
        try { m.setUnreadUserReplies(rs.getInt("unread_user_replies")); } catch (SQLException e) {}
        m.setCreateTime(rs.getTimestamp("create_time"));
        return m;
    }
}
