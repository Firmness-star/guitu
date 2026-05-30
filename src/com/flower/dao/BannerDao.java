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
        Connection conn = null; PreparedStatement pstmt = null; ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                Banner b = new Banner();
                b.setId(rs.getInt("id"));
                b.setImgUrl(rs.getString("img_url"));
                b.setProductId(rs.getInt("pro_id"));
                list.add(b);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(conn, pstmt, rs); }
        return list;
    }

    public boolean save(Banner b) {
        String sql = "INSERT INTO banner_info (img_url, pro_id) VALUES (?, ?)";
        Connection conn = null; PreparedStatement pstmt = null;
        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, b.getImgUrl());
            pstmt.setInt(2, b.getProductId());
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(conn, pstmt); }
        return false;
    }

    public boolean deleteById(int id) {
        String sql = "DELETE FROM banner_info WHERE id = ?";
        Connection conn = null; PreparedStatement pstmt = null;
        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(conn, pstmt); }
        return false;
    }
}
