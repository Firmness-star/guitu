package com.flower.dao;

import com.flower.entity.FavoriteItem;
import com.flower.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FavoriteDao {

    /**
     * 添加收藏（重复收藏自动忽略）
     */
    public boolean addFavorite(int userId, int productId) {
        if (userId <= 0 || productId <= 0) return false;
        String sql = "INSERT IGNORE INTO favorite (user_id, product_id) VALUES (?,?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setInt(2, productId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[FavDAO] " + e.getMessage());
        }
        return false;
    }

    /**
     * 取消收藏
     */
    public boolean removeFavorite(int userId, int productId) {
        if (userId <= 0 || productId <= 0) return false;
        String sql = "DELETE FROM favorite WHERE user_id = ? AND product_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setInt(2, productId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[FavDAO] " + e.getMessage());
        }
        return false;
    }

    /**
     * 查询用户的所有收藏（带商品详情）
     */
    public List<FavoriteItem> findByUserId(int userId) {
        List<FavoriteItem> list = new ArrayList<>();
        if (userId <= 0) return list;
        String sql = "SELECT f.product_id, f.create_time, p.name, p.pic, p.price " +
                     "FROM favorite f JOIN product p ON f.product_id = p.id " +
                     "WHERE f.user_id = ? ORDER BY f.create_time DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    FavoriteItem item = new FavoriteItem();
                    item.setProductId(rs.getInt("product_id"));
                    item.setProductName(rs.getString("name"));
                    item.setProductPic(rs.getString("pic"));
                    item.setProductPrice(rs.getDouble("price"));
                    Timestamp ts = rs.getTimestamp("create_time");
                    item.setCreateTime(ts != null ? ts.toString() : "");
                    list.add(item);
                }
            }
        } catch (SQLException e) {
            System.err.println("[FavDAO] " + e.getMessage());
        }
        return list;
    }

    /**
     * 判断用户是否已收藏某商品
     */
    public boolean isFavorited(int userId, int productId) {
        if (userId <= 0 || productId <= 0) return false;
        String sql = "SELECT 1 FROM favorite WHERE user_id = ? AND product_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setInt(2, productId);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            System.err.println("[FavDAO] " + e.getMessage());
        }
        return false;
    }

    /**
     * 获取用户收藏总数
     */
    public int countByUserId(int userId) {
        if (userId <= 0) return 0;
        String sql = "SELECT COUNT(*) FROM favorite WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[FavDAO] " + e.getMessage());
        }
        return 0;
    }
}
