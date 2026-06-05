package com.flower.controller;

import com.flower.dao.CategoryDao;
import com.flower.dao.CommentDao;
import com.flower.dao.JfDao;
import com.flower.dao.SeckillDao;
import com.flower.dao.UserDao;
import com.flower.entity.Category;
import com.flower.entity.Comment;
import com.flower.entity.SeckillActivity;
import com.flower.service.ISpService;
import com.flower.service.ServiceFactory;
import com.flower.entity.Sp;
import com.flower.util.JsonUtil;
import javax.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * 商品详情控制器
 * 负责处理商品详情页面的展示逻辑
 */
@WebServlet(urlPatterns = {"/product/detail"})
public class ProductDetailController extends HttpServlet {

    private ISpService spService;

    @Override
    public void init() throws ServletException {
        super.init();
        this.spService = ServiceFactory.getSpService();
    }

    /**
     * 处理 GET 请求，根据商品ID获取商品详情并展示
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
        
        String productIdStr = req.getParameter("id");
        
        if (productIdStr == null || productIdStr.trim().isEmpty()) {
            resp.sendRedirect("index");
            return;
        }
        
        try {
            int productId = Integer.parseInt(productIdStr.trim());
            
            if (productId <= 0) {
                resp.sendRedirect("index");
                return;
            }
            
            Sp product = spService.getProductDetail(productId);
            
            if (product == null) {
                resp.sendRedirect("index");
                return;
            }
            
            req.setAttribute("product", product);

            // build multi-image list: main pic + extra pics
            List<String> imageList = new ArrayList<>();
            if (product.getPic() != null && !product.getPic().isEmpty()) {
                imageList.add(product.getPic());
            }
            String pics = product.getPics();
            if (pics != null && !pics.isEmpty()) {
                String cleaned = pics.replaceAll("[\\[\\]\"]", "");
                String[] urls = cleaned.split(",");
                for (String url : urls) {
                    url = url.trim();
                    if (!url.isEmpty() && !url.equals(product.getPic())) {
                        imageList.add(url);
                    }
                }
            }
            req.setAttribute("imageList", imageList);

            // 获取分类层级信息（用于面包屑导航）
            CategoryDao categoryDao = new CategoryDao();
            Category category = categoryDao.findById(product.getCategoryId());
            req.setAttribute("category", category);
            
            if (category != null && category.getParentId() > 0) {
                Category parentCategory = categoryDao.findById(category.getParentId());
                req.setAttribute("parentCategory", parentCategory);
            }
            
            // 获取热销商品推荐（用于相关商品展示）
            req.setAttribute("hotProducts", spService.getHotProducts(6));

            // 加载商品评论
            CommentDao commentDao = new CommentDao();
            List<Comment> comments = commentDao.findByProductId(productId);
            req.setAttribute("comments", comments);
            req.setAttribute("commentCount", commentDao.getCommentCount(productId));
            req.setAttribute("avgRating", commentDao.getAvgRating(productId));

            // 浏览商品送积分：+2（不重复计算同一商品）
            HttpSession session = req.getSession();
            Integer uid = (Integer) session.getAttribute("userId");
            if (uid != null) {
                String viewedKey = "viewed_" + productId;
                if (session.getAttribute(viewedKey) == null) {
                    UserDao userDao = new UserDao();
                    userDao.addJf(uid, 2);
                    new JfDao().addLog(uid, 2, "browse", "浏览商品赠送2积分");
                    session.setAttribute(viewedKey, true);
                }
            }

            // 查询该商品是否有进行中的秒杀活动
            SeckillDao seckillDao = new SeckillDao();
            SeckillActivity activeSeckill = seckillDao.findActiveByProductId(productId);
            req.setAttribute("activeSeckill", activeSeckill);

            req.getRequestDispatcher("/product_detail.jsp").forward(req, resp);
            
        } catch (NumberFormatException e) {
            resp.sendRedirect("index");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        doGet(req, resp);
    }
}
