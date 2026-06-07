package com.flower.controller.api;

import com.flower.dao.FavoriteDao;
import com.flower.dao.SpDao;
import com.flower.entity.FavoriteItem;
import com.flower.entity.Sp;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet("/api/favorites")
public class FavoriteApi extends ApiBaseServlet {

    private FavoriteDao favoriteDao = new FavoriteDao();
    private SpDao spDao = new SpDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer uid = getUserId(req);
        if (uid == null) { unauth(resp); return; }
        List<FavoriteItem> list = favoriteDao.findByUserId(uid);
        Map<String, Object> data = new HashMap<>();
        data.put("list", list);
        data.put("count", list.size());
        ok(resp, data);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer uid = getUserId(req);
        if (uid == null) { unauth(resp); return; }
        try {
            int productId = Integer.parseInt(req.getParameter("productId"));
            Sp p = spDao.findById(productId);
            if (p == null) { fail(resp, 404, "商品不存在"); return; }
            if (favoriteDao.isFavorited(uid, productId)) {
                fail(resp, 400, "已收藏");
            } else {
                favoriteDao.addFavorite(uid, productId);
                ok(resp, "收藏成功", null);
            }
        } catch (NumberFormatException e) { fail(resp, 400, "参数错误"); }
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer uid = getUserId(req);
        if (uid == null) { unauth(resp); return; }
        try {
            int productId = Integer.parseInt(req.getParameter("productId"));
            favoriteDao.removeFavorite(uid, productId);
            ok(resp, "已取消收藏", null);
        } catch (NumberFormatException e) { fail(resp, 400, "参数错误"); }
    }
}
