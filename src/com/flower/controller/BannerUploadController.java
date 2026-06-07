package com.flower.controller;

import com.flower.dao.BannerDao;
import com.flower.entity.Banner;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.UUID;

@WebServlet("/admin/bannerUpload")
public class BannerUploadController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession();
        if (!"管理员".equals(session.getAttribute("userRole"))) {
            resp.sendRedirect("login");
            return;
        }

        if (!ServletFileUpload.isMultipartContent(req)) {
            session.setAttribute("adminError", "请选择要上传的图片");
            resp.sendRedirect(req.getContextPath() + "/admin/banners?tab=banners");
            return;
        }

        try {
            DiskFileItemFactory factory = new DiskFileItemFactory();
            ServletFileUpload upload = new ServletFileUpload(factory);
            upload.setSizeMax(5 * 1024 * 1024); // 5MB

            List<FileItem> items = upload.parseRequest(req);
            Banner banner = new Banner();

            for (FileItem item : items) {
                if (item.isFormField()) {
                    if ("productId".equals(item.getFieldName())) {
                        banner.setProductId(Integer.parseInt(item.getString("UTF-8")));
                    }
                } else if (item.getSize() > 0) {
                    String fileName = item.getName();
                    String ext = fileName.substring(fileName.lastIndexOf(".")).toLowerCase();
                    if (!ext.equals(".jpg") && !ext.equals(".jpeg") && !ext.equals(".png") && !ext.equals(".gif")) {
                        session.setAttribute("adminError", "仅支持 JPG、PNG、GIF 格式");
                        resp.sendRedirect(req.getContextPath() + "/admin/banners?tab=banners");
                        return;
                    }
                    String uploadDir = getServletContext().getRealPath("/") + "uploads";
                    File dir = new File(uploadDir);
                    if (!dir.exists()) dir.mkdirs();
                    String savedName = UUID.randomUUID().toString() + ext;
                    File savedFile = new File(dir, savedName);
                    item.write(savedFile);
                    banner.setImgUrl("uploads/" + savedName);
                }
            }

            if (banner.getImgUrl() != null && banner.getProductId() > 0) {
                new BannerDao().save(banner);
                session.setAttribute("adminSuccess", "海报上传成功！");
            } else {
                session.setAttribute("adminError", "请选择图片并填写商品ID");
            }
        } catch (Exception e) {
            System.err.println("[CTRL] " + e.getMessage());
            session.setAttribute("adminError", "上传失败：" + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/admin/banners?tab=banners");
    }
}
