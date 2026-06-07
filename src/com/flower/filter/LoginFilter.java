package com.flower.filter;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * 登录验证过滤器
 * 拦截需要登录才能访问的页面（如购物车、订单中心等）
 */
@WebFilter(urlPatterns = {"/cart", "/order/*", "/user/*"})
public class LoginFilter implements Filter {

    // 白名单路径（不需要登录）
    private static final String[] WHITE_LIST = {
            "/login", "/reg", "/products", "/index.jsp", "/login.jsp", "/reg.jsp"
    };

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    /**
     * 执行过滤逻辑，检查请求路径是否在白名单中或用户是否已登录
     *
     * @param request  Servlet 请求对象
     * @param response Servlet 响应对象
     * @param chain    过滤器链对象
     * @throws IOException      IO 异常
     * @throws ServletException Servlet 异常
     */
    @Override
    public void doFilter(ServletRequest request, ServletResponse response,
                         FilterChain chain) throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String uri = req.getRequestURI();
        String contextPath = req.getContextPath();

        // 检查是否在白名单中
        for (String white : WHITE_LIST) {
            if (uri.contains(white)) {
                chain.doFilter(request, response);
                return;
            }
        }

        // 检查是否已登录
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("username") != null) {
            chain.doFilter(request, response);
        } else {
            // 未登录，重定向到登录页
            resp.sendRedirect(contextPath + "/login");
        }
    }

    @Override
    public void destroy() {}
}