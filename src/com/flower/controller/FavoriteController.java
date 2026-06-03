package com.flower.controller;

import com.flower.dao.FavoriteDao;
import com.flower.dao.SpDao;
import com.flower.entity.FavoriteItem;
import com.flower.entity.Sp;
import com.flower.util.JsonUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.*;

/**
 * 收藏控制器
 * <p>处理商品收藏的增删查操作，支持 AJAX 及 Session+DB 双写模式</p>
 */
@WebServlet(urlPatterns = "/favorite")
public class FavoriteController extends HttpServlet {

    private FavoriteDao favoriteDao;
    private SpDao spDao;

    @Override
    public void init() throws ServletException {
        super.init();
        this.favoriteDao = new FavoriteDao();
        this.spDao = new SpDao();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession();
        String action = req.getParameter("action");

        List<FavoriteItem> favorites = getFavorites(session);

        if ("add".equals(action)) {
            doToggleFav(req, resp, favorites, session);
            return;
        } else if ("remove".equals(action)) {
            doRemove(req, resp, favorites, session);
            return;
        }

        // list 模式：计算数据并转发到 favorites.jsp
        req.setAttribute("favoriteCount", favorites.size());
        req.getRequestDispatcher("favorites.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        doGet(req, resp);
    }

    /**
     * 切换收藏状态（已收藏则取消，未收藏则添加）
     */
    private void doToggleFav(HttpServletRequest req, HttpServletResponse resp,
                             List<FavoriteItem> favorites, HttpSession session)
            throws IOException {

        try {
            int pid = Integer.parseInt(req.getParameter("productId"));
            boolean favorited = false;

            // 检查是否已收藏
            Optional<FavoriteItem> existing = favorites.stream()
                    .filter(f -> f.getProductId() == pid).findFirst();

            if (existing.isPresent()) {
                // 已收藏 → 取消收藏
                favorites.remove(existing.get());
                Integer uid = (Integer) session.getAttribute("userId");
                if (uid != null) favoriteDao.removeFavorite(uid, pid);
                favorited = false;
            } else {
                // 未收藏 → 添加
                Sp p = spDao.findById(pid);
                if (p != null) {
                    FavoriteItem item = new FavoriteItem(pid, p.getName(), p.getPic(), p.getPrice());
                    favorites.add(item);
                    // 保持按时间倒序，新添加的在最前面
                    Integer uid = (Integer) session.getAttribute("userId");
                    if (uid != null) favoriteDao.addFavorite(uid, pid);
                }
                favorited = true;
            }

            session.setAttribute("favorites", favorites);

            if (isAjax(req)) {
                writeJson(resp, favorited, favorites.size());
            } else {
                resp.sendRedirect("favorite");
            }
        } catch (Exception e) {
            System.err.println("[FavCtrl] " + e.getMessage());
            if (isAjax(req)) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"code\":500,\"message\":\"操作失败\"}");
            } else {
                resp.sendRedirect("favorite");
            }
        }
    }

    /**
     * 取消收藏（非 AJAX 删除用）
     */
    private void doRemove(HttpServletRequest req, HttpServletResponse resp,
                          List<FavoriteItem> favorites, HttpSession session)
            throws IOException {

        try {
            int pid = Integer.parseInt(req.getParameter("productId"));
            favorites.removeIf(f -> f.getProductId() == pid);
            session.setAttribute("favorites", favorites);
            Integer uid = (Integer) session.getAttribute("userId");
            if (uid != null) favoriteDao.removeFavorite(uid, pid);

            if (isAjax(req)) {
                writeJson(resp, false, favorites.size());
            } else {
                resp.sendRedirect("favorite");
            }
        } catch (Exception e) {
            System.err.println("[FavCtrl] " + e.getMessage());
            resp.sendRedirect("favorite");
        }
    }

    /**
     * 从 Session 获取收藏列表（不存在则新建空列表）
     */
    @SuppressWarnings("unchecked")
    private List<FavoriteItem> getFavorites(HttpSession session) {
        List<FavoriteItem> fav = (List<FavoriteItem>) session.getAttribute("favorites");
        if (fav == null) {
            fav = new ArrayList<>();
            session.setAttribute("favorites", fav);
        }
        return fav;
    }

    private boolean isAjax(HttpServletRequest req) {
        return "1".equals(req.getParameter("ajax"))
                || "XMLHttpRequest".equals(req.getHeader("X-Requested-With"));
    }

    private void writeJson(HttpServletResponse resp, boolean favorited, int count) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        Map<String, Object> data = new HashMap<>();
        data.put("favorited", favorited);
        data.put("count", count);
        Map<String, Object> result = new HashMap<>();
        result.put("code", 200);
        result.put("data", data);
        PrintWriter out = resp.getWriter();
        out.print(JsonUtil.toJson(result));
        out.flush();
    }
}
