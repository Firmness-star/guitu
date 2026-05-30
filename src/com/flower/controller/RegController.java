package com.flower.controller;
import com.flower.dao.UserDao;
import com.flower.entity.User;
import com.flower.util.JsonUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

/**
 * 用户注册控制器
 * 处理用户注册页面的展示及注册信息的提交与验证
 */
@WebServlet("/reg")
public class RegController extends HttpServlet {

    private UserDao userDao = new UserDao();

    /**
     * 处理 GET 请求，展示注册页面或处理 AJAX 请求
     *
     * @param req  HTTP 请求对象
     * @param resp HTTP 响应对象
     * @throws ServletException Servlet 异常
     * @throws IOException      IO 异常
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // 处理 AJAX 请求
        String action = req.getParameter("action");
        if ("checkUsername".equals(action)) {
            checkUsernameAvailability(req, resp);
            return;
        }
        if ("checkTel".equals(action)) {
            checkTelAvailability(req, resp);
            return;
        }
        if ("checkEmail".equals(action)) {
            checkEmailAvailability(req, resp);
            return;
        }

        req.getRequestDispatcher("reg.jsp").forward(req, resp);
    }

    /**
     * 处理 POST 请求，执行用户注册逻辑
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

        String username = req.getParameter("username");
        String tel = req.getParameter("tel");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");
        String verifyCode = req.getParameter("verifyCode");

        // 验证码校验
        String sessionCode = (String) req.getSession().getAttribute("verifyCode");
        if (sessionCode == null || !sessionCode.equalsIgnoreCase(verifyCode != null ? verifyCode.trim() : "")) {
            req.setAttribute("error", "验证码错误");
            preserveFormData(req, username, tel, email);
            req.getRequestDispatcher("reg.jsp").forward(req, resp);
            return;
        }

        // 验证输入数据的合法性
        String errorMsg = validateInput(username, tel, email, password, confirmPassword);
        if (errorMsg != null) {
            req.setAttribute("error", errorMsg);
            preserveFormData(req, username, tel, email);
            req.getRequestDispatcher("reg.jsp").forward(req, resp);
            return;
        }

        // 检查用户名是否已被占用
        if (userDao.isUsernameExists(username)) {
            req.setAttribute("error", "用户名已被注册，请选择其他用户名");
            preserveFormData(req, username, tel, email);
            req.getRequestDispatcher("reg.jsp").forward(req, resp);
            return;
        }

        // 检查手机号是否已被占用
        if (userDao.isTelExists(tel)) {
            req.setAttribute("error", "该手机号已被注册，请使用其他手机号");
            preserveFormData(req, username, tel, email);
            req.getRequestDispatcher("reg.jsp").forward(req, resp);
            return;
        }

        // 检查邮箱是否已被占用
        if (userDao.isEmailExists(email)) {
            req.setAttribute("error", "该邮箱已被注册，请使用其他邮箱");
            preserveFormData(req, username, tel, email);
            req.getRequestDispatcher("reg.jsp").forward(req, resp);
            return;
        }

        User user = new User(username, password, tel, email);
        user.setJf(200);  // 新用户注册赠送200积分

        if (userDao.save(user)) {
            resp.sendRedirect("login.jsp?registered=1");
        } else {
            req.setAttribute("error", "注册失败，请稍后重试");
            preserveFormData(req, username, tel, email);
            req.getRequestDispatcher("reg.jsp").forward(req, resp);
        }
    }

    /**
     * 验证注册表单输入数据的有效性
     *
     * @param username        用户名
     * @param tel             手机号
     * @param email           邮箱地址
     * @param password        密码
     * @param confirmPassword 确认密码
     * @return 如果验证通过返回 null，否则返回错误提示信息
     */
    private String validateInput(String username, String tel, String email,
                                 String password, String confirmPassword) {
        if (username == null || username.trim().isEmpty()) {
            return "用户名不能为空";
        }
        if (username.length() < 3 || username.length() > 20) {
            return "用户名长度应为3-20位";
        }
        if (!username.matches("^[a-zA-Z0-9_]+$")) {
            return "用户名只能包含字母、数字和下划线";
        }

        if (tel == null || tel.trim().isEmpty()) {
            return "手机号不能为空";
        }
        if (!tel.matches("^1[3-9]\\d{9}$")) {
            return "请输入有效的11位手机号";
        }

        if (email == null || email.trim().isEmpty()) {
            return "邮箱不能为空";
        }
        if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
            return "请输入有效的邮箱地址";
        }

