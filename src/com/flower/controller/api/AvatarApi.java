package com.flower.controller.api;

import com.flower.dao.UserDao;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.util.*;

@WebServlet("/api/avatar")
public class AvatarApi extends ApiBaseServlet {

    private UserDao userDao = new UserDao();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        Integer userId = getUserId(req);
        if (userId == null) { unauth(resp); return; }

        if (!ServletFileUpload.isMultipartContent(req)) {
            fail(resp, 400, "请选择要上传的头像文件");
            return;
        }

        try {
            DiskFileItemFactory factory = new DiskFileItemFactory();
            ServletFileUpload upload = new ServletFileUpload(factory);
            upload.setSizeMax(2 * 1024 * 1024); // 2MB

            List<FileItem> items = upload.parseRequest(req);
            for (FileItem item : items) {
                if (!item.isFormField() && item.getSize() > 0) {
                    String fileName = item.getName();
                    String ext = fileName.substring(fileName.lastIndexOf(".")).toLowerCase();
                    if (!ext.equals(".jpg") && !ext.equals(".jpeg") && !ext.equals(".png") && !ext.equals(".gif")) {
                        fail(resp, 400, "仅支持 JPG、PNG、GIF 格式的图片");
                        return;
                    }

                    String uploadDir = getServletContext().getRealPath("/") + "uploads";
                    File dir = new File(uploadDir);
                    if (!dir.exists()) dir.mkdirs();

                    String savedName = UUID.randomUUID().toString() + ext;
                    File savedFile = new File(dir, savedName);
                    item.write(savedFile);

                    String avatarPath = "uploads/" + savedName;
                    userDao.updateAvatar(userId, avatarPath);

                    Map<String, Object> data = new HashMap<>();
                    data.put("avatar", avatarPath);
                    ok(resp, "头像上传成功", data);
                    return;
                }
            }
            fail(resp, 400, "未选择文件");
        } catch (Exception e) {
            System.err.println("[AvatarApi] " + e.getMessage());
            fail(resp, 500, "头像上传失败");
        }
    }
}
