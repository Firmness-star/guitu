package com.flower.controller;

import com.flower.dao.*;
import com.flower.entity.Order;
import com.flower.entity.Message;
import com.flower.entity.Category;
import com.flower.entity.Sp;
import com.flower.entity.User;
import com.flower.util.JsonUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 管理员后台控制器
 * 负责处理管理员对用户、订单、商品的查询、统计及维护操作
 */
@WebServlet(urlPatterns = "/admin/*")
public class AdminController extends HttpServlet {

    private UserDao userDao;
    private OrderDao orderDao;
    private SpDao spDao;

    @Override
    public void init() throws ServletException {
        super.init();
        this.userDao = new UserDao();
        this.orderDao = new OrderDao();
        this.spDao = new SpDao();
    }

    /**
     * 处理 GET 请求，根据路径信息分发到不同的管理页面（首页、用户、订单、商品、统计）
     *
     * @param req  HTTP 请求对象
     * @param resp HTTP 响应对象
     * @throws ServletException Servlet 异常
     * @throws IOException      IO 异常
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        String role = (String) session.getAttribute("userRole");

        if (!"管理员".equals(role)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "无权访问");
            return;
        }

        String pathInfo = req.getPathInfo();
        if (pathInfo == null || "/index".equals(pathInfo) || "/".equals(pathInfo)) {
            showDashboard(req, resp);
        } else if ("/users".equals(pathInfo)) {
            showUserManagement(req, resp);
        } else if ("/merchants".equals(pathInfo)) {
            showMerchantManagement(req, resp);
        } else if ("/categories".equals(pathInfo)) {
            showCategories(req, resp);
        } else if ("/messages".equals(pathInfo)) {
            showMessages(req, resp);
        } else if ("/banners".equals(pathInfo)) {
            showBanners(req, resp);
        } else if ("/stats".equals(pathInfo)) {
            showStatistics(req, resp);
        } else {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    /**
     * 处理 POST 请求，执行具体的业务操作（如修改状态、删除等），并返回 JSON 结果
     *
     * @param req  HTTP 请求对象
     * @param resp HTTP 响应对象
     * @throws ServletException Servlet 异常
     * @throws IOException      IO 异常
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        HttpSession session = req.getSession();
        String role = (String) session.getAttribute("userRole");

        if (!"管理员".equals(role)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "无权访问");
            return;
        }

        String pathInfo = req.getPathInfo();
        String action = req.getParameter("action");

        if ("/users".equals(pathInfo)) {
            handleUserAction(req, resp, action);
        } else if ("/orders".equals(pathInfo)) {
            handleOrderAction(req, resp, action);
        } else if ("/products".equals(pathInfo)) {
            handleProductAction(req, resp, action);
        } else if ("/categories".equals(pathInfo)) {
            handleCategoryAction(req, resp, action);
        } else if ("/merchants".equals(pathInfo)) {
            handleMerchantPost(req, resp, action);
        } else {
            doGet(req, resp);
        }
    }

    /**
     * 展示管理后台首页仪表盘数据，包括总体统计、今日统计及最近记录
     *
     * @param req  HTTP 请求对象
     * @param resp HTTP 响应对象
     * @throws ServletException Servlet 异常
     * @throws IOException      IO 异常
     */
    private void showDashboard(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<User> allUsers = userDao.findAllUsers();
        List<Order> allOrders = orderDao.findAllOrders();
        List<Sp> allProducts = spDao.findAll();

        int totalUsers = (int) allUsers.stream().filter(u -> !"商家".equals(u.getRole()) && !"管理员".equals(u.getRole())).count();
        int totalMerchants = (int) allUsers.stream().filter(u -> "商家".equals(u.getRole())).count();

        double totalSales = allOrders.stream()
                .filter(o -> "已完成".equals(o.getStatus()) || "已收货".equals(o.getStatus()))
                .mapToDouble(Order::getTotalAmount)
                .sum();

        req.setAttribute("totalUsers", totalUsers);
        req.setAttribute("totalMerchants", totalMerchants);
        req.setAttribute("totalSales", totalSales);
        req.setAttribute("totalCategories", new CategoryDao().findAll().size());
        req.setAttribute("totalBanners", new BannerDao().findAll().size());
        req.setAttribute("unreadMessages", new MessageDao().countUnreadForAdmin());
        if (!allOrders.isEmpty())
            req.setAttribute("recentOrders", allOrders.subList(0, Math.min(10, allOrders.size())));
        List<User> regularUsers = allUsers.stream()
                .filter(u -> !"商家".equals(u.getRole()) && !"管理员".equals(u.getRole()))
                .collect(java.util.stream.Collectors.toList());
        if (!regularUsers.isEmpty())
            req.setAttribute("recentUsers", regularUsers.subList(0, Math.min(10, regularUsers.size())));

        req.getRequestDispatcher("/admin.jsp").forward(req, resp);
    }

