<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- 权限校验：非管理员或未登录用户重定向至登录页 -->
<c:if test="${empty sessionScope.userId || sessionScope.userRole != '管理员'}">
    <jsp:forward page="/login.jsp"/>
</c:if>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>管理后台 - 花店商城</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="css/common.css">
    <style>
        :root {
            --primary-color: #e74c3c;
            --dark-color: #2c3e50;
            --light-color: #ecf0f1;
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
            transition: transform 0.2s;
        }

        .stat-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 6px 16px rgba(0,0,0,0.1);
        }

        .stat-card.clickable { cursor: pointer; }
        .stat-card.clickable:hover .stat-number { color: var(--primary-color); }

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
        .stat-card.teal .stat-icon { color: #1abc9c; }

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

        .filter-bar {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
        }

        .product-img {
            width: 60px;
            height: 60px;
            object-fit: cover;
            border-radius: 8px;
        }
    </style>
</head>
<body>

<nav class="admin-header">
    <div class="container d-flex justify-content-between align-items-center">
        <h4 class="mb-0"><i class="bi bi-shield-lock me-2"></i>花店商城管理后台</h4>
        <div>
            <span class="me-3">管理员：${sessionScope.username}</span>
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-sm btn-danger">退出登录</a>
        </div>
    </div>
</nav>

<div class="admin-container">
    <!-- Tab 导航栏：根据当前 tab 参数高亮显示 -->
    <ul class="nav nav-tabs mb-4">
        <li class="nav-item">
            <a class="nav-link ${empty param.tab ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/index?tab=index">
                <i class="bi bi-speedometer2"></i> 首页概览
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${param.tab == 'users' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/users?tab=users">
                <i class="bi bi-people"></i> 用户管理
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${param.tab == 'merchants' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/merchants?tab=merchants">
                <i class="bi bi-shop"></i> 商家管理
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${param.tab == 'categories' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/categories?tab=categories">
                <i class="bi bi-tags"></i> 商品类型管理
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${param.tab == 'messages' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/messages?tab=messages">
                <i class="bi bi-chat-dots"></i> 留言管理
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${param.tab == 'banners' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/banners?tab=banners">
                <i class="bi bi-images"></i> 海报管理
            </a>
        </li>
    </ul>

    <!-- 首页概览模块：展示统计数据及最近记录 -->
    <c:if test="${empty param.tab || param.tab == 'index'}">
        <div class="row g-3">
            <div class="col-6 col-md-4 col-lg-2">
                <a href="${pageContext.request.contextPath}/admin/users?tab=users" style="text-decoration:none;">
                    <div class="stat-card blue clickable">
                        <div class="stat-icon"><i class="bi bi-people"></i></div>
                        <div class="stat-number">${totalUsers}</div>
                        <div class="stat-label">普通用户数</div>
                    </div>
                </a>
            </div>
            <div class="col-6 col-md-4 col-lg-2">
                <a href="${pageContext.request.contextPath}/admin/merchants?tab=merchants" style="text-decoration:none;">
                    <div class="stat-card orange clickable">
                        <div class="stat-icon"><i class="bi bi-shop"></i></div>
                        <div class="stat-number">${totalMerchants}</div>
                        <div class="stat-label">商家总数</div>
                    </div>
                </a>
            </div>
            <div class="col-6 col-md-4 col-lg-2">
                <a href="${pageContext.request.contextPath}/admin/stats" style="text-decoration:none;">
                    <div class="stat-card purple clickable">
                        <div class="stat-icon"><i class="bi bi-currency-yuan"></i></div>
                        <div class="stat-number">¥<fmt:formatNumber value="${totalSales}" pattern="#0.00"/></div>
                        <div class="stat-label">总销售额</div>
                    </div>
                </a>
            </div>
            <div class="col-6 col-md-4 col-lg-2">
                <a href="${pageContext.request.contextPath}/admin/categories?tab=categories" style="text-decoration:none;">
                    <div class="stat-card green clickable">
                        <div class="stat-icon"><i class="bi bi-tags"></i></div>
                        <div class="stat-number">${totalCategories}</div>
                        <div class="stat-label">商品分类数</div>
                    </div>
                </a>
            </div>
            <div class="col-6 col-md-4 col-lg-2">
                <a href="${pageContext.request.contextPath}/admin/messages?tab=messages" style="text-decoration:none;">
                    <div class="stat-card teal clickable">
                        <div class="stat-icon"><i class="bi bi-chat-dots"></i></div>
                        <div class="stat-number">${unreadMessages}</div>
                        <div class="stat-label">未读留言</div>
                    </div>
                </a>
            </div>
            <div class="col-6 col-md-4 col-lg-2">
                <a href="${pageContext.request.contextPath}/admin/banners?tab=banners" style="text-decoration:none;">
                    <div class="stat-card yellow clickable">
                        <div class="stat-icon"><i class="bi bi-images"></i></div>
                        <div class="stat-number">${totalBanners}</div>
                        <div class="stat-label">海报数量</div>
                    </div>
                </a>
            </div>
        </div>

        <c:if test="${not empty recentOrders}">
        <div class="content-card">
            <div class="card-header">
                <h5 class="card-title"><i class="bi bi-clock-history me-2"></i>最近订单</h5>
            </div>
            <div class="card-body">
                <table class="table">
                    <thead><tr><th>订单号</th><th>用户</th><th>金额</th><th>状态</th><th>时间</th></tr></thead>
                    <tbody>
                    <c:forEach items="${recentOrders}" var="order">
                        <tr>
                            <td>${order.orderId}</td>
                            <td>${order.username}</td>
                            <td>¥<fmt:formatNumber value="${order.totalAmount}" pattern="#0.00"/></td>
                            <td><span class="badge-status ${order.status == '待付款' ? 'badge-warning' : order.status == '已付款' ? 'badge-info' : order.status == '已发货' ? 'badge-primary' : order.status == '已收货' ? 'badge-success' : order.status == '已完成' ? 'badge-active' : 'badge-disabled'}">${order.status == '已取消' ? (fn:contains(order.remark, '[管理员取消]') ? '管理员取消' : (fn:contains(order.remark, '[商家取消]') ? '商家取消' : '客户取消')) : order.status}</span></td>
                            <td><fmt:formatDate value="${order.createTime}" pattern="yyyy-MM-dd HH:mm"/></td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
        </c:if>

        <c:if test="${not empty recentUsers}">
        <div class="content-card">
            <div class="card-header">
                <h5 class="card-title"><i class="bi bi-person-plus me-2"></i>最近注册用户</h5>
                <a href="${pageContext.request.contextPath}/admin/users?tab=users" class="btn btn-sm btn-outline-primary">查看全部</a>
            </div>
            <div class="card-body">
                <table class="table">
                    <thead>
                    <tr>
                        <th>用户名</th>
                        <th>手机号</th>
                        <th>邮箱</th>
                        <th>角色</th>
                        <th>状态</th>
                        <th>注册时间</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach items="${recentUsers}" var="user">
                        <tr>
                            <td>${user.username}</td>
                            <td>${user.tel}</td>
                            <td>${user.email}</td>
                            <td>${user.role}</td>
                            <td>
                                <span class="badge-status ${user.state == '可用' ? 'badge-active' : 'badge-disabled'}">
                                        ${user.state}
                                </span>
                            </td>
                            <td><fmt:formatDate value="${user.createTime}" pattern="yyyy-MM-dd"/></td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
        </c:if>
    </c:if>

    <!-- 用户管理模块：支持搜索、筛选及角色/状态修改 -->
    <c:if test="${param.tab == 'users'}">
        <c:if test="${not empty adminSuccess}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle"></i> ${adminSuccess}<button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty adminError}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                ${adminError}<button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <div class="content-card">
            <div class="card-header">
                <h5 class="card-title"><i class="bi bi-people me-2"></i>用户管理</h5>
            </div>
            <div class="card-body">
                <div class="filter-bar">
                    <form method="get" action="${pageContext.request.contextPath}/admin/users" class="row g-3">
                        <input type="hidden" name="tab" value="users">
                        <div class="col-md-3">
                            <input type="text" class="form-control" name="keyword" placeholder="搜索用户名/手机/邮箱" value="${keyword}">
                        </div>
                        <div class="col-md-2">
                            <select class="form-select" name="role">
                                <option value="">全部</option>
                                <option value="用户" ${roleFilter == '用户' ? 'selected' : ''}>用户</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <select class="form-select" name="state">
                                <option value="">全部状态</option>
                                <option value="可用" ${stateFilter == '可用' ? 'selected' : ''}>可用</option>
                                <option value="禁用" ${stateFilter == '禁用' ? 'selected' : ''}>禁用</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <button type="submit" class="btn btn-primary w-100">搜索</button>
                        </div>
                        <div class="col-md-3">
                            <a href="${pageContext.request.contextPath}/admin/users?tab=users" class="btn btn-secondary w-100">重置</a>
                        </div>
                    </form>
                </div>

                <table class="table">
                    <thead>
                    <tr>
                        <th>ID</th>
                        <th>用户名</th>
                        <th>手机号</th>
                        <th>邮箱</th>
                        <th>角色</th>
                        <th>状态</th>
                        <th>注册时间</th>
                        <th>操作</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach items="${users}" var="user">
                        <tr>
                            <td>${user.id}</td>
                            <td>${user.username}</td>
                            <td>${user.tel}</td>
                            <td>${user.email}</td>
                            <td>${user.role}</td>
                            <td>
                                <span class="badge-status ${user.state == '可用' ? 'badge-active' : 'badge-disabled'}">
                                        ${user.state}
                                </span>
                            </td>
                            <td><fmt:formatDate value="${user.createTime}" pattern="yyyy-MM-dd"/></td>
                            <td>
                                <c:if test="${user.state == '可用'}">
                                    <button class="btn btn-sm btn-warning" onclick="toggleUserState(${user.id}, '禁用')">禁用</button>
                                </c:if>
                                <c:if test="${user.state == '禁用'}">
                                    <button class="btn btn-sm btn-success" onclick="toggleUserState(${user.id}, '可用')">启用</button>
                                </c:if>
                                <button class="btn btn-sm btn-info" onclick="changeUserToMerchant(${user.id}, '${user.username}')">改商家</button>
                                <button class="btn btn-sm btn-danger" data-bs-toggle="modal" data-bs-target="#pwdModal${user.id}">重置密码</button>
                                <c:if test="${sessionScope.userId != user.id}">
                                    <a href="${pageContext.request.contextPath}/admin/users?tab=users&action=delete&userId=${user.id}" class="btn btn-sm btn-outline-danger" onclick="return confirm('确定删除用户「${user.username}」？此操作不可恢复！')">删除</a>
                                </c:if>

                                <!-- 重置用户密码的模态框 -->
                                <div class="modal fade" id="pwdModal${user.id}" tabindex="-1">
                                    <div class="modal-dialog">
                                        <div class="modal-content">
                                            <div class="modal-header">
                                                <h5 class="modal-title">重置用户密码</h5>
                                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                            </div>
                                            <div class="modal-body">
                                                <form action="${pageContext.request.contextPath}/admin/users" method="post" id="pwdForm${user.id}">
                                                    <input type="hidden" name="action" value="resetPassword">
                                                    <input type="hidden" name="userId" value="${user.id}">
                                                    <div class="mb-3">
                                                        <label class="form-label">用户名</label>
                                                        <input type="text" class="form-control" value="${user.username}" readonly>
                                                    </div>
                                                    <div class="mb-3">
                                                        <label class="form-label">新密码 <span class="text-danger">*</span></label>
                                                        <input type="password" class="form-control" name="newPassword" id="newPwd${user.id}" minlength="6" required placeholder="请输入至少6位新密码">
                                                        <div class="form-text">密码长度不能少于6位</div>
                                                    </div>
                                                    <div class="mb-3">
                                                        <label class="form-label">确认密码 <span class="text-danger">*</span></label>
                                                        <input type="password" class="form-control" id="confirmPwd${user.id}" minlength="6" required placeholder="请再次输入新密码">
                                                    </div>
                                                </form>
                                            </div>
                                            <div class="modal-footer">
                                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">取消</button>
                                                <button type="button" class="btn btn-danger" onclick="submitPwdForm(${user.id})">确认重置</button>
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

    <!-- 商家管理模块 -->
    <c:if test="${param.tab == 'merchants'}">
        <c:if test="${not empty adminSuccess}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle"></i> ${adminSuccess}<button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty adminError}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                ${adminError}<button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <div class="content-card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="card-title"><i class="bi bi-shop me-2"></i>商家管理</h5>
                <button class="btn btn-danger btn-sm" data-bs-toggle="modal" data-bs-target="#addMerchantModal">
                    <i class="bi bi-plus-circle"></i> 添加商家
                </button>
            </div>
            <div class="card-body">
                <table class="table">
                    <thead><tr><th>ID</th><th>用户名</th><th>手机号</th><th>邮箱</th><th>状态</th><th>注册时间</th><th>操作</th></tr></thead>
                    <tbody>
                        <c:forEach items="${merchants}" var="m">
                            <tr>
                                <td>${m.id}</td>
                                <td>${m.username}</td>
                                <td>${m.tel}</td>
                                <td>${m.email}</td>
                                <td><span class="badge-status ${m.state == '可用' ? 'badge-active' : 'badge-disabled'}">${m.state}</span></td>
                                <td><fmt:formatDate value="${m.createTime}" pattern="yyyy-MM-dd"/></td>
                                <td>
                                    <c:if test="${m.id != sessionScope.userId}">
                                        <button class="btn btn-sm btn-info" onclick="changeMerchantRole(${m.id}, '${m.username}')">改为用户</button>
                                        <a href="${pageContext.request.contextPath}/admin/merchants?tab=merchants&action=delete&userId=${m.id}" class="btn btn-sm btn-outline-danger" onclick="return confirm('确定删除商家「${m.username}」？相关商品和订单将一并删除！')">删除</a>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- 添加商家模态框 -->
        <div class="modal fade" id="addMerchantModal" tabindex="-1">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">添加商家账号</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <form id="addMerchantForm" action="${pageContext.request.contextPath}/admin/merchants" method="post">
                            <input type="hidden" name="tab" value="merchants">
                            <input type="hidden" name="action" value="addMerchant">
                            <div class="mb-3">
                                <label class="form-label">商家用户名 <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" name="merchantUsername" required placeholder="请设置商家登录用户名" minlength="3">
                            </div>
                            <div class="mb-3">
                                <label class="form-label">登录密码 <span class="text-danger">*</span></label>
                                <input type="password" class="form-control" name="merchantPassword" id="addMerchantPwd" required placeholder="请设置登录密码" minlength="6">
                            </div>
                            <div class="mb-3">
                                <label class="form-label">确认密码 <span class="text-danger">*</span></label>
                                <input type="password" class="form-control" id="addMerchantConfirmPwd" required placeholder="再次输入密码" minlength="6">
                            </div>
                            <button type="button" class="btn btn-danger" onclick="submitAddMerchant()">确认添加</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </c:if>

    <!-- 订单管理模块 -->
    <c:if test="${param.tab == 'orders'}">
        <c:if test="${not empty adminSuccess}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle"></i> ${adminSuccess}<button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty adminError}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                ${adminError}<button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <div class="content-card">
            <div class="card-header">
                <h5 class="card-title"><i class="bi bi-receipt me-2"></i>订单管理</h5>
            </div>
            <div class="card-body">
                <div class="filter-bar">
                    <form method="get" action="${pageContext.request.contextPath}/admin/orders" class="row g-3">
                        <input type="hidden" name="tab" value="orders">
                        <div class="col-md-3">
                            <input type="text" class="form-control" name="keyword" placeholder="搜索订单号/用户名" value="${keyword}">
                        </div>
                        <div class="col-md-2">
                            <select class="form-select" name="status">
                                <option value="">全部状态</option>
                                <option value="未完成" ${statusFilter == '未完成' ? 'selected' : ''}>未完成</option>
                                <option value="待付款" ${statusFilter == '待付款' ? 'selected' : ''}>待付款</option>
                                <option value="已付款" ${statusFilter == '已付款' ? 'selected' : ''}>已付款</option>
                                <option value="已发货" ${statusFilter == '已发货' ? 'selected' : ''}>已发货</option>
                                <option value="已收货" ${statusFilter == '已收货' ? 'selected' : ''}>已收货</option>
                                <option value="已完成" ${statusFilter == '已完成' ? 'selected' : ''}>已完成</option>
                                <option value="已取消" ${statusFilter == '已取消' ? 'selected' : ''}>已取消</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <button type="submit" class="btn btn-primary w-100">搜索</button>
                        </div>
                        <div class="col-md-2">
                            <a href="${pageContext.request.contextPath}/admin/orders?tab=orders" class="btn btn-secondary w-100">重置</a>
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
                                    order.status == '已收货' ? 'badge-success' :
                                    order.status == '已完成' ? 'badge-active' : 'badge-disabled'}">
                                        ${order.status == '已取消' ? (fn:contains(order.remark, '[管理员取消]') ? '管理员取消' : (fn:contains(order.remark, '[商家取消]') ? '商家取消' : '客户取消')) : order.status}
                                </span>
                            </td>
                            <td>${order.receiverName}</td>
                            <td>${order.receiverPhone}</td>
                            <td><fmt:formatDate value="${order.createTime}" pattern="yyyy-MM-dd HH:mm"/></td>
                            <td>
                                <c:if test="${not empty order.wlNo}">
                                    <span class="badge badge-info me-1">物流: ${order.wlNo}</span>
                                </c:if>
                                <c:if test="${order.status == '已付款'}">
                                    <button class="btn btn-warning btn-sm" onclick="
                                        var wl = prompt('请输入物流单号（可选）：');
                                        location.href='${pageContext.request.contextPath}/admin/orders?tab=orders&action=ship&orderId=${order.orderId}&wlNo=' + encodeURIComponent(wl || '');
                                    ">发货</button>
                                    <a href="${pageContext.request.contextPath}/admin/orders?tab=orders&action=cancel&orderId=${order.orderId}" class="btn btn-sm btn-danger" onclick="return confirm('确认取消该订单？')">取消</a>
                                </c:if>
                                <c:if test="${order.status == '已发货'}">
                                    <a href="${pageContext.request.contextPath}/admin/orders?tab=orders&action=complete&orderId=${order.orderId}" class="btn btn-sm btn-success" onclick="return confirm('确认完成该订单？')">完成</a>
                                    <a href="${pageContext.request.contextPath}/admin/orders?tab=orders&action=cancel&orderId=${order.orderId}" class="btn btn-sm btn-danger" onclick="return confirm('确认取消该订单？退款将原路返回')">取消</a>
                                </c:if>
                                <c:if test="${order.status == '已收货'}">
                                    <a href="${pageContext.request.contextPath}/admin/orders?tab=orders&action=complete&orderId=${order.orderId}" class="btn btn-sm btn-success" onclick="return confirm('确认完成该订单？')">完成</a>
                                    <a href="${pageContext.request.contextPath}/admin/orders?tab=orders&action=cancel&orderId=${order.orderId}" class="btn btn-sm btn-danger" onclick="return confirm('确认取消该订单？退款将原路返回')">取消</a>
                                </c:if>
                                <c:if test="${order.status == '待付款'}">
                                    <a href="${pageContext.request.contextPath}/admin/orders?tab=orders&action=cancel&orderId=${order.orderId}" class="btn btn-sm btn-danger" onclick="return confirm('确认取消该订单？')">取消</a>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </c:if>

    <!-- 商品管理模块：支持上下架、删除及信息编辑 -->
    <c:if test="${param.tab == 'products'}">
        <c:if test="${not empty adminSuccess}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle"></i> ${adminSuccess}<button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty adminError}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                ${adminError}<button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <div class="content-card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="card-title"><i class="bi bi-box-seam me-2"></i>商品管理</h5>
                <button class="btn btn-danger btn-sm" data-bs-toggle="modal" data-bs-target="#addProductModal">
                    <i class="bi bi-plus-circle"></i> 新增商品
                </button>
            </div>
            <div class="card-body">
                <div class="filter-bar">
                    <form method="get" action="${pageContext.request.contextPath}/admin/products" class="row g-3">
                        <input type="hidden" name="tab" value="products">
                        <div class="col-md-3">
                            <input type="text" class="form-control" name="keyword" placeholder="搜索商品名称/描述" value="${keyword}">
                        </div>
                        <div class="col-md-2">
                            <select class="form-select" name="status">
                                <option value="">全部状态</option>
                                <option value="1" ${statusFilter == '1' ? 'selected' : ''}>上架</option>
                                <option value="0" ${statusFilter == '0' ? 'selected' : ''}>下架</option>
                                <option value="lowStock" ${statusFilter == 'lowStock' ? 'selected' : ''}>库存预警</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <button type="submit" class="btn btn-primary w-100">搜索</button>
                        </div>
                        <div class="col-md-2">
                            <a href="${pageContext.request.contextPath}/admin/products?tab=products" class="btn btn-secondary w-100">重置</a>
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
                                    <span class="text-danger fw-bold">${product.stock}</span>
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
                                    <a href="${pageContext.request.contextPath}/admin/products?action=disable&productId=${product.id}" class="btn btn-sm btn-warning">下架</a>
                                </c:if>
                                <c:if test="${product.status == 0}">
                                    <a href="${pageContext.request.contextPath}/admin/products?action=enable&productId=${product.id}" class="btn btn-sm btn-success">上架</a>
                                </c:if>
                                <a href="${pageContext.request.contextPath}/admin/products?action=delete&productId=${product.id}" class="btn btn-sm btn-danger" onclick="return confirm('确认删除该商品？')">删除</a>

                                <!-- 编辑商品信息的模态框 -->
                                <div class="modal fade" id="editModal${product.id}" tabindex="-1">
                                    <div class="modal-dialog modal-lg">
                                        <div class="modal-content">
                                            <div class="modal-header">
                                                <h5 class="modal-title">编辑商品</h5>
                                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                            </div>
                                            <div class="modal-body">
                                                <form action="${pageContext.request.contextPath}/admin/products" method="post">
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
                                                        <label class="form-label">分类ID</label>
                                                        <input type="number" class="form-control" name="categoryId" value="${product.categoryId}" required>
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
    </c:if>

    <!-- 新增商品模态框 -->
    <div class="modal fade" id="addProductModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">新增商品</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form action="${pageContext.request.contextPath}/admin/products" method="get">
                        <input type="hidden" name="tab" value="products">
                        <input type="hidden" name="action" value="add">
                        <div class="mb-3">
                            <label class="form-label">商品名称</label>
                            <input type="text" class="form-control" name="name" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">商品描述</label>
                            <textarea class="form-control" name="intro" rows="2" required></textarea>
                        </div>
                        <div class="row">
                            <div class="col-md-4 mb-3">
                                <label class="form-label">价格</label>
                                <input type="number" class="form-control" name="price" step="0.01" required>
                            </div>
                            <div class="col-md-4 mb-3">
                                <label class="form-label">库存</label>
                                <input type="number" class="form-control" name="stock" required>
                            </div>
                            <div class="col-md-4 mb-3">
                                <label class="form-label">分类ID</label>
                                <input type="number" class="form-control" name="categoryId" value="11" required>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">图片URL</label>
                            <input type="text" class="form-control" name="pic" required placeholder="https://...">
                        </div>
                        <button type="submit" class="btn btn-danger">确认新增</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- 海报管理 -->
    <c:if test="${param.tab == 'banners'}">
        <c:if test="${not empty adminError}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                ${adminError}<button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty adminSuccess}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle"></i> ${adminSuccess}<button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <!-- 轮播设置 -->
        <div class="content-card mb-3">
            <div class="card-header">
                <h5 class="card-title"><i class="bi bi-sliders me-2"></i>轮播设置</h5>
            </div>
            <div class="card-body">
                <form action="${pageContext.request.contextPath}/admin/banners" method="get" class="row g-3 align-items-end">
                    <input type="hidden" name="tab" value="banners">
                    <input type="hidden" name="action" value="setSpeed">
                    <div class="col-md-4">
                        <label class="form-label">轮播速度（秒）</label>
                        <select name="speed" class="form-select">
                            <option value="1500" ${bannerSpeed == 1500 ? 'selected' : ''}>1.5 秒（推荐）</option>
                            <option value="2000" ${bannerSpeed == 2000 ? 'selected' : ''}>2 秒（快）</option>
                            <option value="4000" ${bannerSpeed == 4000 ? 'selected' : ''}>4 秒（默认）</option>
                            <option value="6000" ${bannerSpeed == 6000 ? 'selected' : ''}>6 秒（慢）</option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">热卖商品展示</label>
                        <select name="showHot" class="form-select">
                            <option value="1" ${showHot == 1 ? 'selected' : ''}>仅显示热卖商品</option>
                            <option value="0" ${showHot == 0 ? 'selected' : ''}>热卖商品 + 海报</option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <button type="submit" class="btn btn-primary">保存设置</button>
                    </div>
                </form>
            </div>
        </div>
        <div class="content-card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="card-title"><i class="bi bi-images me-2"></i>海报管理</h5>
                <form action="${pageContext.request.contextPath}/admin/bannerUpload" method="post" enctype="multipart/form-data" class="d-flex gap-2">
                    <input type="file" name="bannerImg" accept="image/*" required class="form-control" style="width:250px;">
                    <input type="number" name="productId" class="form-control" placeholder="关联商品ID" required style="width:130px;" min="1">
                    <button type="submit" class="btn btn-danger btn-sm">上传</button>
                </form>
            </div>
            <div class="card-body">
                <table class="table">
                    <thead><tr><th>ID</th><th>预览</th><th>图片URL</th><th>关联商品ID</th><th>操作</th></tr></thead>
                    <tbody>
                        <c:forEach items="${bannerList}" var="b">
                            <tr>
                                <td>${b.id}</td>
                                <td><img src="${pageContext.request.contextPath}/${b.imgUrl}" style="width:120px;height:40px;object-fit:cover;border-radius:4px;" onerror="this.style.display='none'"></td>
                                <td style="max-width:300px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">${b.imgUrl}</td>
                                <td>${b.productId}</td>
                                <td><a href="${pageContext.request.contextPath}/admin/banners?tab=banners&action=delete&id=${b.id}" class="btn btn-sm btn-danger" onclick="return confirm('确定删除？')">删除</a></td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- 微信二维码管理 -->
        <div class="content-card mt-3">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="card-title"><i class="bi bi-qr-code me-2"></i>首页微信二维码</h5>
                <form action="${pageContext.request.contextPath}/admin/qrcodeUpload" method="post" enctype="multipart/form-data" class="d-flex gap-2">
                    <input type="file" name="qrImg" accept="image/*" required class="form-control" style="width:250px;">
                    <button type="submit" class="btn btn-danger btn-sm">上传替换</button>
                </form>
            </div>
            <div class="card-body text-center">
                <c:set var="qrPath" value="${applicationScope['wechatQrPath']}"/>
                <c:choose>
                    <c:when test="${not empty qrPath}">
                        <img src="${pageContext.request.contextPath}/uploads/${qrPath}?t=<%=System.currentTimeMillis()%>" style="width:120px;height:120px;object-fit:contain;border:1px solid #eee;border-radius:8px;">
                        <p class="text-muted mt-2" style="font-size:12px;">当前二维码：${qrPath}</p>
                        <a href="${pageContext.request.contextPath}/admin/banners?tab=banners&action=deleteQr" class="btn btn-sm btn-outline-danger mt-1">恢复默认</a>
                    </c:when>
                    <c:otherwise>
                        <img src="https://api.qrserver.com/v1/create-qr-code/?size=100x100&data=BEGIN:VCARD%0AVERSION:3.0%0AFN:归途%0ATEL:18023154203%0AEMAIL:guitu2025@qq.com%0ANOTE:归途花店%20-%20创始人%0AEND:VCARD" style="width:120px;height:120px;object-fit:contain;border:1px solid #eee;border-radius:8px;">
                        <p class="text-muted mt-2" style="font-size:12px;">当前使用默认vCard二维码</p>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </c:if>

    <!-- 分类管理 -->
    <c:if test="${param.tab == 'categories'}">
        <c:if test="${not empty adminSuccess}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle"></i> ${adminSuccess}<button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty adminError}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                ${adminError}<button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <div class="content-card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="card-title"><i class="bi bi-tags me-2"></i>分类管理</h5>
                <form action="${pageContext.request.contextPath}/admin/categories" method="post" class="d-flex gap-2">
                    <input type="hidden" name="tab" value="categories">
                    <input type="hidden" name="action" value="add">
                    <input type="text" name="name" class="form-control" placeholder="分类名称" required style="width:150px;">
                    <select name="parentId" class="form-control" style="width:140px;">
                        <option value="0">一级分类</option>
                        <c:forEach items="${parentCategories}" var="pc">
                            <option value="${pc.id}">└ ${pc.name}</option>
                        </c:forEach>
                    </select>
                    <input type="text" name="description" class="form-control" placeholder="描述" style="width:180px;">
                    <button type="submit" class="btn btn-danger btn-sm">新增</button>
                </form>
            </div>
            <div class="card-body">
                <table class="table">
                    <thead><tr><th>ID</th><th>名称</th><th>父级</th><th>描述</th><th>操作</th></tr></thead>
                    <tbody>
                        <c:forEach items="${allCategories}" var="cat">
                            <tr>
                                <td>${cat.id}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${cat.parentId == 0}">
                                            <strong>${cat.name}</strong>
                                        </c:when>
                                        <c:otherwise>
                                            └ ${cat.name}
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${cat.parentId == 0 ? '一级' : '二级'}</td>
                                <td>${cat.description}</td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/admin/categories?tab=categories&action=delete&id=${cat.id}" class="btn btn-sm btn-danger" onclick="return confirm('确定删除？')">删除</a>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </c:if>

    <!-- 留言管理 -->
    <c:if test="${param.tab == 'messages'}">
        <c:if test="${not empty adminSuccess}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle"></i> ${adminSuccess}<button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty adminError}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                ${adminError}<button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <div class="content-card">
            <div class="card-header">
                <h5 class="card-title"><i class="bi bi-chat-dots me-2"></i>用户留言</h5>
            </div>
            <div class="card-body">
                <c:choose>
                    <c:when test="${not empty messageList}">
                        <c:set var="nl" value="
