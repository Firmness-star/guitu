<!--
/**
 * 500 服务器内部错误提示页面
 * 当服务器端发生未捕获异常时展示，显示错误详情并提供返回首页入口
 */
-->
<!-- C:\Users\guitu\OneDrive\Desktop\guitushop\web\error\500.jsp -->
<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>服务器错误 - 花店系统</title>
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
        .error-code {
            font-size: 8rem;
            font-weight: bold;
            color: #ffc107;
            margin-bottom: 0;
        }
        .error-message {
            font-size: 1.5rem;
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
    <h1 class="error-code">500</h1>
    <p class="error-message">服务器内部错误</p>
    <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-primary btn-lg">返回首页</a>

    <!-- 显示具体的异常信息，便于调试和排查问题 -->
    <div class="error-detail mt-4">
        <h5>错误信息：</h5>
        <pre>${exception.message}</pre>
    </div>
</div>
</body>
</html>
