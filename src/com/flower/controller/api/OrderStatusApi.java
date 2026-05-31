package com.flower.controller.api;

import com.flower.dao.OrderDao;
import com.flower.entity.Order;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet("/api/order/status")
public class OrderStatusApi extends ApiBaseServlet {

    private OrderDao orderDao = new OrderDao();

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer uid = getUserId(req);
        if (uid == null) { unauth(resp); return; }

        String orderId = req.getParameter("orderId");
        String action = req.getParameter("action");

        Order order = orderDao.findByOrderId(orderId);
        if (order == null || !order.getUserId().equals(uid)) { fail(resp, 404, "订单不存在"); return; }

        if ("cancel".equals(action)) {
            if ("待付款".equals(order.getStatus()) || "已付款".equals(order.getStatus())) {
                orderDao.updateStatus(orderId, "已取消");
                ok(resp, "订单已取消", null);
            } else { fail(resp, 400, "该订单无法取消"); }
        } else if ("confirm".equals(action)) {
            if ("已发货".equals(order.getStatus())) {
                orderDao.updateStatus(orderId, "已收货");
                ok(resp, "已确认收货", null);
            } else { fail(resp, 400, "该订单无法确认收货"); }
        } else {
            fail(resp, 400, "未知操作");
        }
    }
}
