package com.flower.controller;

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

@WebServlet("/merchant/productUpload")
public class ProductPicUploadController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");
        HttpSession session = req.getSession();
        if (!"商家".equals(session.getAttribute("userRole"))) {
            resp.getWriter().write("{\"success\":false,\"message\":\"无权访问\"}");
            return;
        }

        if (!ServletFileUpload.isMultipartContent(req)) {
            resp.getWriter().write("{\"success\":false,\"message\":\"请选择图片\"}");
            return;
        }

        try {
            DiskFileItemFactory factory = new DiskFileItemFactory();
            ServletFileUpload upload = new ServletFileUpload(factory);
            upload.setSizeMax(5 * 1024 * 1024);

            List<FileItem> items = upload.parseRequest(req);
            for (FileItem item : items) {
                if (!item.isFormField() && item.getSize() > 0) {
                    String fileName = item.getName();
                    String ext = fileName.substring(fileName.lastIndexOf(".")).toLowerCase();
                    if (!ext.equals(".jpg") && !ext.equals(".jpeg") && !ext.equals(".png") && !ext.equals(".gif") && !ext.equals(".webp")) {
                        resp.getWriter().write("{\"success\":false,\"message\":\"仅支持 JPG/PNG/GIF/WEBP 格式\"}");
                        return;
                    }
                    String uploadDir = getServletContext().getRealPath("/") + "uploads";
                    File dir = new File(uploadDir);
                    if (!dir.exists()) dir.mkdirs();
                    String savedName = UUID.randomUUID().toString() + ext;
                    File savedFile = new File(dir, savedName);
                    item.write(savedFile);
                    String url = req.getContextPath() + "/uploads/" + savedName;
                    resp.getWriter().write("{\"success\":true,\"url\":\"" + url + "\"}");
                    return;
                }
            }
            resp.getWriter().write("{\"success\":false,\"message\":\"未收到文件\"}");
        } catch (Exception e) {
            System.err.println("ERROR: " + e.getMessage());
            resp.getWriter().write("{\"success\":false,\"message\":\"上传失败\"}");
        }
    }
}
