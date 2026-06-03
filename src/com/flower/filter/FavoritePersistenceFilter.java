package com.flower.filter;

import com.flower.dao.FavoriteDao;
import com.flower.entity.FavoriteItem;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * 收藏夹持久化过滤器
 * <p>登录用户每次请求时，自动从数据库加载收藏数据到 Session 中</p>
 */
@WebFilter(filterName = "FavoritePersistenceFilter", urlPatterns = "/*")
public class FavoritePersistenceFilter implements Filter {

    private FavoriteDao favoriteDao;

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        this.favoriteDao = new FavoriteDao();
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response,
                         FilterChain chain) throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpSession session = req.getSession(false);

        if (session != null) {
            Integer userId = (Integer) session.getAttribute("userId");
            if (userId != null && session.getAttribute("favoritesLoadedFromDb") == null) {
                List<FavoriteItem> dbFav = favoriteDao.findByUserId(userId);
                session.setAttribute("favorites", dbFav);
                session.setAttribute("favoritesLoadedFromDb", true);
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