"/>
                        <table class="table">
                            <thead><tr><th style="width:10%;">状态</th><th style="width:10%;">用户</th><th style="width:28%;">留言内容</th><th style="width:24%;">对话</th><th style="width:10%;">时间</th><th style="width:18%;">操作</th></tr></thead>
                            <tbody>
                                <c:forEach items="${messageList}" var="msg">
                                    <tr${msg.unreadUserReplies > 0 ? ' style="font-weight:600;"' : ''}>
                                        <td>
                                            <c:choose>
                                                <c:when test="${msg.unreadUserReplies > 0}"><span class="badge bg-warning">${msg.unreadUserReplies} 条新回复</span></c:when>
                                                <c:otherwise><span class="badge bg-success">已读</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>${msg.username}</td>
                                        <td style="max-width:260px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;" title="${msg.content}">${msg.content}</td>
                                        <td style="max-width:260px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;${empty msg.conversation ? 'color:#999;' : 'color:#3498db;text-decoration:underline;cursor:pointer;'}"
                                            ${not empty msg.conversation ? 'data-bs-toggle="modal" data-bs-target="#convModal'.concat(msg.id).concat('"') : ''}>
                                            ${empty msg.conversation ? '暂无' : '查看对话'}
                                        </td>
                                        <td><fmt:formatDate value="${msg.createTime}" pattern="MM-dd HH:mm"/></td>
                                        <td>
                                            <button class="btn btn-sm btn-primary" onclick="document.getElementById('replyForm${msg.id}').style.display='block'">回复</button>
                                            <a href="${pageContext.request.contextPath}/admin/messages?tab=messages&action=delete&id=${msg.id}" class="btn btn-sm btn-danger" onclick="return confirm('确定删除？')">删除</a>
                                            <form id="replyForm${msg.id}" style="display:none;margin-top:6px;" action="${pageContext.request.contextPath}/admin/messages" method="get">
                                                <input type="hidden" name="tab" value="messages">
                                                <input type="hidden" name="action" value="reply">
                                                <input type="hidden" name="msgId" value="${msg.id}">
                                                <div class="d-flex gap-1">
                                                    <input type="text" name="reply" class="form-control form-control-sm" placeholder="输入回复..." required style="width:120px;">
                                                    <button type="submit" class="btn btn-sm btn-success">发送</button>
                                                </div>
                                            </form>
                                        </td>
                                    </tr>
                                    <!-- 对话详情模态框 -->
                                    <div class="modal fade" id="convModal${msg.id}" tabindex="-1">
                                        <div class="modal-dialog">
                                            <div class="modal-content">
                                                <div class="modal-header">
                                                    <h5 class="modal-title">对话详情 - ${msg.username}</h5>
                                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                </div>
                                                <div class="modal-body">
                                                    <div style="font-size:13px;color:#666;margin-bottom:10px;">
                                                        <strong>留言：</strong>${msg.content}
                                                    </div>
                                                    <div style="background:#f8f9fa;border-radius:8px;padding:12px 16px;white-space:pre-wrap;font-size:13px;line-height:1.5;max-height:400px;overflow-y:auto;font-family:inherit;">
