package com.flower.dao;

import com.flower.entity.CartItem;
import com.flower.entity.Order;
import com.flower.util.DBUtil;
import com.flower.util.TransactionManager;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 订单数据访问对象
 * 负责处理订单的持久化、查询及状态更新，支持事务控制
 */
public class OrderDao {

    /**
     * 保存订单信息，包括订单主表和订单项明细（带事务）
     *
     * @param order 待保存的订单对象
     * @return 保存成功返回 true，否则返回 false
     */
    public boolean saveOrder(Order order) {
        if (order == null || order.getUserId() == null) {
            return false;
        }

        Connection conn = null;
        PreparedStatement pstmtOrder = null;
        PreparedStatement pstmtItem = null;
        ResultSet rs = null;

        String orderSql = "INSERT INTO orders (user_id, total_amount, total_count, " +
                "status, receiver_name, receiver_phone, receiver_address, remark, create_time, " +
                "order_no, actual_amount) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        String itemSql = "INSERT INTO order_item (order_id, product_id, product_name, " +
                "product_price, quantity, subtotal) VALUES (?, ?, ?, ?, ?, ?)";

        try {
            conn = TransactionManager.getConnection();

            pstmtOrder = conn.prepareStatement(orderSql, Statement.RETURN_GENERATED_KEYS);
            pstmtOrder.setInt(1, order.getUserId());
            pstmtOrder.setDouble(2, order.getTotalAmount());
            pstmtOrder.setInt(3, order.getTotalCount());
            pstmtOrder.setString(4, order.getStatus());
            pstmtOrder.setString(5, order.getReceiverName());
            pstmtOrder.setString(6, order.getReceiverPhone());
            pstmtOrder.setString(7, order.getReceiverAddress());
            pstmtOrder.setString(8, order.getRemark());
            pstmtOrder.setTimestamp(9, new Timestamp(order.getCreateTime().getTime()));
            pstmtOrder.setString(10, order.getOrderId());
            pstmtOrder.setDouble(11, order.getTotalAmount());

            int orderResult = pstmtOrder.executeUpdate();
            if (orderResult <= 0) {
                throw new SQLException("插入订单主表失败");
            }

            rs = pstmtOrder.getGeneratedKeys();
            Integer generatedId = null;
            if (rs.next()) {
                generatedId = rs.getInt(1);
                // 不要覆盖业务订单号
                // order.setOrderId(String.valueOf(generatedId));
            } else {
                throw new SQLException("获取订单ID失败");
            }

            // 批量插入订单项明细
            pstmtItem = conn.prepareStatement(itemSql);
            for (CartItem item : order.getItems()) {
                pstmtItem.setInt(1, generatedId);
                pstmtItem.setInt(2, item.getProductId());
                pstmtItem.setString(3, item.getProductName());
                pstmtItem.setDouble(4, item.getProductPrice());
                pstmtItem.setInt(5, item.getQuantity());
                pstmtItem.setDouble(6, item.getProductPrice() * item.getQuantity());
                pstmtItem.addBatch();
            }

            int[] itemResults = pstmtItem.executeBatch();
            for (int result : itemResults) {
                if (result <= 0) {
                    throw new SQLException("插入订单明细失败");
                }
            }

            return true;

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("保存订单失败：" + e.getMessage(), e);
        } finally {
            closeQuietly(rs);
            closeQuietly(pstmtItem);
            closeQuietly(pstmtOrder);
        }
    }

    /**
     * 根据用户 ID 查询该用户的所有订单列表
     *
     * @param userId 用户 ID
     * @return 订单列表，按创建时间降序排列
     */
    public List<Order> findByUserId(int userId) {
        if (userId <= 0) {
            return new ArrayList<>();
        }

        String sql = "SELECT o.*, u.username FROM orders o LEFT JOIN user u ON o.user_id = u.id " +
                     "WHERE o.user_id = ? ORDER BY o.create_time DESC";
        List<Order> orders = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Order order = mapResultSetToOrder(rs);
                order.setItems(findOrderItemsByOrderId(rs.getInt("id"), conn));
                orders.add(order);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }
        return orders;
    }

