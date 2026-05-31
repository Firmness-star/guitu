package com.flower.dao;

import com.flower.entity.CartItem;
import com.flower.entity.Order;
import com.flower.util.DBUtil;
import com.flower.util.TransactionManager;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderDao {

    public boolean saveOrder(Order order) {
        if (order == null || order.getUserId() == null) return false;
        String orderSql = "INSERT INTO orders (user_id,total_amount,total_count,status,receiver_name,receiver_phone,receiver_address,remark,create_time,order_no,actual_amount) VALUES (?,?,?,?,?,?,?,?,?,?,?)";
        String itemSql = "INSERT INTO order_item (order_id,product_id,product_name,product_price,quantity,subtotal) VALUES (?,?,?,?,?,?)";
        Connection conn = null;
        PreparedStatement pstmtOrder = null, pstmtItem = null;
        ResultSet rs = null;
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
            if (pstmtOrder.executeUpdate() <= 0) throw new SQLException("插入订单主表失败");
            rs = pstmtOrder.getGeneratedKeys();
            if (!rs.next()) throw new SQLException("获取订单ID失败");
            Integer generatedId = rs.getInt(1);
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
            for (int r : pstmtItem.executeBatch()) if (r <= 0) throw new SQLException("插入订单明细失败");
            return true;
        } catch (SQLException e) {
            System.err.println("DAO ERROR: " + e.getMessage());
            throw new RuntimeException("保存订单失败：" + e.getMessage(), e);
        } finally {
            closeQuietly(rs); closeQuietly(pstmtItem); closeQuietly(pstmtOrder);
        }
    }

    public List<Order> findByUserId(int userId) {
        if (userId <= 0) return new ArrayList<>();
        String sql = "SELECT o.*, u.username FROM orders o LEFT JOIN user u ON o.user_id = u.id WHERE o.user_id = ? ORDER BY o.create_time DESC";
        List<Order> orders = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Order order = mapResultSetToOrder(rs);
                    order.setItems(findOrderItemsByOrderId(rs.getInt("id"), conn));
                    orders.add(order);
                }
            }
        } catch (SQLException e) { System.err.println("DAO ERROR: " + e.getMessage()); }
        return orders;
    }

    public List<Order> findAllOrders() {
        String sql = "SELECT o.*, u.username FROM orders o LEFT JOIN user u ON o.user_id = u.id ORDER BY o.create_time DESC";
        List<Order> orders = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                Order order = mapResultSetToOrder(rs);
                order.setItems(findOrderItemsByOrderId(rs.getInt("id"), conn));
                orders.add(order);
            }
        } catch (SQLException e) { System.err.println("DAO ERROR: " + e.getMessage()); }
        return orders;
    }

    public List<Order> findOrdersByUsername(String username) {
        if (username == null || username.trim().isEmpty()) return new ArrayList<>();
        String sql = "SELECT o.*, u.username as buyer_username FROM orders o LEFT JOIN user u ON o.user_id = u.id WHERE u.username = ? ORDER BY o.create_time DESC";
        List<Order> orders = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, username);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Order order = mapResultSetToOrder(rs);
                    order.setItems(findOrderItemsByOrderId(rs.getInt("id"), conn));
                    orders.add(order);
                }
            }
        } catch (SQLException e) { System.err.println("DAO ERROR: " + e.getMessage()); }
        return orders;
    }

    public Order findByOrderId(String orderId) {
        if (orderId == null || orderId.trim().isEmpty()) return null;
        String sql = "SELECT o.*, u.username FROM orders o LEFT JOIN user u ON o.user_id = u.id WHERE o.order_no = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, orderId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    Order order = mapResultSetToOrder(rs);
                    order.setItems(findOrderItemsByOrderId(rs.getInt("id"), conn));
                    return order;
                }
            }
        } catch (SQLException e) { System.err.println("DAO ERROR: " + e.getMessage()); }
        return null;
    }

    private List<CartItem> findOrderItemsByOrderId(Integer orderId) { return findOrderItemsByOrderId(orderId, null); }

    private List<CartItem> findOrderItemsByOrderId(Integer orderId, Connection parentConn) {
        String sql = "SELECT oi.*, p.pic AS product_pic FROM order_item oi LEFT JOIN product p ON oi.product_id = p.id WHERE oi.order_id = ?";
        List<CartItem> items = new ArrayList<>();
        boolean ownConn = (parentConn == null);
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
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
            System.err.println("DAO ERROR: " + e.getMessage());
        } finally {
            closeQuietly(rs); closeQuietly(pstmt);
            if (ownConn && conn != null) { try { conn.close(); } catch (SQLException e) {} }
        }
        return items;
    }

    public boolean updateStatus(String orderId, String newStatus) {
        if (orderId == null || orderId.trim().isEmpty() || newStatus == null || newStatus.trim().isEmpty()) return false;
        String sql = "UPDATE orders SET status = ? WHERE order_no = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, newStatus);
            pstmt.setString(2, orderId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { throw new RuntimeException("更新订单状态失败", e); }
    }

    public boolean updateStatusById(int orderId, String newStatus) {
        if (orderId <= 0 || newStatus == null || newStatus.trim().isEmpty()) return false;
        String sql = "UPDATE orders SET status = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, newStatus);
            pstmt.setInt(2, orderId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { throw new RuntimeException("更新订单状态失败", e); }
    }

    public boolean updateWlNo(int orderId, String wlNo) {
        String sql = "UPDATE orders SET wl_no = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, wlNo);
            pstmt.setInt(2, orderId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("DAO ERROR: " + e.getMessage()); }
        return false;
    }

    public boolean updateWlNoByOrderNo(String orderNo, String wlNo) {
        String sql = "UPDATE orders SET wl_no = ? WHERE order_no = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, wlNo);
            pstmt.setString(2, orderNo);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("DAO ERROR: " + e.getMessage()); }
        return false;
    }

    public boolean updateStatusAndRemarkByOrderNo(String orderNo, String newStatus, String remark) {
        if (orderNo == null || orderNo.trim().isEmpty() || newStatus == null) return false;
        String sql = "UPDATE orders SET status = ?, remark = CONCAT(IFNULL(remark, ''), ?) WHERE order_no = ?";
        Connection conn = null; PreparedStatement pstmt = null;
        try {
            conn = DBUtil.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, newStatus);
            pstmt.setString(2, remark);
            pstmt.setString(3, orderNo);
            int rows = pstmt.executeUpdate();
            if (rows > 0) recordStatusHistoryByOrderNo(conn, orderNo, newStatus, remark);
            return rows > 0;
        } catch (SQLException e) { throw new RuntimeException("更新订单状态失败", e); }
        finally { closeQuietly(pstmt); if (conn != null) { try { conn.close(); } catch (SQLException e) {} } }
    }

    private void recordStatusHistoryByOrderNo(Connection conn, String orderNo, String newStatus, String remark) {
        String sql = "INSERT INTO order_status_history (order_id, old_status, new_status, change_time, remark) SELECT id, status, ?, NOW(), ? FROM orders WHERE order_no = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, newStatus);
            pstmt.setString(2, remark != null ? remark : "");
            pstmt.setString(3, orderNo);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            /* 历史记录失败不影响主流程 */
        }
    }

    private void closeQuietly(AutoCloseable c) { if (c != null) { try { c.close(); } catch (Exception e) {} } }

    private Order mapResultSetToOrder(ResultSet rs) throws SQLException {
        Order order = new Order();
        order.setOrderId(rs.getString("order_no"));
        order.setUserId(rs.getInt("user_id"));
        String username = rs.getString("username");
        if (username != null) order.setUsername(username);
        else { try { String buyer = rs.getString("buyer_username"); if (buyer != null) order.setUsername(buyer); } catch (SQLException ignored) {} }
        order.setTotalAmount(rs.getDouble("total_amount"));
        order.setTotalCount(rs.getInt("total_count"));
        order.setStatus(rs.getString("status"));
        order.setReceiverName(rs.getString("receiver_name"));
        order.setReceiverPhone(rs.getString("receiver_phone"));
        order.setReceiverAddress(rs.getString("receiver_address"));
        order.setRemark(rs.getString("remark"));
        try { order.setWlNo(rs.getString("wl_no")); } catch (SQLException ignored) {}
        order.setCreateTime(rs.getTimestamp("create_time"));
        return order;
    }
}
