package com.flower.controller.api;

import com.flower.util.JsonUtil;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

public abstract class ApiBaseServlet extends HttpServlet {

    protected void ok(HttpServletResponse resp, Object data) throws IOException {
        writeJson(resp, 200, "成功", data);
    }

    protected void ok(HttpServletResponse resp, String message, Object data) throws IOException {
        writeJson(resp, 200, message, data);
    }

    protected void fail(HttpServletResponse resp, int code, String message) throws IOException {
        writeJson(resp, code, message, null);
    }

    protected void unauth(HttpServletResponse resp) throws IOException {
        writeJson(resp, 401, "请先登录", null);
    }

    private void writeJson(HttpServletResponse resp, int code, String message, Object data) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        Map<String, Object> result = new HashMap<>();
        result.put("code", code);
        result.put("message", message);
        result.put("data", data);
        PrintWriter out = resp.getWriter();
        out.print(JsonUtil.toJson(result));
        out.flush();
    }

    protected Integer getUserId(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        return (Integer) session.getAttribute("userId");
    }

    protected String getUsername(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        return (String) session.getAttribute("username");
    }

    protected boolean isLoggedIn(HttpServletRequest req) {
        return getUserId(req) != null;
    }
}
