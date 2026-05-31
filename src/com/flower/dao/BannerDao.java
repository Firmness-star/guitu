package com.flower.dao;

import com.flower.entity.Banner;
import com.flower.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BannerDao {

    public List<Banner> findAll() {
        String sql = "SELECT * FROM banner_info ORDER BY id";
        List<Banner> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                Banner b = new Banner();
                b.setId(rs.getInt("id"));
                b.setImgUrl(rs.getString("img_url"));
                b.setProductId(rs.getInt("pro_id"));
                list.add(b);
            }
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return list;
    }

    public boolean save(Banner b) {
        String sql = "INSERT INTO banner_info (img_url, pro_id) VALUES (?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, b.getImgUrl());
            pstmt.setInt(2, b.getProductId());
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return false;
    }

    public boolean deleteById(int id) {
        String sql = "DELETE FROM banner_info WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("[DAO] " + e.getMessage()); }
        return false;
    }
}
