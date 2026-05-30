package com.flower.controller;

import com.flower.dao.AddressDao;
import com.flower.dao.OrderDao;
import com.flower.dao.UserDao;
import com.flower.util.TransactionManager;
import com.flower.entity.Address;
import com.flower.entity.CartItem;
import com.flower.entity.Order;
import com.flower.entity.Sp;
import com.flower.service.ISpService;
import com.flower.service.ServiceFactory;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * 结算控制器
 *
 * <p>处理订单确认页面展示和订单提交
 * <ul>
 *   <li>订单提交后存入MySQL数据库</li>
 *   <li>使用OrderDao进行数据持久化，支持事务控制</li>
 *   <li>支持订单历史查询（数据重启不丢失）</li>
 *   <li>自动加载用户默认收货地址</li>
 * </ul>
 *
 * <p><strong>URL映射：</strong>
 * <ul>
 *   <li>GET /checkout - 显示结算确认页面</li>
 *   <li>GET/POST /checkout?action=submit - 提交订单到数据库</li>
 * </ul>
 *
 * @author FlowerShop
 * @version 2.0
 * @since 2026-04-15
 * @see com.flower.dao.OrderDao
 */
@WebServlet(urlPatterns = "/checkout")
public class CheckoutController extends HttpServlet {

    /** 订单数据访问对象，负责订单持久化操作 */
    private OrderDao orderDao;
    
    /** 地址数据访问对象，负责收货地址查询 */
    private AddressDao addressDao;

    /** 商品服务接口，用于获取商品详情 */
    private ISpService spService;

    private UserDao userDao;

    /**
     * Servlet初始化时实例化DAO对象
     * 使用init方法而非静态成员，符合Servlet生命周期规范
     */
    @Override
    public void init() throws ServletException {
        super.init();
        this.orderDao = new OrderDao();
        this.addressDao = new AddressDao();
        this.spService = ServiceFactory.getSpService();
        this.userDao = new UserDao();
    }

