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
import java.util.List;
import java.util.stream.Collectors;

/**
 * 订单列表控制器
 * 负责展示当前登录用户的个人订单历史记录
 */
@WebServlet(urlPatterns = "/orders")
public class OrderListController extends HttpServlet {

    private OrderDao orderDao = new OrderDao();

    /**
     * 处理 GET 请求，查询并展示当前用户的订单列表，支持按状态筛选
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        String username = (String) session.getAttribute("username");
        Integer userId = (Integer) session.getAttribute("userId");

        if (username == null || userId == null) {
            resp.sendRedirect("login?redirect=orders");
            return;
        }

        List<Order> orderList = orderDao.findByUserId(userId);

        String statusFilter = req.getParameter("status");
        if (statusFilter != null && !statusFilter.isEmpty()) {
            if ("已收货".equals(statusFilter)) {
                orderList = orderList.stream()
                        .filter(o -> "已收货".equals(o.getStatus()) || "已完成".equals(o.getStatus()))
                        .collect(Collectors.toList());
            } else {
                orderList = orderList.stream()
                        .filter(o -> statusFilter.equals(o.getStatus()))
                        .collect(Collectors.toList());
            }
        }

        req.setAttribute("orderList", orderList);
        req.setAttribute("statusFilter", statusFilter);
        req.getRequestDispatcher("orders.jsp").forward(req, resp);
    }
}
