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
import java.util.Date;

/**
 * 支付控制器
 * 负责处理订单支付页面的展示及支付结果的模拟处理
 */
@WebServlet("/payment")
public class PaymentController extends HttpServlet {

    private OrderDao orderDao = new OrderDao();

    /**
     * 处理 GET 请求，展示支付页面
     *
     * @param req  HTTP 请求对象
     * @param resp HTTP 响应对象
     * @throws ServletException Servlet 异常
     * @throws IOException      IO 异常
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        HttpSession session = req.getSession();
        String username = (String) session.getAttribute("username");
        Integer userId = (Integer) session.getAttribute("userId");

        if (username == null || userId == null) {
            resp.sendRedirect("login?redirect=payment");
            return;
        }

        String orderId = req.getParameter("orderId");
        if (orderId == null || orderId.trim().isEmpty()) {
            resp.sendRedirect("orders");
            return;
        }

        Order order = orderDao.findByOrderId(orderId);

        // 校验订单是否存在、是否属于当前用户以及是否处于待付款状态
        if (order == null || !order.getUserId().equals(userId)) {
            resp.sendRedirect("orders");
            return;
        }

        if (!"待付款".equals(order.getStatus())) {
            resp.sendRedirect("orders");
            return;
        }

        String payMethod = req.getParameter("payMethod");
        if (payMethod != null) {
            req.setAttribute("payMethod", payMethod);
        }

        req.setAttribute("order", order);
        req.getRequestDispatcher("payment.jsp").forward(req, resp);
    }

    /**
     * 处理 POST 请求，执行支付操作并跳转到支付结果页
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
            resp.sendRedirect("login?redirect=payment");
            return;
        }

        String action = req.getParameter("action");
        String orderId = req.getParameter("orderId");
        String payMethod = req.getParameter("payMethod");

        if ("pay".equals(action) && orderId != null && payMethod != null) {
            Order order = orderDao.findByOrderId(orderId);
            
            if (order != null && order.getUserId().equals(userId) && "待付款".equals(order.getStatus())) {
                boolean success = orderDao.updateStatus(orderId, "已付款");
                
                if (success) {
                    String payMethodName = getPayMethodName(payMethod);
                    req.setAttribute("orderId", orderId);
                    req.setAttribute("amount", String.format("%.2f", order.getTotalAmount()));
                    req.setAttribute("payMethod", payMethodName);
                    req.setAttribute("payTime", new Date());
                    req.getRequestDispatcher("payment_success.jsp").forward(req, resp);
                } else {
                    req.setAttribute("error", "支付失败，请稍后重试");
                    req.setAttribute("order", order);
                    req.getRequestDispatcher("payment.jsp").forward(req, resp);
                }
            } else {
                resp.sendRedirect("orders");
            }
        } else {
            resp.sendRedirect("orders");
        }
    }

    /**
     * 根据支付方式代码获取对应的中文名称
     *
     * @param payMethod 支付方式代码（alipay/wechat/bank）
     * @return 支付方式的中文描述
     */
    private String getPayMethodName(String payMethod) {
        switch (payMethod) {
            case "alipay":
                return "支付宝";
            case "wechat":
                return "微信支付";
            case "bank":
                return "银行卡";
            default:
                return "未知支付方式";
        }
    }
}