    /**
     * 处理 GET 请求，展示结算确认页面或处理订单提交逻辑
     *
     * @param req  HTTP 请求对象
     * @param resp HTTP 响应对象
     * @throws ServletException Servlet 异常
     * @throws IOException      IO 异常
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        HttpSession session = req.getSession();

        // 检查登录状态（未登录跳转到登录页）
        String username = (String) session.getAttribute("username");
        Integer userId = (Integer) session.getAttribute("userId");
        if (username == null || userId == null) {
            resp.sendRedirect("login.jsp?redirect=checkout");
            return;
        }

        // 获取购物车中选中的商品
        @SuppressWarnings("unchecked")
        List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");

        // 支持"立即购买"模式：如果购物车为空或未选中商品，检查是否有直接购买的商品参数
        List<CartItem> selectedItems = new ArrayList<>();
        double totalAmount = 0.0;
        int totalCount = 0;

        // 如果是直接购买（从商品详情页点击"立即购买"）
        if ("directBuy".equals(action)) {
            String productIdStr = req.getParameter("productId");
            String quantityStr = req.getParameter("quantity");

            if (productIdStr != null && !productIdStr.trim().isEmpty() && quantityStr != null && !quantityStr.trim().isEmpty()) {
                try {
                    int productId = Integer.parseInt(productIdStr.trim());
                    int quantity = Integer.parseInt(quantityStr.trim());

                    if (productId > 0 && quantity > 0) {
                        // 直接创建购物车项用于结算（不保存到购物车）
                        Sp product = spService.getProductDetail(productId);
                        if (product != null && product.getStock() >= quantity) {
                            CartItem directItem = new CartItem();
                            directItem.setProductId(product.getId());
                            directItem.setProductName(product.getName());
                            directItem.setProductPic(product.getPic());
                            directItem.setProductPrice(product.getPrice());
                            directItem.setQuantity(quantity);
                            directItem.setSelected(true);

                            selectedItems.add(directItem);
                            totalAmount = product.getPrice() * quantity;
                            totalCount = quantity;

                            // 直接购买时，将商品临时添加到购物车以便后续处理
                            if (cart == null) {
                                cart = new ArrayList<>();
                                session.setAttribute("cart", cart);
                            }
                            // 检查是否已经存在
                            boolean exists = false;
                            for (CartItem item : cart) {
                                if (item.getProductId() == productId) {
                                    exists = true;
                                    break;
                                }
                            }
                            if (!exists) {
                                cart.add(directItem);
                            }
                        }
                    }
                } catch (NumberFormatException e) {
                    // 忽略参数解析错误
                }
            }
        } else {
            // 普通购物车结算流程
            if (cart != null) {
                for (CartItem item : cart) {
                    if (item.isSelected()) {
                        selectedItems.add(item);
                        totalAmount += item.getSubtotal();
                        totalCount += item.getQuantity();
                    }
                }
            }
        }

        // 如果没有选中任何商品，返回购物车并提示
        if (selectedItems.isEmpty()) {
            if (cart == null || cart.isEmpty()) {
                // 购物车完全为空，重定向到购物车页面
                resp.sendRedirect("cart.jsp");
            } else {
                // 购物车有商品但没有选中
                req.setAttribute("error", "请至少选择一件商品进行结算");
                req.getRequestDispatcher("cart.jsp").forward(req, resp);
            }
            return;
        }

        // 处理订单提交操作
        if ("submit".equals(action)) {
            submitOrder(req, resp, session, selectedItems, totalAmount, totalCount, username, userId);
            return;
        }

        // 查询用户的默认收货地址和积分
        Address defaultAddress = addressDao.findDefaultByUserId(userId);
        int userJf = userDao.getJf(userId);

        // 积分抵扣规则：每100积分抵1元，最多抵商品总价的50%
        int maxJfDeduct = Math.min(userJf, (int)(totalAmount * 50 / 1));

        // 显示结算确认页面（准备数据并转发到checkout.jsp）
        req.setAttribute("selectedItems", selectedItems);
        req.setAttribute("totalAmount", Math.round(totalAmount * 100.0) / 100.0);
        req.setAttribute("totalCount", totalCount);
        req.setAttribute("username", username);
        req.setAttribute("defaultAddress", defaultAddress);
        req.setAttribute("userJf", userJf);
        req.setAttribute("maxJfDeduct", maxJfDeduct);

        req.getRequestDispatcher("checkout.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        doGet(req, resp);
    }

    /**
     * 处理订单提交
     *
     * <p>业务流程：
     * <ol>
     *   <li>接收并验证收货信息表单数据</li>
     *   <li>创建Order实体对象，封装订单信息</li>
     *   <li>调用OrderDao.saveOrder()将订单存入数据库（带事务）</li>
     *   <li>如果保存成功：
     *     <ul>
     *       <li>从购物车中移除已购买的商品</li>
     *       <li>将订单放入Session供成功页面展示</li>
     *       <li>重定向到订单成功页面</li>
     *     </ul>
     *   </li>
     *   <li>如果保存失败，返回结算页面并显示错误</li>
     * </ol>
     *
     * @param req           HTTP请求对象
     * @param resp          HTTP响应对象
     * @param session       用户会话对象
     * @param selectedItems 选中的购物车商品列表
     * @param totalAmount   订单总金额
     * @param totalCount    商品总件数
     * @param username      当前登录用户名
     * @param userId        当前登录用户ID
     * @throws ServletException 转发异常时抛出
     * @throws IOException      重定向异常时抛出
     */
    private void submitOrder(HttpServletRequest req, HttpServletResponse resp,
                             HttpSession session, List<CartItem> selectedItems,
                             double totalAmount, int totalCount, String username, Integer userId)
            throws ServletException, IOException {

        // Step 1: 获取并验证表单提交的收货信息
        req.setCharacterEncoding("UTF-8");
        String receiverName = req.getParameter("receiverName");
        String receiverPhone = req.getParameter("receiverPhone");
        String receiverAddress = req.getParameter("receiverAddress");
        String remark = req.getParameter("remark");
        String usePointsStr = req.getParameter("usePoints");

        // 简单验证：必填项不能为空
        if (isEmpty(receiverName) || isEmpty(receiverPhone) || isEmpty(receiverAddress)) {
            req.setAttribute("error", "请填写完整的收货信息");
            req.setAttribute("selectedItems", selectedItems);
            req.setAttribute("totalAmount", totalAmount);
            req.setAttribute("totalCount", totalCount);
            req.getRequestDispatcher("checkout.jsp").forward(req, resp);
            return;
        }

        if (userId == null) {
            resp.sendRedirect("login.jsp?redirect=checkout");
            return;
        }

        // 处理积分抵扣
        int usePoints = 0;
        double actualAmount = totalAmount;
        try {
            if (usePointsStr != null && !usePointsStr.trim().isEmpty()) {
                usePoints = Integer.parseInt(usePointsStr.trim());
                if (usePoints > 0) {
                    int userJf = userDao.getJf(userId);
                    if (usePoints > userJf) usePoints = userJf;
                    // 每100积分抵1元，积分抵扣不超过商品总价的50%
                    int maxDeduct = (int)(totalAmount * 50);
                    if (usePoints > maxDeduct) usePoints = maxDeduct;
                    actualAmount = totalAmount - usePoints / 100.0;
                    if (actualAmount < 0) actualAmount = 0;
                    actualAmount = Math.round(actualAmount * 100.0) / 100.0;
                }
            }
        } catch (NumberFormatException e) {
            usePoints = 0;
        }

        // Step 2: 创建并填充订单实体对象
        Order order = new Order();
        order.setOrderId(Order.generateOrderId());
        order.setUserId(userId);
        order.setUsername(username);
        order.setTotalAmount(actualAmount);
        order.setTotalCount(totalCount);
        order.setReceiverName(receiverName.trim());
        order.setReceiverPhone(receiverPhone.trim());
        order.setReceiverAddress(receiverAddress.trim());
        order.setRemark(remark != null ? remark.trim() : "");
        order.setItems(selectedItems);

        // Step 3: 调用DAO将订单持久化到数据库
        boolean saveSuccess = orderDao.saveOrder(order);

        if (saveSuccess) {
            // 积分处理：使用事务连接确保原子性
            try {
                java.sql.Connection txConn = TransactionManager.getConnection();
                if (usePoints > 0) {
                    userDao.deductJf(userId, usePoints, txConn);
                }
                int earnJf = (int)(actualAmount * 0.1);
                if (earnJf > 0) {
                    userDao.addJf(userId, earnJf, txConn);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            // 从购物车中移除已购买的商品（只移除选中的）
            @SuppressWarnings("unchecked")
            List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");
            if (cart != null) {
                cart.removeIf(CartItem::isSelected);
            }

            // 将当前订单存入session（仅供成功页面展示用，非持久化）
            session.setAttribute("currentOrder", order);

            System.out.println("订单提交成功：" + order.getOrderId() + "，用户：" + username);

            // 重定向到成功页面（防止重复提交）
            resp.sendRedirect("order_success.jsp");

        } else {
            // Step 4b: 保存失败，返回错误信息
            req.setAttribute("error", "订单提交失败，请稍后重试");
            req.setAttribute("selectedItems", selectedItems);
            req.setAttribute("totalAmount", totalAmount);
            req.setAttribute("totalCount", totalCount);
            req.getRequestDispatcher("checkout.jsp").forward(req, resp);
        }
    }

    /**
     * 检查字符串是否为空或空白（私有辅助方法）
     *
     * <p>简化null判断和trim操作，提高代码可读性。</p>
     *
     * @param str 待检查的字符串
     * @return boolean 如果为null或trim后为空字符串返回true
     */
    private boolean isEmpty(String str) {
        return str == null || str.trim().isEmpty();
    }
}