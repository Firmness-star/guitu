package com.flower.controller;

import com.flower.service.ISpService;
import com.flower.service.ICategoryService;
import com.flower.service.ServiceFactory;
import com.flower.dao.BannerDao;
import com.flower.dao.OrderDao;
import com.flower.dao.SeckillDao;
import com.flower.entity.Sp;
import com.flower.entity.Category;
import com.flower.entity.Banner;
import com.flower.entity.SeckillActivity;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * 首页及商品展示控制器
 * 负责处理商品列表的展示、分类筛选及关键词搜索功能
 */
@WebServlet(urlPatterns = {"/index", "/products"})
public class IndexController extends HttpServlet {

    private ISpService spService;
    private ICategoryService categoryService;
    private BannerDao bannerDao;
    private OrderDao orderDao;
    private SeckillDao seckillDao;

    @Override
    public void init() throws ServletException {
        super.init();
        this.spService = ServiceFactory.getSpService();
        this.categoryService = ServiceFactory.getCategoryService();
        this.bannerDao = new BannerDao();
        this.orderDao = new OrderDao();
        this.seckillDao = new SeckillDao();
    }

    /**
     * 处理 GET 请求，根据参数展示全部商品、分类商品或搜索结果
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

        String keyword = req.getParameter("keyword");
        String categoryIdStr = req.getParameter("categoryId");

        List<Sp> productList;
        String pageTitle;
        Integer selectedCategoryId = null;
        Integer selectedParentId = null;

        // 获取所有一级分类用于导航栏展示
        List<Category> parentCategories = categoryService.findParentCategories();
        req.setAttribute("parentCategories", parentCategories);

        // 加载首页海报
        List<Banner> banners = bannerDao.findAll();
        req.setAttribute("banners", banners);

        if (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) {
            try {
                selectedCategoryId = Integer.parseInt(categoryIdStr.trim());
                
                Category selectedCategory = categoryService.getCategoryById(selectedCategoryId);
                
                if (selectedCategory != null) {
                    if (selectedCategory.isParent()) {
                        // 如果选中的是一级分类，则查询其下所有二级分类对应的商品
                        selectedParentId = selectedCategoryId;
                        productList = spService.findProductsByParentCategory(selectedParentId);
                        pageTitle = "分类：" + selectedCategory.getName();
                        
                        List<Category> childCategories = categoryService.findChildCategories(selectedParentId);
                        req.setAttribute("childCategories", childCategories);
                    } else {
                        // 如果选中的是二级分类，直接查询该分类下的商品
                        productList = spService.findProductsByCategory(selectedCategoryId);
                        pageTitle = "分类：" + selectedCategory.getName();
                        
                        selectedParentId = selectedCategory.getParentId();
                        List<Category> childCategories = categoryService.findChildCategories(selectedParentId);
                        req.setAttribute("childCategories", childCategories);
                    }
                } else {
                    productList = spService.findAllProducts();
                    pageTitle = "全部商品";
                }
            } catch (NumberFormatException e) {
                productList = spService.findAllProducts();
                pageTitle = "全部商品";
            }
        } else if (keyword != null && !keyword.trim().isEmpty()) {
            // 执行关键词搜索
            productList = spService.searchProducts(keyword.trim());
            req.setAttribute("searchKeyword", keyword.trim());
            pageTitle = "搜索结果 - " + keyword.trim();
        } else {
            // 默认展示全部商品
            productList = spService.findAllProducts();
            pageTitle = "全部商品";
        }

        req.setAttribute("productList", productList);
        req.setAttribute("productCount", productList.size());
        req.setAttribute("pageTitle", pageTitle);
        req.setAttribute("selectedCategoryId", selectedCategoryId);
        req.setAttribute("selectedParentId", selectedParentId);

        // 热卖商品：销量前10
        List<Sp> allProducts = spService.findAllProducts();
        List<Sp> hotList = new ArrayList<>(allProducts);
        hotList.sort((a, b) -> Integer.compare(b.getSales(), a.getSales()));
        List<Sp> hotProducts = hotList.subList(0, Math.min(10, hotList.size()));
        req.setAttribute("hotProducts", hotProducts);

        // 登录用户加载待处理订单数量
        Integer userId = (Integer) req.getSession().getAttribute("userId");
        if (userId != null) {
            List<com.flower.entity.Order> userOrders = orderDao.findByUserId(userId);
            long pendingOrderCount = userOrders.stream()
                    .filter(o -> "待付款".equals(o.getStatus()) || "已付款".equals(o.getStatus()) || "已发货".equals(o.getStatus()))
                    .count();
            req.setAttribute("pendingOrderCount", pendingOrderCount);
        }

        // 加载进行中的秒杀活动
        List<SeckillActivity> activeSeckillList = seckillDao.findActive();
        req.setAttribute("activeSeckillList", activeSeckillList);

        req.getRequestDispatcher("index.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        doGet(req, resp);
    }
}