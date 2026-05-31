package com.flower.controller.api;

import com.flower.dao.OrderDao;
import com.flower.entity.Order;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/api/payment")
public class PaymentApi extends ApiBaseServlet {

    private OrderDao orderDao = new OrderDao();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer uid = getUserId(req);
        if (uid == null) { unauth(resp); return; }

        String orderId = req.getParameter("orderId");
        Order order = orderDao.findByOrderId(orderId);
        if (order == null || !order.getUserId().equals(uid)) { fail(resp, 404, "订单不存在"); return; }
        if (!"待付款".equals(order.getStatus())) { fail(resp, 400, "该订单无法支付"); return; }

        if (orderDao.updateStatus(orderId, "已付款")) {
            ok(resp, "支付成功", null);
        } else {
            fail(resp, 500, "支付失败");
        }
    }
}
