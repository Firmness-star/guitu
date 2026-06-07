package com.flower.controller.api;

import com.flower.dao.UserDao;
import com.flower.dao.JfDao;
import com.flower.entity.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.*;

@WebServlet("/api/user")
public class UserApi extends ApiBaseServlet {

    private UserDao userDao = new UserDao();
    private JfDao jfDao = new JfDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer uid = getUserId(req);
        String username = getUsername(req);
        if (uid == null || username == null) { unauth(resp); return; }

        String action = req.getParameter("action");
        if ("jfLogs".equals(action)) {
            int limit = 50;
            try { limit = Integer.parseInt(req.getParameter("limit")); } catch (NumberFormatException e) {}
            List<Map<String, Object>> logs = jfDao.findByUserId(uid, limit);
            List<Map<String, Object>> result = new ArrayList<>();
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            for (Map<String, Object> log : logs) {
                Map<String, Object> item = new HashMap<>();
                item.put("id", log.get("id"));
                item.put("amount", log.get("amount"));
                item.put("source", log.get("source"));
                item.put("description", log.get("description"));
                Object ct = log.get("createTime");
                item.put("createTime", ct != null ? sdf.format(ct) : null);
                result.add(item);
            }
            ok(resp, result);
            return;
        }

        if ("loginLogs".equals(action)) {
            int limit = 20;
            try { limit = Integer.parseInt(req.getParameter("limit")); } catch (NumberFormatException e) {}
            List<Map<String, Object>> rawLogs = userDao.getRecentLoginLogs(uid, limit);
            List<Map<String, Object>> result = new ArrayList<>();
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            for (Map<String, Object> log : rawLogs) {
                Map<String, Object> item = new HashMap<>();
                item.put("loginIp", log.get("loginIp"));
                item.put("userAgent", log.get("userAgent"));
                Object lt = log.get("loginTime");
                item.put("loginTime", lt != null ? sdf.format(lt) : null);
                result.add(item);
            }
            ok(resp, result);
            return;
        }

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
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        data.put("createTime", user.getCreateTime() != null ? sdf.format(user.getCreateTime()) : null);
        data.put("lastLoginTime", user.getLastLoginTime() != null ? sdf.format(user.getLastLoginTime()) : null);
        ok(resp, data);
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doPost(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        Integer uid = getUserId(req);
        if (uid == null) { unauth(resp); return; }

        String action = req.getParameter("action");
        if ("updateInfo".equals(action)) {
            String tel = req.getParameter("tel");
            String email = req.getParameter("email");
            String gender = req.getParameter("gender");
            if (tel == null || !tel.matches("^1[3-9]\\d{9}$")) { fail(resp, 400, "手机号格式不正确"); return; }
            if (email == null || !email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) { fail(resp, 400, "邮箱格式不正确"); return; }

            User current = userDao.findById(uid);
            // 只在真正修改了手机号/邮箱时才查重
            if ((current == null || !tel.trim().equals(current.getTel())) && userDao.isTelUsedByOther(tel.trim(), uid)) {
                fail(resp, 400, "该手机号已被其他用户使用"); return;
            }
            if ((current == null || !email.trim().equals(current.getEmail())) && userDao.isEmailUsedByOther(email.trim(), uid)) {
                fail(resp, 400, "该邮箱已被其他用户使用"); return;
            }
            userDao.updateUserInfo(uid, tel.trim(), email.trim());
            if (gender != null && !gender.isEmpty()) {
                userDao.updateGender(uid, gender);
            }
            HttpSession session = req.getSession();
            session.setAttribute("userPhone", tel.trim());
            session.setAttribute("userEmail", email.trim());
            ok(resp, "更新成功", null);
        } else if ("changePwd".equals(action)) {
            String oldPwd = req.getParameter("oldPassword");
            String newPwd = req.getParameter("newPassword");
            if (newPwd == null || newPwd.length() < 6) { fail(resp, 400, "新密码长度不能少于6位"); return; }
            if (oldPwd == null || oldPwd.isEmpty()) { fail(resp, 400, "请输入原密码"); return; }
            User u = userDao.findById(uid);
            if (u == null) { fail(resp, 400, "用户不存在"); return; }
            String oldHash = com.flower.util.MD5Util.encrypt(oldPwd);
            if (!u.getPass().equals(oldHash)) {
                System.err.println("[UserApi] 密码校验失败 uid=" + uid + " 输入加密=" + oldHash + " 存储=" + u.getPass());
                fail(resp, 400, "原密码错误"); return;
            }
            userDao.updatePassword(uid, newPwd);
            ok(resp, "密码修改成功", null);
        } else {
            fail(resp, 400, "未知操作");
        }
    }
}
