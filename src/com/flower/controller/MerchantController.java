package com.flower.controller;

import com.flower.dao.CategoryDao;
import com.flower.dao.OrderDao;
import com.flower.dao.SpDao;
import com.flower.entity.Category;
import com.flower.entity.Order;
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
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 商家后台控制器
 * 负责处理商家的商品管理、订单处理、客户统计及仪表盘数据展示
 */
@WebServlet(urlPatterns = "/merchant/*")
public class MerchantController extends HttpServlet {

    private SpDao spDao;
    private OrderDao orderDao;
    private CategoryDao categoryDao;

    @Override
    public void init() throws ServletException {
        super.init();
        this.spDao = new SpDao();
        this.orderDao = new OrderDao();
        this.categoryDao = new CategoryDao();
    }

    /**
     * 处理 GET 请求，根据路径信息分发到不同的商家管理页面（首页、商品、订单、客户）
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

        if (!"商家".equals(role)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "无权访问");
            return;
        }

        String pathInfo = req.getPathInfo();
        if (pathInfo == null || "/index".equals(pathInfo) || "/".equals(pathInfo)) {
            showDashboard(req, resp);
        } else if ("/products".equals(pathInfo)) {
            showProductManagement(req, resp);
        } else if ("/orders".equals(pathInfo)) {
            showOrderManagement(req, resp);
        } else if ("/customers".equals(pathInfo)) {
            showCustomerManagement(req, resp);
        } else {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    /**
     * 处理 POST 请求，执行具体的业务操作（如商品上下架、订单发货等），并返回 JSON 结果
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

        if (!"商家".equals(role)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "无权访问");
            return;
        }

        String pathInfo = req.getPathInfo();
        String action = req.getParameter("action");

        if ("/products".equals(pathInfo)) {
            handleProductAction(req, resp, action);
        } else if ("/orders".equals(pathInfo)) {
            // 订单操作后重定向回订单管理页面
            handleOrderActionWithRedirect(req, resp, action);
        } else {
            doGet(req, resp);
        }
    }

    /**
     * 展示商家后台首页仪表盘，包括销售统计、库存预警及热销商品排行
     *
     * @param req  HTTP 请求对象
     * @param resp HTTP 响应对象
     * @throws ServletException Servlet 异常
     * @throws IOException      IO 异常
     */
    private void showDashboard(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        String username = (String) session.getAttribute("username");

        List<Sp> allProducts = spDao.findAll();
        List<Order> allOrders = orderDao.findAllOrders();

        int totalProducts = allProducts.size();
        int totalOrders = allOrders.size();
        double totalSales = allOrders.stream()
                .filter(o -> "已完成".equals(o.getStatus()))
                .mapToDouble(Order::getTotalAmount)
                .sum();

        long pendingOrders = allOrders.stream()
                .filter(o -> "待付款".equals(o.getStatus()) || "已付款".equals(o.getStatus()))
                .count();

        long lowStockProducts = allProducts.stream()
                .filter(Sp::isLowStock)
                .count();

        List<Sp> topSellingProducts = allProducts.stream()
                .sorted((p1, p2) -> Integer.compare(p2.getSales(), p1.getSales()))
                .limit(5)
                .collect(Collectors.toList());

        Map<String, Object> todayStats = calculateTodayStats(allOrders);

        req.setAttribute("totalProducts", totalProducts);
        req.setAttribute("totalOrders", totalOrders);
        req.setAttribute("totalSales", totalSales);
        req.setAttribute("pendingOrders", pendingOrders);
        req.setAttribute("lowStockProducts", lowStockProducts);
        req.setAttribute("todayOrders", todayStats.get("todayOrders"));
        req.setAttribute("todaySales", todayStats.get("todaySales"));
        req.setAttribute("recentOrders", allOrders.subList(0, Math.min(10, allOrders.size())));
        req.setAttribute("recentProducts", allProducts.subList(0, Math.min(10, allProducts.size())));
        req.setAttribute("topSellingProducts", topSellingProducts);

        req.getRequestDispatcher("/merchant.jsp").forward(req, resp);
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
     * 展示商品管理页面，支持按状态筛选、关键词搜索及分类选择
     *
     * @param req  HTTP 请求对象
     * @param resp HTTP 响应对象
     * @throws ServletException Servlet 异常
     * @throws IOException      IO 异常
     */
    private void showProductManagement(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String statusFilter = req.getParameter("status");
        String keyword = req.getParameter("keyword");

        List<Sp> products = spDao.findAll();

        if (statusFilter != null && !statusFilter.isEmpty()) {
            int status = Integer.parseInt(statusFilter);
            products = products.stream()
                    .filter(p -> p.getStatus() == status)
                    .collect(Collectors.toList());
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            String searchKeyword = keyword.trim().toLowerCase();
            products = products.stream()
                    .filter(p -> p.getName().toLowerCase().contains(searchKeyword) ||
                            (p.getIntro() != null && p.getIntro().toLowerCase().contains(searchKeyword)))
                    .collect(Collectors.toList());
        }

        List<Category> categories = categoryDao.findAllCategories();

        products.sort((p1, p2) -> Integer.compare(p2.getId(), p1.getId()));

        req.setAttribute("products", products);
        req.setAttribute("categories", categories);
        req.setAttribute("statusFilter", statusFilter);
        req.setAttribute("keyword", keyword);
        req.getRequestDispatcher("/merchant.jsp").forward(req, resp);
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

        String statusFilter = req.getParameter("status");
        String keyword = req.getParameter("keyword");
        String startDate = req.getParameter("startDate");
        String endDate = req.getParameter("endDate");

        List<Order> orders = orderDao.findAllOrders();

        if (statusFilter != null && !statusFilter.isEmpty()) {
            orders = orders.stream()
                    .filter(o -> statusFilter.equals(o.getStatus()))
                    .collect(Collectors.toList());
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
                e.printStackTrace();
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
                e.printStackTrace();
            }
        }

        orders.sort((o1, o2) -> o2.getCreateTime().compareTo(o1.getCreateTime()));

        req.setAttribute("orders", orders);
        req.setAttribute("statusFilter", statusFilter);
        req.setAttribute("keyword", keyword);
        req.setAttribute("startDate", startDate);
        req.setAttribute("endDate", endDate);
        req.getRequestDispatcher("/merchant.jsp").forward(req, resp);
    }

