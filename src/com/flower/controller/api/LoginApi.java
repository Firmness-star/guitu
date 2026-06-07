package com.flower.controller.api;

import com.flower.dao.UserDao;
import com.flower.dao.CartDao;
import com.flower.dao.FavoriteDao;
import com.flower.entity.User;
import com.flower.entity.CartItem;
import com.flower.entity.FavoriteItem;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet("/api/login")
public class LoginApi extends ApiBaseServlet {

    private UserDao userDao = new UserDao();
    private CartDao cartDao = new CartDao();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String verifyCode = req.getParameter("verifyCode");

        if (username == null || username.trim().isEmpty() || password == null || password.isEmpty()) {
            fail(resp, 400, "用户名和密码不能为空"); return;
        }

        User admin = userDao.findByUsername(username.trim());
        if (admin == null || (!"管理员".equals(admin.getRole()) && !"商家".equals(admin.getRole()))) {
            String sessionCode = (String) req.getSession().getAttribute("verifyCode");
            if (sessionCode == null || !sessionCode.equalsIgnoreCase(verifyCode != null ? verifyCode.trim() : "")) {
                fail(resp, 400, "验证码错误"); return;
            }
        }

        User user = userDao.findByUsernameAndPassword(username, password);
        if (user == null) { fail(resp, 400, "用户名或密码错误"); return; }
        if ("禁用".equals(user.getState())) { fail(resp, 403, "账户已被禁用"); return; }

        userDao.updateLastLoginTime(username);

        HttpSession session = req.getSession();
        List<CartItem> guestCart = (List<CartItem>) session.getAttribute("cart");
        if (guestCart != null && !guestCart.isEmpty()) {
            List<CartItem> merged = cartDao.mergeCart(user.getId(), guestCart);
            session.setAttribute("cart", merged);
        }
        session.setAttribute("cartLoadedFromDb", true);

        // 将游客收藏夹合并到数据库
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
        session.setAttribute("userEmail", user.getEmail());
        session.setAttribute("userPhone", user.getTel());

        Map<String, Object> data = new HashMap<>();
        data.put("id", user.getId());
        data.put("username", user.getUsername());
        data.put("role", user.getRole());
        data.put("email", user.getEmail());
        data.put("phone", user.getTel());
        data.put("gender", user.getGender());
        data.put("avatar", user.getAvatar());
        data.put("jf", user.getJf());
        ok(resp, "登录成功", data);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (isLoggedIn(req)) {
            Map<String, Object> data = new HashMap<>();
            data.put("id", getUserId(req));
            data.put("username", getUsername(req));
            data.put("role", req.getSession().getAttribute("userRole"));
            ok(resp, data);
        } else {
            fail(resp, 401, "未登录");
        }
    }
}
