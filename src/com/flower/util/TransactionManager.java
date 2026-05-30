package com.flower.util;

import java.sql.Connection;
import java.sql.SQLException;

/**
 * 事务管理器
 * 基于 ThreadLocal 实现数据库连接与当前线程的绑定，确保在同一事务中多个操作使用同一个连接
 */
public class TransactionManager {

    private static final ThreadLocal<Connection> CONNECTION_HOLDER = new ThreadLocal<>();

    /**
     * 获取当前线程绑定的数据库连接
     *
     * @return 数据库连接对象
     * @throws SQLException 获取连接失败时抛出异常
     */
    public static Connection getConnection() throws SQLException {
        Connection conn = CONNECTION_HOLDER.get();
        if (conn == null) {
            conn = DBUtil.getConnection();
            CONNECTION_HOLDER.set(conn);
        }
        return conn;
    }

    /**
     * 开启事务，关闭自动提交并设置隔离级别
     *
     * @throws SQLException 开启事务失败时抛出异常
     */
    public static void beginTransaction() throws SQLException {
        Connection conn = getConnection();
        if (conn != null && !conn.isClosed()) {
            conn.setAutoCommit(false);
            conn.setTransactionIsolation(Connection.TRANSACTION_READ_COMMITTED);
        }
    }

    /**
     * 提交当前事务并关闭连接
     *
     * @throws SQLException 提交事务失败时抛出异常
     */
    public static void commit() throws SQLException {
        Connection conn = CONNECTION_HOLDER.get();
        if (conn != null && !conn.isClosed()) {
            try {
                conn.commit();
            } catch (SQLException e) {
                throw new SQLException("提交事务失败", e);
            } finally {
                closeConnection();
            }
        }
    }

    /**
     * 回滚当前事务并关闭连接
     *
     * @throws SQLException 回滚事务失败时抛出异常
     */
    public static void rollback() throws SQLException {
        Connection conn = CONNECTION_HOLDER.get();
        if (conn != null && !conn.isClosed()) {
            try {
                conn.rollback();
            } catch (SQLException e) {
                throw new SQLException("回滚事务失败", e);
            } finally {
                closeConnection();
            }
        }
    }

    /**
     * 关闭当前线程的数据库连接并移除 ThreadLocal 绑定
     *
     * @throws SQLException 关闭连接失败时抛出异常
     */
    public static void closeConnection() throws SQLException {
        Connection conn = CONNECTION_HOLDER.get();
        if (conn != null && !conn.isClosed()) {
            try {
                // 恢复连接的自动提交状态，以便连接归还池后可以正常使用
                if (!conn.getAutoCommit()) {
                    conn.setAutoCommit(true);
                }
            } finally {
                conn.close();
                CONNECTION_HOLDER.remove();
            }
        } else {
            CONNECTION_HOLDER.remove();
        }
    }

    /**
     * 检查当前线程是否处于活跃的事务状态中
     *
     * @return 若存在未关闭且非自动提交的连接则返回 true，否则返回 false
     */
    public static boolean isInTransaction() {
        Connection conn = CONNECTION_HOLDER.get();
        if (conn != null) {
            try {
                return !conn.isClosed() && !conn.getAutoCommit();
            } catch (SQLException e) {
                return false;
            }
        }
        return false;
    }
}