    /**
     * 展示客户管理页面，统计客户的订单数、消费总额及最近下单时间
     *
     * @param req  HTTP 请求对象
     * @param resp HTTP 响应对象
     * @throws ServletException Servlet 异常
     * @throws IOException      IO 异常
     */
    private void showCustomerManagement(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<Order> allOrders = orderDao.findAllOrders();

        Map<String, List<Order>> customerOrders = allOrders.stream()
                .filter(o -> o.getUsername() != null)
                .collect(Collectors.groupingBy(Order::getUsername));

        List<Map<String, Object>> customers = new ArrayList<>();
        for (Map.Entry<String, List<Order>> entry : customerOrders.entrySet()) {
            Map<String, Object> customer = new HashMap<>();
            customer.put("username", entry.getKey());
            customer.put("orderCount", entry.getValue().size());

            double totalAmount = entry.getValue().stream()
                    .filter(o -> "已完成".equals(o.getStatus()))
                    .mapToDouble(Order::getTotalAmount)
                    .sum();
            customer.put("totalAmount", totalAmount);

            Date lastOrderTime = entry.getValue().stream()
                    .map(Order::getCreateTime)
                    .max(Date::compareTo)
                    .orElse(null);
            customer.put("lastOrderTime", lastOrderTime);

            customers.add(customer);
        }

        customers.sort((c1, c2) -> Double.compare((double)c2.get("totalAmount"), (double)c1.get("totalAmount")));

        req.setAttribute("customers", customers);
        req.getRequestDispatcher("/merchant_customers.jsp").forward(req, resp);
    }

