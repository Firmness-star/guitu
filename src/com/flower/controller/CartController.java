package com.flower.controller;

import com.flower.dao.CartDao;
import com.flower.dao.SpDao;
import com.flower.dao.UserDao;
import com.flower.entity.CartItem;
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
import java.util.stream.Collectors;

/**
 * 购物车控制器
 * 处理购物车的增删改查、选中状态切换及总价计算等功能
 */
@WebServlet(urlPatterns = "/cart")
public class CartController extends HttpServlet {

    private SpDao spDao = new SpDao();
    private UserDao userDao = new UserDao();
    private CartDao cartDao = new CartDao();

    /**
     * 处理 GET 请求，根据 action 参数执行相应的购物车操作或展示购物车页面
     *
     * @param req  HTTP 请求对象
     * @param resp HTTP 响应对象
     * @throws ServletException Servlet 异常
     * @throws IOException      IO 异常
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession();
        String action = req.getParameter("action");

        List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");
        if (cart == null) {
            cart = new ArrayList<>();
            session.setAttribute("cart", cart);
        }

        if ("add".equals(action)) {
            doAdd(req, cart, session);
            if (isAjax(req)) { writeJson(resp, cart); return; }
            resp.sendRedirect("cart");
            return;
        }
        else if ("directBuy".equals(action)) {
            doDirectBuy(req, session, cart);
            resp.sendRedirect("checkout");
            return;
        }
        else if ("remove".equals(action)) {
            doRemove(req, cart, session);
            if (isAjax(req)) { writeJson(resp, cart); return; }
            resp.sendRedirect("cart");
            return;
        }
        else if ("update".equals(action)) {
            doUpdate(req, cart, session);
            if (isAjax(req)) { writeJson(resp, cart); return; }
            resp.sendRedirect("cart");
            return;
        }
        else if ("select".equals(action)) {
            doSelect(req, cart, session);
            if (isAjax(req)) { writeJson(resp, cart); return; }
            resp.sendRedirect("cart");
            return;
        }
        else if ("selectAll".equals(action)) {
            doSelectAll(cart, session, true);
            if (isAjax(req)) { writeJson(resp, cart); return; }
            resp.sendRedirect("cart");
            return;
        }
        else if ("unselectAll".equals(action)) {
            doSelectAll(cart, session, false);
            if (isAjax(req)) { writeJson(resp, cart); return; }
            resp.sendRedirect("cart");
            return;
        }
        else if ("batchRemove".equals(action)) {
            doBatchRemove(req, cart, session);
            if (isAjax(req)) { writeJson(resp, cart); return; }
            resp.sendRedirect("cart");
            return;
        }
        else if ("clear".equals(action)) {
            cart.clear();
            session.setAttribute("cart", cart);
            Integer uid = (Integer) session.getAttribute("userId");
            if (uid != null) cartDao.clearCart(uid);
            if (isAjax(req)) { writeJson(resp, cart); return; }
            resp.sendRedirect("cart");
            return;
        }

        calculateCartTotals(req, cart);

        req.getRequestDispatcher("cart.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        doGet(req, resp);
    }

    /**
     * 计算购物车中商品的总数量、选中商品的数量及选中商品的总金额
     *
     * @param req  HTTP 请求对象，用于存储计算结果
     * @param cart 购物车商品列表
     */
    private void calculateCartTotals(HttpServletRequest req, List<CartItem> cart) {
        double totalMoney = 0.0;
        int totalNum = 0;
        int selectedNum = 0;

        for (CartItem item : cart) {
            totalNum += item.getQuantity();
            if (item.isSelected()) {
                totalMoney += item.getProductPrice() * item.getQuantity();
                selectedNum += item.getQuantity();
            }
        }

        totalMoney = Math.round(totalMoney * 100.0) / 100.0;

        req.setAttribute("totalMoney", totalMoney);
        req.setAttribute("totalNum", totalNum);
        req.setAttribute("selectedNum", selectedNum);
    }

