<%-- C:\Users\guitu\OneDrive\Desktop\guitushop\web\orders.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- 检查用户登录状态，未登录则重定向至登录页并携带当前页面标识 -->
<c:if test="${empty sessionScope.username}">
    <jsp:forward page="login.jsp?redirect=orders"/>
</c:if>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的订单 - 花店商城</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <style>
        :root {
            --primary-red: #e74c3c;
            --dark-red: #c0392b;
            --primary-green: #27ae60;
            --bg-gray: #f5f5f5;
        }

        body {
            font-family: "PingFang SC", "Microsoft YaHei", sans-serif;
            background: var(--bg-gray);
        }

        /* 优化后的导航栏 */
        .navbar {
            background: #fff;
            padding: 0;
            position: sticky;
            top: 0;
            z-index: 1000;
            box-shadow: 0 2px 12px rgba(0,0,0,0.08);
            border-bottom: none;
        }
        
        .navbar-brand {
            font-weight: 700;
            font-size: 22px;
            letter-spacing: 2px;
            background: linear-gradient(135deg, var(--primary-red) 0%, #ff6b6b 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            transition: transform 0.2s;
            cursor: pointer;
        }
        
        .navbar-brand:hover {
            transform: scale(1.05);
        }
        
        .navbar-brand i {
            -webkit-text-fill-color: var(--primary-red);
        }
        
        /* 版权说明模态框 */
        .copyright-modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.5);
            z-index: 10000;
            align-items: center;
            justify-content: center;
        }
        .copyright-modal.show {
            display: flex;
        }
        .copyright-content {
            background: white;
            padding: 50px;
            border-radius: 16px;
            text-align: center;
            max-width: 550px;
            width: 90%;
            animation: modalSlideIn 0.3s ease;
            box-shadow: 0 20px 60px rgba(0,0,0,0.2);
        }
        @keyframes modalSlideIn {
            from { opacity: 0; transform: translateY(-20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .copyright-icon {
            font-size: 64px;
            margin-bottom: 20px;
        }
        .copyright-title {
            font-size: 28px;
            background: linear-gradient(135deg, var(--primary-red) 0%, #ff6b6b 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 20px;
            font-weight: 700;
        }
        .copyright-divider {
            width: 60px;
            height: 3px;
            background: linear-gradient(90deg, var(--primary-red) 0%, #ff6b6b 100%);
            margin: 0 auto 20px;
            border-radius: 2px;
        }
        .copyright-message {
            color: #666;
            font-size: 16px;
            line-height: 1.8;
            margin-bottom: 15px;
        }
        .copyright-warning {
            background: linear-gradient(135deg, #fff5f5 0%, #ffffff 100%);
            border-left: 4px solid var(--primary-red);
            padding: 15px 20px;
            border-radius: 8px;
            margin: 20px 0;
            text-align: left;
        }
        .copyright-warning p {
            color: #666;
            font-size: 14px;
            margin: 0;
            line-height: 1.6;
        }
        .copyright-warning strong {
            color: var(--primary-red);
        }
        .copyright-btn {
            background: linear-gradient(135deg, var(--primary-red) 0%, #ff6b6b 100%);
            color: white;
            border: none;
            padding: 14px 50px;
            border-radius: 8px;
            font-size: 16px;
            cursor: pointer;
            transition: all 0.3s;
            margin-top: 20px;
            font-weight: 600;
        }
        .copyright-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(231, 76, 60, 0.4);
        }
        
        .nav-link {
            color: #555 !important;
            transition: all 0.2s;
            padding: 6px 12px !important;
            border-radius: 6px;
        }
        
        .nav-link:hover {
            color: var(--primary-red) !important;
            background: #fff5f5;
        }

        .orders-container {
            max-width: 1000px;
            margin: 0 auto;
            padding: 30px 20px;
        }
        
        .page-title {
            font-size: 24px;
            font-weight: 600;
            color: #333;
            margin-bottom: 25px;
            display: flex;
            align-items: center;
        }
        
        .page-title i {
            color: var(--primary-red);
            margin-right: 10px;
        }
        
        .page-title small {
            margin-left: 12px;
            font-weight: 400;
        }

        .order-card {
            background: white;
            border-radius: 12px;
            margin-bottom: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            overflow: hidden;
        }

        .order-header {
            background: #f8f9fa;
            padding: 15px 20px;
            border-bottom: 1px solid #eee;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .order-id {
            font-weight: 600;
            color: #333;
            font-size: 14px;
        }

        .order-time {
            color: #999;
            font-size: 13px;
            margin-left: 15px;
        }

        .status-badge {
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 500;
        }

        .status-waiting {
            background: #fff3cd;
            color: #856404;
        }
        .status-paid {
            background: #d1ecf1;
            color: #0c5460;
        }
        .status-shipped {
            background: #e2e3f3;
            color: #383d7d;
        }
        .status-completed {
            background: #d4edda;
            color: #155724;
        }
        .status-cancelled {
            background: #f8d7da;
            color: #721c24;
        }

        .order-items {
            padding: 20px;
        }

        .item-row {
            display: flex;
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px solid #f0f0f0;
        }

        .item-row:last-child {
            border-bottom: none;
        }

        .item-img {
            width: 70px;
            height: 70px;
            object-fit: cover;
            border-radius: 8px;
            margin-right: 15px;
            border: 1px solid #eee;
            transition: transform 0.2s;
        }
        
        .item-img:hover {
            transform: scale(1.05);
        }

        .item-info {
            flex: 1;
        }

        .item-name {
            font-weight: 500;
            color: #333;
            margin-bottom: 4px;
        }

        .item-price {
            color: #666;
            font-size: 13px;
        }

        .item-qty {
            color: #999;
            font-size: 13px;
            text-align: center;
            min-width: 60px;
        }

        .item-subtotal {
            color: var(--primary-red);
            font-weight: 600;
            min-width: 80px;
            text-align: right;
        }

        .order-footer {
            background: #fafafa;
            padding: 15px 20px;
            border-top: 1px solid #eee;
        }

        .receiver-info {
            color: #666;
            font-size: 13px;
            margin-bottom: 10px;
        }

        .receiver-info i {
            color: #999;
            margin-right: 5px;
        }

        .order-total {
            display: flex;
            justify-content: flex-end;
            align-items: center;
            padding-top: 10px;
            border-top: 1px dashed #ddd;
        }

        .total-label {
            color: #666;
            margin-right: 10px;
        }

        .total-amount {
            color: var(--primary-red);
            font-size: 20px;
            font-weight: bold;
        }

        .empty-state {
            text-align: center;
            padding: 80px 20px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }

        .empty-icon {
            font-size: 80px;
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 20px;
        }

        .empty-text {
            color: #666;
            margin-bottom: 10px;
            font-size: 18px;
            font-weight: 500;
        }

        .btn-action {
            padding: 8px 18px;
            border-radius: 6px;
            font-size: 13px;
            margin-left: 10px;
            text-decoration: none;
            display: inline-block;
            border: none;
            cursor: pointer;
            transition: all 0.2s;
            font-weight: 500;
        }

        .btn-pay {
            background: var(--primary-red);
            color: white;
        }

        .btn-pay:hover {
            background: var(--dark-red);
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(231, 76, 60, 0.3);
        }

        .btn-cancel {
            background: #6c757d;
            color: white;
        }

        .btn-cancel:hover {
            background: #5a6268;
            color: white;
            transform: translateY(-2px);
        }

        .btn-confirm {
            background: var(--primary-green);
            color: white;
        }

        .btn-confirm:hover {
            background: #218838;
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(39, 174, 96, 0.3);
        }

        @media (max-width: 576px) {
            .order-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
            }

            .item-row {
                flex-wrap: wrap;
            }

            .item-subtotal {
                width: 100%;
                text-align: left;
                margin-top: 5px;
                padding-left: 75px;
            }
        }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg">
    <div class="container">
        <a class="navbar-brand" href="javascript:void(0)" onclick="showCopyright()">
            🌸 归途
        </a>
        <div class="collapse navbar-collapse">
            <ul class="navbar-nav ms-auto align-items-center">
                <li class="nav-item">
                    <span class="nav-link">欢迎，${sessionScope.username}</span>
                </li>
                <c:if test="${param.ref == 'uc'}">
                <li class="nav-item">
                    <a class="nav-link" href="usercenter">
                        <i class="bi bi-person-circle"></i> 个人中心
                    </a>
                </li>
                </c:if>
                <li class="nav-item">
                    <a class="nav-link" href="index.jsp">
                        <i class="bi bi-shop"></i> 继续购物
                    </a>
                </li>
                <c:if test="${sessionScope.userRole == '管理员'}">
                <li class="nav-item">
                    <a class="nav-link" href="admin/index" style="color:var(--primary-red);font-weight:600;">
                        <i class="bi bi-gear"></i> 管理中心
                    </a>
                </li>
                </c:if>
            </ul>
        </div>
    </div>
</nav>

<div class="orders-container">
    <h4 class="page-title">
        <i class="bi bi-receipt"></i> 我的订单
        <small class="text-muted">共 ${fn:length(orderList)} 个订单</small>
    </h4>

    <!-- 展示操作成功或失败的提示信息 -->
    <c:if test="${not empty sessionScope.message}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
                ${sessionScope.message}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <c:remove var="message" scope="session"/>
    </c:if>

    <c:if test="${not empty sessionScope.error}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                ${sessionScope.error}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <c:remove var="error" scope="session"/>
    </c:if>

    <c:choose>
        <c:when test="${empty orderList}">
            <div class="empty-state">
                <div class="empty-icon">
                    <i class="bi bi-inbox"></i>
                </div>
                <h5 class="empty-text">暂无订单</h5>
                <p class="text-muted mb-4">您还没有下单，快去选购心仪的商品吧</p>
                <a href="index.jsp" class="btn btn-danger">
                    <i class="bi bi-shop"></i> 去购物
                </a>
            </div>
        </c:when>

        <c:otherwise>
            <c:forEach items="${orderList}" var="order">
                <div class="order-card">
                    <!-- 订单头部：展示订单号、创建时间及当前状态 -->
                    <div class="order-header">
                        <div>
                            <span class="order-id">订单号：${order.orderId}</span>
                            <span class="order-time">
                                <i class="bi bi-clock"></i>
                                <fmt:formatDate value="${order.createTime}" pattern="yyyy-MM-dd HH:mm"/>
                            </span>
                        </div>
                        <div class="d-flex align-items-center">
                            <!-- 根据订单状态展示不同的徽章及可执行的操作按钮 -->
                            <c:choose>
                                <c:when test="${order.status == '待付款'}">
                                    <span class="status-badge status-waiting">
                                        <i class="bi bi-hourglass-split"></i> ${order.status}
                                    </span>
                                    <a href="payment?orderId=${order.orderId}" class="btn-action btn-pay">立即支付</a>
                                    <form action="orderstatus" method="post" style="display: inline;">
                                        <input type="hidden" name="orderId" value="${order.orderId}">
                                        <input type="hidden" name="action" value="cancel">
                                        <button type="submit" class="btn-action btn-cancel" onclick="return confirm('确定要取消订单吗？')">取消订单</button>
                                    </form>
                                </c:when>
                                <c:when test="${order.status == '已付款'}">
                                    <span class="status-badge status-paid">
                                        <i class="bi bi-check-circle"></i> ${order.status}
                                    </span>
                                </c:when>
                                <c:when test="${order.status == '已发货'}">
                                    <span class="status-badge status-shipped">
                                        <i class="bi bi-truck"></i> ${order.status}
                                    </span>
                                    <c:if test="${not empty order.wlNo}">
                                        <div style="font-size:12px;color:#666;margin-top:4px;">物流单号：${order.wlNo}</div>
                                    </c:if>
                                    <form action="orderstatus" method="post" style="display: inline;">
                                        <input type="hidden" name="orderId" value="${order.orderId}">
                                        <input type="hidden" name="action" value="confirm">
                                        <button type="submit" class="btn-action btn-confirm" onclick="return confirm('确认已收到商品？')">确认收货</button>
                                    </form>
                                </c:when>
                                <c:when test="${order.status == '已收货'}">
                                    <span class="status-badge status-completed">
                                        <i class="bi bi-box-seam"></i> ${order.status}
                                    </span>
                                </c:when>
                                <c:when test="${order.status == '已完成'}">
                                    <span class="status-badge status-completed">
                                        <i class="bi bi-check-all"></i> ${order.status}
                                    </span>
                                </c:when>
                                <c:when test="${order.status == '已取消'}">
                                    <span class="status-badge status-cancelled">
                                        <i class="bi bi-x-circle"></i> ${order.status}
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="status-badge bg-secondary text-white">${order.status}</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <!-- 订单商品列表：展示图片、名称、单价、数量及小计 -->
                    <div class="order-items">
                        <c:forEach items="${order.items}" var="item">
                            <div class="item-row">
                                <img src="${item.productPic}" alt="${item.productName}"
                                     class="item-img" onerror="this.src='https://via.placeholder.com/60?text=暂无图'">
                                <div class="item-info">
                                    <div class="item-name">${item.productName}</div>
                                    <div class="item-price">¥<fmt:formatNumber value="${item.productPrice}" pattern="#0.00"/></div>
                                </div>
                                <div class="item-qty">×${item.quantity}</div>
                                <div class="item-subtotal">
                                    ¥<fmt:formatNumber value="${item.subtotal}" pattern="#0.00"/>
                                </div>
                            </div>
                        </c:forEach>
                    </div>

                    <!-- 订单底部：展示收货信息及实付总金额 -->
                    <div class="order-footer">
                        <div class="receiver-info">
                            <i class="bi bi-geo-alt"></i>
                            收货人：${order.receiverName} ${order.receiverPhone}
                            <br>
                            <i class="bi bi-house"></i>
                            地址：${order.receiverAddress}
                            <c:if test="${not empty order.remark}">
                                <br>
                                <i class="bi bi-chat-left-text"></i>
                                备注：${order.remark}
                            </c:if>
                        </div>
                        <div class="order-total">
                            <span class="total-label">共 ${order.totalCount} 件商品，实付金额：</span>
                            <span class="total-amount">
                                ¥<fmt:formatNumber value="${order.totalAmount}" pattern="#0.00"/>
                            </span>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </c:otherwise>
    </c:choose>
</div>

<!-- 版权说明模态框 -->
<div class="copyright-modal" id="copyrightModal">
    <div class="copyright-content">
        <div class="copyright-icon">🌸</div>
        <h2 class="copyright-title">关于「归途」</h2>
        <div class="copyright-divider"></div>
        <p class="copyright-message">
            「归途花店」是一款基于 Java Web 技术开发的电商学习项目
        </p>
        <div class="copyright-warning">
            <p><strong>⚠️ 声明：</strong>本项目仅供个人学习与技术研究使用，所有代码、设计及内容版权归开发者本人所有。</p>
            <p style="margin-top: 10px;"><strong>🚫 请勿抄袭：</strong>未经授权，任何人不得将本项目或其部分内容用于商业目的、课程作业提交或任何形式的抄袭行为。</p>
            <p style="margin-top: 10px;">如有学习需求，欢迎交流探讨，但请尊重他人劳动成果。</p>
        </div>
        <p class="copyright-message" style="font-size: 14px; color: #999; margin-top: 25px;">
            © 2026 归途花店 · 保留所有权利
        </p>
        <button class="copyright-btn" onclick="closeCopyright()">我知道了</button>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // 显示版权说明模态框
    function showCopyright() {
        document.getElementById('copyrightModal').classList.add('show');
    }

    // 关闭版权说明模态框
    function closeCopyright() {
        document.getElementById('copyrightModal').classList.remove('show');
    }

    // 点击模态框背景关闭
    document.addEventListener('DOMContentLoaded', function() {
        const modal = document.getElementById('copyrightModal');
        if (modal) {
            modal.addEventListener('click', function(e) {
                if (e.target === modal) {
                    closeCopyright();
                }
            });
        }
    });
</script>
</body>
</html>
