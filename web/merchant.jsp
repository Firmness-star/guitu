<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!-- 权限校验：非商家或未登录用户重定向至登录页 -->
<c:if test="${empty sessionScope.userId || sessionScope.userRole != '商家'}">
    <jsp:forward page="/login.jsp"/>
</c:if>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>商家后台 - 花店商城</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root {
            --primary-color: #27ae60;
            --dark-color: #2c3e50;
            --light-color: #ecf0f1;
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

        .stat-card {
            background: white;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            transition: transform 0.2s;
        }

        .stat-card:hover {
            transform: translateY(-4px);
        }

        .stat-icon {
            font-size: 40px;
            margin-bottom: 15px;
        }

        .stat-card.blue .stat-icon { color: #3498db; }
        .stat-card.green .stat-icon { color: #27ae60; }
        .stat-card.orange .stat-icon { color: #f39c12; }
        .stat-card.red .stat-icon { color: #e74c3c; }
        .stat-card.purple .stat-icon { color: #9b59b6; }
        .stat-card.yellow .stat-icon { color: #f1c40f; }

        .stat-number {
            font-size: 32px;
            font-weight: bold;
            color: #333;
            margin-bottom: 5px;
        }

        .stat-label {
            color: #666;
            font-size: 14px;
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
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .card-title {
            font-size: 18px;
            font-weight: 600;
            margin: 0;
        }

        .card-body {
            padding: 20px;
        }

        .table {
            margin-bottom: 0;
        }

        .table th {
            background: #f8f9fa;
            border-bottom: 2px solid #dee2e6;
        }

        .badge-status {
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 12px;
        }

        .badge-active {
            background: #d4edda;
            color: #155724;
        }

        .badge-disabled {
            background: #f8d7da;
            color: #721c24;
        }

        .badge-warning {
            background: #fff3cd;
            color: #856404;
        }

        .badge-info {
            background: #d1ecf1;
            color: #0c5460;
        }

        .product-img {
            width: 60px;
            height: 60px;
            object-fit: cover;
            border-radius: 8px;
        }

        .filter-bar {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>

<nav class="merchant-header">
    <div class="container d-flex justify-content-between align-items-center">
        <h4 class="mb-0"><i class="bi bi-shop me-2"></i>花店商城商家后台</h4>
        <div>
            <span class="me-3">商家：${sessionScope.username}</span>
            <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-sm btn-light me-2">返回首页</a>
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-sm btn-danger">退出登录</a>
        </div>
    </div>
</nav>

<div class="merchant-container">
    <!-- Tab 导航栏：根据当前 tab 参数高亮显示对应模块 -->
    <ul class="nav nav-tabs mb-4">
        <li class="nav-item">
            <a class="nav-link ${empty param.tab ? 'active' : ''}" href="${pageContext.request.contextPath}/merchant/index?tab=index">
                <i class="bi bi-speedometer2"></i> 首页概览
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${param.tab == 'products' ? 'active' : ''}" href="${pageContext.request.contextPath}/merchant/products?tab=products">
                <i class="bi bi-box-seam"></i> 商品管理
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${param.tab == 'orders' ? 'active' : ''}" href="${pageContext.request.contextPath}/merchant/orders?tab=orders">
                <i class="bi bi-receipt"></i> 订单管理
            </a>
        </li>
    </ul>

    <!-- 首页概览模块：展示经营统计数据、热销商品及最近订单 -->
    <c:if test="${empty param.tab || param.tab == 'index'}">
        <div class="row">
            <div class="col-md-2">
                <div class="stat-card blue">
                    <div class="stat-icon"><i class="bi bi-box-seam"></i></div>
                    <div class="stat-number">${totalProducts}</div>
                    <div class="stat-label">总商品数</div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="stat-card green">
                    <div class="stat-icon"><i class="bi bi-bag-check"></i></div>
                    <div class="stat-number">${totalOrders}</div>
                    <div class="stat-label">总订单数</div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="stat-card orange">
                    <div class="stat-icon"><i class="bi bi-currency-yuan"></i></div>
                    <div class="stat-number">¥<fmt:formatNumber value="${totalSales}" pattern="#0.00"/></div>
                    <div class="stat-label">总销售额</div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="stat-card yellow">
                    <div class="stat-icon"><i class="bi bi-clock-history"></i></div>
                    <div class="stat-number">${pendingOrders}</div>
                    <div class="stat-label">待处理订单</div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="stat-card red">
                    <div class="stat-icon"><i class="bi bi-exclamation-triangle"></i></div>
                    <div class="stat-number">${lowStockProducts}</div>
                    <div class="stat-label">库存预警</div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="stat-card purple">
                    <div class="stat-icon"><i class="bi bi-graph-up"></i></div>
                    <div class="stat-number">${totalOrders > 0 ? String.format("%.0f", totalSales / totalOrders) : 0}</div>
                    <div class="stat-label">平均客单价</div>
                </div>
            </div>
        </div>

        <div class="content-card">
            <div class="card-header">
                <h5 class="card-title"><i class="bi bi-fire me-2"></i>热销商品TOP 5</h5>
            </div>
            <div class="card-body">
                <table class="table">
                    <thead>
                    <tr>
                        <th>排名</th>
                        <th>商品图片</th>
                        <th>商品名称</th>
                        <th>价格</th>
                        <th>销量</th>
                        <th>库存</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach items="${topSellingProducts}" var="product" varStatus="status">
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
                            <td><img src="${product.pic}" alt="${product.name}" class="product-img"></td>
                            <td>${product.name}</td>
                            <td>¥<fmt:formatNumber value="${product.price}" pattern="#0.00"/></td>
                            <td>${product.sales}</td>
                            <td>
                                <c:if test="${product.stock < 20}">
                                    <span class="text-danger fw-bold">${product.stock}</span>
                                </c:if>
                                <c:if test="${product.stock >= 20}">
                                    ${product.stock}
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="content-card">
            <div class="card-header">
                <h5 class="card-title"><i class="bi bi-clock-history me-2"></i>最近订单</h5>
                <a href="${pageContext.request.contextPath}/merchant/orders?tab=orders" class="btn btn-sm btn-outline-primary">查看全部</a>
            </div>
            <div class="card-body">
                <table class="table">
                    <thead>
                    <tr>
                        <th>订单号</th>
                        <th>用户</th>
                        <th>金额</th>
                        <th>状态</th>
                        <th>时间</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach items="${recentOrders}" var="order">
                        <tr>
                            <td>${order.orderId}</td>
                            <td>${order.username}</td>
                            <td>¥<fmt:formatNumber value="${order.totalAmount}" pattern="#0.00"/></td>
                            <td>
                                <span class="badge-status ${order.status == '待付款' ? 'badge-warning' :
                                    order.status == '已付款' ? 'badge-info' :
                                    order.status == '已发货' ? 'badge-primary' :
                                    order.status == '已完成' ? 'badge-active' : 'badge-disabled'}">
                                        ${order.status}
                                </span>
                            </td>
                            <td><fmt:formatDate value="${order.createTime}" pattern="yyyy-MM-dd HH:mm"/></td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </c:if>

    <!-- 商品管理模块：支持搜索、筛选、上下架、删除及添加/编辑商品 -->
    <c:if test="${param.tab == 'products'}">
        <div class="content-card">
            <div class="card-header">
                <h5 class="card-title"><i class="bi bi-box-seam me-2"></i>商品管理</h5>
                <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addProductModal">
                    <i class="bi bi-plus"></i> 添加商品
                </button>
            </div>
            <div class="card-body">
                <div class="filter-bar">
                    <form method="get" action="${pageContext.request.contextPath}/merchant/products" class="row g-3">
                        <input type="hidden" name="tab" value="products">
                        <div class="col-md-3">
                            <input type="text" class="form-control" name="keyword" placeholder="搜索商品名称/描述" value="${keyword}">
                        </div>
                        <div class="col-md-2">
                            <select class="form-select" name="status">
                                <option value="">全部状态</option>
                                <option value="1" ${statusFilter == '1' ? 'selected' : ''}>上架</option>
                                <option value="0" ${statusFilter == '0' ? 'selected' : ''}>下架</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <button type="submit" class="btn btn-primary w-100">搜索</button>
                        </div>
                        <div class="col-md-2">
                            <a href="${pageContext.request.contextPath}/merchant/products?tab=products" class="btn btn-secondary w-100">重置</a>
                        </div>
                    </form>
                </div>

                <table class="table">
                    <thead>
                    <tr>
                        <th>ID</th>
                        <th>商品图片</th>
                        <th>商品名称</th>
                        <th>价格</th>
                        <th>库存</th>
                        <th>销量</th>
                        <th>状态</th>
                        <th>操作</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach items="${products}" var="product">
                        <tr>
                            <td>${product.id}</td>
                            <td><img src="${product.pic}" alt="${product.name}" class="product-img"></td>
                            <td>${product.name}</td>
                            <td>¥<fmt:formatNumber value="${product.price}" pattern="#0.00"/></td>
                            <td>
                                <c:if test="${product.stock < 20}">
                                    <span class="text-danger fw-bold">${product.stock} ⚠️</span>
                                </c:if>
                                <c:if test="${product.stock >= 20}">
                                    ${product.stock}
                                </c:if>
                            </td>
                            <td>${product.sales}</td>
                            <td>
                                <span class="badge-status ${product.status == 1 ? 'badge-active' : 'badge-disabled'}">
                                        ${product.status == 1 ? '上架' : '下架'}
                                </span>
                            </td>
                            <td>
                                <button class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#editModal${product.id}">编辑</button>
                                <c:if test="${product.status == 1}">
                                    <a href="${pageContext.request.contextPath}/merchant/products?action=disable&id=${product.id}" class="btn btn-sm btn-warning">下架</a>
                                </c:if>
                                <c:if test="${product.status == 0}">
                                    <a href="${pageContext.request.contextPath}/merchant/products?action=enable&id=${product.id}" class="btn btn-sm btn-success">上架</a>
                                </c:if>
                                <a href="${pageContext.request.contextPath}/merchant/products?action=delete&id=${product.id}" class="btn btn-sm btn-danger" onclick="return confirm('确认删除该商品？')">删除</a>

                                <!-- 编辑商品信息的模态框 -->
                                <div class="modal fade" id="editModal${product.id}" tabindex="-1">
                                    <div class="modal-dialog modal-lg">
                                        <div class="modal-content">
                                            <div class="modal-header">
                                                <h5 class="modal-title">编辑商品</h5>
                                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                            </div>
                                            <div class="modal-body">
                                                <form action="${pageContext.request.contextPath}/merchant/products" method="post">
                                                    <input type="hidden" name="action" value="update">
                                                    <input type="hidden" name="id" value="${product.id}">
                                                    <div class="mb-3">
                                                        <label class="form-label">商品名称</label>
                                                        <input type="text" class="form-control" name="name" value="${product.name}" required>
                                                    </div>
                                                    <div class="mb-3">
                                                        <label class="form-label">商品描述</label>
                                                        <textarea class="form-control" name="intro" rows="3" required>${product.intro}</textarea>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-6 mb-3">
                                                            <label class="form-label">价格</label>
                                                            <input type="number" class="form-control" name="price" step="0.01" value="${product.price}" required>
                                                        </div>
                                                        <div class="col-md-6 mb-3">
                                                            <label class="form-label">库存</label>
                                                            <input type="number" class="form-control" name="stock" value="${product.stock}" required>
                                                        </div>
                                                    </div>
                                                    <div class="mb-3">
                                                        <label class="form-label">商品图片URL</label>
                                                        <input type="text" class="form-control" name="pic" value="${product.pic}" required>
                                                    </div>
                                                    <div class="mb-3">
                                                        <label class="form-label">分类</label>
                                                        <select class="form-select" name="categoryId" required>
                                                            <c:forEach items="${categories}" var="cat">
                                                                <c:if test="${cat.parentId > 0}">
                                                                    <option value="${cat.id}" ${product.categoryId == cat.id ? 'selected' : ''}>
                                                                            ${cat.name}
                                                                    </option>
                                                                </c:if>
                                                            </c:forEach>
                                                        </select>
                                                    </div>
                                                    <button type="submit" class="btn btn-primary">保存修改</button>
                                                </form>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- 添加新商品的模态框 -->
        <div class="modal fade" id="addProductModal" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">添加商品</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <form action="${pageContext.request.contextPath}/merchant/products" method="post">
                            <input type="hidden" name="action" value="add">
                            <div class="mb-3">
                                <label class="form-label">商品名称</label>
                                <input type="text" class="form-control" name="name" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">商品描述</label>
                                <textarea class="form-control" name="intro" rows="3" required></textarea>
                            </div>
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">价格</label>
                                    <input type="number" class="form-control" name="price" step="0.01" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">库存</label>
                                    <input type="number" class="form-control" name="stock" required>
                                </div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">商品图片URL</label>
                                <input type="text" class="form-control" name="pic" placeholder="https://..." required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">分类</label>
                                <select class="form-select" name="categoryId" required>
                                    <option value="">请选择分类</option>
                                    <c:forEach items="${categories}" var="cat">
                                        <c:if test="${cat.parentId > 0}">
                                            <option value="${cat.id}">${cat.name}</option>
                                        </c:if>
                                    </c:forEach>
                                </select>
                            </div>
                            <button type="submit" class="btn btn-primary">添加商品</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </c:if>

    <!-- 订单管理模块：支持按状态和关键词筛选，提供发货/完成操作 -->
    <c:if test="${param.tab == 'orders'}">
        <div class="content-card">
            <div class="card-header">
                <h5 class="card-title"><i class="bi bi-receipt me-2"></i>订单管理</h5>
            </div>
            <div class="card-body">
                <div class="filter-bar">
                    <form method="get" action="${pageContext.request.contextPath}/merchant/orders" class="row g-3">
                        <input type="hidden" name="tab" value="orders">
                        <div class="col-md-3">
                            <input type="text" class="form-control" name="keyword" placeholder="搜索订单号/用户名/收货人" value="${keyword}">
                        </div>
                        <div class="col-md-2">
                            <select class="form-select" name="status">
                                <option value="">全部状态</option>
                                <option value="待付款" ${statusFilter == '待付款' ? 'selected' : ''}>待付款</option>
                                <option value="已付款" ${statusFilter == '已付款' ? 'selected' : ''}>已付款</option>
                                <option value="已发货" ${statusFilter == '已发货' ? 'selected' : ''}>已发货</option>
                                <option value="已完成" ${statusFilter == '已完成' ? 'selected' : ''}>已完成</option>
                                <option value="已取消" ${statusFilter == '已取消' ? 'selected' : ''}>已取消</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <button type="submit" class="btn btn-primary w-100">搜索</button>
                        </div>
                        <div class="col-md-2">
                            <a href="${pageContext.request.contextPath}/merchant/orders?tab=orders" class="btn btn-secondary w-100">重置</a>
                        </div>
                    </form>
                </div>

                <table class="table">
                    <thead>
                    <tr>
                        <th>订单号</th>
                        <th>用户</th>
                        <th>金额</th>
                        <th>状态</th>
                        <th>收货人</th>
                        <th>电话</th>
                        <th>地址</th>
                        <th>时间</th>
                        <th>操作</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach items="${orders}" var="order">
                        <tr>
                            <td>${order.orderId}</td>
                            <td>${order.username}</td>
                            <td>¥<fmt:formatNumber value="${order.totalAmount}" pattern="#0.00"/></td>
                            <td>
                                <span class="badge-status ${order.status == '待付款' ? 'badge-warning' :
                                    order.status == '已付款' ? 'badge-info' :
                                    order.status == '已发货' ? 'badge-primary' :
                                    order.status == '已完成' ? 'badge-active' : 'badge-disabled'}">
                                        ${order.status}
                                </span>
                            </td>
                            <td>${order.receiverName}</td>
                            <td>${order.receiverPhone}</td>
                            <td>${order.receiverAddress}</td>
                            <td><fmt:formatDate value="${order.createTime}" pattern="yyyy-MM-dd HH:mm"/></td>
                            <td>
                                <c:if test="${order.status == '已付款'}">
                                    <button class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#shipModal${order.orderId}">发货</button>
                                </c:if>
                                <c:if test="${order.status == '已发货'}">
                                    <a href="${pageContext.request.contextPath}/merchant/orders?action=complete&orderId=${order.orderId}" class="btn btn-sm btn-success" onclick="return confirm('确认完成？')">完成</a>
                                </c:if>

                                <!-- 发货模态框 -->
                                <div class="modal fade" id="shipModal${order.orderId}" tabindex="-1">
                                    <div class="modal-dialog">
                                        <div class="modal-content">
                                            <div class="modal-header">
                                                <h5 class="modal-title">订单发货</h5>
                                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                            </div>
                                            <div class="modal-body">
                                                <form id="shipForm${order.orderId}" action="${pageContext.request.contextPath}/merchant/orders" method="post">
                                                    <input type="hidden" name="action" value="ship">
                                                    <input type="hidden" name="orderId" value="${order.orderId}">
                                                    <div class="mb-3">
                                                        <label class="form-label">订单号</label>
                                                        <input type="text" class="form-control" value="${order.orderId}" readonly>
                                                    </div>
                                                    <div class="mb-3">
                                                        <label class="form-label">收货人</label>
                                                        <input type="text" class="form-control" value="${order.receiverName}" readonly>
                                                    </div>
                                                    <div class="mb-3">
                                                        <label class="form-label">收货地址</label>
                                                        <textarea class="form-control" rows="2" readonly>${order.receiverAddress}</textarea>
                                                    </div>
                                                    <div class="mb-3">
                                                        <label class="form-label">物流公司（选填）</label>
                                                        <select class="form-select" name="logisticsCompany">
                                                            <option value="">请选择物流公司</option>
                                                            <option value="顺丰速运">顺丰速运</option>
                                                            <option value="圆通速递">圆通速递</option>
                                                            <option value="中通快递">中通快递</option>
                                                            <option value="申通快递">申通快递</option>
                                                            <option value="韵达快递">韵达快递</option>
                                                            <option value="邮政EMS">邮政EMS</option>
                                                            <option value="京东物流">京东物流</option>
                                                            <option value="其他">其他</option>
                                                        </select>
                                                    </div>
                                                    <div class="mb-3">
                                                        <label class="form-label">物流单号（选填）</label>
                                                        <input type="text" class="form-control" name="trackingNumber" placeholder="请输入物流单号">
                                                    </div>
                                                    <div class="mb-3">
                                                        <label class="form-label">备注（选填）</label>
                                                        <textarea class="form-control" name="shipRemark" rows="2" placeholder="可填写发货说明"></textarea>
                                                    </div>
                                                </form>
                                            </div>
                                            <div class="modal-footer">
                                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">取消</button>
                                                <button type="button" class="btn btn-primary" onclick="document.getElementById('shipForm${order.orderId}').submit()">确认发货</button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </c:if>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
