<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- 检查用户登录状态，未登录则重定向至登录页 -->
<c:if test="${empty sessionScope.username}">
    <jsp:forward page="login.jsp?redirect=usercenter"/>
</c:if>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>个人中心 - 花店商城</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="css/common.css">
    <style>
        :root {
            --primary-red: #e74c3c;
            --dark-red: #c0392b;
            --primary-green: #27ae60;
            --bg-gray: #f5f5f5;
            --sidebar-width: 240px;
        }

        body {
            font-family: "PingFang SC", "Microsoft YaHei", sans-serif;
            background: var(--bg-gray);
        }

        .top-navbar {
            background: white;
            border-bottom: 1px solid #e0e0e0;
            padding: 15px 0;
            position: sticky;
            top: 0;
            z-index: 100;
        }

        .brand-logo {
            font-size: 20px;
            font-weight: 700;
            color: #333;
            text-decoration: none;
            cursor: pointer;
            background: linear-gradient(135deg, var(--primary-red) 0%, #ff6b6b 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            transition: transform 0.2s;
        }

        .brand-logo:hover {
            transform: scale(1.05);
        }

        /* 版权说明模态框 */
        .copyright-modal { display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 10000; align-items: center; justify-content: center; }
        .copyright-modal.show { display: flex; }
        .copyright-content { background: white; padding: 50px; border-radius: 16px; text-align: center; max-width: 550px; width: 90%; animation: modalSlideIn 0.3s ease; box-shadow: 0 20px 60px rgba(0,0,0,0.2); }
        @keyframes modalSlideIn { from { opacity: 0; transform: translateY(-20px); } to { opacity: 1; transform: translateY(0); } }
        .copyright-icon { font-size: 64px; margin-bottom: 20px; }
        .copyright-title { font-size: 28px; background: linear-gradient(135deg, var(--primary-red) 0%, #ff6b6b 100%); -webkit-background-clip: text; -webkit-text-fill-color: transparent; margin-bottom: 20px; font-weight: 700; }
        .copyright-divider { width: 60px; height: 3px; background: linear-gradient(90deg, var(--primary-red) 0%, #ff6b6b 100%); margin: 0 auto 20px; border-radius: 2px; }
        .copyright-message { color: #666; font-size: 16px; line-height: 1.8; margin-bottom: 15px; }
        .copyright-warning { background: linear-gradient(135deg, #fff5f5 0%, #ffffff 100%); border-left: 4px solid var(--primary-red); padding: 15px 20px; border-radius: 8px; margin: 20px 0; text-align: left; }
        .copyright-warning p { color: #666; font-size: 14px; margin: 0; line-height: 1.6; }
        .copyright-warning strong { color: var(--primary-red); }
        .copyright-btn { background: linear-gradient(135deg, var(--primary-red) 0%, #ff6b6b 100%); color: white; border: none; padding: 14px 50px; border-radius: 8px; font-size: 16px; cursor: pointer; transition: all 0.3s; margin-top: 20px; font-weight: 600; }
        .copyright-btn:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(231, 76, 60, 0.4); }

        .center-container {
            max-width: 1200px;
            margin: 30px auto;
            display: flex;
            gap: 20px;
            padding: 0 15px;
        }

        .sidebar {
            width: var(--sidebar-width);
            flex-shrink: 0;
        }

        .user-card {
            background: white;
            border-radius: 12px;
            padding: 25px;
            text-align: center;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            margin-bottom: 15px;
        }

        .user-avatar {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, var(--primary-red), #ff6b6b);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 32px;
            margin: 0 auto 15px;
        }

        .user-name {
            font-size: 18px;
            font-weight: 600;
            color: #333;
            margin-bottom: 5px;
        }

        .user-email {
            font-size: 13px;
            color: #999;
            word-break: break-all;
        }

        .nav-menu {
            background: white;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }

        .nav-item {
            border-bottom: 1px solid #f0f0f0;
        }

        .nav-item:last-child {
            border-bottom: none;
        }

        .nav-link {
            display: flex;
            align-items: center;
            padding: 15px 20px;
            color: #666;
            text-decoration: none;
            transition: all 0.2s;
        }

        .nav-link:hover,
        .nav-link.active {
            background: #fff5f5;
            color: var(--primary-red);
        }

        .nav-link i {
            font-size: 18px;
            margin-right: 12px;
            width: 24px;
            text-align: center;
        }

        .nav-badge {
            margin-left: auto;
            background: var(--primary-red);
            color: white;
            font-size: 11px;
            padding: 2px 8px;
            border-radius: 10px;
        }

        .main-content {
            flex: 1;
            min-width: 0;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 15px;
            margin-bottom: 20px;
        }

        .stat-card {
            background: white;
            border-radius: 12px;
            padding: 20px;
            text-align: center;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            transition: transform 0.2s;
            cursor: pointer;
            text-decoration: none;
            color: inherit;
            border: 2px solid transparent;
        }

        .stat-card:hover {
            transform: translateY(-2px);
            border-color: var(--primary-red);
        }

        .stat-icon {
            font-size: 28px;
            margin-bottom: 8px;
        }

        .stat-card.pending .stat-icon { color: #f39c12; }
        .stat-card.paid .stat-icon { color: #3498db; }
        .stat-card.shipped .stat-icon { color: #9b59b6; }
        .stat-card.completed .stat-icon { color: var(--primary-green); }

        .stat-num {
            font-size: 24px;
            font-weight: bold;
            color: #333;
            margin-bottom: 4px;
        }

        .stat-label {
            font-size: 13px;
            color: #666;
        }

        .content-card {
            background: white;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            overflow: hidden;
        }

        .card-header {
            padding: 20px;
            border-bottom: 1px solid #f0f0f0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .card-title {
            font-size: 16px;
            font-weight: 600;
            color: #333;
            margin: 0;
        }

        .card-body {
            padding: 20px;
        }

        .order-item-mini {
            display: flex;
            align-items: center;
            padding: 15px 0;
            border-bottom: 1px solid #f5f5f5;
        }

        .order-item-mini:last-child {
            border-bottom: none;
        }

        .order-img {
            width: 60px;
            height: 60px;
            object-fit: cover;
            border-radius: 8px;
            margin-right: 15px;
            border: 1px solid #eee;
        }

        .order-info {
            flex: 1;
        }

        .order-id {
            font-size: 13px;
            color: #999;
            margin-bottom: 4px;
        }

        .order-products {
            font-size: 14px;
            color: #333;
            font-weight: 500;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            max-width: 300px;
        }

        .order-meta {
            text-align: right;
        }

        .order-price {
            color: var(--primary-red);
            font-weight: bold;
            font-size: 16px;
            margin-bottom: 4px;
        }

        .order-status {
            font-size: 12px;
            padding: 3px 10px;
            border-radius: 20px;
            display: inline-block;
        }

        .status-waiting { background: #fff3cd; color: #856404; }
        .status-paid { background: #d1ecf1; color: #0c5460; }
        .status-shipped { background: #e2e3f5; color: #383d7d; }
        .status-completed { background: #d4edda; color: #155724; }

        .info-row {
            display: flex;
            padding: 15px 0;
            border-bottom: 1px solid #f5f5f5;
        }

        .info-label {
            width: 100px;
            color: #666;
            font-size: 14px;
        }

        .info-value {
            flex: 1;
            color: #333;
            font-weight: 500;
        }

        .btn-edit {
            color: var(--primary-red);
            font-size: 13px;
            text-decoration: none;
            cursor: pointer;
            background: none;
            border: none;
            padding: 0;
        }

        .btn-edit:hover {
            text-decoration: underline;
        }

        /* 编辑资料模态框样式 */
        .modal-content {
            border-radius: 12px;
            border: none;
        }

        .modal-header {
            border-bottom: 1px solid #f0f0f0;
            padding: 20px;
        }

        .modal-title {
            font-size: 18px;
            font-weight: 600;
            color: #333;
        }

        .modal-body {
            padding: 25px 20px;
        }

        .modal-footer {
            border-top: 1px solid #f0f0f0;
            padding: 15px 20px;
        }

        .form-group-edit {
            margin-bottom: 20px;
        }

        .form-group-edit label {
            display: block;
            font-size: 14px;
            color: #666;
            margin-bottom: 8px;
            font-weight: 500;
        }

        .form-group-edit label .required {
            color: var(--primary-red);
            margin-left: 2px;
        }

        .form-group-edit input {
            width: 100%;
            padding: 10px 15px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 14px;
            outline: none;
            transition: border-color 0.2s;
        }

        .form-group-edit input:focus {
            border-color: var(--primary-red);
        }

        .form-group-edit input:disabled {
            background-color: #f5f5f5;
            cursor: not-allowed;
        }

        .form-group-edit .form-hint {
            font-size: 12px;
            color: #999;
            margin-top: 4px;
        }

        /* 提示信息样式 */
        .alert-msg {
            padding: 12px 15px;
            border-radius: 8px;
            margin-bottom: 15px;
            font-size: 14px;
        }

        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .alert-error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        .empty-state {
            text-align: center;
            padding: 60px 20px;
        }

        .empty-icon {
            font-size: 48px;
            color: #ddd;
            margin-bottom: 15px;
        }

        .empty-text {
            color: #999;
            font-size: 14px;
        }

        @media (max-width: 768px) {
            .center-container {
                flex-direction: column;
            }

            .sidebar {
                width: 100%;
            }

            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }
    </style>
</head>
<body>

<nav class="top-navbar">
    <div class="container d-flex justify-content-between align-items-center">
        <a href="javascript:void(0)" onclick="showCopyright()" class="brand-logo"> 归途</a>
        <div>
            <span class="text-muted me-3">欢迎，${sessionScope.username}</span>
            <c:if test="${sessionScope.userRole == '管理员'}">
            <a href="${pageContext.request.contextPath}/admin/index" class="btn btn-sm me-2" style="color:var(--primary-red);border:1px solid var(--primary-red);border-radius:4px;text-decoration:none;padding:6px 12px;">
                <i class="bi bi-gear"></i> 管理中心
            </a>
            </c:if>
            <a href="index.jsp" class="btn btn-outline-danger btn-sm">返回首页</a>
        </div>
    </div>
</nav>

<div class="center-container">
    <aside class="sidebar">
        <div class="user-card">
            <div class="user-avatar">
                <c:choose>
                    <c:when test="${not empty user.avatar}">
                        <img src="${pageContext.request.contextPath}/${user.avatar}" style="width:80px;height:80px;border-radius:50%;object-fit:cover;" alt="头像">
                    </c:when>
                    <c:otherwise>
                        <i class="bi bi-person-fill"></i>
                    </c:otherwise>
                </c:choose>
            </div>
            <div class="user-name">${user.username}</div>
            <div class="user-email">${user.email}</div>
            <!-- 头像上传 -->
            <form action="${pageContext.request.contextPath}/avatar" method="post" enctype="multipart/form-data" style="margin-top:8px;">
                <input type="file" name="avatar" id="avatarInput" style="display:none;" accept="image/*" onchange="this.form.submit()">
                <button type="button" class="btn btn-sm btn-outline-danger" onclick="document.getElementById('avatarInput').click()" style="font-size:11px;padding:4px 10px;">
                    <i class="bi bi-camera"></i> 上传头像
                </button>
            </form>

            <!-- 积分展示 -->
            <div style="margin-top:10px;padding-top:10px;border-top:1px solid #f0f0f0;">
                <div style="font-size:22px;font-weight:700;color:#e74c3c;">${user.jf}</div>
                <div style="font-size:12px;color:#999;">我的积分</div>
                <a href="javascript:void(0)" onclick="showJfDetail()" style="font-size:11px;color:#e74c3c;text-decoration:none;display:inline-block;margin-top:4px;">
                  <i class="bi bi-list-ul"></i> 积分明细
                </a>
                <a href="javascript:void(0)" onclick="showJfRules()" style="font-size:11px;color:#e74c3c;text-decoration:none;display:inline-block;margin-left:10px;">
                  <i class="bi bi-question-circle"></i> 积分规则
                </a>
            </div>
        </div>

        <nav class="nav-menu">
            <div class="nav-item">
                <a href="usercenter" class="nav-link ${empty param.tab ? 'active' : ''}">
                    <i class="bi bi-house-door"></i>
                    个人中心
                </a>
            </div>
            <div class="nav-item">
                <a href="orders?ref=uc" class="nav-link">
                    <i class="bi bi-receipt"></i>
                    <c:set var="pendingCount" value="${orderStats['待付款'] + orderStats['已付款'] + orderStats['已发货']}"/>
                    我的订单
                    <c:if test="${pendingCount > 0}">
                        <span class="nav-badge">${pendingCount}</span>
                    </c:if>
                </a>
            </div>
            <div class="nav-item">
                <a href="message" class="nav-link">
                    <i class="bi bi-chat-dots"></i>
                    我的留言
                    <c:if test="${unreadMsgCount > 0}">
                        <span style="background:#e74c3c;color:white;font-size:11px;padding:2px 7px;border-radius:10px;margin-left:6px;">${unreadMsgCount}</span>
                    </c:if>
                </a>
            </div>
            <div class="nav-item">
                <a href="address" class="nav-link">
                    <i class="bi bi-geo-alt"></i>
                    收货地址
                </a>
            </div>
            <div class="nav-item">
                <a href="security" class="nav-link">
                    <i class="bi bi-shield-lock"></i>
                    账号安全
                </a>
            </div>
            <div class="nav-item">
                <a href="logout" class="nav-link text-danger">
                    <i class="bi bi-box-arrow-right"></i>
                    退出登录
                </a>
            </div>
        </nav>
    </aside>

    <main class="main-content">

        <!-- 显示更新成功/失败的提示信息 -->
        <c:if test="${not empty sessionScope.updateSuccess}">
            <div class="alert-msg alert-success">
                <i class="bi bi-check-circle me-2"></i>${sessionScope.updateSuccess}
            </div>
            <c:remove var="updateSuccess" scope="session"/>
        </c:if>

        <c:if test="${not empty sessionScope.updateError}">
            <div class="alert-msg alert-error">
                <i class="bi bi-exclamation-circle me-2"></i>${sessionScope.updateError}
            </div>
            <c:remove var="updateError" scope="session"/>
        </c:if>

        <!-- 订单状态统计卡片：展示各阶段订单数量并支持点击跳转 -->
        <c:if test="${empty param.tab}">
            <div class="stats-grid">
                <a href="orders" class="stat-card pending">
                    <div class="stat-icon"><i class="bi bi-hourglass-split"></i></div>
                    <div class="stat-num">${orderStats['待付款']}</div>
                    <div class="stat-label">待付款</div>
                </a>
                <a href="orders" class="stat-card paid">
                    <div class="stat-icon"><i class="bi bi-check-circle"></i></div>
                    <div class="stat-num">${orderStats['已付款']}</div>
                    <div class="stat-label">待发货</div>
                </a>
                <a href="orders" class="stat-card shipped">
                    <div class="stat-icon"><i class="bi bi-truck"></i></div>
                    <div class="stat-num">${orderStats['已发货']}</div>
                    <div class="stat-label">待收货</div>
                </a>
                <a href="orders" class="stat-card completed">
                    <div class="stat-icon"><i class="bi bi-bag-check"></i></div>
                    <div class="stat-num">${orderStats['已收货']}</div>
                    <div class="stat-label">已收货</div>
                </a>
            </div>
        </c:if>

        <div class="content-card">
            <div class="card-header">
                <h5 class="card-title">
                    <c:choose>
                        <c:when test="${param.tab == 'orders'}">全部订单</c:when>
                        <c:otherwise>最近订单</c:otherwise>
                    </c:choose>
                </h5>
                <c:if test="${empty param.tab && fn:length(recentOrders) > 0}">
                    <a href="orders" class="btn-edit">查看全部 <i class="bi bi-chevron-right"></i></a>
                </c:if>
            </div>

            <div class="card-body">
                <!-- 订单列表展示区：根据是否有 tab 参数决定展示最近订单还是全部订单 -->
                <c:choose>
                    <c:when test="${empty recentOrders && empty param.tab}">
                        <div class="empty-state">
                            <div class="empty-icon"><i class="bi bi-inbox"></i></div>
                            <p class="empty-text">暂无订单，快去选购心仪的商品吧</p>
                            <a href="index.jsp" class="btn btn-danger btn-sm mt-2">去购物</a>
                        </div>
                    </c:when>

                    <c:otherwise>
                        <c:forEach items="${empty param.tab ? recentOrders : allOrders}" var="order" varStatus="status">
                            <div class="order-item-mini">
                                <c:if test="${not empty order.items}">
                                    <img src="${order.items[0].productPic}" alt="" class="order-img"
                                         onerror="this.src='https://via.placeholder.com/60?text=暂无图'">
                                </c:if>

                                <div class="order-info">
                                    <div class="order-id">订单号：${order.orderId}</div>
                                    <div class="order-products">
                                        <c:forEach items="${order.items}" var="item" varStatus="itemStatus">
                                            ${item.productName}<c:if test="${!itemStatus.last}">、</c:if>
                                        </c:forEach>
                                        <span class="text-muted">等${order.totalCount}件商品</span>
                                    </div>
                                    <div class="text-muted mt-1" style="font-size: 12px;">
                                        <fmt:formatDate value="${order.createTime}" pattern="yyyy-MM-dd HH:mm"/>
                                    </div>
                                </div>

                                <div class="order-meta">
                                    <div class="order-price">¥<fmt:formatNumber value="${order.totalAmount}" pattern="#0.00"/></div>
                                    <span class="order-status status-${order.status == '待付款' ? 'waiting' :
                                                                    order.status == '已付款' ? 'paid' :
                                                                    order.status == '已发货' ? 'shipped' : 'completed'}">
                                            ${order.status}
                                    </span>
                                </div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- 账号基本信息展示模块 -->
        <c:if test="${empty param.tab}">
            <div class="content-card mt-4">
                <div class="card-header">
                    <h5 class="card-title">账号信息</h5>
                    <button class="btn-edit" data-bs-toggle="modal" data-bs-target="#editProfileModal">编辑资料</button>
                </div>
                <div class="card-body">
                    <div class="info-row">
                        <span class="info-label">用户名</span>
                        <span class="info-value">${user.username}</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">手机号</span>
                        <span class="info-value">${user.tel}</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">邮箱</span>
                        <span class="info-value">${user.email}</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">注册时间</span>
                        <span class="info-value">
                            <fmt:formatDate value="${user.createTime}" pattern="yyyy-MM-dd HH:mm"/>
                        </span>
                    </div>
                    <div class="info-row" style="border-bottom: none;">
                        <span class="info-label">最后登录</span>
                        <span class="info-value">
                            <fmt:formatDate value="${user.lastLoginTime}" pattern="yyyy-MM-dd HH:mm"/>
                        </span>
                    </div>
                </div>
            </div>
        </c:if>

    </main>
</div>

<!-- 编辑资料模态框 -->
<div class="modal fade" id="editProfileModal" tabindex="-1" aria-labelledby="editProfileModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="editProfileModalLabel">编辑资料</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="${pageContext.request.contextPath}/usercenter" method="post" id="editProfileForm">
                <div class="modal-body">
                    <div class="form-group-edit">
                        <label>用户名</label>
                        <input type="text" value="${user.username}" disabled>
                        <div class="form-hint">用户名不可修改</div>
                    </div>
                    <div class="form-group-edit">
                        <label>手机号<span class="required">*</span></label>
                        <input type="tel" name="tel" id="editTel" value="${user.tel}" required
                               pattern="1[3-9]\d{9}" title="请输入有效的11位手机号" onblur="checkTel()">
                        <div class="form-hint" id="telHint">11位手机号码</div>
                    </div>
                    <div class="form-group-edit">
                        <label>邮箱<span class="required">*</span></label>
                        <input type="email" name="email" id="editEmail" value="${user.email}" required onblur="checkEmail()">
                        <div class="form-hint" id="emailHint">用于接收订单通知</div>
                    </div>
                    <div class="form-group-edit">
                        <label>性别</label>
                        <select name="gender" class="form-control" style="width:100%;padding:10px 15px;border:1px solid #ddd;border-radius:6px;font-size:14px;outline:none;">
                            <option value="男" ${user.gender == '男' ? 'selected' : ''}>男</option>
                            <option value="女" ${user.gender == '女' ? 'selected' : ''}>女</option>
                            <option value="未知" ${user.gender == '未知' ? 'selected' : ''}>未知</option>
                        </select>
                        <div class="form-hint">请选择您的性别</div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">取消</button>
                    <button type="submit" class="btn btn-danger">保存修改</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<!-- 版权说明模态框 -->
<div class="copyright-modal" id="copyrightModal">
    <div class="copyright-content">
        <div class="copyright-icon">🌸</div>
        <h2 class="copyright-title">关于「归途」</h2>
        <div class="copyright-divider"></div>
        <p class="copyright-message">「归途花店」是一款基于 Java Web 技术开发的电商学习项目</p>
        <div class="copyright-warning">
            <p><strong>⚠️ 声明：</strong>本项目仅供个人学习与技术研究使用，所有代码、设计及内容版权归开发者本人所有。</p>
            <p style="margin-top: 10px;"><strong>🚫 请勿抄袭：</strong>未经授权，任何人不得将本项目或其部分内容用于商业目的、课程作业提交或任何形式的抄袭行为。</p>
            <p style="margin-top: 10px;">如有学习需求，欢迎交流探讨，但请尊重他人劳动成果。</p>
        </div>
        <p class="copyright-message" style="font-size: 14px; color: #999; margin-top: 25px;">© 2026 归途花店 · 保留所有权利</p>
        <button class="copyright-btn" onclick="closeCopyright()">我知道了</button>
    </div>
</div>
<script>
    function showCopyright() { document.getElementById('copyrightModal').classList.add('show'); }
    function closeCopyright() { document.getElementById('copyrightModal').classList.remove('show'); }
    document.addEventListener('DOMContentLoaded', function() {
        const modal = document.getElementById('copyrightModal');
        if (modal) { modal.addEventListener('click', function(e) { if (e.target === modal) closeCopyright(); }); }
    });

    // AJAX 检查手机号唯一性
    function checkTel() {
        var tel = document.getElementById('editTel').value;
        var hint = document.getElementById('telHint');
        if (!tel.match(/^1[3-9]\d{9}$/)) {
            hint.textContent = '请输入有效的11位手机号';
            hint.style.color = '#999';
            return;
        }
        var xhr = new XMLHttpRequest();
        xhr.open('GET', 'usercenter?action=checkTel&tel=' + encodeURIComponent(tel), true);
        xhr.onload = function() {
            var res = JSON.parse(xhr.responseText);
            hint.textContent = res.message;
            hint.style.color = res.available ? '#27ae60' : '#e74c3c';
        };
        xhr.send();
    }

    // AJAX 检查邮箱唯一性
    function checkEmail() {
        var email = document.getElementById('editEmail').value;
        var hint = document.getElementById('emailHint');
        if (!email.match(/^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/)) {
            hint.textContent = '请输入有效的邮箱地址';
            hint.style.color = '#999';
            return;
        }
        var xhr = new XMLHttpRequest();
        xhr.open('GET', 'usercenter?action=checkEmail&email=' + encodeURIComponent(email), true);
        xhr.onload = function() {
            var res = JSON.parse(xhr.responseText);
            hint.textContent = res.message;
            hint.style.color = res.available ? '#27ae60' : '#e74c3c';
        };
        xhr.send();
    }
</script>

<!-- 积分明细模态框 -->
<div class="modal fade" id="jfDetailModal" tabindex="-1">
  <div class="modal-dialog modal-dialog-scrollable">
    <div class="modal-content">
      <div class="modal-header" style="background:#e74c3c;color:white;">
        <h5 class="modal-title"><i class="bi bi-coin"></i> 积分明细</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body" style="padding:0;">
        <c:choose>
          <c:when test="${not empty jfLogs}">
            <div style="padding:15px;background:#f8f9fa;border-bottom:1px solid #eee;font-size:13px;color:#666;">
              当前积分余额：<strong style="color:#e74c3c;">${user.jf}</strong>
            </div>
            <c:forEach items="${jfLogs}" var="log">
              <div style="display:flex;justify-content:space-between;align-items:center;padding:14px 16px;border-bottom:1px solid #f0f0f0;">
                <div>
                  <div style="font-size:14px;color:#333;">${log.description}</div>
                  <div style="font-size:11px;color:#999;margin-top:2px;">
                    <fmt:formatDate value="${log.createTime}" pattern="yyyy-MM-dd HH:mm"/>
                  </div>
                </div>
                <div style="font-size:18px;font-weight:700;${log.amount > 0 ? 'color:#27ae60;' : 'color:#e74c3c;'}">
                  ${log.amount > 0 ? '+' : ''}${log.amount}
                </div>
              </div>
            </c:forEach>
          </c:when>
          <c:otherwise>
            <div style="text-align:center;padding:60px 20px;color:#999;">
              <i class="bi bi-inbox" style="font-size:40px;display:block;margin-bottom:10px;"></i>
              暂无积分记录，快去获取积分吧！
            </div>
          </c:otherwise>
        </c:choose>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">关闭</button>
      </div>
    </div>
  </div>
</div>

<!-- 积分规则模态框 -->
<div class="modal fade" id="jfRulesModal" tabindex="-1">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header" style="background:#e74c3c;color:white;">
        <h5 class="modal-title"><i class="bi bi-info-circle"></i> 积分规则</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body" style="padding:24px;">
        <h6 style="color:#e74c3c;margin-bottom:16px;font-weight:600;">📌 获取积分</h6>
        <table style="width:100%;border-collapse:collapse;font-size:14px;margin-bottom:20px;">
          <tr style="border-bottom:1px solid #eee;"><td style="padding:8px 4px;">新用户注册</td><td style="padding:8px 4px;color:#27ae60;font-weight:600;text-align:right;">+200</td></tr>
          <tr style="border-bottom:1px solid #eee;"><td style="padding:8px 4px;">每日首次登录</td><td style="padding:8px 4px;color:#27ae60;font-weight:600;text-align:right;">+5</td></tr>
          <tr style="border-bottom:1px solid #eee;"><td style="padding:8px 4px;">浏览商品（每件不重复）</td><td style="padding:8px 4px;color:#27ae60;font-weight:600;text-align:right;">+2</td></tr>
          <tr style="border-bottom:1px solid #eee;"><td style="padding:8px 4px;">首次添加收货地址</td><td style="padding:8px 4px;color:#27ae60;font-weight:600;text-align:right;">+50</td></tr>
          <tr style="border-bottom:1px solid #eee;"><td style="padding:8px 4px;">完善个人信息（首次）</td><td style="padding:8px 4px;color:#27ae60;font-weight:600;text-align:right;">+50</td></tr>
          <tr style="border-bottom:1px solid #eee;"><td style="padding:8px 4px;">更新个人信息</td><td style="padding:8px 4px;color:#27ae60;font-weight:600;text-align:right;">+10</td></tr>
          <tr style="border-bottom:1px solid #eee;"><td style="padding:8px 4px;">购物消费（每¥10积1分）</td><td style="padding:8px 4px;color:#27ae60;font-weight:600;text-align:right;">+1%</td></tr>
        </table>
        <h6 style="color:#e74c3c;margin-bottom:8px;font-weight:600;">📌 使用积分</h6>
        <table style="width:100%;border-collapse:collapse;font-size:14px;">
          <tr style="border-bottom:1px solid #eee;"><td style="padding:8px 4px;">积分抵扣</td><td style="padding:8px 4px;color:#e74c3c;font-weight:600;text-align:right;">100积分 = ¥1</td></tr>
          <tr style="border-bottom:1px solid #eee;"><td style="padding:8px 4px;">最高抵扣比例</td><td style="padding:8px 4px;color:#666;text-align:right;">订单金额 50%</td></tr>
        </table>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">关闭</button>
      </div>
    </div>
  </div>
</div>

<script>
function showCopyright() { document.getElementById('copyrightModal').classList.add('show'); }
function closeCopyright() { document.getElementById('copyrightModal').classList.remove('show'); }
function showJfDetail() { new bootstrap.Modal(document.getElementById('jfDetailModal')).show(); }
function showJfRules() { new bootstrap.Modal(document.getElementById('jfRulesModal')).show(); }
</script>
</body>
</html>