    /**
     * 处理商品相关的异步操作（添加、更新、删除、上下架、复制）
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
            if ("add".equals(action)) {
                addProduct(req, resp);
                result.put("success", true);
                result.put("message", "添加成功");
            } else if ("update".equals(action)) {
                updateProduct(req, resp);
                result.put("success", true);
                result.put("message", "更新成功");
            } else if ("delete".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                boolean success = spDao.deleteById(id);
                result.put("success", success);
                result.put("message", success ? "删除成功" : "删除失败");
            } else if ("disable".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                boolean success = spDao.updateStatus(id, 0);
                result.put("success", success);
                result.put("message", success ? "下架成功" : "下架失败");
            } else if ("enable".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                boolean success = spDao.updateStatus(id, 1);
                result.put("success", success);
                result.put("message", success ? "上架成功" : "上架失败");
            } else if ("copy".equals(action)) {
                copyProduct(req, resp);
                result.put("success", true);
                result.put("message", "复制成功");
            }

            out.print(JsonUtil.toJson(result));
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "操作失败：" + e.getMessage());
            out.print(JsonUtil.toJson(result));
        }
    }

    /**
     * 添加新商品到数据库
     *
     * @param req  HTTP 请求对象，包含商品各项参数
     * @param resp HTTP 响应对象
     * @throws ServletException Servlet 异常
     * @throws IOException      IO 异常
     */
    private void addProduct(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String name = req.getParameter("name");
        String intro = req.getParameter("intro");
        double price = Double.parseDouble(req.getParameter("price"));
        int stock = Integer.parseInt(req.getParameter("stock"));
        String pic = req.getParameter("pic");
        int categoryId = Integer.parseInt(req.getParameter("categoryId"));

        Sp product = new Sp();
        product.setName(name);
        product.setIntro(intro);
        product.setPrice(price);
        product.setStock(stock);
        product.setPic(pic);
        product.setCategoryId(categoryId);
        product.setSales(0);
        product.setStatus(1);

        spDao.save(product);
    }

    /**
     * 更新指定商品的信息
     *
     * @param req  HTTP 请求对象，包含商品 ID 及更新后的参数
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

    /**
     * 复制现有商品，生成一个新的草稿状态商品
     *
     * @param req  HTTP 请求对象，包含原商品 ID
     * @param resp HTTP 响应对象
     * @throws ServletException Servlet 异常
     * @throws IOException      IO 异常
     */
    private void copyProduct(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int id = Integer.parseInt(req.getParameter("id"));
        Sp originalProduct = spDao.findById(id);

        if (originalProduct != null) {
            Sp newProduct = new Sp();
            newProduct.setName(originalProduct.getName() + " (副本)");
            newProduct.setIntro(originalProduct.getIntro());
            newProduct.setPrice(originalProduct.getPrice());
            newProduct.setStock(originalProduct.getStock());
            newProduct.setPic(originalProduct.getPic());
            newProduct.setCategoryId(originalProduct.getCategoryId());
            newProduct.setSales(0);
            newProduct.setStatus(0);

            spDao.save(newProduct);
        }
    }

