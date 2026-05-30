<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!-- 权限校验：仅允许商家用户访问客户管理页面 -->
<c:if test="${empty sessionScope.userId || sessionScope.userRole != '商家'}">
    <jsp:forward page="/login.jsp"/>
</c:if>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>客户管理 - 商家后台</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root {
            --primary-color: #27ae60;
            --dark-color: #2c3e50;
        }

        body {
            font-family: "PingFang SC", "Microsoft YaHei", sans-serif;
            background: #f5f6fa;
        }

        .merchant-header {
            background: var(--dark-color);
            color: white;
            padding: 15px 0;
        }

        .merchant-container {
            max-width: 1400px;
            margin: 30px auto;
            padding: 0 15px;
        }

        .content-card {
            background: white;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            overflow: hidden;
        }

        .card-header {
            padding: 20px;
            border-bottom: 1px solid #eee;
        }

        .card-title {
            font-size: 18px;
            font-weight: 600;
            margin: 0;
        }

        .card-body {
            padding: 20px;
        }

        .table th {
            background: #f8f9fa;
        }
    </style>
</head>
<body>

<nav class="merchant-header">
    <div class="container d-flex justify-content-between align-items-center">
        <h4 class="mb-0"><i class="bi bi-shop me-2"></i>花店商城商家后台</h4>
        <div>
            <span class="me-3">商家：${sessionScope.username}</span>
            <a href="${pageContext.request.contextPath}/merchant/index" class="btn btn-sm btn-light">返回首页</a>
        </div>
    </div>
</nav>

<div class="merchant-container">
    <!-- Tab 导航栏：当前高亮显示“客户管理”模块 -->
    <ul class="nav nav-tabs mb-4">
        <li class="nav-item">
            <a class="nav-link" href="${pageContext.request.contextPath}/merchant/index?tab=index">
                <i class="bi bi-speedometer2"></i> 首页概览
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link" href="${pageContext.request.contextPath}/merchant/products?tab=products">
                <i class="bi bi-box-seam"></i> 商品管理
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link" href="${pageContext.request.contextPath}/merchant/orders?tab=orders">
                <i class="bi bi-receipt"></i> 订单管理
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link active" href="${pageContext.request.contextPath}/merchant/customers">
                <i class="bi bi-people"></i> 客户管理
            </a>
        </li>
    </ul>

    <div class="content-card">
        <div class="card-header">
            <h5 class="card-title"><i class="bi bi-people me-2"></i>客户列表</h5>
        </div>
        <div class="card-body">
            <table class="table table-hover">
                <thead>
                <tr>
                    <th>排名</th>
                    <th>用户名</th>
                    <th>订单数</th>
                    <th>消费总额</th>
                    <th>最近下单时间</th>
                    <th>客户等级</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${customers}" var="customer" varStatus="status">
                    <tr>
                        <td>
                            <!-- 根据客户消费排名展示不同的奖牌图标 -->
                            <c:choose>
                                <c:when test="${status.index == 0}">
                                    <span class="badge bg-danger">🥇 第1名</span>
                                </c:when>
                                <c:when test="${status.index == 1}">
                                    <span class="badge bg-warning">🥈 第2名</span>
                                </c:when>
                                <c:when test="${status.index == 2}">
                                    <span class="badge bg-info">🥉 第3名</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-secondary">第${status.index + 1}名</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>${customer.username}</td>
                        <td>${customer.orderCount} 单</td>
                        <td>¥<fmt:formatNumber value="${customer.totalAmount}" pattern="#0.00"/></td>
                        <td>
                            <c:if test="${not empty customer.lastOrderTime}">
                                <fmt:formatDate value="${customer.lastOrderTime}" pattern="yyyy-MM-dd HH:mm"/>
                            </c:if>
                        </td>
                        <td>
                            <!-- 根据客户累计消费金额自动划分会员等级 -->
                            <c:choose>
                                <c:when test="${customer.totalAmount >= 1000}">
                                    <span class="badge bg-danger">VIP客户</span>
                                </c:when>
                                <c:when test="${customer.totalAmount >= 500}">
                                    <span class="badge bg-warning">黄金客户</span>
                                </c:when>
                                <c:when test="${customer.totalAmount >= 100}">
                                    <span class="badge bg-info">白银客户</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-secondary">普通客户</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
