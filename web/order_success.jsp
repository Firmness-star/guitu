<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!-- 从会话中获取当前订单对象，若不存在则重定向至首页 -->
<c:set var="order" value="${sessionScope.currentOrder}"/>

<c:if test="${empty order}">
    <jsp:forward page="index.jsp"/>
</c:if>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>订单提交成功 - 花店商城</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="css/common.css">
    <style>
        body { background: var(--bg-gray); display: flex; align-items: center; justify-content: center; min-height: calc(100vh - 70px); }

        .success-container { background: white; border-radius: 16px; padding: 60px 40px;
            text-align: center; max-width: 600px; width: 90%; box-shadow: 0 4px 20px rgba(0,0,0,0.1); }

        .success-icon { font-size: 80px; color: var(--primary-green); margin-bottom: 20px; }
        .success-title { font-size: 28px; font-weight: bold; color: #333; margin-bottom: 10px; }
        .success-text { color: #666; margin-bottom: 30px; }

        .order-info { background: #f8f9fa; border-radius: 12px; padding: 20px;
            margin: 30px 0; text-align: left; }
        .order-info-row { display: flex; justify-content: space-between; margin-bottom: 10px; }
        .order-info-row:last-child { margin-bottom: 0; }
        .order-label { color: #666; }
        .order-value { font-weight: 500; color: #333; }
        .order-id { color: var(--primary-red); font-weight: bold; }
        .order-amount { color: var(--primary-red); font-size: 20px; font-weight: bold; }

        .btn-group { display: flex; gap: 15px; margin-top: 30px; }
        .btn { flex: 1; padding: 12px; border-radius: 8px; text-decoration: none;
            font-weight: 500; transition: all 0.3s; }
        .btn-primary { background: var(--primary-red); color: white; border: none; }
        .btn-primary:hover { background: var(--dark-red); color: white; }
        .btn-secondary { background: white; color: #333; border: 1px solid #ddd; }
        .btn-secondary:hover { background: #f5f5f5; }
    </style>
</head>
<body>

<jsp:include page="common/navbar.jsp"/>

<div class="success-container">
    <div class="success-icon">
        <i class="bi bi-check-circle-fill"></i>
    </div>

    <h1 class="success-title">订单提交成功！</h1>
    <p class="success-text">感谢您的购买，我们将尽快为您安排发货</p>

    <!-- 展示订单核心信息：编号、状态、收货信息及应付金额 -->
    <div class="order-info">
        <div class="order-info-row">
            <span class="order-label">订单编号</span>
            <span class="order-value order-id">${order.orderId}</span>
        </div>
        <div class="order-info-row">
            <span class="order-label">订单状态</span>
            <span class="order-value" style="color: var(--primary-green);">${order.status}</span>
        </div>
        <div class="order-info-row">
            <span class="order-label">收货人</span>
            <span class="order-value">${order.receiverName} ${order.receiverPhone}</span>
        </div>
        <div class="order-info-row">
            <span class="order-label">收货地址</span>
            <span class="order-value">${order.receiverAddress}</span>
        </div>
        <div class="order-info-row" style="margin-top: 15px; padding-top: 15px; border-top: 1px solid #e0e0e0;">
            <span class="order-label">应付金额</span>
            <span class="order-amount">¥<fmt:formatNumber value="${order.totalAmount}" pattern="#0.00"/></span>
        </div>
    </div>

    <div class="btn-group">
        <a href="products" class="btn btn-secondary">
            <i class="bi bi-shop"></i> 继续购物
        </a>
        <a href="payment?orderId=${order.orderId}" class="btn btn-primary">
            <i class="bi bi-credit-card"></i> 立即支付
        </a>
    </div>
</div>

</body>
</html>
