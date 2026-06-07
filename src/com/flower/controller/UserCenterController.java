package com.flower.controller;

import com.flower.dao.JfDao;
import com.flower.dao.OrderDao;
import com.flower.dao.UserDao;
import com.flower.dao.MessageDao;
import com.flower.entity.Order;
import com.flower.entity.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 用户中心控制器
 * 负责展示用户个人信息、订单统计及最近订单记录
 */
@WebServlet(urlPatterns = "/usercenter")
public class UserCenterController extends HttpServlet {

    private OrderDao orderDao;
    private UserDao userDao;

    @Override
    public void init() throws ServletException {
        super.init();
        this.orderDao = new OrderDao();
        this.userDao = new UserDao();
    }

    /**
     * 处理 GET 请求，展示用户中心页面。也用于 AJAX 查重请求。
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
            resp.sendRedirect("login?redirect=usercenter");
            return;
        }

        // AJAX 检查电话唯一性
        String action = req.getParameter("action");
        if ("checkTel".equals(action)) {
            checkTel(req, resp, userId);
            return;
        }
        // AJAX 检查邮箱唯一性
        if ("checkEmail".equals(action)) {
            checkEmail(req, resp, userId);
            return;
        }

        User user = userDao.findByUsername(username);
        if (user == null) {
            session.invalidate();
            resp.sendRedirect("login");
            return;
        }

        // 同步头像到 session（供其他页面侧边栏使用）
        if (user.getAvatar() != null && !user.getAvatar().isEmpty()) {
            session.setAttribute("userAvatar", user.getAvatar());
        }

        List<Order> allOrders = orderDao.findByUserId(userId);
        Map<String, Integer> orderStats = calculateOrderStats(allOrders);
        List<Order> recentOrders = allOrders.isEmpty() ?
                new ArrayList<>() :
                allOrders.subList(0, Math.min(3, allOrders.size()));

        req.setAttribute("user", user);
        req.setAttribute("orderStats", orderStats);
        req.setAttribute("recentOrders", recentOrders);
        req.setAttribute("allOrders", allOrders);
        req.setAttribute("totalOrders", allOrders.size());
        req.setAttribute("unreadMsgCount", new MessageDao().countUnreadByUserId(userId));

        // 加载积分流水和规则
        List<Map<String, Object>> jfLogs = new JfDao().findByUserId(userId, 50);
        req.setAttribute("jfLogs", jfLogs);

        String tab = req.getParameter("tab");
        if ("orders".equals(tab)) {
            req.setAttribute("viewMode", "allOrders");
        } else if ("address".equals(tab)) {
            req.setAttribute("viewMode", "address");
        } else {
            req.setAttribute("viewMode", "overview");
        }

        req.getRequestDispatcher("user_center.jsp").forward(req, resp);
    }

    private void checkTel(HttpServletRequest req, HttpServletResponse resp, int currentUserId) throws IOException {
        String tel = req.getParameter("tel");
        resp.setContentType("application/json;charset=UTF-8");
        if (tel == null || !tel.matches("^1[3-9]\\d{9}$")) {
            resp.getWriter().write("{\"available\":false,\"message\":\"手机号格式不正确\"}");
            return;
        }
        User existing = userDao.findByTel(tel);
        if (existing != null && existing.getId() != currentUserId) {
            resp.getWriter().write("{\"available\":false,\"message\":\"该手机号已被其他用户使用\"}");
        } else {
            resp.getWriter().write("{\"available\":true,\"message\":\"手机号可用\"}");
        }
    }

    private void checkEmail(HttpServletRequest req, HttpServletResponse resp, int currentUserId) throws IOException {
        String email = req.getParameter("email");
        resp.setContentType("application/json;charset=UTF-8");
        if (email == null || !email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
            resp.getWriter().write("{\"available\":false,\"message\":\"邮箱格式不正确\"}");
            return;
        }
        User existing = userDao.findByEmail(email);
        if (existing != null && existing.getId() != currentUserId) {
            resp.getWriter().write("{\"available\":false,\"message\":\"该邮箱已被其他用户使用\"}");
        } else {
            resp.getWriter().write("{\"available\":true,\"message\":\"邮箱可用\"}");
        }
    }

    /**
     * 处理 POST 请求，更新用户资料（手机号和邮箱）
     *
     * @param req  HTTP 请求对象
     * @param resp HTTP 响应对象
     * @throws ServletException Servlet 异常
     * @throws IOException      IO 异常
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession();
        Integer userId = (Integer) session.getAttribute("userId");

        if (userId == null) {
            resp.sendRedirect("login");
            return;
        }

        String tel = req.getParameter("tel");
        String email = req.getParameter("email");
        String gender = req.getParameter("gender");

        if (tel == null || tel.trim().isEmpty()) {
            session.setAttribute("updateError", "手机号不能为空");
            resp.sendRedirect("usercenter");
            return;
        }
        if (!tel.matches("^1[3-9]\\d{9}$")) {
            session.setAttribute("updateError", "请输入有效的11位手机号");
            resp.sendRedirect("usercenter");
            return;
        }
        if (email == null || email.trim().isEmpty()) {
            session.setAttribute("updateError", "邮箱不能为空");
            resp.sendRedirect("usercenter");
            return;
        }

        // 只在真正修改了手机号/邮箱时才查重
        User current = userDao.findById(userId);
        if ((current == null || !tel.trim().equals(current.getTel())) && userDao.isTelUsedByOther(tel.trim(), userId)) {
            session.setAttribute("updateError", "该手机号已被其他用户使用");
            resp.sendRedirect("usercenter");
            return;
        }
        if ((current == null || !email.trim().equals(current.getEmail())) && userDao.isEmailUsedByOther(email.trim(), userId)) {
            session.setAttribute("updateError", "该邮箱已被其他用户使用");
            resp.sendRedirect("usercenter");
            return;
        }

        // 更新资料（手机、邮箱、性别）
        boolean success = userDao.updateUserInfo(userId, tel.trim(), email.trim());

        // 更新性别
        if (success && gender != null && !gender.isEmpty()) {
            userDao.updateGender(userId, gender);
        }

        // 完善个人资料奖励积分
        if (success) {
            User profileUser = userDao.findById(userId);
            boolean firstTime = profileUser != null &&
                    (profileUser.getTel() == null || profileUser.getTel().isEmpty() ||
                     profileUser.getEmail() == null || profileUser.getEmail().isEmpty());
            int jfAmount = firstTime ? 50 : 10;
            userDao.addJf(userId, jfAmount);
            new JfDao().addLog(userId, jfAmount, "completeProfile",
                    firstTime ? "首次完善个人信息获得50积分奖励" : "更新个人信息获得10积分");
        }

        if (success) {
            session.setAttribute("updateSuccess", "资料更新成功");
        } else {
            session.setAttribute("updateError", "资料更新失败，请稍后重试");
        }

        resp.sendRedirect("usercenter");
    }

    /**
     * 计算用户订单的状态统计数据
     *
     * @param orders 用户的订单列表
     * @return 包含各状态（待付款、已付款、已发货、已完成、全部）订单数量的 Map
     */
    private Map<String, Integer> calculateOrderStats(List<Order> orders) {
        Map<String, Integer> stats = new HashMap<>();
        stats.put("待付款", 0);
        stats.put("已付款", 0);
        stats.put("已发货", 0);
        stats.put("已收货", 0);
        stats.put("全部", orders.size());

        for (Order order : orders) {
            String status = order.getStatus();
            if ("已完成".equals(status)) {
                stats.put("已收货", stats.get("已收货") + 1);
            } else {
                stats.put(status, stats.getOrDefault(status, 0) + 1);
            }
        }

        return stats;
    }
}