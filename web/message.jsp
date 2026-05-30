<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:if test="${empty sessionScope.username}">
    <jsp:forward page="login.jsp"/>
</c:if>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的留言 - 花店商城</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <style>
        :root { --primary-red: #e74c3c; --dark-red: #c0392b; --bg-gray: #f5f5f5; }
        body { font-family: "PingFang SC","Microsoft YaHei",sans-serif; background:var(--bg-gray); }
        .top-navbar { background:white; border-bottom:1px solid #e0e0e0; padding:15px 0; position:sticky; top:0; z-index:100; }
        .brand-logo { font-size:20px; font-weight:700; text-decoration:none; cursor:pointer;
            background:linear-gradient(135deg,var(--primary-red) 0%,#ff6b6b 100%); -webkit-background-clip:text; -webkit-text-fill-color:transparent; }
        .msg-container { max-width:800px; margin:30px auto; padding:0 15px; }
        .msg-card { background:white; border-radius:12px; box-shadow:0 2px 8px rgba(0,0,0,0.05); padding:24px; margin-bottom:20px; }
        .msg-item { padding:16px 0; border-bottom:1px solid #f0f0f0; }
        .msg-item:last-child { border-bottom:none; }
        .msg-time { font-size:12px; color:#999; }
    </style>
</head>
<body>
<nav class="top-navbar">
    <div class="container d-flex justify-content-between align-items-center">
        <a href="index.jsp" class="brand-logo">归途</a>
        <div>
            <span class="text-muted me-3">欢迎，${sessionScope.username}</span>
            <a href="usercenter" class="btn btn-outline-danger btn-sm">返回个人中心</a>
        </div>
    </div>
</nav>

<div class="msg-container">
    <h4 class="mb-4"><i class="bi bi-chat-dots"></i> 我的留言</h4>

    <c:if test="${not empty sessionScope.msgSuccess}">
        <div class="alert alert-success">${sessionScope.msgSuccess}</div>
        <c:remove var="msgSuccess" scope="session"/>
    </c:if>
    <c:if test="${not empty sessionScope.msgError}">
        <div class="alert alert-danger">${sessionScope.msgError}</div>
        <c:remove var="msgError" scope="session"/>
    </c:if>

    <div class="msg-card">
        <form action="message" method="post">
            <div class="mb-3">
                <label class="form-label fw-bold">发送留言给管理员</label>
                <textarea name="content" class="form-control" rows="3" placeholder="请在此输入您对商城的意见或建议..." required></textarea>
            </div>
            <button type="submit" class="btn btn-danger"><i class="bi bi-send"></i> 发送留言</button>
        </form>
    </div>

    <div class="msg-card">
        <h5 class="mb-3">留言记录</h5>
        <c:choose>
            <c:when test="${not empty myMessages}">
                <c:forEach items="${myMessages}" var="msg">
                    <div class="msg-item">
                        <div class="d-flex justify-content-between mb-1">
                            <span class="text-muted small">${msg.username}</span>
                            <span class="msg-time"><fmt:formatDate value="${msg.createTime}" pattern="yyyy-MM-dd HH:mm"/></span>
                        </div>
                        <div style="font-size:14px;color:#333;">${msg.content}</div>
                        <c:if test="${not empty msg.conversation}">
                            <c:set var="nl" value="
"/>
                            <c:set var="lines" value="${fn:split(msg.conversation, nl)}"/>
                            <div style="margin-top:8px;padding:10px 14px;background:#f8f9fa;border-radius:6px;">
                                <c:forEach items="${lines}" var="line">
                                    <c:if test="${not empty line}">
                                        <c:choose>
                                            <c:when test="${fn:startsWith(line, '[管理员]')}">
                                                <div style="padding:6px 0;color:#155724;font-size:13px;">
                                                    <span style="font-weight:600;color:#27ae60;">管理员：</span>${fn:substringAfter(line, '[管理员]')}
                                                </div>
                                            </c:when>
                                            <c:when test="${fn:startsWith(line, '[用户]')}">
                                                <div style="padding:6px 0;color:#856404;font-size:13px;">
                                                    <span style="font-weight:600;color:#e67e22;">我说：</span>${fn:substringAfter(line, '[用户]')}
                                                </div>
                                            </c:when>
                                        </c:choose>
                                    </c:if>
                                </c:forEach>
                            </div>
                            <!-- 用户可再次回复 -->
                            <form action="message" method="post" style="margin-top:8px;" onsubmit="return this.userReply.value.trim()!==''">
                                <input type="hidden" name="action" value="reply">
                                <input type="hidden" name="msgId" value="${msg.id}">
                                <div style="display:flex;gap:8px;">
                                    <input type="text" name="userReply" placeholder="继续回复..." style="flex:1;border:1px solid #ddd;border-radius:6px;padding:6px 10px;font-size:13px;">
                                    <button type="submit" style="background:#f39c12;color:white;border:none;border-radius:6px;padding:6px 14px;font-size:13px;cursor:pointer;">发送</button>
                                </div>
                            </form>
                        </c:if>
                        <c:if test="${empty msg.conversation}">
                            <form action="message" method="post" style="margin-top:8px;" onsubmit="return this.userReply.value.trim()!==''">
                                <input type="hidden" name="action" value="reply">
                                <input type="hidden" name="msgId" value="${msg.id}">
                                <div style="display:flex;gap:8px;">
                                    <input type="text" name="userReply" placeholder="补充留言..." style="flex:1;border:1px solid #ddd;border-radius:6px;padding:6px 10px;font-size:13px;">
                                    <button type="submit" style="background:#f39c12;color:white;border:none;border-radius:6px;padding:6px 14px;font-size:13px;cursor:pointer;">发送</button>
                                </div>
                            </form>
                        </c:if>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="text-center py-4 text-muted">暂无留言记录</div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
