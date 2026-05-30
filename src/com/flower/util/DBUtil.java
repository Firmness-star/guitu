package com.flower.util;

import com.flower.dao.C3p0Utils;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * 数据库连接工具类（C3P0桥接模式）
 *
 * <p>该类作为DAO层与连接池之间的桥梁，对外保持原有DBUtil API不变。</p>
 *
 * <p><strong>设计模式：桥接模式（Bridge Pattern）</strong>
 * 所有DAO类（UserDao、SpDao等）无需任何修改即可使用连接池。</p>
 *
 * <p><strong>关键特性：</strong>
 * <ul>
 *   <li>连接复用：通过C3P0连接池管理，避免频繁创建/销毁连接</li>
 *   <li>自动归还：close()方法实际是将连接归还连接池，而非真正关闭</li>
 * </ul>
 *
 * <p><strong>线程安全：</strong>C3P0提供的Connection是线程安全的，
 * 但建议每个线程独立获取连接，避免多线程共享同一Connection实例。</p>
 *
 * @author FlowerShop
 * @version 2.0
 * @since 2026-04-15
 * @see com.flower.dao.C3p0Utils
 */
public class DBUtil {

    /**
     * 获取数据库连接（C3P0连接池版本）
     *
     * <p>从C3P0连接池获取可用连接。如果当前无空闲连接且未达到最大连接数，
     * C3P0会自动创建新连接；如果已达上限，会阻塞等待直到有连接释放。</p>
     *
     * <p><strong>重要提示：</strong>获取的连接必须在使用后调用close()方法归还，
     * 否则会导致连接池耗尽，后续请求无法获取连接。</p>
     *
     * @return Connection 可用的数据库连接对象（来自C3P0连接池）
     * @throws SQLException 当连接池初始化失败、数据库不可达或认证失败时抛出
     */
    public static Connection getConnection() throws SQLException {
        // 委托给C3P0数据源获取连接
        // 这里得到的Connection是C3P0的代理对象，close()方法被重载为归还连接池
        return C3p0Utils.getDDs().getConnection();
    }

    /**
     * 关闭数据库资源（三参数版本）
     *
     * <p><strong>关闭顺序：</strong>遵循"先创建后关闭"原则（LIFO），
     * 先关闭ResultSet，再关闭Statement，最后关闭Connection。</p>
     *
     * <p><strong>空安全检查：</strong>每个参数都进行null检查，
     * 避免因为某个资源未初始化而导致的NullPointerException。</p>
     *
     * @param conn 数据库连接对象（可为null）
     * @param stmt Statement或PreparedStatement对象（可为null）
     * @param rs   结果集对象（可为null）
     */
    public static void close(Connection conn, Statement stmt, ResultSet rs) {
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException e) {
                // 忽略关闭异常，继续关闭其他资源
            }
        }

        if (stmt != null) {
            try {
                stmt.close();
            } catch (SQLException e) {
                // 忽略关闭异常，继续关闭其他资源
            }
        }

        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                // 忽略关闭异常
            }
        }
    }

    /**
     * 关闭数据库资源（两参数版本，无结果集）
     *
     * <p>用于执行INSERT、UPDATE、DELETE等无结果集返回的操作。
     * 内部调用三参数版本，简化DAO层代码。</p>
     *
     * @param conn 数据库连接对象（可为null）
     * @param stmt Statement或PreparedStatement对象（可为null）
     * @see #close(Connection, Statement, ResultSet)
     */
    public static void close(Connection conn, Statement stmt) {
        close(conn, stmt, null);
    }
}