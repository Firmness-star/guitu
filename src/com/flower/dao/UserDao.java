package com.flower.dao;
import com.flower.entity.User;
import com.flower.util.DBUtil;
import com.flower.util.MD5Util;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 用户数据访问对象
 * 负责处理用户信息的查询、注册、状态管理及权限维护
 */
public class UserDao {

    /**
     * 根据用户名查询用户信息
     *
     * @param username 用户名
     * @return 用户对象，若不存在则返回 null
     */
    public User findByUsername(String username) {
        if (username == null || username.trim().isEmpty()) {
            return null;
        }

        String sql = "SELECT * FROM user WHERE username = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                return mapResultSetToUser(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }
        return null;
    }

    /**
     * 根据用户 ID 查询用户信息
     *
     * @param id 用户 ID
     * @return 用户对象，若不存在或参数无效则返回 null
     */
    public User findById(int id) {
        if (id <= 0) {
            return null;
        }

        String sql = "SELECT * FROM user WHERE id = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                return mapResultSetToUser(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }
        return null;
    }

    /**
     * 根据用户名和密码（MD5 加密后）验证用户身份
     *
     * @param username 用户名
     * @param password 原始密码
     * @return 验证通过返回用户对象，否则返回 null
     */
    public User findByUsernameAndPassword(String username, String password) {
        if (username == null || username.trim().isEmpty() || 
            password == null || password.isEmpty()) {
            return null;
        }

        String sql = "SELECT * FROM user WHERE username = ? AND pass = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            pstmt.setString(2, MD5Util.encrypt(password));
            rs = pstmt.executeQuery();

            if (rs.next()) {
                return mapResultSetToUser(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }
        return null;
    }

    /**
     * 保存新用户信息，密码会自动进行 MD5 加密
     *
     * @param user 待保存的用户对象
     * @return 保存成功返回 true，否则返回 false
     */
    public boolean save(User user) {
        if (user == null) {
            return false;
        }

        String sql = "INSERT INTO user (username, pass, tel, email, gender, state, role, jf, create_time) VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())";
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, user.getUsername());
            pstmt.setString(2, MD5Util.encrypt(user.getPass()));
            pstmt.setString(3, user.getTel());
            pstmt.setString(4, user.getEmail());
            pstmt.setString(5, user.getGender() != null ? user.getGender() : "未知");
            pstmt.setString(6, user.getState() != null ? user.getState() : "可用");
            pstmt.setString(7, user.getRole() != null ? user.getRole() : "用户");
            pstmt.setInt(8, user.getJf());

            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt);
        }
        return false;
    }

    /**
     * 检查指定用户名是否已被注册
     *
     * @param username 待检查的用户名
     * @return 若用户名已存在返回 true，否则返回 false
     */
    public boolean isUsernameExists(String username) {
        if (username == null || username.trim().isEmpty()) {
            return false;
        }

        String sql = "SELECT COUNT(*) FROM user WHERE username = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }
        return false;
    }

    public boolean isTelExists(String tel) {
        if (tel == null || tel.trim().isEmpty()) return false;
        String sql = "SELECT COUNT(*) FROM user WHERE tel = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, tel.trim());
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean isTelUsedByOther(String tel, int excludeUserId) {
        if (tel == null || tel.trim().isEmpty()) return false;
        String sql = "SELECT COUNT(*) FROM user WHERE tel = ? AND id != ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, tel.trim());
            pstmt.setInt(2, excludeUserId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean isEmailExists(String email) {
        if (email == null || email.trim().isEmpty()) return false;
        String sql = "SELECT COUNT(*) FROM user WHERE email = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, email.trim());
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean isEmailUsedByOther(String email, int excludeUserId) {
        if (email == null || email.trim().isEmpty()) return false;
        String sql = "SELECT COUNT(*) FROM user WHERE email = ? AND id != ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, email.trim());
            pstmt.setInt(2, excludeUserId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean deleteById(int userId) {
        if (userId <= 0) return false;
        String sql = "DELETE FROM user WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    /**
     * 更新用户的最后登录时间为当前时间
     *
     * @param username 用户名
     * @return 更新成功返回 true，否则返回 false
     */
    public boolean updateLastLoginTime(String username) {
        if (username == null || username.trim().isEmpty()) {
            return false;
        }

        String sql = "UPDATE user SET last_login_time = NOW() WHERE username = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt);
        }
        return false;
    }

    /**
     * 更新用户的账户状态（如：可用、禁用）
     *
     * @param userId 用户 ID
     * @param state  新的状态字符串
     * @return 更新成功返回 true，否则返回 false
     */
    public boolean updateUserState(int userId, String state) {
        if (userId <= 0 || state == null) {
            return false;
        }

        String sql = "UPDATE user SET state = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, state);
            pstmt.setInt(2, userId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt);
        }
        return false;
    }

    /**
     * 更新用户的角色权限（如：用户、商家、管理员）
     *
     * @param userId 用户 ID
     * @param role   新的角色字符串
     * @return 更新成功返回 true，否则返回 false
     */
    public boolean updateUserRole(int userId, String role) {
        if (userId <= 0 || role == null) {
            return false;
        }

        String sql = "UPDATE user SET role = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, role);
            pstmt.setInt(2, userId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt);
        }
        return false;
    }

    /**
     * 更新用户的登录密码（新密码会进行 MD5 加密）
     *
     * @param userId      用户 ID
     * @param newPassword 新的原始密码
     * @return 更新成功返回 true，否则返回 false
     */
    public boolean updatePassword(int userId, String newPassword) {
        if (userId <= 0 || newPassword == null || newPassword.isEmpty()) {
            return false;
        }

        String sql = "UPDATE user SET pass = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, MD5Util.encrypt(newPassword));
            pstmt.setInt(2, userId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt);
        }
        return false;
    }

    /**
     * 更新用户的绑定手机号和邮箱地址
     *
     * @param userId 用户 ID
     * @param tel    新的手机号
     * @param email  新的邮箱地址
     * @return 更新成功返回 true，否则返回 false
     */
    public boolean updateUserInfo(int userId, String tel, String email) {
        if (userId <= 0) {
            return false;
        }

        String sql = "UPDATE user SET tel = ?, email = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, tel);
            pstmt.setString(2, email);
            pstmt.setInt(3, userId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt);
        }
        return false;
    }

    public boolean updateGender(int userId, String gender) {
        if (userId <= 0 || gender == null) return false;
        String sql = "UPDATE user SET gender = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, gender);
            pstmt.setInt(2, userId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt);
        }
        return false;
    }

    public boolean updateAvatar(int userId, String avatarPath) {
        if (userId <= 0) return false;
        String sql = "UPDATE user SET avatar = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, avatarPath);
            pstmt.setInt(2, userId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt);
        }
        return false;
    }

    public boolean addJf(int userId, int amount) {
        return addJf(userId, amount, null);
    }

    public boolean addJf(int userId, int amount, Connection conn) {
        if (userId <= 0 || amount <= 0) return false;
        String sql = "UPDATE user SET jf = jf + ? WHERE id = ?";
        boolean ownConn = (conn == null);
        PreparedStatement pstmt = null;
        try {
            if (ownConn) conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, amount);
            pstmt.setInt(2, userId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            if (pstmt != null) { try { pstmt.close(); } catch (SQLException e) {} }
            if (ownConn && conn != null) { try { conn.close(); } catch (SQLException e) {} }
        }
        return false;
    }

    public boolean deductJf(int userId, int amount) {
        return deductJf(userId, amount, null);
    }

    public boolean deductJf(int userId, int amount, Connection conn) {
        if (userId <= 0 || amount <= 0) return false;
        String sql = "UPDATE user SET jf = jf - ? WHERE id = ? AND jf >= ?";
        boolean ownConn = (conn == null);
        PreparedStatement pstmt = null;
        try {
            if (ownConn) conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, amount);
            pstmt.setInt(2, userId);
            pstmt.setInt(3, amount);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            if (pstmt != null) { try { pstmt.close(); } catch (SQLException e) {} }
            if (ownConn && conn != null) { try { conn.close(); } catch (SQLException e) {} }
        }
        return false;
    }

    public int getJf(int userId) {
        if (userId <= 0) return 0;
        String sql = "SELECT jf FROM user WHERE id = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            if (rs.next()) return rs.getInt("jf");
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }
        return 0;
    }

    public User findByTel(String tel) {
        if (tel == null || tel.isEmpty()) return null;
        String sql = "SELECT * FROM user WHERE tel = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, tel);
            rs = pstmt.executeQuery();
            if (rs.next()) return mapResultSetToUser(rs);
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }
        return null;
    }

    public User findByEmail(String email) {
        if (email == null || email.isEmpty()) return null;
        String sql = "SELECT * FROM user WHERE email = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, email);
            rs = pstmt.executeQuery();
            if (rs.next()) return mapResultSetToUser(rs);
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }
        return null;
    }

    /**
     * 记录用户登录日志到数据库
     *
     * @param userId   用户 ID
     * @param username 用户名
     * @param ip       登录 IP 地址
     * @param userAgent 用户代理信息
     * @return 记录成功返回 true，否则返回 false
     */
    public boolean recordLoginLog(int userId, String username, String ip, String userAgent) {
        if (userId <= 0 || username == null) {
            return false;
        }

        String sql = "INSERT INTO login_log (user_id, username, login_ip, user_agent, login_time) VALUES (?, ?, ?, ?, NOW())";
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            pstmt.setString(2, username);
            pstmt.setString(3, ip != null ? ip : "未知");
            pstmt.setString(4, userAgent != null ? userAgent : "未知");
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt);
        }
        return false;
    }

    /**
     * 查询用户的最近登录日志
     *
     * @param userId 用户 ID
     * @param limit  返回记录数量限制
     * @return 登录日志列表，按时间降序排列
     */
    public List<java.util.Map<String, Object>> getRecentLoginLogs(int userId, int limit) {
        List<java.util.Map<String, Object>> logs = new ArrayList<>();
        
        if (userId <= 0 || limit <= 0) {
            return logs;
        }

        String sql = "SELECT login_ip, user_agent, login_time FROM login_log WHERE user_id = ? ORDER BY login_time DESC LIMIT ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            pstmt.setInt(2, limit);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                java.util.Map<String, Object> log = new java.util.HashMap<>();
                log.put("loginIp", rs.getString("login_ip"));
                log.put("userAgent", rs.getString("user_agent"));
                log.put("loginTime", rs.getTimestamp("login_time"));
                logs.add(log);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }
        return logs;
    }

    /**
     * 查询系统中的所有用户列表
     *
     * @return 用户列表，按创建时间降序排列
     */
    public List<User> findAllUsers() {
        String sql = "SELECT * FROM user ORDER BY create_time DESC";
        List<User> users = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                users.add(mapResultSetToUser(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }
        return users;
    }

    /**
     * 根据角色筛选用户列表
     *
     * @param role 角色名称
     * @return 对应用户角色的列表
     */
    public List<User> findUsersByRole(String role) {
        if (role == null || role.isEmpty()) {
            return findAllUsers();
        }

        String sql = "SELECT * FROM user WHERE role = ? ORDER BY create_time DESC";
        List<User> users = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, role);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                users.add(mapResultSetToUser(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }
        return users;
    }

    /**
     * 将 ResultSet 结果集映射为 User 实体对象
     *
     * @param rs 数据库查询结果集
     * @return User 实体对象
     * @throws SQLException SQL 异常
     */
    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setUsername(rs.getString("username"));
        user.setPass(rs.getString("pass"));
        user.setGender(rs.getString("gender"));
        user.setTel(rs.getString("tel"));
        user.setEmail(rs.getString("email"));
        user.setState(rs.getString("state"));
        user.setRole(rs.getString("role") != null ? rs.getString("role") : "用户");
        user.setJf(rs.getInt("jf"));
        try { user.setAvatar(rs.getString("avatar")); } catch (SQLException e) { /* avatar column may not exist yet */ }
        user.setCreateTime(rs.getTimestamp("create_time"));
        user.setLastLoginTime(rs.getTimestamp("last_login_time"));
        return user;
    }
}