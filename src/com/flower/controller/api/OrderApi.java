package com.flower.controller.api;

import com.flower.dao.OrderDao;
import com.flower.dao.AddressDao;
import com.flower.dao.UserDao;
import com.flower.dao.CartDao;
import com.flower.util.TransactionManager;
import com.flower.entity.Order;
import com.flower.entity.CartItem;
import com.flower.entity.Address;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet("/api/orders")
public class OrderApi extends ApiBaseServlet {

    private OrderDao orderDao = new OrderDao();
    private AddressDao addressDao = new AddressDao();
    private UserDao userDao = new UserDao();
    private CartDao cartDao = new CartDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer uid = getUserId(req);
        if (uid == null) { unauth(resp); return; }
        List<Order> orders = orderDao.findByUserId(uid);
        String status = req.getParameter("status");
        if (status != null && !status.isEmpty()) {
            orders.removeIf(o -> !status.equals(o.getStatus()));
        }
        ok(resp, orders);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer uid = getUserId(req);
        String username = getUsername(req);
        if (uid == null || username == null) { unauth(resp); return; }

        String receiverName = req.getParameter("receiverName");
        String receiverPhone = req.getParameter("receiverPhone");
        String receiverAddress = req.getParameter("receiverAddress");
        String remark = req.getParameter("remark");
        String payMethod = req.getParameter("payMethod");

        if (receiverName == null || receiverPhone == null || receiverAddress == null) {
            fail(resp, 400, "请填写完整的收货信息"); return;
        }

        List<CartItem> cart = cartDao.findByUserId(uid);
        List<CartItem> selected = new ArrayList<>();
        double total = 0;
        int count = 0;
        for (CartItem item : cart) {
            if (item.isSelected()) {
                selected.add(item);
                total += item.getProductPrice() * item.getQuantity();
                count += item.getQuantity();
            }
        }
        if (selected.isEmpty()) { fail(resp, 400, "请选择商品"); return; }

        // handle points deduction
        String usePointsStr = req.getParameter("usePoints");
        int usePoints = 0;
        double actualAmount = total;
        if (usePointsStr != null && !usePointsStr.trim().isEmpty() && !"0".equals(usePointsStr)) {
            try {
                usePoints = Integer.parseInt(usePointsStr.trim());
                if (usePoints > 0) {
                    int userJf = userDao.getJf(uid);
                    if (usePoints > userJf) usePoints = userJf;
                    int maxDeduct = (int)(total * 50);  // 50% of total in points
                    if (usePoints > maxDeduct) usePoints = maxDeduct;
                    actualAmount = total - usePoints / 100.0;
                    if (actualAmount < 0) actualAmount = 0;
                    actualAmount = Math.round(actualAmount * 100.0) / 100.0;
                }
            } catch (NumberFormatException e) { usePoints = 0; }
        }

        Order order = new Order();
        order.setOrderId(Order.generateOrderId());
        order.setUserId(uid);
        order.setUsername(username);
        order.setTotalAmount(actualAmount);
        order.setTotalCount(count);
        order.setReceiverName(receiverName.trim());
        order.setReceiverPhone(receiverPhone.trim());
        order.setReceiverAddress(receiverAddress.trim());
        order.setRemark(remark != null ? remark.trim() : "");
        order.setItems(selected);

        if (orderDao.saveOrder(order)) {
            // points: deduct used, award 10% of actual
            if (usePoints > 0) userDao.deductJf(uid, usePoints);
            int earnJf = (int)(actualAmount * 0.1);
            if (earnJf > 0) userDao.addJf(uid, earnJf);

            cartDao.clearCart(uid);
            Map<String, Object> data = new HashMap<>();
            data.put("orderId", order.getOrderId());
            data.put("amount", order.getTotalAmount());
            data.put("payMethod", payMethod);
            ok(resp, "下单成功", data);
        } else {
            fail(resp, 500, "下单失败");
        }
    }
}
