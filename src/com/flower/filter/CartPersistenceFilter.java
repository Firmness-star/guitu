package com.flower.filter;

import com.flower.dao.CartDao;
import com.flower.entity.CartItem;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebFilter(filterName = "CartPersistenceFilter", urlPatterns = "/*")
public class CartPersistenceFilter implements Filter {

    private CartDao cartDao;

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        this.cartDao = new CartDao();
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response,
                         FilterChain chain) throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpSession session = req.getSession(false);

        if (session != null) {
            Integer userId = (Integer) session.getAttribute("userId");
            if (userId != null && session.getAttribute("cartLoadedFromDb") == null) {
                List<CartItem> dbCart = cartDao.findByUserId(userId);
                session.setAttribute("cart", dbCart);
                session.setAttribute("cartLoadedFromDb", true);
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
