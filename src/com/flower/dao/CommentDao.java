package com.flower.dao;

import com.flower.entity.Comment;
import com.flower.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CommentDao {

    public List<Comment> findByProductId(int productId) {
        String sql = "SELECT * FROM comment WHERE product_id = ? ORDER BY create_time DESC";
        List<Comment> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, productId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Comment c = new Comment();
                    c.setId(rs.getInt("id"));
                    c.setProductId(rs.getInt("product_id"));
                    c.setUserId(rs.getInt("user_id"));
                    c.setUsername(rs.getString("username"));
                    c.setContent(rs.getString("content"));
                    c.setRating(rs.getInt("rating"));
                    c.setCreateTime(rs.getTimestamp("create_time"));
                    list.add(c);
                }
            }
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return list;
    }

    public boolean save(Comment comment) {
        if (comment == null) return false;
        String sql = "INSERT INTO comment (product_id, user_id, username, content, rating) VALUES (?,?,?,?,?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, comment.getProductId());
            pstmt.setInt(2, comment.getUserId());
            pstmt.setString(3, comment.getUsername());
            pstmt.setString(4, comment.getContent());
            pstmt.setInt(5, comment.getRating());
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return false;
    }

    public double getAvgRating(int productId) {
        String sql = "SELECT AVG(rating) FROM comment WHERE product_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, productId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getDouble(1);
            }
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return 0;
    }

    public int getCommentCount(int productId) {
        String sql = "SELECT COUNT(*) FROM comment WHERE product_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, productId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return 0;
    }
}
