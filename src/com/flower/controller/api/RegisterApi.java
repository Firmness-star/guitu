package com.flower.controller.api;

import com.flower.dao.UserDao;
import com.flower.entity.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/api/register")
public class RegisterApi extends ApiBaseServlet {

    private UserDao userDao = new UserDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("checkUsername".equals(action)) {
            checkUsername(req, resp);
        } else if ("checkTel".equals(action)) {
            checkTel(req, resp);
        } else if ("checkEmail".equals(action)) {
            checkEmail(req, resp);
        } else {
            fail(resp, 400, "未知操作");
        }
    }

    private void checkUsername(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String username = req.getParameter("username");
        if (username == null || username.trim().isEmpty()) { fail(resp, 400, "用户名不能为空"); return; }
        username = username.trim();
        if (username.length() < 3 || username.length() > 20) { fail(resp, 400, "用户名长度应为3-20位"); return; }
        if (!username.matches("^[a-zA-Z0-9_]+$")) { fail(resp, 400, "用户名只能包含字母、数字和下划线"); return; }
        if (userDao.isUsernameExists(username)) fail(resp, 400, "该用户名已被占用");
        else ok(resp, "用户名可用", null);
    }

    private void checkTel(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String tel = req.getParameter("tel");
        if (tel == null || tel.trim().isEmpty()) { fail(resp, 400, "手机号不能为空"); return; }
        tel = tel.trim();
        if (!tel.matches("^1[3-9]\\d{9}$")) { fail(resp, 400, "请输入有效的11位手机号"); return; }
        if (userDao.isTelExists(tel)) fail(resp, 400, "该手机号已被占用");
        else ok(resp, "手机号可用", null);
    }

    private void checkEmail(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String email = req.getParameter("email");
        if (email == null || email.trim().isEmpty()) { fail(resp, 400, "邮箱不能为空"); return; }
        email = email.trim();
        if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) { fail(resp, 400, "请输入有效的邮箱地址"); return; }
        if (userDao.isEmailExists(email)) fail(resp, 400, "该邮箱已被占用");
        else ok(resp, "邮箱可用", null);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String username = req.getParameter("username");
        String tel = req.getParameter("tel");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");
        String verifyCode = req.getParameter("verifyCode");

        String sessionCode = (String) req.getSession().getAttribute("verifyCode");
        if (sessionCode == null || !sessionCode.equalsIgnoreCase(verifyCode != null ? verifyCode.trim() : "")) {
            fail(resp, 400, "验证码错误"); return;
        }
        if (username == null || username.length() < 3 || username.length() > 20 || !username.matches("^[a-zA-Z0-9_]+$")) {
            fail(resp, 400, "用户名格式不正确"); return;
        }
        if (tel == null || !tel.matches("^1[3-9]\\d{9}$")) { fail(resp, 400, "手机号格式不正确"); return; }
        if (email == null || !email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) { fail(resp, 400, "邮箱格式不正确"); return; }
        if (password == null || password.length() < 6) { fail(resp, 400, "密码长度不能少于6位"); return; }
        if (!password.equals(confirmPassword)) { fail(resp, 400, "两次密码不一致"); return; }
        if (userDao.isUsernameExists(username)) { fail(resp, 400, "用户名已被注册"); return; }
        if (userDao.isTelExists(tel)) { fail(resp, 400, "该手机号已被注册"); return; }
        if (userDao.isEmailExists(email)) { fail(resp, 400, "该邮箱已被注册"); return; }

        User user = new User(username, password, tel, email);
        user.setJf(200);
        if (userDao.save(user)) {
            ok(resp, "注册成功", null);
        } else {
            fail(resp, 500, "注册失败");
        }
    }
}
