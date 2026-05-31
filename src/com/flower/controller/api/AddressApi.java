package com.flower.controller.api;

import com.flower.dao.AddressDao;
import com.flower.entity.Address;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet("/api/address")
public class AddressApi extends ApiBaseServlet {

    private AddressDao addressDao = new AddressDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer uid = getUserId(req);
        if (uid == null) { unauth(resp); return; }
        List<Address> list = addressDao.findByUserId(uid);
        Map<String, Object> data = new HashMap<>();
        data.put("list", list);
        Address def = addressDao.findDefaultByUserId(uid);
        data.put("defaultAddress", def);
        ok(resp, data);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer uid = getUserId(req);
        if (uid == null) { unauth(resp); return; }
        String receiverName = req.getParameter("receiverName");
        String receiverPhone = req.getParameter("receiverPhone");
        String province = req.getParameter("province");
        String city = req.getParameter("city");
        String district = req.getParameter("district");
        String detailAddress = req.getParameter("detailAddress");
        String isDefault = req.getParameter("isDefault");

        if (receiverName == null || receiverPhone == null || province == null || city == null || district == null || detailAddress == null) {
            fail(resp, 400, "请填写完整信息"); return;
        }

        Address address = new Address(uid, receiverName, receiverPhone, province, city, district, detailAddress);
        List<Address> existing = addressDao.findByUserId(uid);
        address.setDefault(existing.isEmpty() || "1".equals(isDefault));

        if (addressDao.save(address)) {
            ok(resp, "添加成功", address);
        } else {
            fail(resp, 500, "添加失败");
        }
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer uid = getUserId(req);
        if (uid == null) { unauth(resp); return; }
        String action = req.getParameter("action");
        try {
            int id = Integer.parseInt(req.getParameter("id"));
            if ("setDefault".equals(action)) {
                addressDao.setDefault(id, uid);
                ok(resp, "已设为默认", null);
            } else {
                String receiverName = req.getParameter("receiverName");
                String receiverPhone = req.getParameter("receiverPhone");
                String province = req.getParameter("province");
                String city = req.getParameter("city");
                String district = req.getParameter("district");
                String detailAddress = req.getParameter("detailAddress");
                Address addr = addressDao.findById(id);
                if (addr == null || addr.getUserId() != uid) { fail(resp, 404, "地址不存在"); return; }
                addr.setReceiverName(receiverName);
                addr.setReceiverPhone(receiverPhone);
                addr.setProvince(province);
                addr.setCity(city);
                addr.setDistrict(district);
                addr.setDetailAddress(detailAddress);
                if ("1".equals(req.getParameter("isDefault"))) addr.setDefault(true);
                addressDao.update(addr);
                ok(resp, "修改成功", null);
            }
        } catch (NumberFormatException e) { fail(resp, 400, "参数错误"); }
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer uid = getUserId(req);
        if (uid == null) { unauth(resp); return; }
        try {
            int id = Integer.parseInt(req.getParameter("id"));
            addressDao.delete(id, uid);
            ok(resp, "已删除", null);
        } catch (NumberFormatException e) { fail(resp, 400, "参数错误"); }
    }
}
