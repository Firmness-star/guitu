package com.flower.controller.api;

import com.flower.dao.BannerDao;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/api/banners")
public class BannerApi extends ApiBaseServlet {

    private BannerDao bannerDao = new BannerDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        ok(resp, bannerDao.findAll());
    }
}
