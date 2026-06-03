package com.flower.controller;

import com.flower.dao.CartDao;
import com.flower.dao.FavoriteDao;
import com.flower.dao.JfDao;
import com.flower.dao.UserDao;
import com.flower.entity.CartItem;
import com.flower.entity.FavoriteItem;
import com.flower.entity.User;
import com.flower.util.MD5Util;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * 登录控制器
 * 处理用户登录验证、会话管理及“记住我”功能
 */
@WebServlet("/login")
public class LoginController extends HttpServlet {

    private UserDao userDao = new UserDao();
    private JfDao jfDao = new JfDao();

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


        if (username == null || username.trim().isEmpty() ||
                password == null || password.trim().isEmpty()) {
            req.setAttribute("error", "用户名和密码不能为空");
            req.getRequestDispatcher("login.jsp").forward(req, resp);
            return;
        }

        String encryptedPassword = MD5Util.encrypt(password);

        User userByName = userDao.findByUsername(username);
        if (userByName == null) {
            req.setAttribute("error", "用户名或密码错误");
            req.setAttribute("username", username);
            req.getRequestDispatcher("login.jsp").forward(req, resp);
            return;
        }

        User user = userDao.findByUsernameAndPassword(username, password);

        if (user != null) {

            if ("禁用".equals(user.getState())) {
                req.setAttribute("error", "账户已被禁用，请联系管理员");
                req.getRequestDispatcher("login.jsp").forward(req, resp);
                return;
            }

            userDao.updateLastLoginTime(username);

            String ip = getClientIp(req);
            String userAgent = req.getHeader("User-Agent");
            userDao.recordLoginLog(user.getId(), user.getUsername(), ip, userAgent);

            HttpSession session = req.getSession();

            // 将游客购物车合并到数据库购物车
            @SuppressWarnings("unchecked")
            List<CartItem> guestCart = (List<CartItem>) session.getAttribute("cart");
            CartDao cartDao = new CartDao();
            if (guestCart != null && !guestCart.isEmpty()) {
                List<CartItem> mergedCart = cartDao.mergeCart(user.getId(), guestCart);
                session.setAttribute("cart", mergedCart);
            }
            session.setAttribute("cartLoadedFromDb", true);

            // 将游客收藏夹合并到数据库收藏夹
            @SuppressWarnings("unchecked")
            List<FavoriteItem> guestFav = (List<FavoriteItem>) session.getAttribute("favorites");
            FavoriteDao favDao = new FavoriteDao();
            if (guestFav != null && !guestFav.isEmpty()) {
                for (FavoriteItem item : guestFav) {
                    favDao.addFavorite(user.getId(), item.getProductId());
                }
                List<FavoriteItem> mergedFav = favDao.findByUserId(user.getId());
                session.setAttribute("favorites", mergedFav);
            }
            session.setAttribute("favoritesLoadedFromDb", true);

            session.setAttribute("userId", user.getId());
            session.setAttribute("username", user.getUsername());
            session.setAttribute("userRole", user.getRole());
            session.setAttribute("loginTime", new java.util.Date());
            session.setAttribute("userEmail", user.getEmail());
            session.setAttribute("userPhone", user.getTel());

            // 每日首次登录赠送 5 积分
            if (!jfDao.hasTodaySource(user.getId(), "login")) {
                userDao.addJf(user.getId(), 5);
                jfDao.addLog(user.getId(), 5, "login", "每日首次登录赠送5积分");
            }
            if (user.getAvatar() != null && !user.getAvatar().isEmpty()) {
                session.setAttribute("userAvatar", user.getAvatar());
            }

            if ("on".equals(remember)) {
                createRememberMeCookie(resp, username);
            } else {
                removeRememberMeCookie(resp);
            }

            String redirect = req.getParameter("redirect");
            if (redirect != null && !redirect.isEmpty()) {
                resp.sendRedirect(redirect);
            } else if ("管理员".equals(user.getRole())) {
                resp.sendRedirect(req.getContextPath() + "/admin/index");
            } else if ("商家".equals(user.getRole())) {
                resp.sendRedirect(req.getContextPath() + "/merchant/index");
            } else {
                resp.sendRedirect("index.jsp?welcome=1");
            }

        } else {
            req.setAttribute("error", "用户名或密码错误");
            req.setAttribute("username", username);
            req.getRequestDispatcher("login.jsp").forward(req, resp);
        }
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