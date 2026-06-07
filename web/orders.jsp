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
    <link rel="stylesheet" href="css/common.css">
    <style>
        body { background: var(--bg-gray); }
        
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

        .toggle-indicator {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 28px;
            height: 28px;
            border-radius: 50%;
            background: #f0f0f0;
            transition: all 0.3s;
            font-size: 14px;
            color: #666;
        }

        .order-header:hover .toggle-indicator {
            background: var(--primary-red);
            color: white;
        }

        .order-header:hover {
            background: #f5f5f5;
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

<jsp:include page="common/navbar.jsp"/>

<div class="orders-container">
    <h4 class="page-title">
        <i class="bi bi-receipt"></i> 我的订单
        <small class="text-muted">共 ${fn:length(orderList)} 个订单</small>
    </h4>

    <!-- 状态筛选栏 -->
    <div style="background:white;border-radius:12px;padding:15px 20px;margin-bottom:20px;box-shadow:0 2px 8px rgba(0,0,0,0.05);">
        <form method="get" action="orders" style="display:flex;gap:10px;align-items:center;flex-wrap:wrap;">
            <select class="form-select" name="status" style="width:auto;min-width:140px;" onchange="this.form.submit()">
                <option value="">全部订单</option>
                <option value="待付款" ${statusFilter == '待付款' ? 'selected' : ''}>待付款</option>
                <option value="已付款" ${statusFilter == '已付款' ? 'selected' : ''}>已付款</option>
                <option value="已发货" ${statusFilter == '已发货' ? 'selected' : ''}>已发货</option>
                <option value="已收货" ${statusFilter == '已收货' ? 'selected' : ''}>已收货</option>
                <option value="已取消" ${statusFilter == '已取消' ? 'selected' : ''}>已取消</option>
            </select>
            <c:if test="${not empty statusFilter}">
                <a href="orders" class="btn btn-sm btn-outline-secondary">清除筛选</a>
            </c:if>
        </form>
    </div>

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
                <a href="index" class="btn btn-danger">
                    <i class="bi bi-shop"></i> 去购物
                </a>
            </div>
        </c:when>

        <c:otherwise>
            <c:forEach items="${orderList}" var="order" varStatus="os">
                <div class="order-card">
                    <!-- 订单头部：展示订单号、创建时间及当前状态，含展开/收起按钮 -->
                    <div class="order-header" style="cursor:pointer;" onclick="toggleOrder('orderDetail_${os.index}')">
                        <div>
                            <span class="order-id">订单号：${order.orderId}</span>
                            <span class="order-time">
                                <i class="bi bi-clock"></i>
                                <fmt:formatDate value="${order.createTime}" pattern="yyyy-MM-dd HH:mm"/>
                            </span>
                        </div>
                        <div class="d-flex align-items-center gap-2">
                            <!-- 根据订单状态展示不同的徽章及可执行的操作按钮 -->
                            <span class="toggle-indicator" id="toggleIcon_${os.index}">
                                <i class="bi bi-chevron-down"></i>
                            </span>
                            <c:choose>
                                <c:when test="${order.status == '待付款'}">
                                    <span class="status-badge status-waiting">
                                        <i class="bi bi-hourglass-split"></i> ${order.status}
                                    </span>
                                    <a href="payment?orderId=${order.orderId}" class="btn-action btn-pay">立即支付</a>
                                    <form action="orderstatus" method="post" style="display: inline;">
                                        <input type="hidden" name="orderId" value="${order.orderId}">
                                        <input type="hidden" name="action" value="cancel">
                                        <input type="hidden" name="cancelSource" value="customer">
                                        <button type="submit" class="btn-action btn-cancel" onclick="return confirm('确定要取消订单吗？')">取消订单</button>
                                    </form>
                                </c:when>
                                <c:when test="${order.status == '已付款'}">
                                    <span class="status-badge status-paid">
                                        <i class="bi bi-check-circle"></i> ${order.status}
                                    </span>
                                    <form action="orderstatus" method="post" style="display: inline;">
                                        <input type="hidden" name="orderId" value="${order.orderId}">
                                        <input type="hidden" name="action" value="cancel">
                                        <input type="hidden" name="cancelSource" value="customer">
                                        <button type="submit" class="btn-action btn-cancel" onclick="return confirm('确定要取消订单吗？')">取消订单</button>
                                    </form>
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
                                        <i class="bi bi-box-seam"></i> 已收货
                                    </span>
                                </c:when>
                                <c:when test="${order.status == '已完成'}">
                                    <span class="status-badge status-completed">
                                        <i class="bi bi-check-all"></i> 已收货
                                    </span>
                                </c:when>
                                <c:when test="${order.status == '已取消'}">
                                    <c:choose>
                                        <c:when test="${fn:contains(order.remark, '[商家取消]') or fn:contains(order.remark, '[管理员取消]')}">
                                            <span class="status-badge status-cancelled">
                                                <i class="bi bi-x-circle"></i> 商家取消
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-badge status-cancelled">
                                                <i class="bi bi-x-circle"></i> 客户取消
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </c:when>
                                <c:otherwise>
                                    <span class="status-badge bg-secondary text-white">${order.status}</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <!-- 订单详情（可折叠，默认展开第一个，其余收起） -->
                    <div class="collapse ${os.index == 0 ? 'show' : ''}" id="orderDetail_${os.index}">
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
                </div>
            </c:forEach>
        </c:otherwise>
    </c:choose>
</div>

    });
</script>
</body>
</html>
