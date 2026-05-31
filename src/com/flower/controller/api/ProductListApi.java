package com.flower.controller.api;

import com.flower.dao.SpDao;
import com.flower.dao.CategoryDao;
import com.flower.dao.BannerDao;
import com.flower.entity.Sp;
import com.flower.entity.Category;
import com.flower.entity.Banner;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.*;

@WebServlet("/api/products")
public class ProductListApi extends ApiBaseServlet {

    private SpDao spDao = new SpDao();
    private CategoryDao categoryDao = new CategoryDao();
    private BannerDao bannerDao = new BannerDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String keyword = req.getParameter("keyword");
        String categoryIdStr = req.getParameter("categoryId");
        String pageStr = req.getParameter("page");
        String pageSizeStr = req.getParameter("pageSize");

        List<Sp> products;
        if (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) {
            int cid = Integer.parseInt(categoryIdStr.trim());
            Category cat = categoryDao.findById(cid);
            if (cat != null && cat.isParent()) {
                products = spDao.findByParentCategory(cid);
            } else {
                products = spDao.findByCategory(cid);
            }
        } else if (keyword != null && !keyword.trim().isEmpty()) {
            products = spDao.search(keyword.trim());
        } else {
            products = spDao.findAll();
        }

        // pagination: if page not specified, return all (for homepage)
        int page = (pageStr != null) ? Integer.parseInt(pageStr) : 1;
        int pageSize = (pageSizeStr != null) ? Integer.parseInt(pageSizeStr) : 20;
        boolean hasPage = pageStr != null;

        int total = products.size();
        List<Sp> pageList;
        if (hasPage) {
            int from = (page - 1) * pageSize;
            int to = Math.min(from + pageSize, total);
            pageList = (from < total) ? products.subList(from, to) : new ArrayList<>();
        } else {
            pageList = products;
        }

        Map<String, Object> data = new HashMap<>();
        data.put("list", pageList);
        data.put("total", total);
        data.put("page", page);
        data.put("pageSize", pageSize);

        // 分类
        List<Category> parentCats = categoryDao.findParentCategories();
        for (Category pc : parentCats) {
            pc.setChildren(categoryDao.findChildCategories(pc.getId()));
        }
        data.put("categories", parentCats);

        // 轮播
        data.put("banners", bannerDao.findAll());

        // 热卖
        List<Sp> hot = new ArrayList<>(products);
        hot.sort((a, b) -> Integer.compare(b.getSales(), a.getSales()));
        data.put("hotProducts", hot.subList(0, Math.min(6, hot.size())));

        ok(resp, data);
    }
}
