package com.flower.dao;

import com.mchange.v2.c3p0.ComboPooledDataSource;
import javax.sql.DataSource;
import java.beans.PropertyVetoException;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;

/**
 * C3P0 数据库连接池工具类
 * 负责初始化和管理数据库连接池，提供数据源获取及连接测试功能
 */
public class C3p0Utils {

    private static ComboPooledDataSource dataSource = null;
    private static boolean initialized = false;
    private static String initError = null;

    // 静态代码块：在类加载时自动初始化 C3P0 连接池
    static {
        InputStream is = null;
        try {
            is = C3p0Utils.class.getClassLoader().getResourceAsStream("c3p0.properties");

            if (is == null) {
                is = C3p0Utils.class.getResourceAsStream("/c3p0.properties");
            }

            if (is == null) {
                throw new IOException("找不到c3p0.properties文件！请确认文件放在src目录");
            }

            Properties props = new Properties();
            props.load(is);

            String driver = props.getProperty("jdbc.driver", "com.mysql.cj.jdbc.Driver");
            String url = props.getProperty("jdbc.url");
            String user = props.getProperty("jdbc.user", "root");
            String password = props.getProperty("jdbc.password", "");

            int initialSize = Integer.parseInt(props.getProperty("c3p0.initialPoolSize", "5"));
            int maxSize = Integer.parseInt(props.getProperty("c3p0.maxPoolSize", "20"));
            int minSize = Integer.parseInt(props.getProperty("c3p0.minPoolSize", "5"));
            int maxIdle = Integer.parseInt(props.getProperty("c3p0.maxIdleTime", "60"));

            if (url == null || url.trim().isEmpty()) {
                throw new IllegalArgumentException("jdbc.url不能为空！");
            }

            dataSource = new ComboPooledDataSource();

            // 尝试设置驱动类，若失败则尝试兼容旧版驱动
            try {
                dataSource.setDriverClass(driver);
            } catch (PropertyVetoException e) {
                if (driver.contains("cj")) {
                    dataSource.setDriverClass("com.mysql.jdbc.Driver");
                } else {
                    throw e;
                }
            }

            dataSource.setJdbcUrl(url);
            dataSource.setUser(user);
            dataSource.setPassword(password);
            dataSource.setInitialPoolSize(initialSize);
            dataSource.setMaxPoolSize(maxSize);
            dataSource.setMinPoolSize(minSize);
            dataSource.setMaxIdleTime(maxIdle);

            // 进行一次连接测试以确保配置正确
            Connection testConn = dataSource.getConnection();
            testConn.close();

            initialized = true;

        } catch (Exception e) {
            initialized = false;
            initError = e.getMessage();
            System.err.println("[C3P0] 连接池初始化失败：" + e.getMessage());
            e.printStackTrace();
        } finally {
            if (is != null) {
                try {
                    is.close();
                } catch (IOException e) {
                    // 忽略
                }
            }
        }
    }

    /**
     * 获取 C3P0 数据源对象
     *
     * @return DataSource 数据源实例
     * @throws RuntimeException 若连接池未成功初始化则抛出异常
     */
    public static DataSource getDDs() {
        if (!initialized || dataSource == null) {
            throw new RuntimeException(
                    "C3P0连接池未正确初始化！错误信息：" + initError
            );
        }
        return dataSource;
    }

    /**
     * 测试数据库连接是否可用
     *
     * @return 如果成功获取并关闭连接则返回 true，否则返回 false
     */
    public static boolean testConnection() {
        Connection conn = null;
        try {
            conn = getDDs().getConnection();
            return conn != null && !conn.isClosed();
        } catch (Exception e) {
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    // 忽略
                }
            }
        }
    }

    /**
     * 主方法：用于独立运行以诊断 C3P0 连接池配置及数据库连通性
     *
     * @param args 命令行参数
     */
    public static void main(String[] args) {
        System.out.println("========== C3P0连接池诊断测试 ==========");

        if (!initialized) {
            System.err.println("[失败] 初始化失败！错误：" + initError);
            return;
        }

        System.out.println("[成功] 初始化成功");

        Connection conn = null;
        try {
            conn = getDDs().getConnection();
            System.out.println("[成功] 连接获取成功");

            java.sql.Statement stmt = conn.createStatement();
            java.sql.ResultSet rs = stmt.executeQuery("SELECT 1");
            if (rs.next()) {
                System.out.println("[成功] 查询测试通过");
            }

            rs.close();
            stmt.close();
            System.out.println("[成功] 全部测试通过");

        } catch (SQLException e) {
            System.err.println("[失败] 数据库操作失败：" + e.getMessage());
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    // 忽略
                }
            }
        }
    }
}