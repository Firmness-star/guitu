package com.flower.dao;

import com.flower.entity.Address;
import com.flower.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AddressDao {

    public List<Address> findByUserId(int userId) {
        if (userId <= 0) return new ArrayList<>();
        String sql = "SELECT * FROM address WHERE user_id = ? ORDER BY is_default DESC, create_time DESC";
        List<Address> addresses = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) addresses.add(mapResultSetToAddress(rs));
            }
        } catch (SQLException e) { System.err.println("DAO ERROR: " + e.getMessage()); }
        return addresses;
    }

    public Address findById(int id) {
        if (id <= 0) return null;
        String sql = "SELECT * FROM address WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return mapResultSetToAddress(rs);
            }
        } catch (SQLException e) { System.err.println("DAO ERROR: " + e.getMessage()); }
        return null;
    }

    public Address findDefaultByUserId(int userId) {
        if (userId <= 0) return null;
        String sql = "SELECT * FROM address WHERE user_id = ? AND is_default = 1 LIMIT 1";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return mapResultSetToAddress(rs);
            }
        } catch (SQLException e) { System.err.println("DAO ERROR: " + e.getMessage()); }
        return null;
    }

    /**
     * 保存新的收货地址。若设置为默认地址，则自动取消该用户原有的默认地址
     *
     * @param address 待保存的收货地址对象
     * @return 保存成功返回 true，否则返回 false
     */
    public boolean save(Address address) {
        if (address == null || address.getUserId() <= 0) {
            return false;
        }

        String sql = "INSERT INTO address (user_id, receiver_name, receiver_phone, province, " +
                     "city, district, detail_address, is_default) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBUtil.getConnection();

            // 如果新地址是默认地址，先取消该用户其他地址的默认状态
            if (address.isDefault()) {
                cancelDefault(conn, address.getUserId());
            }

            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, address.getUserId());
            pstmt.setString(2, address.getReceiverName());
            pstmt.setString(3, address.getReceiverPhone());
            pstmt.setString(4, address.getProvince());
            pstmt.setString(5, address.getCity());
            pstmt.setString(6, address.getDistrict());
            pstmt.setString(7, address.getDetailAddress());
            pstmt.setInt(8, address.isDefault() ? 1 : 0);

            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("ERROR: " + e.getMessage());
        } finally {
            DBUtil.close(conn, pstmt);
        }
        return false;
    }

    public boolean update(Address address) {
        if (address == null || address.getId() <= 0) return false;
        String sql = "UPDATE address SET receiver_name=?,receiver_phone=?,province=?,city=?,district=?,detail_address=?,is_default=? WHERE id=?";
        Connection conn = null; PreparedStatement pstmt = null;
        try {
            conn = DBUtil.getConnection();
            Address old = findById(address.getId());
            if (old != null && address.isDefault() && !old.isDefault()) cancelDefault(conn, old.getUserId());
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, address.getReceiverName());
            pstmt.setString(2, address.getReceiverPhone());
            pstmt.setString(3, address.getProvince());
            pstmt.setString(4, address.getCity());
            pstmt.setString(5, address.getDistrict());
            pstmt.setString(6, address.getDetailAddress());
            pstmt.setInt(7, address.isDefault() ? 1 : 0);
            pstmt.setInt(8, address.getId());

            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("ERROR: " + e.getMessage());
        } finally {
            DBUtil.close(conn, pstmt);
        }
        return false;
    }

    /**
     * 删除指定的收货地址（需校验地址归属权）
     *
     * @param id     地址 ID
     * @param userId 用户 ID，确保只能删除自己的地址
     * @return 删除成功返回 true，否则返回 false
     */
    public boolean delete(int id, int userId) {
        if (id <= 0 || userId <= 0) {
            return false;
        }

        String sql = "DELETE FROM address WHERE id = ? AND user_id = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            pstmt.setInt(2, userId);

            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("ERROR: " + e.getMessage());
        } finally {
            DBUtil.close(conn, pstmt);
        }
        return false;
    }

    /**
     * 将指定地址设置为默认地址，并取消该用户其他地址的默认状态
     *
     * @param id     地址 ID
     * @param userId 用户 ID
     * @return 设置成功返回 true，否则返回 false
     */
    public boolean setDefault(int id, int userId) {
        if (id <= 0 || userId <= 0) {
            return false;
        }

        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DBUtil.getConnection();
            
            // 先取消该用户所有地址的默认状态
            cancelDefault(conn, userId);

            String sql = "UPDATE address SET is_default = 1 WHERE id = ? AND user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            pstmt.setInt(2, userId);

            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("ERROR: " + e.getMessage());
        } finally {
            DBUtil.close(conn, pstmt);
        }
        return false;
    }

    /**
     * 取消指定用户所有地址的默认状态
     *
     * @param conn   数据库连接对象
     * @param userId 用户 ID
     * @throws SQLException SQL 异常
     */
    private void cancelDefault(Connection conn, int userId) throws SQLException {
        String sql = "UPDATE address SET is_default = 0 WHERE user_id = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, userId);
        pstmt.executeUpdate();
        pstmt.close();
    }

    /**
     * 将 ResultSet 结果集映射为 Address 实体对象
     *
     * @param rs 数据库查询结果集
     * @return Address 实体对象
     * @throws SQLException SQL 异常
     */
    private Address mapResultSetToAddress(ResultSet rs) throws SQLException {
        Address address = new Address();
        address.setId(rs.getInt("id"));
        address.setUserId(rs.getInt("user_id"));
        address.setReceiverName(rs.getString("receiver_name"));
        address.setReceiverPhone(rs.getString("receiver_phone"));
        address.setProvince(rs.getString("province"));
        address.setCity(rs.getString("city"));
        address.setDistrict(rs.getString("district"));
        address.setDetailAddress(rs.getString("detail_address"));
        address.setDefault(rs.getInt("is_default") == 1);
        address.setCreateTime(rs.getTimestamp("create_time"));
        address.setUpdateTime(rs.getTimestamp("update_time"));
        return address;
    }
}