    /**
     * 处理订单相关的异步操作（发货、完成、取消）
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

            if ("ship".equals(action)) {
                // 获取物流信息
                String logisticsCompany = req.getParameter("logisticsCompany");
                String trackingNumber = req.getParameter("trackingNumber");
                String shipRemark = req.getParameter("shipRemark");
                
                // 更新订单状态为已发货
                boolean success = orderDao.updateStatusById(orderId, "已发货");
                
                if (success) {
                    // 记录发货日志（可以扩展保存到数据库）
                    System.out.println("订单发货 - 订单ID: " + orderId);
                    System.out.println("物流公司: " + (logisticsCompany != null ? logisticsCompany : "未填写"));
                    System.out.println("物流单号: " + (trackingNumber != null ? trackingNumber : "未填写"));
                    System.out.println("发货备注: " + (shipRemark != null ? shipRemark : "无"));
                    System.out.println("发货时间: " + new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date()));
                    
                    result.put("success", true);
                    result.put("message", "发货成功");
                } else {
                    result.put("success", false);
                    result.put("message", "发货失败");
                }
            } else if ("complete".equals(action)) {
                boolean success = orderDao.updateStatusById(orderId, "已完成");
                result.put("success", success);
                result.put("message", success ? "完成成功" : "完成失败");
            } else if ("cancel".equals(action)) {
                boolean success = orderDao.updateStatusById(orderId, "已取消");
                result.put("success", success);
                result.put("message", success ? "取消成功" : "取消失败");
            }

            out.print(JsonUtil.toJson(result));
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "操作失败：" + e.getMessage());
            out.print(JsonUtil.toJson(result));
        }
    }

    /**
     * 处理订单操作并重定向回订单管理页面（用于表单提交）
     *
     * @param req    HTTP 请求对象
     * @param resp   HTTP 响应对象
     * @param action 具体的操作类型
     * @throws ServletException Servlet 异常
     * @throws IOException      IO 异常
     */
    private void handleOrderActionWithRedirect(HttpServletRequest req, HttpServletResponse resp, String action)
            throws ServletException, IOException {

        HttpSession session = req.getSession();

        try {
            String orderNo = req.getParameter("orderId");
            boolean success = false;
            String message = "";

            if ("ship".equals(action)) {
                // 获取物流信息
                String logisticsCompany = req.getParameter("logisticsCompany");
                String trackingNumber = req.getParameter("trackingNumber");
                String shipRemark = req.getParameter("shipRemark");
                
                // 构建物流信息备注
                StringBuilder remarkBuilder = new StringBuilder();
                remarkBuilder.append("\n【发货信息】\n");
                remarkBuilder.append("发货时间: ").append(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())).append("\n");
                if (logisticsCompany != null && !logisticsCompany.trim().isEmpty()) {
                    remarkBuilder.append("物流公司: ").append(logisticsCompany).append("\n");
                }
                if (trackingNumber != null && !trackingNumber.trim().isEmpty()) {
                    remarkBuilder.append("物流单号: ").append(trackingNumber).append("\n");
                }
                if (shipRemark != null && !shipRemark.trim().isEmpty()) {
                    remarkBuilder.append("备注: ").append(shipRemark).append("\n");
                }
                
                String remark = remarkBuilder.toString();
                
                // 更新订单状态为已发货，并保存物流信息
                success = orderDao.updateStatusAndRemarkByOrderNo(orderNo, "已发货", remark);
                
                if (success) {
                    // 记录发货日志
                    System.out.println("=== 订单发货 ===");
                    System.out.println("订单号: " + orderNo);
                    System.out.println("物流公司: " + (logisticsCompany != null ? logisticsCompany : "未填写"));
                    System.out.println("物流单号: " + (trackingNumber != null ? trackingNumber : "未填写"));
                    System.out.println("发货备注: " + (shipRemark != null ? shipRemark : "无"));
                    System.out.println("发货时间: " + new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date()));
                    System.out.println("================");
                    
                    message = "发货成功！物流信息已保存。";
                } else {
                    message = "发货失败，请重试";
                }
            } else if ("complete".equals(action)) {
                success = orderDao.updateStatus(orderNo, "已完成");
                message = success ? "订单已完成" : "操作失败";
            } else if ("cancel".equals(action)) {
                success = orderDao.updateStatus(orderNo, "已取消");
                message = success ? "订单已取消" : "操作失败";
            }

            // 将消息存入 Session，在页面中显示
            session.setAttribute("orderMessage", message);
            session.setAttribute("orderMessageType", success ? "success" : "danger");

        } catch (Exception e) {
            session.setAttribute("orderMessage", "操作失败：" + e.getMessage());
            session.setAttribute("orderMessageType", "danger");
            e.printStackTrace();
        }

        // 重定向回订单管理页面
        resp.sendRedirect(req.getContextPath() + "/merchant/orders?tab=orders");
    }
}