        if (password == null || password.isEmpty()) {
            return "密码不能为空";
        }
        if (password.length() < 6 || password.length() > 20) {
            return "密码长度应为6-20位";
        }

        if (!password.equals(confirmPassword)) {
            return "两次输入的密码不一致";
        }

        return null;
    }

    /**
     * 在注册失败时保留用户已填写的表单数据，提升用户体验
     *
     * @param req      HTTP 请求对象
     * @param username 用户名
     * @param tel      手机号
     * @param email    邮箱地址
     */
    private void preserveFormData(HttpServletRequest req, String username, String tel, String email) {
        req.setAttribute("username", username);
        req.setAttribute("tel", tel);
        req.setAttribute("email", email);
    }

    /**
     * 异步检测用户名是否可用（AJAX 接口）
     *
     * @param req  HTTP 请求对象
     * @param resp HTTP 响应对象
     * @throws IOException IO 异常
     */
    private void checkUsernameAvailability(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        Map<String, Object> result = new HashMap<>();
        
        String username = req.getParameter("username");
        
        if (username == null || username.trim().isEmpty()) {
            result.put("available", false);
            result.put("message", "用户名不能为空");
            out.print(JsonUtil.toJson(result));
            return;
        }
        
        username = username.trim();
        
        // 验证用户名格式
        if (username.length() < 3 || username.length() > 20) {
            result.put("available", false);
            result.put("message", "用户名长度应为3-20位");
            out.print(JsonUtil.toJson(result));
            return;
        }
        
        if (!username.matches("^[a-zA-Z0-9_]+$")) {
            result.put("available", false);
            result.put("message", "用户名只能包含字母、数字和下划线");
            out.print(JsonUtil.toJson(result));
            return;
        }
        
        // 检测用户名是否已存在
        boolean exists = userDao.isUsernameExists(username);
        if (exists) {
            result.put("available", false);
            result.put("message", "该用户名已被占用，请更换");
        } else {
            result.put("available", true);
            result.put("message", "用户名可用");
        }
        
        out.print(JsonUtil.toJson(result));
    }

    private void checkTelAvailability(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        Map<String, Object> result = new HashMap<>();

        String tel = req.getParameter("tel");
        if (tel == null || tel.trim().isEmpty()) {
            result.put("available", false);
            result.put("message", "手机号不能为空");
            out.print(JsonUtil.toJson(result));
            return;
        }
        tel = tel.trim();
        if (!tel.matches("^1[3-9]\\d{9}$")) {
            result.put("available", false);
            result.put("message", "请输入有效的11位手机号");
            out.print(JsonUtil.toJson(result));
            return;
        }
        boolean exists = userDao.isTelExists(tel);
        result.put("available", !exists);
        result.put("message", exists ? "该手机号已被占用" : "手机号可用");
        out.print(JsonUtil.toJson(result));
    }

    private void checkEmailAvailability(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        Map<String, Object> result = new HashMap<>();

        String email = req.getParameter("email");
        if (email == null || email.trim().isEmpty()) {
            result.put("available", false);
            result.put("message", "邮箱不能为空");
            out.print(JsonUtil.toJson(result));
            return;
        }
        email = email.trim();
        if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
            result.put("available", false);
            result.put("message", "请输入有效的邮箱地址");
            out.print(JsonUtil.toJson(result));
            return;
        }
        boolean exists = userDao.isEmailExists(email);
        result.put("available", !exists);
        result.put("message", exists ? "该邮箱已被占用" : "邮箱可用");
        out.print(JsonUtil.toJson(result));
    }
}