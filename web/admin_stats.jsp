<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!-- 权限校验：仅允许管理员访问数据统计页面 -->
<c:if test="${empty sessionScope.userId || sessionScope.userRole != '管理员'}">
    <jsp:forward page="/login.jsp"/>
</c:if>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>数据统计 - 管理后台</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root {
            --primary-color: #e74c3c;
            --dark-color: #2c3e50;
        }

        body {
            font-family: "PingFang SC", "Microsoft YaHei", sans-serif;
            background: #f5f6fa;
        }

        .admin-header {
            background: var(--dark-color);
            color: white;
            padding: 15px 0;
        }

        .admin-container {
            max-width: 1400px;
            margin: 30px auto;
            padding: 0 15px;
        }

        .stat-card {
            background: white;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            margin-bottom: 20px;
        }

        .stat-number {
            font-size: 36px;
            font-weight: bold;
            color: #333;
        }

        .stat-label {
            color: #666;
            font-size: 14px;
            margin-top: 10px;
        }

        .content-card {
            background: white;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            margin-top: 30px;
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

        .progress-bar-custom {
            height: 25px;
            line-height: 25px;
            text-align: center;
            color: white;
            font-size: 12px;
            border-radius: 5px;
        }
    </style>
</head>
<body>

<nav class="admin-header">
    <div class="container d-flex justify-content-between align-items-center">
        <h4 class="mb-0"><i class="bi bi-shield-lock me-2"></i>花店商城管理后台</h4>
        <div>
            <span class="me-3">管理员：${sessionScope.username}</span>
            <a href="${pageContext.request.contextPath}/admin/index" class="btn btn-sm btn-light">返回首页</a>
        </div>
    </div>
</nav>

<div class="admin-container">
    <!-- 核心数据概览卡片：展示用户、订单、销售额及商品总量 -->
    <div class="row">
        <div class="col-md-3">
            <div class="stat-card text-center">
                <div class="stat-number text-primary">${stats.totalUsers}</div>
                <div class="stat-label">总用户数</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card text-center">
                <div class="stat-number text-success">${stats.totalOrders}</div>
                <div class="stat-label">总订单数</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card text-center">
                <div class="stat-number text-warning">¥<fmt:formatNumber value="${stats.totalSales}" pattern="#0.00"/></div>
                <div class="stat-label">总销售额</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card text-center">
                <div class="stat-number text-info">${stats.totalProducts}</div>
                <div class="stat-label">总商品数</div>
            </div>
        </div>
    </div>

    <!-- 订单状态分布图：使用进度条直观展示各状态订单占比 -->
    <div class="content-card">
        <div class="card-header">
            <h5 class="card-title"><i class="bi bi-pie-chart me-2"></i>订单状态分布</h5>
        </div>
        <div class="card-body">
            <c:forEach items="${stats.orderStatusStats}" var="statusEntry">
                <div class="mb-3">
                    <div class="d-flex justify-content-between mb-1">
                        <span>${statusEntry.key}</span>
                        <span>${statusEntry.value} 单</span>
                    </div>
                    <div class="progress">
                        <c:set var="percentage" value="${statusEntry.value * 100 / stats.totalOrders}" />
                        <div class="progress-bar progress-bar-custom 
                            <c:choose>
                                <c:when test='${statusEntry.key == "待付款"}'>bg-warning</c:when>
                                <c:when test='${statusEntry.key == "已付款"}'>bg-info</c:when>
                                <c:when test='${statusEntry.key == "已发货"}'>bg-primary</c:when>
                                <c:when test='${statusEntry.key == "已完成"}'>bg-success</c:when>
                                <c:otherwise>bg-secondary</c:otherwise>
                            </c:choose>"
                             style="width: ${percentage}%">
                            <fmt:formatNumber value="${percentage}" pattern="#0.0"/>%
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>

    <!-- 热销商品排行榜：展示销量前 10 的商品及其销售数据 -->
    <div class="content-card">
        <div class="card-header">
            <h5 class="card-title"><i class="bi bi-trophy me-2"></i>热销商品 TOP 10</h5>
        </div>
        <div class="card-body">
            <table class="table table-hover">
                <thead>
                <tr>
                    <th>排名</th>
                    <th>商品名称</th>
                    <th>价格</th>
                    <th>销量</th>
                    <th>销售额</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${stats.topProducts}" var="product" varStatus="status">
                    <tr>
                        <td>
                            <!-- 根据排名索引显示不同的奖牌图标 -->
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
                        <td>${product.name}</td>
                        <td>¥<fmt:formatNumber value="${product.price}" pattern="#0.00"/></td>
                        <td>${product.sales}</td>
                        <td>¥<fmt:formatNumber value="${product.price * product.sales}" pattern="#0.00"/></td>
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
