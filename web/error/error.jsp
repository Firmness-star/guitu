<!--
/**
 * 通用系统错误提示页面
 * 用于捕获并展示未预期的系统异常信息，包含异常类型和详细消息
 */
-->
<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>系统错误 - 花店系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .error-container {
            text-align: center;
            padding: 2rem;
            max-width: 600px;
        }
        .error-icon {
            font-size: 6rem;
            color: #dc3545;
            margin-bottom: 1rem;
        }
        .error-title {
            font-size: 2rem;
            color: #343a40;
            margin-bottom: 1rem;
        }
        .error-message {
            font-size: 1.2rem;
            color: #6c757d;
            margin-bottom: 2rem;
        }
        .error-detail {
            background-color: #fff;
            border-radius: 8px;
            padding: 1rem;
            margin-top: 1rem;
            text-align: left;
        }
    </style>
</head>
<body>
<div class="error-container">
    <div class="error-icon">⚠️</div>
    <h2 class="error-title">系统发生错误</h2>
    <p class="error-message">很抱歉，系统遇到了一个意外问题</p>
    <a href="${pageContext.request.contextPath}/index" class="btn btn-primary btn-lg">返回首页</a>

    <!-- 展示具体的异常类型和错误消息，辅助定位问题 -->
    <div class="error-detail mt-4">
        <h5>异常类型：</h5>
        <p><%= exception.getClass().getName() %></p>

        <h5>错误信息：</h5>
        <p><%= exception.getMessage() %></p>
    </div>
</div>
</body>
</html>
