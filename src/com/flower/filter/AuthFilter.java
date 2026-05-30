package com.flower.filter;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * 管理员及商家权限过滤器
 * 拦截管理后台和商家后台的请求，验证用户登录状态及角色权限
 */
@WebFilter(urlPatterns = {"/admin/*", "/merchant/*"})
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    /**
     * 执行过滤逻辑，检查用户是否登录以及是否具备访问特定路径的权限
     *
     * @param request  Servlet 请求对象
     * @param response Servlet 响应对象
     * @param chain    过滤器链对象
     * @throws IOException      IO 异常
     * @throws ServletException Servlet 异常
     */
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        // 检查是否登录
        if (session == null || session.getAttribute("userId") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?redirect=" + req.getRequestURI());
            return;
        }

        String role = (String) session.getAttribute("userRole");
        String uri = req.getRequestURI();

        // 管理员后台权限检查
        if (uri.contains("/admin/")) {
            if (!"管理员".equals(role)) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "无权访问管理员后台");
                return;
            }
        }

        // 商家后台权限检查：允许商家和管理员访问
        if (uri.contains("/merchant/")) {
            if (!"商家".equals(role) && !"管理员".equals(role)) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "无权访问商家后台");
                return;
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}