    /**
     * 查询所有订单（管理员使用）
     *
     * @return 包含所有订单的列表
     */
    public List<Order> findAllOrders() {
        String sql = "SELECT o.*, u.username FROM orders o LEFT JOIN user u ON o.user_id = u.id " +
                     "ORDER BY o.create_time DESC";
        List<Order> orders = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Order order = mapResultSetToOrder(rs);
                order.setItems(findOrderItemsByOrderId(rs.getInt("id"), conn));
                orders.add(order);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }
        return orders;
    }

    /**
     * 根据用户名查询订单（商家使用）
     * 商家查看所有订单，因为每个订单都包含该商家的商品
     *
     * @param username 买家用户名
     * @return 对应的订单列表
     */
    public List<Order> findOrdersByUsername(String username) {
        if (username == null || username.trim().isEmpty()) {
            return new ArrayList<>();
        }

        String sql = "SELECT o.*, u.username as buyer_username " +
                     "FROM orders o LEFT JOIN user u ON o.user_id = u.id " +
                     "WHERE u.username = ? ORDER BY o.create_time DESC";
        List<Order> orders = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Order order = mapResultSetToOrder(rs);
                order.setItems(findOrderItemsByOrderId(rs.getInt("id"), conn));
                orders.add(order);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }
        return orders;
    }

    /**
     * 根据订单号查询单个订单详情
     *
     * @param orderId 订单编号
     * @return 订单对象，若不存在则返回 null
     */
    public Order findByOrderId(String orderId) {
        if (orderId == null || orderId.trim().isEmpty()) {
            return null;
        }

        String sql = "SELECT o.*, u.username FROM orders o LEFT JOIN user u ON o.user_id = u.id " +
                     "WHERE o.order_no = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Order order = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, orderId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                order = mapResultSetToOrder(rs);
                order.setItems(findOrderItemsByOrderId(rs.getInt("id"), conn));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }
        return order;
    }

    /**
     * 根据订单 ID 查询该订单下的所有商品明细
     *
     * @param orderId 订单在数据库中的自增 ID
     * @return 订单项（CartItem）列表
     */
    private List<CartItem> findOrderItemsByOrderId(Integer orderId) {
        return findOrderItemsByOrderId(orderId, null);
    }

    private List<CartItem> findOrderItemsByOrderId(Integer orderId, Connection parentConn) {
        String sql = "SELECT oi.*, p.pic AS product_pic FROM order_item oi " +
                     "LEFT JOIN product p ON oi.product_id = p.id WHERE oi.order_id = ?";
        List<CartItem> items = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean ownConn = (parentConn == null);

        try {
            conn = ownConn ? DBUtil.getConnection() : parentConn;
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, orderId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                CartItem item = new CartItem();
                item.setProductId(rs.getInt("product_id"));
                item.setProductName(rs.getString("product_name"));
                item.setProductPrice(rs.getDouble("product_price"));
                item.setQuantity(rs.getInt("quantity"));
                item.setProductPic(rs.getString("product_pic"));
                item.setSelected(true);
                items.add(item);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeQuietly(rs);
            closeQuietly(pstmt);
            if (ownConn) {
                try { if (conn != null) conn.close(); } catch (SQLException e) { }
            }
        }
        return items;
    }

    /**
     * 根据订单号更新订单状态
     *
     * @param orderId   订单编号
     * @param newStatus 新的状态字符串
     * @return 更新成功返回 true，否则返回 false
     */
    public boolean updateStatus(String orderId, String newStatus) {
        if (orderId == null || orderId.trim().isEmpty() || 
            newStatus == null || newStatus.trim().isEmpty()) {
            return false;
        }

        String sql = "UPDATE orders SET status = ? WHERE order_no = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, newStatus);
            pstmt.setString(2, orderId);

            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("更新订单状态失败", e);
        } finally {
            DBUtil.close(conn, pstmt);
        }
    }

    /**
     * 根据数据库自增ID更新订单状态（管理员后台使用）
     * 
     * @param orderId 数据库自增ID
     * @param newStatus 新状态
     * @return 是否更新成功
     */
    public boolean updateStatusById(int orderId, String newStatus) {
        if (orderId <= 0 || newStatus == null || newStatus.trim().isEmpty()) {
            return false;
        }

        String sql = "UPDATE orders SET status = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, newStatus);
            pstmt.setInt(2, orderId);

            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("更新订单状态失败", e);
        } finally {
            closeQuietly(pstmt);
        }
    }

    public boolean updateWlNo(int orderId, String wlNo) {
        String sql = "UPDATE orders SET wl_no = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, wlNo);
            pstmt.setInt(2, orderId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeQuietly(pstmt);
        }
        return false;
    }

    public boolean updateWlNoByOrderNo(String orderNo, String wlNo) {
        String sql = "UPDATE orders SET wl_no = ? WHERE order_no = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, wlNo);
            pstmt.setString(2, orderNo);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeQuietly(pstmt);
        }
        return false;
    }

    /**
     * 根据订单号（order_no）更新订单状态和备注（用于发货时保存物流信息）
     * 
     * @param orderNo 业务订单号（如 ORD1779107601422）
     * @param newStatus 新状态
     * @param remark 备注信息（可包含物流信息）
     * @return 是否更新成功
     */
    public boolean updateStatusAndRemarkByOrderNo(String orderNo, String newStatus, String remark) {
        if (orderNo == null || orderNo.trim().isEmpty() || newStatus == null || newStatus.trim().isEmpty()) {
            return false;
        }

        String sql = "UPDATE orders SET status = ?, remark = CONCAT(IFNULL(remark, ''), ?) WHERE order_no = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, newStatus);
            pstmt.setString(2, remark);
            pstmt.setString(3, orderNo);

            int rows = pstmt.executeUpdate();
            
            // 如果更新成功，记录状态变更历史
            if (rows > 0) {
                recordStatusHistoryByOrderNo(conn, orderNo, newStatus, remark);
            }
            
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("更新订单状态失败", e);
        } finally {
            closeQuietly(pstmt);
        }
    }

    /**
     * 根据订单号记录状态变更历史
     * 
     * @param conn 数据库连接
     * @param orderNo 订单号
     * @param newStatus 新状态
     * @param remark 备注信息
     */
    private void recordStatusHistoryByOrderNo(Connection conn, String orderNo, String newStatus, String remark) {
        String sql = "INSERT INTO order_status_history (order_id, old_status, new_status, change_time, remark) " +
                     "SELECT id, status, ?, NOW(), ? FROM orders WHERE order_no = ?";
        PreparedStatement pstmt = null;
        
        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, newStatus);
            pstmt.setString(2, remark != null ? remark : "");
            pstmt.setString(3, orderNo);
            pstmt.executeUpdate();
        } catch (SQLException e) {
        } finally {
            closeQuietly(pstmt);
        }
    }

    /**
     * 静默关闭资源，忽略关闭过程中产生的异常
     *
     * @param closeable 待关闭的资源对象
     */
    private void closeQuietly(AutoCloseable closeable) {
        if (closeable != null) {
            try {
                closeable.close();
            } catch (Exception e) {
            }
        }
    }

    /**
     * 将 ResultSet 结果集映射为 Order 实体对象
     *
     * @param rs 数据库查询结果集
     * @return Order 实体对象
     * @throws SQLException SQL 异常
     */
    private Order mapResultSetToOrder(ResultSet rs) throws SQLException {
        Order order = new Order();
        order.setOrderId(rs.getString("order_no"));
        order.setUserId(rs.getInt("user_id"));
        String username = rs.getString("username");
        if (username != null) {
            order.setUsername(username);
        } else {
            String buyerUsername = rs.getString("buyer_username");
            if (buyerUsername != null) {
                order.setUsername(buyerUsername);
            }
        }
        order.setTotalAmount(rs.getDouble("total_amount"));
        order.setTotalCount(rs.getInt("total_count"));
        order.setStatus(rs.getString("status"));
        order.setReceiverName(rs.getString("receiver_name"));
        order.setReceiverPhone(rs.getString("receiver_phone"));
        order.setReceiverAddress(rs.getString("receiver_address"));
        order.setRemark(rs.getString("remark"));
        try { order.setWlNo(rs.getString("wl_no")); } catch (SQLException e) { /* wl_no column may not exist yet */ }
        order.setCreateTime(rs.getTimestamp("create_time"));
        return order;
    }
}
