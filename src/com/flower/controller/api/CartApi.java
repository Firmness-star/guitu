package com.flower.controller.api;

import com.flower.dao.CartDao;
import com.flower.dao.SpDao;
import com.flower.entity.CartItem;
import com.flower.entity.Sp;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet("/api/cart")
public class CartApi extends ApiBaseServlet {

    private CartDao cartDao = new CartDao();
    private SpDao spDao = new SpDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer uid = getUserId(req);
        if (uid == null) { unauth(resp); return; }
        List<CartItem> cart = cartDao.findByUserId(uid);
        double total = 0;
        int count = 0;
        for (CartItem item : cart) {
            if (item.isSelected()) {
                total += item.getProductPrice() * item.getQuantity();
                count += item.getQuantity();
            }
        }
        Map<String, Object> data = new HashMap<>();
        data.put("items", cart);
        data.put("totalAmount", Math.round(total * 100.0) / 100.0);
        data.put("totalCount", count);
        ok(resp, data);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer uid = getUserId(req);
        if (uid == null) { unauth(resp); return; }
        try {
            int pid = Integer.parseInt(req.getParameter("productId"));
            int qty = Integer.parseInt(req.getParameter("quantity"));
            Sp p = spDao.findById(pid);
            if (p == null) { fail(resp, 404, "商品不存在"); return; }
            // check if already in cart, accumulate properly
            List<CartItem> existing = cartDao.findByUserId(uid);
            boolean found = false;
            for (CartItem it : existing) {
                if (it.getProductId() == pid) {
                    cartDao.updateQuantity(uid, pid, it.getQuantity() + qty);
                    found = true;
                    break;
                }
            }
            if (!found) {
                CartItem item = new CartItem();
                item.setProductId(pid);
                item.setProductName(p.getName());
                item.setProductPic(p.getPic());
                item.setProductPrice(p.getPrice());
                item.setQuantity(qty);
                cartDao.addItem(uid, item);
            }
            ok(resp, "已加入购物车", null);
        } catch (NumberFormatException e) { fail(resp, 400, "参数错误"); }
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer uid = getUserId(req);
        if (uid == null) { unauth(resp); return; }
        try {
            int pid = Integer.parseInt(req.getParameter("productId"));
            int qty = Integer.parseInt(req.getParameter("quantity"));
            if (qty < 1) { cartDao.removeItem(uid, pid); }
            else { cartDao.updateQuantity(uid, pid, qty); }
            ok(resp, "已更新", null);
        } catch (NumberFormatException e) { fail(resp, 400, "参数错误"); }
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer uid = getUserId(req);
        if (uid == null) { unauth(resp); return; }
        String action = req.getParameter("action");
        if ("clear".equals(action)) { cartDao.clearCart(uid); ok(resp, "已清空", null); return; }
        try {
            int pid = Integer.parseInt(req.getParameter("productId"));
            cartDao.removeItem(uid, pid);
            ok(resp, "已移除", null);
        } catch (NumberFormatException e) { fail(resp, 400, "参数错误"); }
    }
}
