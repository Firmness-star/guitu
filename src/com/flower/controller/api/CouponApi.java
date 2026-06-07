package com.flower.controller.api;

import com.flower.dao.CouponDao;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet("/api/coupons")
public class CouponApi extends ApiBaseServlet {

    private CouponDao couponDao = new CouponDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer uid = getUserId(req);
        if (uid == null) { unauth(resp); return; }
        try {
            List<Map<String, Object>> list = couponDao.findAvailableByUser(uid);
            Map<String, Object> data = new HashMap<>();
            data.put("list", list);
            ok(resp, data);
        } catch (Exception e) {
            fail(resp, 500, "加载失败");
        }
    }
}