    /**
     * 计算今日的订单数和销售额统计数据
     *
     * @param allOrders 所有订单列表
     * @return 包含今日订单数（todayOrders）和今日销售额（todaySales）的 Map
     */
    private Map<String, Object> calculateTodayStats(List<Order> allOrders) {
        Map<String, Object> stats = new HashMap<>();

        Calendar calendar = Calendar.getInstance();
        calendar.set(Calendar.HOUR_OF_DAY, 0);
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 0);
        Date todayStart = calendar.getTime();

        long todayOrders = allOrders.stream()
                .filter(o -> o.getCreateTime().after(todayStart))
                .count();

        double todaySales = allOrders.stream()
                .filter(o -> o.getCreateTime().after(todayStart) && "已完成".equals(o.getStatus()))
                .mapToDouble(Order::getTotalAmount)
                .sum();

        stats.put("todayOrders", todayOrders);
        stats.put("todaySales", todaySales);

        return stats;
    }

    /**
     * 展示用户管理页面，支持按角色、状态筛选以及关键词搜索
     *
     * @param req  HTTP 请求对象
     * @param resp HTTP 响应对象
     * @throws ServletException Servlet 异常
     * @throws IOException      IO 异常
     */
    private void showUserManagement(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // 处理删除操作
        String action = req.getParameter("action");
        if ("delete".equals(action)) {
            try {
                int userId = Integer.parseInt(req.getParameter("userId"));
                Integer sessionUserId = (Integer) req.getSession().getAttribute("userId");
                if (sessionUserId != null && sessionUserId == userId) {
                    req.getSession().setAttribute("adminError", "不能删除自己的账户");
                } else {
                    boolean ok = userDao.deleteById(userId);
                    req.getSession().setAttribute(ok ? "adminSuccess" : "adminError",
                            ok ? "用户已删除" : "删除失败");
                }
            } catch (NumberFormatException e) {
                req.getSession().setAttribute("adminError", "参数错误");
            }
            resp.sendRedirect(req.getContextPath() + "/admin/users?tab=users");
            return;
        }

        // 显示结果消息
        HttpSession session = req.getSession();
        if (session.getAttribute("adminSuccess") != null) {
            req.setAttribute("adminSuccess", session.getAttribute("adminSuccess"));
            session.removeAttribute("adminSuccess");
        }
        if (session.getAttribute("adminError") != null) {
            req.setAttribute("adminError", session.getAttribute("adminError"));
            session.removeAttribute("adminError");
        }

        String roleFilter = req.getParameter("role");
        String stateFilter = req.getParameter("state");
        String keyword = req.getParameter("keyword");

        // 默认只显示普通用户
        final String effectiveRoleFilter = (roleFilter == null || roleFilter.isEmpty()) ? "用户" : roleFilter;

        List<User> users = userDao.findAllUsers();

        if (effectiveRoleFilter != null && !effectiveRoleFilter.isEmpty()) {
            users = users.stream()
                    .filter(u -> effectiveRoleFilter.equals(u.getRole()))
                    .collect(Collectors.toList());
        }

        if (stateFilter != null && !stateFilter.isEmpty()) {
            users = users.stream()
                    .filter(u -> stateFilter.equals(u.getState()))
                    .collect(Collectors.toList());
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            String searchKeyword = keyword.trim().toLowerCase();
            users = users.stream()
                    .filter(u -> u.getUsername().toLowerCase().contains(searchKeyword) ||
                            (u.getTel() != null && u.getTel().contains(searchKeyword)) ||
                            (u.getEmail() != null && u.getEmail().toLowerCase().contains(searchKeyword)))
                    .collect(Collectors.toList());
        }

        req.setAttribute("users", users);
        req.setAttribute("roleFilter", effectiveRoleFilter);
        req.setAttribute("stateFilter", stateFilter);
        req.setAttribute("keyword", keyword);
        req.getRequestDispatcher("/admin.jsp").forward(req, resp);
    }

    /**
     * 展示订单管理页面，支持按状态、关键词及日期范围进行高级筛选
     *
     * @param req  HTTP 请求对象
     * @param resp HTTP 响应对象
     * @throws ServletException Servlet 异常
     * @throws IOException      IO 异常
     */
    private void showMerchantManagement(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        if ("delete".equals(action)) {
            try {
                int userId = Integer.parseInt(req.getParameter("userId"));
                Integer sessionUserId = (Integer) req.getSession().getAttribute("userId");
                if (sessionUserId != null && sessionUserId == userId) {
                    req.getSession().setAttribute("adminError", "不能删除自己的账户");
                } else {
                    userDao.deleteById(userId);
                    req.getSession().setAttribute("adminSuccess", "商家已删除");
                }
            } catch (Exception e) {
                req.getSession().setAttribute("adminError", "删除失败");
            }
            resp.sendRedirect(req.getContextPath() + "/admin/merchants?tab=merchants");
            return;
        }

        HttpSession session = req.getSession();
        if (session.getAttribute("adminSuccess") != null) {
            req.setAttribute("adminSuccess", session.getAttribute("adminSuccess"));
            session.removeAttribute("adminSuccess");
        }
        if (session.getAttribute("adminError") != null) {
            req.setAttribute("adminError", session.getAttribute("adminError"));
            session.removeAttribute("adminError");
        }

        List<User> merchants = userDao.findUsersByRole("商家");
        req.setAttribute("merchants", merchants);
        req.getRequestDispatcher("/admin.jsp").forward(req, resp);
    }

    /**
     * 展示订单管理页面，支持按状态、关键词及日期范围进行高级筛选
     *
     * @param req  HTTP 请求对象
     * @param resp HTTP 响应对象
     * @throws ServletException Servlet 异常
     * @throws IOException      IO 异常
     */
    private void showOrderManagement(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // 处理操作请求（发货、完成、取消）
        String action = req.getParameter("action");
        if (action != null) {
            String orderId = req.getParameter("orderId");
            if (orderId != null && !orderId.isEmpty()) {
                boolean ok = false;
                String msg = "";
                if ("ship".equals(action)) {
                    ok = orderDao.updateStatus(orderId, "已发货");
                    String wlNo = req.getParameter("wlNo");
                    if (wlNo != null && !wlNo.isEmpty()) {
                        orderDao.updateWlNoByOrderNo(orderId, wlNo);
                    }
                    msg = ok ? "发货成功" : "发货失败";
                } else if ("complete".equals(action)) {
                    // 必须先等客户确认收货
                    Order checkOrder = orderDao.findByOrderId(orderId);
                    if (checkOrder != null && !"已收货".equals(checkOrder.getStatus())) {
                        req.getSession().setAttribute("adminError", "客户尚未确认收货，暂时无法完成订单");
                        resp.sendRedirect(req.getContextPath() + "/admin/orders?tab=orders");
                        return;
                    }
                    ok = orderDao.updateStatus(orderId, "已完成");
                    msg = ok ? "订单已完成" : "操作失败";
                } else if ("cancel".equals(action)) {
                    ok = orderDao.updateStatus(orderId, "已取消");
                    msg = ok ? "订单已取消" : "操作失败";
                }
                if (ok) {
                    req.getSession().setAttribute("adminSuccess", msg);
                } else {
                    req.getSession().setAttribute("adminError", msg);
                }
            }
        }

        String statusFilter = req.getParameter("status");
        String keyword = req.getParameter("keyword");
        String startDate = req.getParameter("startDate");
        String endDate = req.getParameter("endDate");

        List<Order> orders = orderDao.findAllOrders();

        if (statusFilter != null && !statusFilter.isEmpty()) {
            if ("未完成".equals(statusFilter)) {
                orders = orders.stream()
                        .filter(o -> !"已完成".equals(o.getStatus())
                                  && !"已收货".equals(o.getStatus())
                                  && !"已取消".equals(o.getStatus()))
                        .collect(Collectors.toList());
            } else {
                orders = orders.stream()
                        .filter(o -> statusFilter.equals(o.getStatus()))
                        .collect(Collectors.toList());
            }
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            String searchKeyword = keyword.trim();
            orders = orders.stream()
                    .filter(o -> o.getOrderId().contains(searchKeyword) ||
                            (o.getUsername() != null && o.getUsername().contains(searchKeyword)) ||
                            (o.getReceiverName() != null && o.getReceiverName().contains(searchKeyword)))
                    .collect(Collectors.toList());
        }

        if (startDate != null && !startDate.isEmpty()) {
            try {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                Date start = sdf.parse(startDate);
                orders = orders.stream()
                        .filter(o -> !o.getCreateTime().before(start))
                        .collect(Collectors.toList());
            } catch (Exception e) {
                System.err.println("ERROR: " + e.getMessage());
            }
        }

        if (endDate != null && !endDate.isEmpty()) {
            try {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                Date end = sdf.parse(endDate);
                Calendar cal = Calendar.getInstance();
                cal.setTime(end);
                cal.add(Calendar.DAY_OF_YEAR, 1);
                Date endNextDay = cal.getTime();

                Date finalEnd = endNextDay;
                orders = orders.stream()
                        .filter(o -> o.getCreateTime().before(finalEnd))
                        .collect(Collectors.toList());
            } catch (Exception e) {
                System.err.println("ERROR: " + e.getMessage());
            }
        }

        orders.sort((o1, o2) -> o2.getCreateTime().compareTo(o1.getCreateTime()));

        // 传递操作结果消息
        HttpSession session = req.getSession();
        if (session.getAttribute("adminSuccess") != null) {
            req.setAttribute("adminSuccess", session.getAttribute("adminSuccess"));
            session.removeAttribute("adminSuccess");
        }
        if (session.getAttribute("adminError") != null) {
            req.setAttribute("adminError", session.getAttribute("adminError"));
            session.removeAttribute("adminError");
        }

        req.setAttribute("orders", orders);
        req.setAttribute("statusFilter", statusFilter);
        req.setAttribute("keyword", keyword);
        req.setAttribute("startDate", startDate);
        req.setAttribute("endDate", endDate);
        req.getRequestDispatcher("/admin.jsp").forward(req, resp);
    }

    /**
     * 展示商品管理页面，支持按上下架状态筛选及关键词搜索
     *
     * @param req  HTTP 请求对象
     * @param resp HTTP 响应对象
     * @throws ServletException Servlet 异常
     * @throws IOException      IO 异常
     */
    private void showProductManagement(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // 处理操作（上下架、删除、新增）
        String action = req.getParameter("action");
        HttpSession session = req.getSession();
        if (action != null) {
            if (!"add".equals(action)) {
                String pidStr = req.getParameter("productId");
                try {
                    int productId = pidStr != null ? Integer.parseInt(pidStr) : -1;
                    if ("disable".equals(action)) {
                        spDao.updateStatus(productId, 0);
                        session.setAttribute("adminSuccess", "商品已下架");
                    } else if ("enable".equals(action)) {
                        spDao.updateStatus(productId, 1);
                        session.setAttribute("adminSuccess", "商品已上架");
                    } else if ("delete".equals(action)) {
                        spDao.deleteById(productId);
                        session.setAttribute("adminSuccess", "商品已删除");
                    }
                } catch (Exception e) {
                    session.setAttribute("adminError", "操作失败：" + e.getMessage());
                    System.err.println("ERROR: " + e.getMessage());
                }
                resp.sendRedirect(req.getContextPath() + "/admin/products?tab=products");
                return;
            } else {
                // 新增商品
                try {
                    Sp sp = new Sp();
                    sp.setName(req.getParameter("name"));
                    sp.setIntro(req.getParameter("intro"));
                    sp.setPrice(Double.parseDouble(req.getParameter("price")));
                    sp.setStock(Integer.parseInt(req.getParameter("stock")));
                    sp.setPic(req.getParameter("pic"));
                    sp.setCategoryId(Integer.parseInt(req.getParameter("categoryId")));
                    sp.setStatus(1);
                    sp.setSales(0);
                    spDao.save(sp);
                    session.setAttribute("adminSuccess", "商品已新增");
                } catch (Exception e) {
                    session.setAttribute("adminError", "新增失败：" + e.getMessage());
                    System.err.println("ERROR: " + e.getMessage());
                }
                resp.sendRedirect(req.getContextPath() + "/admin/products?tab=products");
                return;
            }
        }

        String statusFilter = req.getParameter("status");
        String keyword = req.getParameter("keyword");
        String lowStock = req.getParameter("lowStock");

        List<Sp> products = spDao.findAll();

        if (statusFilter != null && !statusFilter.isEmpty()) {
            if ("lowStock".equals(statusFilter)) {
                products = products.stream()
                        .filter(p -> p.isLowStock())
                        .collect(Collectors.toList());
            } else {
                int status = Integer.parseInt(statusFilter);
                products = products.stream()
                        .filter(p -> p.getStatus() == status)
                        .collect(Collectors.toList());
            }
        }

        if ("1".equals(lowStock)) {
            products = products.stream()
                    .filter(p -> p.isLowStock())
                    .collect(Collectors.toList());
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            String searchKeyword = keyword.trim().toLowerCase();
            products = products.stream()
                    .filter(p -> p.getName().toLowerCase().contains(searchKeyword) ||
                            (p.getIntro() != null && p.getIntro().toLowerCase().contains(searchKeyword)))
                    .collect(Collectors.toList());
        }

        products.sort((p1, p2) -> Integer.compare(p2.getId(), p1.getId()));

        req.setAttribute("products", products);
        req.setAttribute("statusFilter", statusFilter);
        req.setAttribute("keyword", keyword);
        req.getRequestDispatcher("/admin.jsp").forward(req, resp);
    }

    /**
     * 展示数据统计页面，提供全局统计、订单状态分布及热销商品排行
     *
     * @param req  HTTP 请求对象
     * @param resp HTTP 响应对象
     * @throws ServletException Servlet 异常
     * @throws IOException      IO 异常
     */
    private void showStatistics(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<Order> allOrders = orderDao.findAllOrders();
        List<Sp> allProducts = spDao.findAll();
        List<User> allUsers = userDao.findAllUsers();

        Map<String, Object> stats = new HashMap<>();

        stats.put("totalUsers", allUsers.stream().filter(u -> !"商家".equals(u.getRole()) && !"管理员".equals(u.getRole())).count());
        stats.put("totalOrders", allOrders.size());
        stats.put("totalProducts", allProducts.size());

        double totalSales = allOrders.stream()
                .filter(o -> "已完成".equals(o.getStatus()))
                .mapToDouble(Order::getTotalAmount)
                .sum();
        stats.put("totalSales", totalSales);

        Map<String, Long> statusCount = allOrders.stream()
                .collect(Collectors.groupingBy(Order::getStatus, Collectors.counting()));
        stats.put("orderStatusStats", statusCount);

        List<Sp> topProducts = allProducts.stream()
                .sorted((p1, p2) -> Integer.compare(p2.getSales(), p1.getSales()))
                .limit(10)
                .collect(Collectors.toList());
        stats.put("topProducts", topProducts);

        req.setAttribute("stats", stats);
        req.getRequestDispatcher("/admin_stats.jsp").forward(req, resp);
    }

    private void showMessages(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        MessageDao messageDao = new MessageDao();
        HttpSession session = req.getSession();

        // 处理操作
        String action = req.getParameter("action");
        if ("delete".equals(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                messageDao.deleteById(id);
                session.setAttribute("adminSuccess", "留言已删除");
            } catch (Exception e) {
                session.setAttribute("adminError", "删除失败");
            }
            resp.sendRedirect(req.getContextPath() + "/admin/messages?tab=messages");
            return;
        } else if ("reply".equals(action)) {
            try {
                int msgId = Integer.parseInt(req.getParameter("msgId"));
                String reply = req.getParameter("reply");
                if (reply != null && !reply.trim().isEmpty()) {
                    messageDao.adminReply(msgId, reply.trim());
                    session.setAttribute("adminSuccess", "回复成功");
                }
            } catch (Exception e) {
                session.setAttribute("adminError", "回复失败");
            }
            String focus = req.getParameter("focusModal");
            String redirectUrl = req.getContextPath() + "/admin/messages?tab=messages";
            if (focus != null) redirectUrl += "&focusModal=" + focus;
            resp.sendRedirect(redirectUrl);
            return;
        }

        // 管理员进入留言管理时，将所有管理员未读标为已读
        messageDao.markAdminRead();

        // 显示结果消息
        if (session.getAttribute("adminSuccess") != null) {
            req.setAttribute("adminSuccess", session.getAttribute("adminSuccess"));
            session.removeAttribute("adminSuccess");
        }
        if (session.getAttribute("adminError") != null) {
            req.setAttribute("adminError", session.getAttribute("adminError"));
            session.removeAttribute("adminError");
        }

        req.setAttribute("messageList", messageDao.findAll());
        req.setAttribute("focusModal", req.getParameter("focusModal"));
        req.getRequestDispatcher("/admin.jsp").forward(req, resp);
    }

    /**
     * 处理用户相关的异步操作（禁用、启用、修改角色）
     *
     * @param req    HTTP 请求对象
     * @param resp   HTTP 响应对象
     * @param action 具体的操作类型
     * @throws ServletException Servlet 异常
     * @throws IOException      IO 异常
     */
    private void handleUserAction(HttpServletRequest req, HttpServletResponse resp, String action)
            throws ServletException, IOException {

        PrintWriter out = resp.getWriter();
        Map<String, Object> result = new HashMap<>();

        try {
            int userId = Integer.parseInt(req.getParameter("userId"));

            if ("disable".equals(action)) {
                boolean success = userDao.updateUserState(userId, "禁用");
                result.put("success", success);
                result.put("message", success ? "禁用成功" : "禁用失败");
            } else if ("enable".equals(action)) {
                boolean success = userDao.updateUserState(userId, "可用");
                result.put("success", success);
                result.put("message", success ? "启用成功" : "启用失败");
            } else if ("changeRole".equals(action)) {
                String newRole = req.getParameter("newRole");
                if (newRole != null && (newRole.equals("用户") || newRole.equals("商家") || newRole.equals("管理员"))) {
                    boolean success = userDao.updateUserRole(userId, newRole);
                    result.put("success", success);
                    result.put("message", success ? "角色修改成功" : "角色修改失败");
                } else {
                    result.put("success", false);
                    result.put("message", "无效的角色");
                }
            } else if ("resetPassword".equals(action)) {
                String newPassword = req.getParameter("newPassword");
                if (newPassword != null && !newPassword.trim().isEmpty() && newPassword.length() >= 6) {
                    boolean success = userDao.updatePassword(userId, newPassword.trim());
                    result.put("success", success);
                    result.put("message", success ? "密码重置成功" : "密码重置失败");
                } else {
                    result.put("success", false);
                    result.put("message", "密码长度不能少于6位");
                }
            }

            out.print(JsonUtil.toJson(result));
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "操作失败：" + e.getMessage());
            out.print(JsonUtil.toJson(result));
        }
    }

    private void handleMerchantPost(HttpServletRequest req, HttpServletResponse resp, String action)
            throws ServletException, IOException {

        HttpSession session = req.getSession();

        if ("addMerchant".equals(action)) {
            String username = req.getParameter("merchantUsername");
            String password = req.getParameter("merchantPassword");

            if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
                session.setAttribute("adminError", "用户名和密码不能为空");
            } else if (userDao.isUsernameExists(username.trim())) {
                session.setAttribute("adminError", "用户名已存在");
            } else if (password.trim().length() < 6) {
                session.setAttribute("adminError", "密码长度不能少于6位");
            } else {
                User merchant = new User(username.trim(), password.trim(), "", "");
                merchant.setRole("商家");
                merchant.setState("可用");
                merchant.setGender("未知");
                merchant.setJf(0);
                if (userDao.save(merchant)) {
                    session.setAttribute("adminSuccess", "商家账号「" + username.trim() + "」已创建");
                } else {
                    session.setAttribute("adminError", "创建失败，请重试");
                }
            }
        }

        resp.sendRedirect(req.getContextPath() + "/admin/merchants?tab=merchants");
    }

    /**
     * 处理订单相关的异步操作（取消订单、完成订单）
     *
     * @param req    HTTP 请求对象
     * @param resp   HTTP 响应对象
     * @param action 具体的操作类型
     * @throws ServletException Servlet 异常
     * @throws IOException      IO 异常
     */
    private void handleOrderAction(HttpServletRequest req, HttpServletResponse resp, String action)
            throws ServletException, IOException {

        PrintWriter out = resp.getWriter();
        Map<String, Object> result = new HashMap<>();

        try {
            int orderId = Integer.parseInt(req.getParameter("orderId"));

            if ("cancel".equals(action)) {
                boolean success = orderDao.updateStatusById(orderId, "已取消");
                result.put("success", success);
                result.put("message", success ? "取消成功" : "取消失败");
            } else if ("complete".equals(action)) {
                boolean success = orderDao.updateStatusById(orderId, "已完成");
                result.put("success", success);
                result.put("message", success ? "完成成功" : "完成失败");
            } else if ("ship".equals(action)) {
                String wlNo = req.getParameter("wlNo");
                boolean success = orderDao.updateStatusById(orderId, "已发货");
                if (success && wlNo != null && !wlNo.isEmpty()) {
                    orderDao.updateWlNo(orderId, wlNo);
                }
                result.put("success", success);
                result.put("message", success ? "发货成功" : "操作失败");
            }

            out.print(JsonUtil.toJson(result));
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "操作失败：" + e.getMessage());
            out.print(JsonUtil.toJson(result));
        }
    }

    /**
     * 处理商品相关的异步操作（更新信息、上架、下架、删除）
     *
     * @param req    HTTP 请求对象
     * @param resp   HTTP 响应对象
     * @param action 具体的操作类型
     * @throws ServletException Servlet 异常
     * @throws IOException      IO 异常
     */
    private void handleProductAction(HttpServletRequest req, HttpServletResponse resp, String action)
            throws ServletException, IOException {

        PrintWriter out = resp.getWriter();
        Map<String, Object> result = new HashMap<>();

        try {
            if ("update".equals(action)) {
                updateProduct(req, resp);
                result.put("success", true);
                result.put("message", "更新成功");
            } else {
                int productId = Integer.parseInt(req.getParameter("productId"));

                if ("disable".equals(action)) {
                    boolean success = spDao.updateStatus(productId, 0);
                    result.put("success", success);
                    result.put("message", success ? "下架成功" : "下架失败");
                } else if ("enable".equals(action)) {
                    boolean success = spDao.updateStatus(productId, 1);
                    result.put("success", success);
                    result.put("message", success ? "上架成功" : "上架失败");
                } else if ("delete".equals(action)) {
                    boolean success = spDao.deleteById(productId);
                    result.put("success", success);
                    result.put("message", success ? "删除成功" : "删除失败");
                }
            }

            out.print(JsonUtil.toJson(result));
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "操作失败：" + e.getMessage());
            out.print(JsonUtil.toJson(result));
        }
    }

    /**
     * 根据请求参数更新商品信息
     *
     * @param req  HTTP 请求对象
     * @param resp HTTP 响应对象
     * @throws ServletException Servlet 异常
     * @throws IOException      IO 异常
     */
    private void updateProduct(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int id = Integer.parseInt(req.getParameter("id"));
        String name = req.getParameter("name");
        String intro = req.getParameter("intro");
        double price = Double.parseDouble(req.getParameter("price"));
        int stock = Integer.parseInt(req.getParameter("stock"));
        String pic = req.getParameter("pic");
        int categoryId = Integer.parseInt(req.getParameter("categoryId"));

        Sp product = new Sp();
        product.setId(id);
        product.setName(name);
        product.setIntro(intro);
        product.setPrice(price);
        product.setStock(stock);
        product.setPic(pic);
        product.setCategoryId(categoryId);

        spDao.update(product);
    }

    private void showCategories(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        CategoryDao categoryDao = new CategoryDao();
        HttpSession session = req.getSession();

        // 处理操作
        String action = req.getParameter("action");
        if ("delete".equals(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                categoryDao.deleteById(id);
                session.setAttribute("adminSuccess", "分类已删除");
            } catch (Exception e) {
                session.setAttribute("adminError", "删除失败：" + e.getMessage());
            }
            resp.sendRedirect(req.getContextPath() + "/admin/categories?tab=categories");
            return;
        }

        // 显示结果消息
        if (session.getAttribute("adminSuccess") != null) {
            req.setAttribute("adminSuccess", session.getAttribute("adminSuccess"));
            session.removeAttribute("adminSuccess");
        }
        if (session.getAttribute("adminError") != null) {
            req.setAttribute("adminError", session.getAttribute("adminError"));
            session.removeAttribute("adminError");
        }

        req.setAttribute("allCategories", categoryDao.findAll());
        req.setAttribute("parentCategories", categoryDao.findParentCategories());
        req.getRequestDispatcher("/admin.jsp").forward(req, resp);
    }

    private void handleCategoryAction(HttpServletRequest req, HttpServletResponse resp, String action)
            throws ServletException, IOException {
        CategoryDao categoryDao = new CategoryDao();
        HttpSession session = req.getSession();
        if ("add".equals(action)) {
            String name = req.getParameter("name");
            int parentId = Integer.parseInt(req.getParameter("parentId"));
            String desc = req.getParameter("description");
            com.flower.entity.Category cat = new com.flower.entity.Category();
            cat.setName(name);
            cat.setParentId(parentId);
            cat.setDescription(desc != null ? desc : "");
            categoryDao.save(cat);
            session.setAttribute("adminSuccess", "分类已添加");
        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(req.getParameter("id"));
            categoryDao.deleteById(id);
            session.setAttribute("adminSuccess", "分类已删除");
        }
        resp.sendRedirect(req.getContextPath() + "/admin/categories?tab=categories");
    }

    private void showBanners(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        com.flower.dao.BannerDao bannerDao = new com.flower.dao.BannerDao();
        HttpSession session = req.getSession();

        // 处理操作
        String action = req.getParameter("action");
        if ("delete".equals(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                bannerDao.deleteById(id);
                session.setAttribute("adminSuccess", "海报已删除");
            } catch (NumberFormatException e) {
                System.err.println("ERROR: " + e.getMessage());
            }
        } else if ("deleteQr".equals(action)) {
            getServletContext().removeAttribute("wechatQrPath");
            session.setAttribute("adminSuccess", "二维码已恢复默认");
            resp.sendRedirect(req.getContextPath() + "/admin/banners?tab=banners");
            return;
        } else if ("setSpeed".equals(action)) {
            try {
                int speed = Integer.parseInt(req.getParameter("speed"));
                int showHot = Integer.parseInt(req.getParameter("showHot"));
                session.setAttribute("bannerSpeed", speed);
                session.setAttribute("showHot", showHot);
                session.setAttribute("adminSuccess", "轮播设置已保存");
            } catch (NumberFormatException e) {
                session.setAttribute("adminError", "设置格式错误");
            }
        }
        // 显示结果消息
        if (session.getAttribute("adminError") != null) {
            req.setAttribute("adminError", session.getAttribute("adminError"));
            session.removeAttribute("adminError");
        }
        if (session.getAttribute("adminSuccess") != null) {
            req.setAttribute("adminSuccess", session.getAttribute("adminSuccess"));
            session.removeAttribute("adminSuccess");
        }
        // 读取当前设置
        Object speedObj = session.getAttribute("bannerSpeed");
        Object hotObj = session.getAttribute("showHot");
        req.setAttribute("bannerSpeed", speedObj != null ? speedObj : 1500);
        req.setAttribute("showHot", hotObj != null ? hotObj : 1);
        req.setAttribute("bannerList", bannerDao.findAll());
        req.getRequestDispatcher("/admin.jsp").forward(req, resp);
    }
}
