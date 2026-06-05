package com.flower.dao;

import com.flower.entity.Sp;
import com.flower.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SpDao {

    public List<Sp> findAll() {
        String sql = "SELECT * FROM product ORDER BY id ASC";
        List<Sp> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) list.add(mapResultSetToSp(rs));
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return list;
    }

    public Sp findById(int id) {
        if (id <= 0) return null;
        String sql = "SELECT * FROM product WHERE id = ? AND status = 1";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return mapResultSetToSp(rs);
            }
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return null;
    }

    /**
     * 根据 ID 查询商品（不限状态，管理后台使用）
     */
    public Sp findByIdAnyStatus(int id) {
        if (id <= 0) return null;
        String sql = "SELECT * FROM product WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return mapResultSetToSp(rs);
            }
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return null;
    }

    public Sp findById(int id, Connection conn) throws SQLException {
        if (id <= 0) return null;
        String sql = "SELECT * FROM product WHERE id = ? AND status = 1";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return mapResultSetToSp(rs);
            }
        }
        return null;
    }

    public List<Sp> findByCategory(int categoryId) {
        if (categoryId <= 0) return new ArrayList<>();
        String sql = "SELECT * FROM product WHERE category_id = ? AND status = 1";
        List<Sp> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, categoryId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) list.add(mapResultSetToSp(rs));
            }
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return list;
    }

    public List<Sp> findByParentCategory(int parentCategoryId) {
        if (parentCategoryId <= 0) return new ArrayList<>();
        String sql = "SELECT p.* FROM product p INNER JOIN category c ON p.category_id = c.id WHERE c.parent_id = ? AND p.status = 1 ORDER BY p.id ASC";
        List<Sp> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, parentCategoryId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) list.add(mapResultSetToSp(rs));
            }
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return list;
    }

    public List<Sp> search(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) return new ArrayList<>();
        String sql = "SELECT * FROM product WHERE (name LIKE ? OR intro LIKE ?) AND status = 1";
        List<Sp> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            String p = "%" + keyword.trim() + "%";
            pstmt.setString(1, p);
            pstmt.setString(2, p);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) list.add(mapResultSetToSp(rs));
            }
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return list;
    }

    public boolean save(Sp sp) {
        if (sp == null) return false;
        String sql = "INSERT INTO product (name, intro, price, stock, pic, category_id, sales, status, create_time) VALUES (?,?,?,?,?,?,?,?,NOW())";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, sp.getName());
            pstmt.setString(2, sp.getIntro());
            pstmt.setDouble(3, sp.getPrice());
            pstmt.setInt(4, sp.getStock());
            pstmt.setString(5, sp.getPic());
            pstmt.setInt(6, sp.getCategoryId());
            pstmt.setInt(7, sp.getSales());
            pstmt.setInt(8, sp.getStatus());
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return false;
    }

    public boolean update(Sp sp) {
        if (sp == null || sp.getId() <= 0) return false;
        String sql = "UPDATE product SET name = ?, intro = ?, price = ?, stock = ?, pic = ?, category_id = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, sp.getName());
            pstmt.setString(2, sp.getIntro());
            pstmt.setDouble(3, sp.getPrice());
            pstmt.setInt(4, sp.getStock());
            pstmt.setString(5, sp.getPic());
            pstmt.setInt(6, sp.getCategoryId());
            pstmt.setInt(7, sp.getId());
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return false;
    }

    public boolean updateStock(int productId, int newStock) {
        if (productId <= 0 || newStock < 0) return false;
        String sql = "UPDATE product SET stock = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, newStock);
            pstmt.setInt(2, productId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return false;
    }

    public boolean updateStock(int productId, int newStock, Connection conn) throws SQLException {
        if (productId <= 0 || newStock < 0) return false;
        String sql = "UPDATE product SET stock = ? WHERE id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, newStock);
            pstmt.setInt(2, productId);
            return pstmt.executeUpdate() > 0;
        }
    }

    public boolean updateStatus(int productId, int status) {
        if (productId <= 0) return false;
        String sql = "UPDATE product SET status = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, status);
            pstmt.setInt(2, productId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return false;
    }

    public boolean deleteById(int productId) {
        if (productId <= 0) return false;
        String sql = "DELETE FROM product WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, productId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return false;
    }

    public boolean isEmpty() {
        String sql = "SELECT COUNT(*) FROM product";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) return rs.getInt(1) == 0;
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return false;
    }

    public int countByCategory(int categoryId) {
        if (categoryId <= 0) return 0;
        String sql = "SELECT COUNT(*) FROM product WHERE category_id = ? OR category_id IN (SELECT id FROM category WHERE parent_id = ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, categoryId);
            pstmt.setInt(2, categoryId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return 0;
    }

    public boolean batchUpdateStatus(List<Integer> ids, int status) {
        if (ids == null || ids.isEmpty()) return false;
        String sql = "UPDATE product SET status = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            int count = 0;
            for (int id : ids) {
                pstmt.setInt(1, status);
                pstmt.setInt(2, id);
                count += pstmt.executeUpdate();
            }
            return count > 0;
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return false;
    }

    private Sp mapResultSetToSp(ResultSet rs) throws SQLException {
        Sp sp = new Sp();
        sp.setId(rs.getInt("id"));
        sp.setName(rs.getString("name"));
        sp.setIntro(rs.getString("intro"));
        sp.setPrice(rs.getDouble("price"));
        sp.setStock(rs.getInt("stock"));
        sp.setPic(rs.getString("pic"));
        sp.setCategoryId(rs.getInt("category_id"));
        sp.setSales(rs.getInt("sales"));
        sp.setCreateTime(rs.getTimestamp("create_time"));
        sp.setStatus(rs.getInt("status"));
        return sp;
    }
}
