<%-- C:\Users\guitu\OneDrive\Desktop\guitushop\web\payment_success.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>支付成功 - 花店商城</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="css/common.css">
    <style>
        body {
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .success-container {
            max-width: 600px;
            width: 100%;
            padding: 20px;
        }

        .success-card {
            background: white;
            border-radius: 12px;
            padding: 50px 30px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            text-align: center;
        }

        .success-icon {
            width: 100px;
            height: 100px;
            background: var(--primary-green);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 30px;
            animation: scaleIn 0.5s ease;
        }

        @keyframes scaleIn {
            0% { transform: scale(0); }
            50% { transform: scale(1.2); }
            100% { transform: scale(1); }
        }

        .success-icon i {
            font-size: 60px;
            color: white;
        }

        .success-title {
            font-size: 28px;
            font-weight: 600;
            color: #333;
            margin-bottom: 15px;
        }

        .success-message {
            font-size: 16px;
            color: #666;
            margin-bottom: 30px;
        }

        .order-info {
            background: #f8f9fa;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 30px;
            text-align: left;
        }

        .order-info-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
            color: #666;
        }

        .order-info-row:last-child {
            margin-bottom: 0;
        }

        .btn-group-custom {
            display: flex;
            gap: 15px;
            justify-content: center;
        }

        .btn-continue {
            background: var(--primary-red);
            color: white;
            border: none;
            padding: 12px 30px;
            border-radius: 8px;
            font-size: 16px;
            text-decoration: none;
            transition: all 0.3s;
        }

        .btn-continue:hover {
            background: var(--dark-red);
            color: white;
            transform: translateY(-2px);
        }

        .btn-view-order {
            background: white;
            color: var(--primary-red);
            border: 2px solid var(--primary-red);
            padding: 12px 30px;
            border-radius: 8px;
            font-size: 16px;
            text-decoration: none;
            transition: all 0.3s;
        }

        .btn-view-order:hover {
            background: #fff5f5;
            transform: translateY(-2px);
        }
    </style>
</head>
<body>

<jsp:include page="common/navbar.jsp"/>

<div class="success-container">
    <div class="success-card">
        <div class="success-icon">
            <i class="bi bi-check-lg"></i>
        </div>

        <h2 class="success-title">支付成功！</h2>
        <p class="success-message">您的订单已支付成功，我们将尽快为您处理</p>

        <!-- 展示支付详情：包括订单号、金额、支付方式及时间 -->
        <div class="order-info">
            <div class="order-info-row">
                <span>订单号：</span>
                <span class="fw-bold">${orderId}</span>
            </div>
            <div class="order-info-row">
                <span>支付金额：</span>
                <span class="text-danger fw-bold">¥${amount}</span>
            </div>
            <div class="order-info-row">
                <span>支付方式：</span>
                <span>${payMethod}</span>
            </div>
            <div class="order-info-row">
                <span>支付时间：</span>
                <span><fmt:formatDate value="${payTime}" pattern="yyyy-MM-dd HH:mm:ss"/></span>
            </div>
        </div>

        <div class="btn-group-custom">
            <a href="orders" class="btn-view-order">
                <i class="bi bi-receipt"></i> 查看订单
            </a>
            <a href="index" class="btn-continue">
                <i class="bi bi-shop"></i> 继续购物
            </a>
        </div>
    </div>
</div>

</body>
</html>
