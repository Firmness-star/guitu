package com.flower.filter;

import com.flower.util.TransactionManager;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import java.io.IOException;

/**
 * 事务管理过滤器
 * 为订单结算等关键业务提供数据库事务支持，确保数据一致性
 */
@WebFilter(filterName = "TransactionFilter", urlPatterns = {
        "/checkout",
        "/orders"
})
public class TransactionFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    /**
     * 执行过滤逻辑，开启事务、执行业务并根据结果提交或回滚
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

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        String requestURI = httpRequest.getRequestURI();

        try {
            // 开启数据库事务
            TransactionManager.beginTransaction();
            chain.doFilter(request, response);
            
            // 如果事务仍在进行中，则提交更改
            if (TransactionManager.isInTransaction()) {
                TransactionManager.commit();
            }

        } catch (Exception e) {
            // 发生异常时回滚事务
            try {
                if (TransactionManager.isInTransaction()) {
                    TransactionManager.rollback();
                }
            } catch (Exception rollbackEx) {
                System.err.println("TRANSACTION ERROR: 事务回滚失败 - " + rollbackEx.getMessage());
            }
            
            if (e instanceof ServletException) {
                throw (ServletException) e;
            } else {
                throw new ServletException("事务执行失败，已回滚", e);
            }

        } finally {
            // 无论成功与否，最后都关闭连接以释放资源
            if (TransactionManager.isInTransaction()) {
                try {
                    TransactionManager.closeConnection();
                } catch (Exception e) {
                    System.err.println("[SYS] " + e.getMessage());
                }
            }
        }
    }

    @Override
    public void destroy() {
    }
}