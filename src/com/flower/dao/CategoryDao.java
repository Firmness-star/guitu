package com.flower.dao;

import com.flower.entity.Category;
import com.flower.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 商品分类数据访问对象
 * 负责处理商品分类信息的查询、存储及层级关系管理
 */
public class CategoryDao {

    /**
     * 查询所有商品分类信息，按父级 ID 和自身 ID 排序
     *
     * @return 包含所有分类对象的列表
     */
    public List<Category> findAll() {
        String sql = "SELECT * FROM category ORDER BY parent_id, id";
        List<Category> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                list.add(mapResultSetToCategory(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }
        return list;
    }

    /**
     * 查询所有一级分类（父级 ID 为 0 的分类）
     *
     * @return 一级分类列表
     */
    public List<Category> findParentCategories() {
        String sql = "SELECT * FROM category WHERE parent_id = 0 ORDER BY id";
        List<Category> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                list.add(mapResultSetToCategory(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }
        return list;
    }

    /**
     * 根据父级 ID 查询指定的二级分类列表
     *
     * @param parentId 父级分类的 ID
     * @return 对应的子分类列表，若参数无效则返回空列表
     */
    public List<Category> findChildCategories(int parentId) {
        if (parentId <= 0) {
            return new ArrayList<>();
        }

        String sql = "SELECT * FROM category WHERE parent_id = ? ORDER BY id";
        List<Category> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, parentId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                list.add(mapResultSetToCategory(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }
        return list;
    }

    /**
     * 根据分类 ID 查询单个分类详情
     *
     * @param id 分类 ID
     * @return 分类对象，若不存在或参数无效则返回 null
     */
    public Category findById(int id) {
        if (id <= 0) {
            return null;
        }

        String sql = "SELECT * FROM category WHERE id = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                return mapResultSetToCategory(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }
        return null;
    }

    /**
     * 保存新的商品分类信息
     *
     * @param category 待保存的分类对象
     * @return 保存成功返回 true，否则返回 false
     */
    public boolean save(Category category) {
        if (category == null) {
            return false;
        }

        String sql = "INSERT INTO category (name, parent_id, description) VALUES (?, ?, ?)";
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, category.getName());
            pstmt.setInt(2, category.getParentId());
            pstmt.setString(3, category.getDescription());

            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, null);
        }
        return false;
    }

    /**
     * 检查数据库中是否没有任何分类数据
     *
     * @return 若数据库为空则返回 true，否则返回 false
     */
    public boolean isEmpty() {
        String sql = "SELECT COUNT(*) FROM category";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) == 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }
        return false;
    }

    public boolean deleteById(int id) {
        if (id <= 0) return false;
        String sql = "DELETE FROM category WHERE id = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            if (e.getMessage() != null && e.getMessage().contains("foreign key")) {
            } else {
                e.printStackTrace();
            }
        } finally { DBUtil.close(conn, pstmt); }
        return false;
    }

    /**
     * 获取所有分类列表（作为 findAll 的别名方法）
     *
     * @return 包含所有分类对象的列表
     */
    public List<Category> findAllCategories() {
        return findAll();
    }

    /**
     * 将 ResultSet 结果集映射为 Category 实体对象
     *
     * @param rs 数据库查询结果集
     * @return Category 实体对象
     * @throws SQLException SQL 异常
     */
    private Category mapResultSetToCategory(ResultSet rs) throws SQLException {
        Category category = new Category();
        category.setId(rs.getInt("id"));
        category.setName(rs.getString("name"));
        category.setParentId(rs.getInt("parent_id"));
        category.setDescription(rs.getString("description"));
        return category;
    }
}
