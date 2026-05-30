package com.flower.dao;

import com.flower.entity.Sp;
import com.flower.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 商品数据访问对象
 * 负责处理商品信息的增删改查、库存管理及分类检索等功能
 */
public class SpDao {

    /**
     * 查询所有上架的商品列表
     *
     * @return 商品列表，按 ID 升序排列
     */
    public List<Sp> findAll() {
        String sql = "SELECT * FROM product ORDER BY id ASC";
        List<Sp> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                list.add(mapResultSetToSp(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }
        return list;
    }

    /**
     * 根据商品 ID 查询单个商品信息（仅限上架商品）
     *
     * @param id 商品 ID
     * @return 商品对象，若不存在或未上架则返回 null
     */
    public Sp findById(int id) {
        if (id <= 0) {
            return null;
        }

        String sql = "SELECT * FROM product WHERE id = ? AND status = 1";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                return mapResultSetToSp(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }
        return null;
    }

    /**
     * 在指定数据库连接中查询商品详情（用于事务环境）
     *
     * @param id   商品 ID
     * @param conn 数据库连接对象
     * @return 商品对象，若不存在或未上架则返回 null
     * @throws SQLException SQL 异常
     */
    public Sp findById(int id, Connection conn) throws SQLException {
        if (id <= 0) {
            return null;
        }

        String sql = "SELECT * FROM product WHERE id = ? AND status = 1";
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                return mapResultSetToSp(rs);
            }
        } finally {
            if (rs != null) {
                rs.close();
            }
            if (pstmt != null) {
                pstmt.close();
            }
        }
        return null;
    }

    /**
     * 根据分类 ID 查询该分类下的所有上架商品
     *
     * @param categoryId 分类 ID
     * @return 对应的商品列表
     */
    public List<Sp> findByCategory(int categoryId) {
        if (categoryId <= 0) {
            return new ArrayList<>();
        }

        String sql = "SELECT * FROM product WHERE category_id = ? AND status = 1";
        List<Sp> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, categoryId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                list.add(mapResultSetToSp(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }
        return list;
    }

    /**
     * 根据父级分类 ID 查询其子分类下的所有上架商品
     *
     * @param parentCategoryId 父级分类 ID
     * @return 对应的商品列表
     */
    public List<Sp> findByParentCategory(int parentCategoryId) {
        if (parentCategoryId <= 0) {
            return new ArrayList<>();
        }

        String sql = "SELECT p.* FROM product p " +
                     "INNER JOIN category c ON p.category_id = c.id " +
                     "WHERE c.parent_id = ? AND p.status = 1 " +
                     "ORDER BY p.id ASC";
        List<Sp> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, parentCategoryId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                list.add(mapResultSetToSp(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }
        return list;
    }

    /**
     * 根据关键词搜索商品（支持名称和简介模糊匹配）
     *
     * @param keyword 搜索关键词
     * @return 匹配的商品列表
     */
    public List<Sp> search(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return new ArrayList<>();
        }

        String sql = "SELECT * FROM product WHERE (name LIKE ? OR intro LIKE ?) AND status = 1";
        List<Sp> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            String searchPattern = "%" + keyword.trim() + "%";
            pstmt.setString(1, searchPattern);
            pstmt.setString(2, searchPattern);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                list.add(mapResultSetToSp(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }
        return list;
    }

    /**
     * 保存新商品信息到数据库
     *
     * @param sp 待保存的商品对象
     * @return 保存成功返回 true，否则返回 false
     */
    public boolean save(Sp sp) {
        if (sp == null) {
            return false;
        }

        String sql = "INSERT INTO product (name, intro, price, stock, pic, category_id, sales, status, create_time) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())";
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);

            pstmt.setString(1, sp.getName());
            pstmt.setString(2, sp.getIntro());
            pstmt.setDouble(3, sp.getPrice());
            pstmt.setInt(4, sp.getStock());
            pstmt.setString(5, sp.getPic());
            pstmt.setInt(6, sp.getCategoryId());
            pstmt.setInt(7, sp.getSales());
            pstmt.setInt(8, sp.getStatus());

            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, null);
        }
        return false;
    }

    /**
     * 更新商品的基本信息（不包含库存和状态）
     *
     * @param sp 包含更新后信息的商品对象
     * @return 更新成功返回 true，否则返回 false
     */
    public boolean update(Sp sp) {
        if (sp == null || sp.getId() <= 0) {
            return false;
        }

        String sql = "UPDATE product SET name = ?, intro = ?, price = ?, stock = ?, pic = ?, category_id = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);

            pstmt.setString(1, sp.getName());
            pstmt.setString(2, sp.getIntro());
            pstmt.setDouble(3, sp.getPrice());
            pstmt.setInt(4, sp.getStock());
            pstmt.setString(5, sp.getPic());
            pstmt.setInt(6, sp.getCategoryId());
            pstmt.setInt(7, sp.getId());

            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, null);
        }
        return false;
    }

    /**
     * 更新指定商品的库存数量
     *
     * @param productId 商品 ID
     * @param newStock  新的库存数量
     * @return 更新成功返回 true，否则返回 false
     */
    public boolean updateStock(int productId, int newStock) {
        if (productId <= 0 || newStock < 0) {
            return false;
        }

        String sql = "UPDATE product SET stock = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, newStock);
            pstmt.setInt(2, productId);

            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, null);
        }
        return false;
    }

    /**
     * 在指定数据库连接中更新商品库存（用于事务环境）
     *
     * @param productId 商品 ID
     * @param newStock  新的库存数量
     * @param conn      数据库连接对象
     * @return 更新成功返回 true，否则返回 false
     * @throws SQLException SQL 异常
     */
    public boolean updateStock(int productId, int newStock, Connection conn) throws SQLException {
        if (productId <= 0 || newStock < 0) {
            return false;
        }

        String sql = "UPDATE product SET stock = ? WHERE id = ?";
        PreparedStatement pstmt = null;

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, newStock);
            pstmt.setInt(2, productId);

            return pstmt.executeUpdate() > 0;
        } finally {
            if (pstmt != null) {
                pstmt.close();
            }
        }
    }

    /**
     * 更新商品的上架/下架状态
     *
     * @param productId 商品 ID
     * @param status    状态值（1 为上架，0 为下架）
     * @return 更新成功返回 true，否则返回 false
     */
    public boolean updateStatus(int productId, int status) {
        if (productId <= 0) {
            return false;
        }

        String sql = "UPDATE product SET status = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, status);
            pstmt.setInt(2, productId);

            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, null);
        }
        return false;
    }

    /**
     * 根据 ID 删除商品记录
     *
     * @param productId 商品 ID
     * @return 删除成功返回 true，否则返回 false
     */
    public boolean deleteById(int productId) {
        if (productId <= 0) {
            return false;
        }

        String sql = "DELETE FROM product WHERE id = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, productId);

            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, null);
        }
        return false;
    }

    /**
     * 检查商品表中是否没有任何数据
     *
     * @return 若表为空则返回 true，否则返回 false
     */
    public boolean isEmpty() {
        String sql = "SELECT COUNT(*) FROM product";
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

    /**
     * 将 ResultSet 结果集映射为 Sp 实体对象
     *
     * @param rs 数据库查询结果集
     * @return Sp 实体对象
     * @throws SQLException SQL 异常
     */
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