package com.flower.controller;

import com.flower.dao.OrderDao;
import com.flower.dao.SeckillDao;
import com.flower.dao.AddressDao;
import com.flower.entity.*;
import com.flower.util.TransactionManager;

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
 * 秒杀控制器
 * 处理秒杀活动的展示和秒杀下单逻辑
 * 使用悲观锁 + 事务确保不超卖
 */
@WebServlet(urlPatterns = "/seckill")
public class SeckillController extends HttpServlet {

    private SeckillDao seckillDao;
    private OrderDao orderDao;
    private AddressDao addressDao;

    @Override
    public void init() throws ServletException {
        super.init();
        this.seckillDao = new SeckillDao();
        this.orderDao = new OrderDao();
        this.addressDao = new AddressDao();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        if ("buy".equals(action)) {
            doBuy(req, resp);
            return;
        }

        // 默认：秒杀活动列表页
        showList(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        doGet(req, resp);
    }

    /**
     * 展示秒杀活动列表页
     */
    private void showList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<SeckillActivity> allActivities = seckillDao.findAll();
        req.setAttribute("seckillList", allActivities);
        req.getRequestDispatcher("seckill.jsp").forward(req, resp);
    }

    /**
     * 秒杀下单核心逻辑
     * 事务流程：校验 → 悲观锁扣库存 → 记录秒杀订单 → 创建普通订单 → 提交
     */
    private void doBuy(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        String username = (String) session.getAttribute("username");

        // 1. 校验登录
        if (userId == null || username == null) {
            resp.sendRedirect("login.jsp?redirect=seckill?action=list");
            return;
        }

        // 2. 解析参数
        int seckillId;
        int quantity = 1;
        try {
            seckillId = Integer.parseInt(req.getParameter("seckillId"));
            String qtyStr = req.getParameter("quantity");
            if (qtyStr != null && !qtyStr.trim().isEmpty()) {
                quantity = Integer.parseInt(qtyStr.trim());
            }
        } catch (NumberFormatException e) {
            session.setAttribute("seckillError", "参数错误");
            resp.sendRedirect("seckill?action=list");
            return;
        }

        if (quantity <= 0) quantity = 1;

        // 3. 校验活动存在且进行中
        SeckillActivity activity = seckillDao.findById(seckillId);
        if (activity == null) {
            session.setAttribute("seckillError", "秒杀活动不存在");
            resp.sendRedirect("seckill?action=list");
            return;
        }
        if (!activity.isOngoing()) {
            session.setAttribute("seckillError", "秒杀活动未开始或已结束");
            resp.sendRedirect("seckill?action=list");
            return;
        }

        // 4. 校验限购数量
        if (quantity > activity.getPerUserLimit()) {
            quantity = activity.getPerUserLimit();
        }

        // 5. 校验用户是否已购买过
        if (seckillDao.hasUserBought(seckillId, userId)) {
            session.setAttribute("seckillError", "您已购买过该秒杀商品，每人限购一次");
            resp.sendRedirect("seckill?action=list");
            return;
        }

        // 6. 获取用户默认收货地址
        Address defaultAddress = addressDao.findDefaultByUserId(userId);
        if (defaultAddress == null) {
            session.setAttribute("seckillError", "请先添加收货地址");
            resp.sendRedirect("address?first=1");
            return;
        }

        // 7. 开启事务：扣库存 → 记录秒杀订单 → 创建普通订单
        try {
            TransactionManager.beginTransaction();

            // 悲观锁扣减库存
            boolean deducted = seckillDao.deductStock(seckillId, quantity, TransactionManager.getConnection());
            if (!deducted) {
                TransactionManager.rollback();
                session.setAttribute("seckillError", "秒杀库存不足，已被抢光");
                resp.sendRedirect("seckill?action=list");
                return;
            }

            // 创建普通订单
            String orderId = Order.generateOrderId();
            double totalAmount = activity.getSeckillPrice() * quantity;

            Order order = new Order();
            order.setOrderId(orderId);
            order.setUserId(userId);
            order.setUsername(username);
            order.setTotalAmount(totalAmount);
            order.setTotalCount(quantity);
            order.setStatus("待付款");
            order.setReceiverName(defaultAddress.getReceiverName());
            order.setReceiverPhone(defaultAddress.getReceiverPhone());
            order.setReceiverAddress(defaultAddress.getFullAddress());
            order.setRemark("[秒杀订单]");

            CartItem seckillItem = new CartItem();
            seckillItem.setProductId(activity.getProductId());
            seckillItem.setProductName(activity.getProductName());
            seckillItem.setProductPic(activity.getProductPic());
            seckillItem.setProductPrice(activity.getSeckillPrice());
            seckillItem.setQuantity(quantity);
            seckillItem.setSelected(true);

            List<CartItem> items = new ArrayList<>();
            items.add(seckillItem);
            order.setItems(items);

            orderDao.saveOrder(order);

            // 记录秒杀订单
            seckillDao.recordSeckillOrder(seckillId, userId, orderId, quantity, activity.getSeckillPrice(), TransactionManager.getConnection());

            TransactionManager.commit();

            // 成功：跳转支付页
            resp.sendRedirect("payment?orderId=" + orderId);
            return;

        } catch (Exception e) {
            try { TransactionManager.rollback(); } catch (Exception ignored) {}
            System.err.println("[CTRL] 秒杀下单失败: " + e.getMessage());
            session.setAttribute("seckillError", "秒杀下单失败，请稍后重试");
            resp.sendRedirect("seckill?action=list");
            return;
        }
    }
}
