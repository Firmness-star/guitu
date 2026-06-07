package com.flower.controller;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

import javax.servlet.ServletContext;
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

@WebServlet("/admin/qrcodeUpload")
public class QrCodeUploadController extends HttpServlet {

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
            session.setAttribute("adminError", "请选择二维码图片");
            resp.sendRedirect(req.getContextPath() + "/admin/banners?tab=banners");
            return;
        }

        try {
            DiskFileItemFactory factory = new DiskFileItemFactory();
            ServletFileUpload upload = new ServletFileUpload(factory);
            upload.setSizeMax(2 * 1024 * 1024);

            List<FileItem> items = upload.parseRequest(req);
            for (FileItem item : items) {
                if (!item.isFormField() && item.getSize() > 0) {
                    String fileName = item.getName();
                    String ext = fileName.substring(fileName.lastIndexOf(".")).toLowerCase();
                    if (!ext.equals(".jpg") && !ext.equals(".jpeg") && !ext.equals(".png") && !ext.equals(".gif")) {
                        session.setAttribute("adminError", "仅支持 JPG/PNG/GIF 格式");
                        resp.sendRedirect(req.getContextPath() + "/admin/banners?tab=banners");
                        return;
                    }
                    String uploadDir = getServletContext().getRealPath("/") + "uploads";
                    File dir = new File(uploadDir);
                    if (!dir.exists()) dir.mkdirs();
                    String savedName = "qr_wechat_" + UUID.randomUUID().toString().substring(0, 8) + ext;
                    File savedFile = new File(dir, savedName);
                    item.write(savedFile);

                    // 删除旧二维码文件
                    ServletContext ctx = getServletContext();
                    String oldQr = (String) ctx.getAttribute("wechatQrPath");
                    if (oldQr != null && !oldQr.isEmpty()) {
                        File oldFile = new File(dir, oldQr);
                        if (oldFile.exists()) oldFile.delete();
                    }
                    ctx.setAttribute("wechatQrPath", savedName);
                    session.setAttribute("adminSuccess", "微信二维码已更新");
                }
            }
        } catch (Exception e) {
            System.err.println("[CTRL] " + e.getMessage());
            session.setAttribute("adminError", "上传失败：" + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/admin/banners?tab=banners");
    }
}