    /**
     * 向购物车中添加商品，若商品已存在则增加数量，否则新增条目
     *
     * @param req     HTTP 请求对象，包含商品 ID 和数量
     * @param cart    购物车商品列表
     * @param session 用户会话对象
     */
    private void doAdd(HttpServletRequest req, List<CartItem> cart, HttpSession session) {
        try {
            int pid = Integer.parseInt(req.getParameter("productId"));
            int qty = Integer.parseInt(req.getParameter("quantity"));

            if (qty <= 0) {
                return;
            }

            for (CartItem item : cart) {
                if (item.getProductId() == pid) {
                    item.setQuantity(item.getQuantity() + qty);
                    session.setAttribute("cart", cart);
                    Integer uid = (Integer) session.getAttribute("userId");
                    if (uid != null) cartDao.updateQuantity(uid, pid, item.getQuantity());
                    return;
                }
            }

            Sp p = spDao.findById(pid);
            if (p != null) {
                CartItem item = new CartItem();
                item.setProductId(pid);
                item.setProductName(p.getName());
                item.setProductPic(p.getPic());
                item.setProductPrice(p.getPrice());
                item.setQuantity(qty);
                item.setSelected(true);
                item.setStock(p.getStock());
                item.setStatus(p.getStatus());
                cart.add(item);
                session.setAttribute("cart", cart);

                Integer uid = (Integer) session.getAttribute("userId");
                if (uid != null) {
                    cartDao.addItem(uid, item);
                    userDao.addJf(uid, 5);
                }
            }
        } catch (Exception e) {
            System.err.println("[CTRL] " + e.getMessage());
        }
    }

    /**
     * 从购物车中移除指定商品
     *
     * @param req     HTTP 请求对象，包含商品 ID
     * @param cart    购物车商品列表
     * @param session 用户会话对象
     */
    private void doRemove(HttpServletRequest req, List<CartItem> cart, HttpSession session) {
        try {
            int pid = Integer.parseInt(req.getParameter("productId"));
            cart.removeIf(item -> item.getProductId() == pid);
            session.setAttribute("cart", cart);
            Integer uid = (Integer) session.getAttribute("userId");
            if (uid != null) cartDao.removeItem(uid, pid);
        } catch (Exception e) {
            System.err.println("[CTRL] " + e.getMessage());
        }
    }

    /**
     * 直接购买指定商品（不保存到购物车，直接跳转到结算页面）
     *
     * @param req     HTTP 请求对象，包含商品 ID 和数量
     * @param session 用户会话对象
     * @param cart    购物车商品列表
     */
    private void doDirectBuy(HttpServletRequest req, HttpSession session, List<CartItem> cart) {
        try {
            int pid = Integer.parseInt(req.getParameter("productId"));
            int qty = Integer.parseInt(req.getParameter("quantity"));

            if (qty <= 0) {
                qty = 1;
            }

            // 检查商品是否已经在购物车中
            for (CartItem item : cart) {
                if (item.getProductId() == pid) {
                    // 如果已存在，标记为选中状态
                    item.setSelected(true);
                    session.setAttribute("directBuyProductId", pid);
                    return;
                }
            }

            // 如果不在购物车中，添加到购物车并标记为选中
            Sp p = spDao.findById(pid);
            if (p != null) {
                CartItem item = new CartItem();
                item.setProductId(pid);
                item.setProductName(p.getName());
                item.setProductPic(p.getPic());
                item.setProductPrice(p.getPrice());
                item.setQuantity(qty);
                item.setSelected(true);
                item.setStock(p.getStock());
                item.setStatus(p.getStatus());
                cart.add(item);
            }
        } catch (Exception e) {
            System.err.println("[CTRL] " + e.getMessage());
        }
    }

    /**
     * 更新购物车中指定商品的数量
     *
     * @param req     HTTP 请求对象，包含商品 ID 和新数量
     * @param cart    购物车商品列表
     * @param session 用户会话对象
     */
    private void doUpdate(HttpServletRequest req, List<CartItem> cart, HttpSession session) {
        try {
            int pid = Integer.parseInt(req.getParameter("productId"));
            int qty = Integer.parseInt(req.getParameter("quantity"));

            if (qty < 1) {
                qty = 1;
            }

            for (CartItem item : cart) {
                if (item.getProductId() == pid) {
                    // 服务端库存校验：不允许超过库存
                    if (item.getStock() > 0 && qty > item.getStock()) {
                        qty = item.getStock();
                    }
                    item.setQuantity(qty);
                    session.setAttribute("cart", cart);
                    Integer uid = (Integer) session.getAttribute("userId");
                    if (uid != null) cartDao.updateQuantity(uid, pid, qty);
                    break;
                }
            }
        } catch (Exception e) {
            System.err.println("[CTRL] " + e.getMessage());
        }
    }

