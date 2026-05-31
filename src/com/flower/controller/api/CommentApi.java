package com.flower.controller.api;

import com.flower.dao.CommentDao;
import com.flower.entity.Comment;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/api/comments")
public class CommentApi extends ApiBaseServlet {

    private CommentDao commentDao = new CommentDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            int productId = Integer.parseInt(req.getParameter("productId"));
            ok(resp, commentDao.findByProductId(productId));
        } catch (NumberFormatException e) { fail(resp, 400, "参数错误"); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer uid = getUserId(req);
        String username = getUsername(req);
        if (uid == null || username == null) { unauth(resp); return; }

        String content = req.getParameter("content");
        if (content == null || content.trim().isEmpty()) { fail(resp, 400, "评论内容不能为空"); return; }

        try {
            int productId = Integer.parseInt(req.getParameter("productId"));
            int rating = req.getParameter("rating") != null ? Integer.parseInt(req.getParameter("rating")) : 5;
            if (rating < 1) rating = 1;
            if (rating > 5) rating = 5;

            Comment comment = new Comment();
            comment.setProductId(productId);
            comment.setUserId(uid);
            comment.setUsername(username);
            comment.setContent(content.trim());
            comment.setRating(rating);

            if (commentDao.save(comment)) {
                ok(resp, "评论发表成功", null);
            } else {
                fail(resp, 500, "评论发表失败");
            }
        } catch (NumberFormatException e) { fail(resp, 400, "参数错误"); }
    }
}
