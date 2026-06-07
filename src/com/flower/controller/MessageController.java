package com.flower.controller;

import com.flower.dao.MessageDao;
import com.flower.entity.Message;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/message")
public class MessageController extends HttpServlet {

    private MessageDao messageDao = new MessageDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) { resp.sendRedirect("login"); return; }
        // 用户点击"我的留言"时，将该用户所有未读标为已读
        messageDao.markUserRead(userId);
        req.setAttribute("myMessages", messageDao.findByUserId(userId));
        req.getRequestDispatcher("message.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        String username = (String) session.getAttribute("username");
        if (userId == null || username == null) { resp.sendRedirect("login"); return; }

        String action = req.getParameter("action");

        if ("reply".equals(action)) {
            String msgIdStr = req.getParameter("msgId");
            String userReply = req.getParameter("userReply");
            if (userReply == null || userReply.trim().isEmpty()) {
                session.setAttribute("msgError", "回复内容不能为空");
            } else {
                try {
                    int msgId = Integer.parseInt(msgIdStr);
                    if (messageDao.userReply(msgId, userReply.trim())) {
                        session.setAttribute("msgSuccess", "回复成功");
                    } else {
                        session.setAttribute("msgError", "回复失败，请稍后重试");
                    }
                } catch (NumberFormatException e) {
                    session.setAttribute("msgError", "参数错误");
                }
            }
            resp.sendRedirect("message");
            return;
        }

        // 新留言
        String content = req.getParameter("content");
        if (content == null || content.trim().isEmpty()) {
            session.setAttribute("msgError", "留言内容不能为空");
            resp.sendRedirect("message");
            return;
        }

        Message msg = new Message();
        msg.setUserId(userId);
        msg.setUsername(username);
        msg.setContent(content.trim());

        if (messageDao.save(msg)) {
            session.setAttribute("msgSuccess", "留言发送成功");
        } else {
            session.setAttribute("msgError", "发送失败，请稍后重试");
        }
        resp.sendRedirect("message");
    }
}
