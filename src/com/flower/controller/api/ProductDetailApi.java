package com.flower.controller.api;

import com.flower.dao.SpDao;
import com.flower.dao.CategoryDao;
import com.flower.dao.CommentDao;
import com.flower.entity.Sp;
import com.flower.entity.Category;
import com.flower.entity.Comment;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.*;

@WebServlet("/api/product/detail")
public class ProductDetailApi extends ApiBaseServlet {

    private SpDao spDao = new SpDao();
    private CategoryDao categoryDao = new CategoryDao();
    private CommentDao commentDao = new CommentDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            int id = Integer.parseInt(req.getParameter("id"));
            Sp product = spDao.findById(id);
            if (product == null) { fail(resp, 404, "商品不存在"); return; }
            Map<String, Object> data = new HashMap<>();
            data.put("product", product);
            Category category = categoryDao.findById(product.getCategoryId());
            data.put("category", category);
            if (category != null && category.getParentId() > 0) {
                data.put("parentCategory", categoryDao.findById(category.getParentId()));
            }
            data.put("comments", commentDao.findByProductId(id));
            data.put("commentCount", commentDao.getCommentCount(id));
            data.put("avgRating", commentDao.getAvgRating(id));
            List<Sp> all = spDao.findAll();
            all.sort((a,b) -> Integer.compare(b.getSales(), a.getSales()));
            data.put("hotProducts", all.subList(0, Math.min(6, all.size())));
            ok(resp, data);
        } catch (NumberFormatException e) { fail(resp, 400, "参数错误"); }
    }
}