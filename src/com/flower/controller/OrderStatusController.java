package com.flower.controller;

import com.flower.dao.OrderDao;
import com.flower.dao.SpDao;
import com.flower.entity.Order;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;

@WebServlet("/orderstatus")
public class OrderStatusController extends HttpServlet {

    private OrderDao orderDao = new OrderDao();
    private SpDao spDao = new SpDao();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        String username = (String) session.getAttribute("username");
        Integer userId = (Integer) session.getAttribute("userId");

        if (username == null || userId == null) {
            resp.sendRedirect("login?redirect=orders");
            return;
        }

        String action = req.getParameter("action");
        String orderId = req.getParameter("orderId");

        if (orderId == null || orderId.trim().isEmpty()) {
            resp.sendRedirect("orders");
            return;
        }

        Order order = orderDao.findByOrderId(orderId);
        if (order == null || !order.getUserId().equals(userId)) {
            resp.sendRedirect("orders");
            return;
        }

        boolean success = false;

        switch (action) {
            case "pay":
                if ("待付款".equals(order.getStatus())) {
                    resp.sendRedirect("payment?orderId=" + orderId);
                    return;
                }
                break;
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
        }

        if (success) req.getSession().setAttribute("message", "操作成功");
        else req.getSession().setAttribute("error", "操作失败");
        resp.sendRedirect("orders");
    }

    private void restoreOrderStock(Order order) {
        if (order == null || order.getItems() == null) return;
        try (Connection conn = com.flower.util.DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                for (com.flower.entity.CartItem item : order.getItems()) {
                    spDao.restoreStock(item.getProductId(), item.getQuantity(), conn);
                }
                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                System.err.println("[OrderStatus] 返还库存失败: " + e.getMessage());
            }
        } catch (Exception e) {
            System.err.println("[OrderStatus] " + e.getMessage());
        }
    }
}
