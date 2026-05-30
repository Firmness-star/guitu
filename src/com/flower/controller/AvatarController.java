package com.flower.controller;

import com.flower.dao.UserDao;
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

@WebServlet("/avatar")
public class AvatarController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        // 检查是否是 multipart 请求（文件上传）
        if (!ServletFileUpload.isMultipartContent(req)) {
            session.setAttribute("updateError", "请选择要上传的头像文件");
            resp.sendRedirect("usercenter");
            return;
        }

        try {
            DiskFileItemFactory factory = new DiskFileItemFactory();
            ServletFileUpload upload = new ServletFileUpload(factory);
            upload.setSizeMax(2 * 1024 * 1024); // 2MB 限制

            List<FileItem> items = upload.parseRequest(req);
            for (FileItem item : items) {
                if (!item.isFormField() && item.getSize() > 0) {
                    String fileName = item.getName();
                    String ext = fileName.substring(fileName.lastIndexOf(".")).toLowerCase();
                    if (!ext.equals(".jpg") && !ext.equals(".jpeg") && !ext.equals(".png") && !ext.equals(".gif")) {
                        session.setAttribute("updateError", "仅支持 JPG、PNG、GIF 格式的图片");
                        resp.sendRedirect("usercenter");
                        return;
                    }

                    // 保存到 uploads 目录
                    String uploadDir = getServletContext().getRealPath("/") + "uploads";
                    File dir = new File(uploadDir);
                    if (!dir.exists()) dir.mkdirs();

                    String savedName = UUID.randomUUID().toString() + ext;
                    File savedFile = new File(dir, savedName);
                    item.write(savedFile);

                    // 更新数据库
                    UserDao userDao = new UserDao();
                    String avatarPath = "uploads/" + savedName;
                    userDao.updateAvatar(userId, avatarPath);

                    // 更新 session 中的头像信息（用于即时显示）
                    session.setAttribute("userAvatar", avatarPath);
                    session.setAttribute("updateSuccess", "头像上传成功");
                    break;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("updateError", "头像上传失败：" + e.getMessage());
        }

        resp.sendRedirect("usercenter");
    }
}
