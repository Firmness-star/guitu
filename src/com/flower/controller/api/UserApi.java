package com.flower.controller.api;

import com.flower.dao.UserDao;
import com.flower.entity.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet("/api/user")
public class UserApi extends ApiBaseServlet {

    private UserDao userDao = new UserDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer uid = getUserId(req);
        String username = getUsername(req);
        if (uid == null || username == null) { unauth(resp); return; }
        User user = userDao.findByUsername(username);
        if (user == null) { fail(resp, 404, "用户不存在"); return; }
        Map<String, Object> data = new HashMap<>();
        data.put("id", user.getId());
        data.put("username", user.getUsername());
        data.put("tel", user.getTel());
        data.put("email", user.getEmail());
        data.put("gender", user.getGender());
        data.put("role", user.getRole());
        data.put("jf", user.getJf());
        data.put("avatar", user.getAvatar());
        data.put("createTime", user.getCreateTime());
        ok(resp, data);
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer uid = getUserId(req);
        if (uid == null) { unauth(resp); return; }

        String action = req.getParameter("action");
        if ("updateInfo".equals(action)) {
            String tel = req.getParameter("tel");
            String email = req.getParameter("email");
            if (tel == null || !tel.matches("^1[3-9]\\d{9}$")) { fail(resp, 400, "手机号格式不正确"); return; }
            if (email == null || !email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) { fail(resp, 400, "邮箱格式不正确"); return; }
            if (userDao.isTelUsedByOther(tel.trim(), uid)) { fail(resp, 400, "该手机号已被其他用户使用"); return; }
            if (userDao.isEmailUsedByOther(email.trim(), uid)) { fail(resp, 400, "该邮箱已被其他用户使用"); return; }
            userDao.updateUserInfo(uid, tel.trim(), email.trim());
            HttpSession session = req.getSession();
            session.setAttribute("userPhone", tel.trim());
            session.setAttribute("userEmail", email.trim());
            ok(resp, "更新成功", null);
        } else if ("changePwd".equals(action)) {
            String oldPwd = req.getParameter("oldPassword");
            String newPwd = req.getParameter("newPassword");
            if (newPwd == null || newPwd.length() < 6) { fail(resp, 400, "新密码长度不能少于6位"); return; }
            User u = userDao.findById(uid);
            if (u == null || !u.getPass().equals(com.flower.util.MD5Util.encrypt(oldPwd))) { fail(resp, 400, "原密码错误"); return; }
            userDao.updatePassword(uid, newPwd);
            ok(resp, "密码修改成功", null);
        } else {
            fail(resp, 400, "未知操作");
        }
    }
}
