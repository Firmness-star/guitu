package com.flower.controller;

import com.flower.dao.UserDao;
import com.flower.entity.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * 账号安全控制器
 * 处理修改密码、修改绑定信息等功能
 */
@WebServlet(urlPatterns = "/security")
public class SecurityController extends HttpServlet {

    private UserDao userDao;

    @Override
    public void init() throws ServletException {
        super.init();
        this.userDao = new UserDao();
    }

    /**
     * 处理 GET 请求，展示账号安全设置页面
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
        Integer userId = (Integer) session.getAttribute("userId");
        String username = (String) session.getAttribute("username");

        if (userId == null || username == null) {
            resp.sendRedirect("login");
            return;
        }

        User user = userDao.findByUsername(username);
        if (user == null) {
            session.invalidate();
            resp.sendRedirect("login");
            return;
        }

        req.setAttribute("user", user);
        
        // 获取最近登录日志（最多10条）
        java.util.List<java.util.Map<String, Object>> loginLogs = userDao.getRecentLoginLogs(userId, 10);
        req.setAttribute("loginLogs", loginLogs);
        
        String tab = req.getParameter("tab");
        if ("logs".equals(tab)) {
            req.setAttribute("activeTab", "logs");
        } else {
            req.setAttribute("activeTab", "password");
        }
        
        req.getRequestDispatcher("security.jsp").forward(req, resp);
    }

    /**
     * 处理 POST 请求，根据 action 参数分发到不同的安全设置操作
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
        String username = (String) session.getAttribute("username");

        if (userId == null) {
            resp.sendRedirect("login");
            return;
        }

        String action = req.getParameter("action");

        if ("changePassword".equals(action)) {
            changePassword(req, resp, userId, username);
        } else {
            doGet(req, resp);
        }
    }

    /**
     * 修改用户登录密码
     *
     * @param req      HTTP 请求对象
     * @param resp     HTTP 响应对象
     * @param userId   当前登录用户的 ID
     * @param username 当前登录用户的用户名
     * @throws ServletException Servlet 异常
     * @throws IOException      IO 异常
     */
    private void changePassword(HttpServletRequest req, HttpServletResponse resp, Integer userId, String username)
            throws ServletException, IOException {

        String oldPassword = req.getParameter("oldPassword");
        String newPassword = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        User user = userDao.findByUsername(username);

        if (user == null) {
            req.setAttribute("error", "用户信息不存在");
            doGet(req, resp);
            return;
        }

        if (isEmpty(oldPassword) || isEmpty(newPassword) || isEmpty(confirmPassword)) {
            req.setAttribute("error", "请填写完整信息");
            req.setAttribute("user", user);
            req.setAttribute("activeTab", "password");
            req.getRequestDispatcher("security.jsp").forward(req, resp);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            req.setAttribute("error", "两次输入的密码不一致");
            req.setAttribute("user", user);
            req.setAttribute("activeTab", "password");
            req.getRequestDispatcher("security.jsp").forward(req, resp);
            return;
        }

        if (newPassword.length() < 6) {
            req.setAttribute("error", "新密码长度不能少于6位");
            req.setAttribute("user", user);
            req.setAttribute("activeTab", "password");
            req.getRequestDispatcher("security.jsp").forward(req, resp);
            return;
        }

        // 验证原密码是否正确
        if (!com.flower.util.MD5Util.encrypt(oldPassword).equals(user.getPass())) {
            req.setAttribute("error", "原密码错误");
            req.setAttribute("user", user);
            req.setAttribute("activeTab", "password");
            req.getRequestDispatcher("security.jsp").forward(req, resp);
            return;
        }

        boolean success = userDao.updatePassword(userId, newPassword);

        if (success) {
            req.setAttribute("success", "密码修改成功，请重新登录");
            req.setAttribute("user", user);
            req.setAttribute("activeTab", "password");
            req.getRequestDispatcher("security.jsp").forward(req, resp);
        } else {
            req.setAttribute("error", "密码修改失败，请稍后重试");
            req.setAttribute("user", user);
            req.setAttribute("activeTab", "password");
            req.getRequestDispatcher("security.jsp").forward(req, resp);
        }
    }

    /**
     * 检查字符串是否为空或仅包含空白字符
     *
     * @param str 待检查的字符串
     * @return 如果字符串为 null 或 trim 后为空则返回 true，否则返回 false
     */
    private boolean isEmpty(String str) {
        return str == null || str.trim().isEmpty();
    }
}