    /**
     * 切换购物车中指定商品的选中状态
     *
     * @param req     HTTP 请求对象，包含商品 ID 和选中状态标识
     * @param cart    购物车商品列表
     * @param session 用户会话对象
     */
    private void doSelect(HttpServletRequest req, List<CartItem> cart, HttpSession session) {
        try {
            int pid = Integer.parseInt(req.getParameter("productId"));
            String checked = req.getParameter("checked");

            for (CartItem item : cart) {
                if (item.getProductId() == pid) {
                    boolean newState = "on".equals(checked);
                    item.setSelected(newState);
                    session.setAttribute("cart", cart);
                    // 持久化选中状态到数据库
                    Integer uid = (Integer) session.getAttribute("userId");
                    if (uid != null) cartDao.updateSelected(uid, pid, newState);
                    break;
                }
            }
        } catch (Exception e) {
            System.err.println("[CTRL] " + e.getMessage());
        }
    }

    /**
     * 全选或全不选购物车中的所有商品
     *
     * @param cart     购物车商品列表
     * @param session  用户会话对象
     * @param selected 是否选中（true 为全选，false 为全不选）
     */
    private void doSelectAll(List<CartItem> cart, HttpSession session, boolean selected) {
        if (cart == null || cart.isEmpty()) {
            return;
        }

        for (CartItem item : cart) {
            item.setSelected(selected);
        }
        session.setAttribute("cart", cart);
        // 持久化全选/取消全选状态到数据库
        Integer uid = (Integer) session.getAttribute("userId");
        if (uid != null) cartDao.updateAllSelected(uid, selected);
    }

    /**
     * 批量删除购物车中的指定商品
     *
     * @param req     HTTP 请求对象，包含用逗号分隔的 productIds
     * @param cart    购物车商品列表
     * @param session 用户会话对象
     */
    private void doBatchRemove(HttpServletRequest req, List<CartItem> cart, HttpSession session) {
        try {
            String idsStr = req.getParameter("productIds");
            if (idsStr == null || idsStr.trim().isEmpty()) return;
            Set<Integer> idsToRemove = Arrays.stream(idsStr.split(","))
                    .map(String::trim).filter(s -> !s.isEmpty()).map(Integer::parseInt)
                    .collect(Collectors.toSet());
            if (idsToRemove.isEmpty()) return;
            cart.removeIf(item -> idsToRemove.contains(item.getProductId()));
            session.setAttribute("cart", cart);
            Integer uid = (Integer) session.getAttribute("userId");
            if (uid != null) {
                for (int pid : idsToRemove) cartDao.removeItem(uid, pid);
            }
        } catch (Exception e) {
            System.err.println("[CTRL] " + e.getMessage());
        }
    }

    /**
     * 判断是否为 AJAX 请求
     */
    private boolean isAjax(HttpServletRequest req) {
        return "1".equals(req.getParameter("ajax"))
                || "XMLHttpRequest".equals(req.getHeader("X-Requested-With"));
    }

    /**
     * 以 JSON 格式返回购物车统计数据
     */
    private void writeJson(HttpServletResponse resp, List<CartItem> cart) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        double totalMoney = 0.0;
        int totalNum = 0;
        int selectedNum = 0;
        for (CartItem item : cart) {
            totalNum += item.getQuantity();
            if (item.isSelected()) {
                totalMoney += item.getProductPrice() * item.getQuantity();
                selectedNum += item.getQuantity();
            }
        }
        totalMoney = Math.round(totalMoney * 100.0) / 100.0;
        Map<String, Object> data = new HashMap<>();
        data.put("totalMoney", totalMoney);
        data.put("totalNum", totalNum);
        data.put("selectedNum", selectedNum);
        Map<String, Object> result = new HashMap<>();
        result.put("code", 200);
        result.put("data", data);
        PrintWriter out = resp.getWriter();
        out.print(JsonUtil.toJson(result));
        out.flush();
    }
}