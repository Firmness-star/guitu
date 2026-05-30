package com.flower.controller;

import com.flower.dao.CommentDao;
import com.flower.entity.Comment;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/comment")
public class CommentController extends HttpServlet {

    private CommentDao commentDao = new CommentDao();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        String username = (String) session.getAttribute("username");

        if (userId == null || username == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        String productIdStr = req.getParameter("productId");
        String content = req.getParameter("content");
        String ratingStr = req.getParameter("rating");

        if (content == null || content.trim().isEmpty()) {
            session.setAttribute("commentError", "评论内容不能为空");
            resp.sendRedirect("product/detail?id=" + productIdStr);
            return;
        }

        try {
            int productId = Integer.parseInt(productIdStr);
            int rating = ratingStr != null ? Integer.parseInt(ratingStr) : 5;
            if (rating < 1) rating = 1;
            if (rating > 5) rating = 5;

            Comment comment = new Comment();
            comment.setProductId(productId);
            comment.setUserId(userId);
            comment.setUsername(username);
            comment.setContent(content.trim());
            comment.setRating(rating);

            if (commentDao.save(comment)) {
                session.setAttribute("commentSuccess", "评论发表成功");
            } else {
                session.setAttribute("commentError", "评论发表失败，请稍后重试");
            }
        } catch (NumberFormatException e) {
            session.setAttribute("commentError", "参数错误");
        }

        resp.sendRedirect("product/detail?id=" + productIdStr);
    }
}
