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
