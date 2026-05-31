package com.flower.controller;

import com.flower.dao.OrderDao;
import com.flower.entity.Order;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * 订单状态控制器
 * 处理用户端的订单状态变更操作，如支付、取消订单及确认收货
 */
@WebServlet("/orderstatus")
public class OrderStatusController extends HttpServlet {

    private OrderDao orderDao = new OrderDao();

    /**
     * 处理 POST 请求，根据 action 参数更新订单状态
     *
     * @param req  HTTP 请求对象
     * @param resp HTTP 响应对象
     * @throws ServletException Servlet 异常
     * @throws IOException      IO 异常
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        HttpSession session = req.getSession();
        String username = (String) session.getAttribute("username");
        Integer userId = (Integer) session.getAttribute("userId");

        if (username == null || userId == null) {
            resp.sendRedirect("login.jsp?redirect=orders");
            return;
        }

        String action = req.getParameter("action");
        String orderId = req.getParameter("orderId");

        if (orderId == null || orderId.trim().isEmpty()) {
            resp.sendRedirect("orders");
            return;
        }

        Order order = orderDao.findByOrderId(orderId);
        
        // 校验订单是否存在以及是否属于当前登录用户
        if (order == null || !order.getUserId().equals(userId)) {
            resp.sendRedirect("orders");
            return;
        }

        boolean success = false;
        
        switch (action) {
            case "pay":
                // 待付款 -> 已付款
                if ("待付款".equals(order.getStatus())) {
                    success = orderDao.updateStatus(orderId, "已付款");
                }
                break;
                
            case "ship":
                // 已付款 -> 已发货 (需要管理员权限，这里简化处理)
                if ("已付款".equals(order.getStatus())) {
                    success = orderDao.updateStatus(orderId, "已发货");
                }
                break;
                
            case "confirm":
                // 已发货 -> 已收货 (用户确认收货)
                if ("已发货".equals(order.getStatus())) {
                    success = orderDao.updateStatus(orderId, "已收货");
                }
                break;
                
            case "cancel":
                // 待付款 或 已付款 -> 已取消，记录取消来源
                if ("待付款".equals(order.getStatus()) || "已付款".equals(order.getStatus())) {
                    String cancelSource = req.getParameter("cancelSource");
                    String cancelRemark = "[客户取消]";
                    if ("merchant".equals(cancelSource) || "admin".equals(cancelSource)) {
                        cancelRemark = "[商家取消]";
                    }
                    success = orderDao.updateStatusAndRemarkByOrderNo(orderId, "已取消", cancelRemark);
                }
                break;
        }

        if (success) {
            req.getSession().setAttribute("message", "操作成功");
        } else {
            req.getSession().setAttribute("error", "操作失败");
        }
        
        resp.sendRedirect("orders");
    }
}
