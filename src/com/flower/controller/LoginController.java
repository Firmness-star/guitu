package com.flower.controller;

import com.flower.dao.UserDao;
import com.flower.entity.User;
import com.flower.util.MD5Util;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * 登录控制器
 * 处理用户登录验证、会话管理及“记住我”功能
 */
@WebServlet("/login")
public class LoginController extends HttpServlet {

    private UserDao userDao = new UserDao();

    /**
     * 处理 GET 请求，展示登录页面并自动填充“记住我”的用户名
     *
     * @param req  HTTP 请求对象
     * @param resp HTTP 响应对象
     * @throws ServletException Servlet 异常
     * @throws IOException      IO 异常
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // AJAX 角色检测：前端输入用户名时判断是否需要验证码
        String action = req.getParameter("action");
        if ("checkRole".equals(action)) {
            String username = req.getParameter("username");
            resp.setContentType("application/json;charset=UTF-8");
            if (username == null || username.trim().isEmpty()) {
                resp.getWriter().write("{\"requireCode\":true,\"role\":\"未知\"}");
                return;
            }
            User user = userDao.findByUsername(username.trim());
            if (user != null && ("管理员".equals(user.getRole()) || "商家".equals(user.getRole()))) {
                resp.getWriter().write("{\"requireCode\":false,\"role\":\"" + user.getRole() + "\"}");
            } else {
                resp.getWriter().write("{\"requireCode\":true,\"role\":\"" + (user != null ? user.getRole() : "未知") + "\"}");
            }
            return;
        }
        handleRememberMe(req);
        req.getRequestDispatcher("login.jsp").forward(req, resp);
    }

    /**
     * 处理 POST 请求，执行用户身份验证及登录后的跳转逻辑
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
        String password = req.getParameter("password");
        String remember = req.getParameter("remember");
        String verifyCode = req.getParameter("verifyCode");

        // 先查用户，如果是管理员或商家则跳过验证码
        if (username != null && !username.trim().isEmpty()) {
            User admin = userDao.findByUsername(username.trim());
            if (admin == null || (!"管理员".equals(admin.getRole()) && !"商家".equals(admin.getRole()))) {
                // 非管理员需要验证码
                String sessionCode = (String) req.getSession().getAttribute("verifyCode");
                if (sessionCode == null || !sessionCode.equalsIgnoreCase(verifyCode != null ? verifyCode.trim() : "")) {
                    req.setAttribute("error", "验证码错误");
                    req.setAttribute("username", username);
                    req.getRequestDispatcher("login.jsp").forward(req, resp);
                    return;
                }
            }
        }

        System.out.println("========== 登录调试信息 ==========");
        System.out.println("用户名: " + username);
        System.out.println("密码: " + password);
        
        if (username == null || username.trim().isEmpty() ||
                password == null || password.trim().isEmpty()) {
            System.out.println("错误: 用户名或密码为空");
            req.setAttribute("error", "用户名和密码不能为空");
            req.getRequestDispatcher("login.jsp").forward(req, resp);
            return;
        }

        // 测试 MD5 加密
        String encryptedPassword = MD5Util.encrypt(password);
        System.out.println("MD5加密后的密码: " + encryptedPassword);
        
        // 先查找用户是否存在
        User userByName = userDao.findByUsername(username);
        if (userByName == null) {
            System.out.println("错误: 用户不存在 - " + username);
            req.setAttribute("error", "用户名或密码错误");
            req.setAttribute("username", username);
            req.getRequestDispatcher("login.jsp").forward(req, resp);
            return;
        }
        
        System.out.println("找到用户: " + userByName.getUsername());
        System.out.println("数据库中的密码: " + userByName.getPass());
        System.out.println("用户角色: " + userByName.getRole());
        System.out.println("用户状态: " + userByName.getState());
        
        // 使用用户名和密码查询
        User user = userDao.findByUsernameAndPassword(username, password);

        if (user != null) {
            System.out.println("登录成功!");
            
            if ("禁用".equals(user.getState())) {
                System.out.println("错误: 账户已被禁用");
                req.setAttribute("error", "账户已被禁用，请联系管理员");
                req.getRequestDispatcher("login.jsp").forward(req, resp);
                return;
            }

            userDao.updateLastLoginTime(username);

            // 记录登录日志
            String ip = getClientIp(req);
            String userAgent = req.getHeader("User-Agent");
            userDao.recordLoginLog(user.getId(), user.getUsername(), ip, userAgent);

            HttpSession session = req.getSession();
            session.setAttribute("userId", user.getId());
            session.setAttribute("username", user.getUsername());
            session.setAttribute("userRole", user.getRole());
            session.setAttribute("loginTime", new java.util.Date());
            session.setAttribute("userEmail", user.getEmail());
            session.setAttribute("userPhone", user.getTel());
            // 同步头像路径到 session
            if (user.getAvatar() != null && !user.getAvatar().isEmpty()) {
                session.setAttribute("userAvatar", user.getAvatar());
            }

            // 处理"记住我"功能
            if ("on".equals(remember)) {
                createRememberMeCookie(resp, username);
            } else {
                removeRememberMeCookie(resp);
            }

            // 根据角色跳转到不同页面
            String redirect = req.getParameter("redirect");
            if (redirect != null && !redirect.isEmpty()) {
                System.out.println("重定向到: " + redirect);
                resp.sendRedirect(redirect);
            } else if ("管理员".equals(user.getRole())) {
                System.out.println("重定向到管理员后台");
                resp.sendRedirect(req.getContextPath() + "/admin/index");
            } else if ("商家".equals(user.getRole())) {
                System.out.println("重定向到商家后台");
                resp.sendRedirect(req.getContextPath() + "/merchant/index");
            } else {
                System.out.println("重定向到首页");
                resp.sendRedirect("index.jsp?welcome=1");
            }

        } else {
            System.out.println("错误: 密码不匹配");
            System.out.println("输入的密码MD5: " + encryptedPassword);
            System.out.println("数据库密码: " + userByName.getPass());
            System.out.println("是否相等: " + encryptedPassword.equals(userByName.getPass()));
            
            req.setAttribute("error", "用户名或密码错误");
            req.setAttribute("username", username);
            req.getRequestDispatcher("login.jsp").forward(req, resp);
        }
        
        System.out.println("====================================");
    }

    /**
     * 获取客户端真实 IP 地址
     *
     * @param request HTTP 请求对象
     * @return 客户端 IP 地址
     */
    private String getClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_CLIENT_IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_X_FORWARDED_FOR");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        // 多级代理取第一个
        if (ip != null && ip.contains(",")) {
            ip = ip.split(",")[0].trim();
        }
        // IPv6 本地环回地址转换为可读格式
        if ("0:0:0:0:0:0:0:1".equals(ip) || "::1".equals(ip)) {
            ip = "127.0.0.1";
        }
        return ip;
    }

    /**
     * 处理“记住我”功能，从 Cookie 中读取已保存的用户名并回显到登录页
     *
     * @param req HTTP 请求对象
     */
    private void handleRememberMe(HttpServletRequest req) {
        Cookie[] cookies = req.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if ("remember_username".equals(cookie.getName())) {
                    String username = cookie.getValue();
                    if (username != null && !username.isEmpty()) {
                        req.setAttribute("rememberedUsername", username);
                        req.setAttribute("rememberChecked", true);
                    }
                    break;
                }
            }
        }
    }

    /**
     * 创建“记住我” Cookie，保存用户名至客户端
     *
     * @param resp     HTTP 响应对象
     * @param username 需要保存的用户名
     */
    private void createRememberMeCookie(HttpServletResponse resp, String username) {
        Cookie cookie = new Cookie("remember_username", username);
        cookie.setMaxAge(7 * 24 * 60 * 60); // 7天
        cookie.setPath("/");
        cookie.setHttpOnly(true);
        resp.addCookie(cookie);
    }

    /**
     * 删除“记住我” Cookie，取消自动填充
     *
     * @param resp HTTP 响应对象
     */
    private void removeRememberMeCookie(HttpServletResponse resp) {
        Cookie cookie = new Cookie("remember_username", "");
        cookie.setMaxAge(0);
        cookie.setPath("/");
        resp.addCookie(cookie);
    }
}