${msg.conversation}
                                                    </div>
                                                </div>
                                                <div class="modal-footer">
                                                    <form id="modalReplyForm${msg.id}" action="${pageContext.request.contextPath}/admin/messages" method="get">
                                                        <input type="hidden" name="tab" value="messages">
                                                        <input type="hidden" name="action" value="reply">
                                                        <input type="hidden" name="msgId" value="${msg.id}">
                                                        <input type="hidden" name="focusModal" value="${msg.id}">
                                                        <div class="d-flex gap-2">
                                                            <input type="text" name="reply" class="form-control form-control-sm" placeholder="输入回复..." required style="width:200px;">
                                                            <button type="submit" class="btn btn-sm btn-success">发送</button>
                                                        </div>
                                                    </form>
                                                    <button type="button" class="btn btn-sm btn-secondary" data-bs-dismiss="modal">关闭</button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:when>
                    <c:otherwise>
                        <div class="text-center py-5 text-muted">暂无留言</div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </c:if>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    /**
     * 禁用/启用用户账号 - 通过隐藏表单提交
     * @param {number} userId 用户ID
     * @param {string} newState 新状态（禁用/可用）
     */
    function toggleUserState(userId, newState) {
        var action = newState === '禁用' ? 'disable' : 'enable';
        var confirmMsg = newState === '禁用'
            ? '确认禁用该用户？禁用后该用户将无法登录。'
            : '确认启用该用户？';

        if (!confirm(confirmMsg)) {
            return;
        }

        var formData = new URLSearchParams();
        formData.append('userId', userId);
        formData.append('action', action);

        fetch('${pageContext.request.contextPath}/admin/users', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: formData.toString()
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.success) {
                alert(data.message);
                location.reload();
            } else {
                alert('操作失败：' + data.message);
            }
        })
        .catch(function(e) {
            alert('网络错误，请重试');
        });
    }

    /**
     * 重置用户密码 - 校验两次密码是否一致后提交表单
     * @param {number} userId 用户ID
     */
    function submitPwdForm(userId) {
        var newPwd = document.getElementById('newPwd' + userId).value;
        var confirmPwd = document.getElementById('confirmPwd' + userId).value;

        if (newPwd.length < 6) {
            alert('密码长度不能少于6位');
            return;
        }

        if (newPwd !== confirmPwd) {
            alert('两次输入的密码不一致，请重新输入');
            return;
        }

        if (!confirm('确认重置该用户的密码？重置后用户需使用新密码登录。')) {
            return;
        }

        var formData = new URLSearchParams();
        formData.append('userId', userId);
        formData.append('action', 'resetPassword');
        formData.append('newPassword', newPwd);

        fetch('${pageContext.request.contextPath}/admin/users', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: formData.toString()
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.success) {
                alert(data.message);
                var modalEl = document.getElementById('pwdModal' + userId);
                if (modalEl) {
                    var modal = bootstrap.Modal.getInstance(modalEl);
                    if (modal) modal.hide();
                }
            } else {
                alert('操作失败：' + data.message);
            }
        })
        .catch(function(e) {
            alert('网络错误，请重试');
        });
    }

    // 回复后自动重开对话框
    (function() {
        var fm = '${focusModal}';
        if (fm && fm !== '') {
            var modalEl = document.getElementById('convModal' + fm);
            if (modalEl) new bootstrap.Modal(modalEl).show();
        }
    })();

    function changeMerchantRole(userId, username) {
        if (!confirm('确定将该商家「' + username + '」的角色改为普通用户？')) return;

        var formData = new URLSearchParams();
        formData.append('userId', userId);
        formData.append('action', 'changeRole');
        formData.append('newRole', '用户');

        fetch('${pageContext.request.contextPath}/admin/users', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: formData.toString()
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.success) {
                alert(data.message);
                location.reload();
            } else {
                alert('操作失败：' + data.message);
            }
        })
        .catch(function(e) {
            alert('网络错误，请重试');
        });
    }

    function changeUserToMerchant(userId, username) {
        if (!confirm('确定将该用户「' + username + '」的角色改为商家？')) return;

        var formData = new URLSearchParams();
        formData.append('userId', userId);
        formData.append('action', 'changeRole');
        formData.append('newRole', '商家');

        fetch('${pageContext.request.contextPath}/admin/users', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: formData.toString()
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.success) {
                alert(data.message);
                location.reload();
            } else {
                alert('操作失败：' + data.message);
            }
        })
        .catch(function(e) {
            alert('网络错误，请重试');
        });
    }

    function submitAddMerchant() {
        var pwd = document.getElementById('addMerchantPwd').value;
        var confirmPwd = document.getElementById('addMerchantConfirmPwd').value;
        if (pwd.length < 6) { alert('密码长度不能少于6位'); return; }
        if (pwd !== confirmPwd) { alert('两次输入的密码不一致'); return; }
        document.getElementById('addMerchantForm').submit();
    }
</script>
</body>
</html>
