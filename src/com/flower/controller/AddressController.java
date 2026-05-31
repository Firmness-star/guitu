package com.flower.controller;

import com.flower.dao.AddressDao;
import com.flower.entity.Address;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * 收货地址管理控制器
 * 处理用户收货地址的增删改查及默认地址设置功能
 */
@WebServlet("/address")
public class AddressController extends HttpServlet {

    private AddressDao addressDao = new AddressDao();

    /**
     * 处理 GET 请求，查询并展示当前用户的收货地址列表
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
        String username = (String) session.getAttribute("username");
        Integer userId = (Integer) session.getAttribute("userId");

        if (username == null || userId == null) {
            resp.sendRedirect("login.jsp?redirect=address");
            return;
        }

        List<Address> addressList = addressDao.findByUserId(userId);
        req.setAttribute("addressList", addressList);
        req.getRequestDispatcher("address.jsp").forward(req, resp);
    }

    /**
     * 处理 POST 请求，根据 action 参数分发到不同的地址操作方法
     *
     * @param req  HTTP 请求对象
     * @param resp HTTP 响应对象
     * @throws ServletException Servlet 异常
     * @throws IOException      IO 异常
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        String username = (String) session.getAttribute("username");
        Integer userId = (Integer) session.getAttribute("userId");

        if (username == null || userId == null) {
            resp.sendRedirect("login.jsp?redirect=address");
            return;
        }

        String action = req.getParameter("action");
        
        if ("add".equals(action)) {
            addAddress(req, resp, userId);
        } else if ("update".equals(action)) {
            updateAddress(req, resp, userId);
        } else if ("delete".equals(action)) {
            deleteAddress(req, resp, userId);
        } else if ("setDefault".equals(action)) {
            setDefaultAddress(req, resp, userId);
        } else {
            resp.sendRedirect("address");
        }
    }

    /**
     * 添加新的收货地址
     *
     * @param req    HTTP 请求对象
     * @param resp   HTTP 响应对象
     * @param userId 当前登录用户的 ID
     * @throws ServletException Servlet 异常
     * @throws IOException      IO 异常
     */
    private void addAddress(HttpServletRequest req, HttpServletResponse resp, int userId)
            throws ServletException, IOException {
        
        String receiverName = req.getParameter("receiverName");
        String receiverPhone = req.getParameter("receiverPhone");
        String province = req.getParameter("province");
        String city = req.getParameter("city");
        String district = req.getParameter("district");
        String detailAddress = req.getParameter("detailAddress");
        String isDefault = req.getParameter("isDefault");

        if (receiverName == null || receiverPhone == null || province == null || 
            city == null || district == null || detailAddress == null) {
            req.getSession().setAttribute("error", "请填写完整信息");
            resp.sendRedirect("address");
            return;
        }

        Address address = new Address(userId, receiverName, receiverPhone,
                                       province, city, district, detailAddress);
        // 第一个地址自动设为默认
        List<Address> existing = addressDao.findByUserId(userId);
        address.setDefault(existing.isEmpty() || "on".equals(isDefault));

        boolean success = addressDao.save(address);
        
        if (success) {
            req.getSession().setAttribute("message", "添加成功");
        } else {
            req.getSession().setAttribute("error", "添加失败");
        }
        resp.sendRedirect("address");
    }

    /**
     * 更新指定的收货地址信息
     *
     * @param req    HTTP 请求对象
     * @param resp   HTTP 响应对象
     * @param userId 当前登录用户的 ID，用于权限校验
     * @throws ServletException Servlet 异常
     * @throws IOException      IO 异常
     */
    private void updateAddress(HttpServletRequest req, HttpServletResponse resp, int userId)
            throws ServletException, IOException {
        
        String idStr = req.getParameter("id");
        if (idStr == null) {
            resp.sendRedirect("address");
            return;
        }

        int id = Integer.parseInt(idStr);
        Address address = addressDao.findById(id);
        
        if (address == null || address.getUserId() != userId) {
            resp.sendRedirect("address");
            return;
        }

        String receiverName = req.getParameter("receiverName");
        String receiverPhone = req.getParameter("receiverPhone");
        String province = req.getParameter("province");
        String city = req.getParameter("city");
        String district = req.getParameter("district");
        String detailAddress = req.getParameter("detailAddress");
        String isDefault = req.getParameter("isDefault");

        address.setReceiverName(receiverName);
        address.setReceiverPhone(receiverPhone);
        address.setProvince(province);
        address.setCity(city);
        address.setDistrict(district);
        address.setDetailAddress(detailAddress);
        address.setDefault("on".equals(isDefault));

        boolean success = addressDao.update(address);
        
        if (success) {
            req.getSession().setAttribute("message", "修改成功");
        } else {
            req.getSession().setAttribute("error", "修改失败");
        }
        resp.sendRedirect("address");
    }

    /**
     * 删除指定的收货地址
     *
     * @param req    HTTP 请求对象
     * @param resp   HTTP 响应对象
     * @param userId 当前登录用户的 ID，确保只能删除自己的地址
     * @throws ServletException Servlet 异常
     * @throws IOException      IO 异常
     */
    private void deleteAddress(HttpServletRequest req, HttpServletResponse resp, int userId)
            throws ServletException, IOException {
        
        String idStr = req.getParameter("id");
        if (idStr == null) {
            resp.sendRedirect("address");
            return;
        }

        int id = Integer.parseInt(idStr);
        boolean success = addressDao.delete(id, userId);
        
        if (success) {
            req.getSession().setAttribute("message", "删除成功");
        } else {
            req.getSession().setAttribute("error", "删除失败");
        }
        resp.sendRedirect("address");
    }

    /**
     * 设置指定的收货地址为默认地址
     *
     * @param req    HTTP 请求对象
     * @param resp   HTTP 响应对象
     * @param userId 当前登录用户的 ID
     * @throws ServletException Servlet 异常
     * @throws IOException      IO 异常
     */
    private void setDefaultAddress(HttpServletRequest req, HttpServletResponse resp, int userId)
            throws ServletException, IOException {
        
        String idStr = req.getParameter("id");
        if (idStr == null) {
            resp.sendRedirect("address");
            return;
        }

        int id = Integer.parseInt(idStr);
        boolean success = addressDao.setDefault(id, userId);
        
        if (success) {
            req.getSession().setAttribute("message", "设置成功");
        } else {
            req.getSession().setAttribute("error", "设置失败");
        }
        resp.sendRedirect("address");
    }
}
