package com.flower.controller.api;

import com.flower.dao.MessageDao;
import com.flower.entity.Message;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.*;

@WebServlet("/api/message")
public class MessageApi extends ApiBaseServlet {

    private MessageDao messageDao = new MessageDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer uid = getUserId(req);
        if (uid == null) { unauth(resp); return; }

        messageDao.markUserRead(uid);
        List<Message> msgs = messageDao.findByUserId(uid);

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
        List<Map<String, Object>> result = new ArrayList<>();
        for (Message m : msgs) {
            Map<String, Object> item = new HashMap<>();
            item.put("id", m.getId());
            item.put("userId", m.getUserId());
            item.put("username", m.getUsername());
            item.put("content", m.getContent());
            item.put("conversation", m.getConversation());
            item.put("unreadAdminReplies", m.getUnreadAdminReplies());
            item.put("createTime", sdf.format(m.getCreateTime()));

            // parse conversation into structured replies
            String conv = m.getConversation();
            if (conv != null && !conv.trim().isEmpty()) {
                List<Map<String, String>> replies = new ArrayList<>();
                String[] lines = conv.split("\n");
                for (String line : lines) {
                    line = line.trim();
                    if (line.isEmpty()) continue;
                    if (line.startsWith("[管理员]")) {
                        Map<String, String> r = new HashMap<>();
                        r.put("role", "admin");
                        r.put("text", line.substring(5));
                        replies.add(r);
                    } else if (line.startsWith("[用户]")) {
                        Map<String, String> r = new HashMap<>();
                        r.put("role", "user");
                        r.put("text", line.substring(4));
                        replies.add(r);
                    }
                }
                item.put("replies", replies);
            }
            result.add(item);
        }
        ok(resp, result);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        Integer uid = getUserId(req);
        String username = getUsername(req);
        if (uid == null || username == null) { unauth(resp); return; }

        String action = req.getParameter("action");
        if ("reply".equals(action)) {
            int msgId;
            try { msgId = Integer.parseInt(req.getParameter("msgId")); }
            catch (NumberFormatException e) { fail(resp, 400, "参数错误"); return; }

            String reply = req.getParameter("content");
            if (reply == null || reply.trim().isEmpty()) { fail(resp, 400, "回复内容不能为空"); return; }

            if (messageDao.userReply(msgId, reply.trim())) {
                ok(resp, "回复成功", null);
            } else {
                fail(resp, 500, "回复失败");
            }
            return;
        }

        // new message
        String content = req.getParameter("content");
        if (content == null || content.trim().isEmpty()) { fail(resp, 400, "留言内容不能为空"); return; }

        Message msg = new Message();
        msg.setUserId(uid);
        msg.setUsername(username);
        msg.setContent(content.trim());

        if (messageDao.save(msg)) {
            ok(resp, "留言发送成功", null);
        } else {
            fail(resp, 500, "发送失败");
        }
    }
}
