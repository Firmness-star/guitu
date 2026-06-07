package com.flower.controller.api;

import com.flower.dao.OrderDao;
import com.flower.dao.SpDao;
import com.flower.entity.Order;
import com.flower.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;

@WebServlet("/api/order/status")
public class OrderStatusApi extends ApiBaseServlet {

    private OrderDao orderDao = new OrderDao();
    private SpDao spDao = new SpDao();

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer uid = getUserId(req);
        if (uid == null) { unauth(resp); return; }

        String action = req.getParameter("action");
        String orderId = req.getParameter("orderId");
        if (orderId == null || orderId.trim().isEmpty()) { fail(resp, 400, "参数错误"); return; }

        Order order = orderDao.findByOrderId(orderId);
        if (order == null || !order.getUserId().equals(uid)) { fail(resp, 404, "订单不存在"); return; }

        boolean success = false;

        switch (action) {
            case "confirm":
                if ("已发货".equals(order.getStatus())) {
                    success = orderDao.updateStatus(orderId, "已收货");
                }
                break;
            case "cancel":
                if ("待付款".equals(order.getStatus())) {
                    success = orderDao.updateStatusAndRemarkByOrderNo(orderId, "已取消", "[客户取消]");
                    if (success) restoreOrderStock(order);
                }
                break;
            default:
                fail(resp, 400, "不支持的操作");
                return;
        }

        if (success) ok(resp, "操作成功", null);
        else fail(resp, 400, "操作失败，当前状态不允许该操作");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer uid = getUserId(req);
        if (uid == null) { unauth(resp); return; }

        String action = req.getParameter("action");
        String orderId = req.getParameter("orderId");
        if (orderId == null || orderId.trim().isEmpty()) { fail(resp, 400, "参数错误"); return; }

        Order order = orderDao.findByOrderId(orderId);
        if (order == null || !order.getUserId().equals(uid)) { fail(resp, 404, "订单不存在"); return; }

        if ("pay".equals(action) && "待付款".equals(order.getStatus())) {
            boolean success = orderDao.updateStatus(orderId, "已付款");
            if (success) ok(resp, "支付成功", null);
            else fail(resp, 500, "支付失败");
        } else {
            fail(resp, 400, "当前状态不允许支付");
        }
    }

    private void restoreOrderStock(Order order) {
        if (order == null || order.getItems() == null) return;
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                for (com.flower.entity.CartItem item : order.getItems()) {
                    spDao.restoreStock(item.getProductId(), item.getQuantity(), conn);
                }
                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                System.err.println("[OrderStatusApi] 返还库存失败: " + e.getMessage());
            }
        } catch (Exception e) {
            System.err.println("[OrderStatusApi] " + e.getMessage());
        }
    }
}
