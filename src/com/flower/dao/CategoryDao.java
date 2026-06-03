package com.flower.dao;

import com.flower.entity.Category;
import com.flower.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CategoryDao {

    public List<Category> findAll() {
        String sql = "SELECT * FROM category ORDER BY parent_id, id";
        List<Category> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) list.add(mapResultSetToCategory(rs));
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return list;
    }

    public List<Category> findParentCategories() {
        String sql = "SELECT * FROM category WHERE parent_id = 0 ORDER BY id";
        List<Category> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) list.add(mapResultSetToCategory(rs));
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return list;
    }

    public List<Category> findChildCategories(int parentId) {
        if (parentId <= 0) return new ArrayList<>();
        String sql = "SELECT * FROM category WHERE parent_id = ? ORDER BY id";
        List<Category> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, parentId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) list.add(mapResultSetToCategory(rs));
            }
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return list;
    }

    public Category findById(int id) {
        if (id <= 0) return null;
        String sql = "SELECT * FROM category WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return mapResultSetToCategory(rs);
            }
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return null;
    }

    public boolean save(Category category) {
        if (category == null) return false;
        String sql = "INSERT INTO category (name, parent_id, description) VALUES (?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, category.getName());
            pstmt.setInt(2, category.getParentId());
            pstmt.setString(3, category.getDescription());
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return false;
    }

    public boolean isEmpty() {
        String sql = "SELECT COUNT(*) FROM category";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) return rs.getInt(1) == 0;
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return false;
    }

    public boolean deleteById(int id) {
        if (id <= 0) return false;
        String sql = "DELETE FROM category WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            if (e.getMessage() == null || !e.getMessage().contains("foreign key")) {
                System.err.println("[DAO] " + e.getMessage());
            }
        }
        return false;
    }

    public List<Category> findAllCategories() { return findAll(); }

    public boolean update(Category category) {
        if (category == null || category.getId() <= 0) return false;
        String sql = "UPDATE category SET name = ?, parent_id = ?, description = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, category.getName());
            pstmt.setInt(2, category.getParentId());
            pstmt.setString(3, category.getDescription());
            pstmt.setInt(4, category.getId());
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return false;
    }

    public boolean updateParent(int id, int newParentId) {
        if (id <= 0) return false;
        String sql = "UPDATE category SET parent_id = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, newParentId);
            pstmt.setInt(2, id);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return false;
    }

    private Category mapResultSetToCategory(ResultSet rs) throws SQLException {
        Category category = new Category();
        category.setId(rs.getInt("id"));
        category.setName(rs.getString("name"));
        category.setParentId(rs.getInt("parent_id"));
        category.setDescription(rs.getString("description"));
        return category;
    }
}
