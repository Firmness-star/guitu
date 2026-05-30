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

/**
 * 订单列表控制器
 * 负责展示当前登录用户的个人订单历史记录
 */
@WebServlet(urlPatterns = "/orders")
public class OrderListController extends HttpServlet {

    private OrderDao orderDao = new OrderDao();

    /**
     * 处理 GET 请求，查询并展示当前用户的订单列表
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
            resp.sendRedirect("login.jsp?redirect=orders");
            return;
        }

        List<Order> orderList = orderDao.findByUserId(userId);

        req.setAttribute("orderList", orderList);
        req.getRequestDispatcher("orders.jsp").forward(req, resp);
    }
}
