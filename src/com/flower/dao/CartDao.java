package com.flower.dao;

import com.flower.entity.CartItem;
import com.flower.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CartDao {

    public boolean addItem(int userId, CartItem item) {
        if (userId <= 0 || item == null) return false;
        String sql = "INSERT INTO cart (user_id, product_id, quantity) VALUES (?,?,?) ON DUPLICATE KEY UPDATE quantity = quantity + VALUES(quantity)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setInt(2, item.getProductId());
            pstmt.setInt(3, item.getQuantity());
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("DAO ERROR: " + e.getMessage()); }
        return false;
    }

    public boolean updateQuantity(int userId, int productId, int quantity) {
        if (userId <= 0 || productId <= 0 || quantity < 1) return false;
        String sql = "UPDATE cart SET quantity = ? WHERE user_id = ? AND product_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, quantity);
            pstmt.setInt(2, userId);
            pstmt.setInt(3, productId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("DAO ERROR: " + e.getMessage()); }
        return false;
    }

    public boolean removeItem(int userId, int productId) {
        if (userId <= 0 || productId <= 0) return false;
        String sql = "DELETE FROM cart WHERE user_id = ? AND product_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setInt(2, productId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("DAO ERROR: " + e.getMessage()); }
        return false;
    }

    public List<CartItem> findByUserId(int userId) {
        List<CartItem> list = new ArrayList<>();
        if (userId <= 0) return list;
        String sql = "SELECT c.product_id, c.quantity, p.name, p.pic, p.price FROM cart c JOIN product p ON c.product_id = p.id WHERE c.user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    CartItem item = new CartItem();
                    item.setProductId(rs.getInt("product_id"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setProductName(rs.getString("name"));
                    item.setProductPic(rs.getString("pic"));
                    item.setProductPrice(rs.getDouble("price"));
                    item.setSelected(true);
                    list.add(item);
                }
            }
        } catch (SQLException e) { System.err.println("DAO ERROR: " + e.getMessage()); }
        return list;
    }

    public boolean clearCart(int userId) {
        if (userId <= 0) return false;
        String sql = "DELETE FROM cart WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("DAO ERROR: " + e.getMessage()); }
        return false;
    }

    public List<CartItem> mergeCart(int userId, List<CartItem> guestCart) {
        if (guestCart != null) { for (CartItem item : guestCart) addItem(userId, item); }
        return findByUserId(userId);
    }
}
