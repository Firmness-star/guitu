<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>购物车</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="css/common.css">
    <style>
        body { background: #f8f9fa; }

        .cart-item {
            background: white;
            border-radius: 10px;
            padding: 15px;
            margin-bottom: 15px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            display: flex;
            align-items: center;
        }

        .cart-item img {
            width: 80px;
            height: 80px;
            object-fit: cover;
            border-radius: 5px;
        }

        .item-check {
            width: 20px;
            height: 20px;
            margin-right: 15px;
            accent-color: var(--primary-red);
            cursor: pointer;
        }

        .price {
            color: var(--primary-red);
            font-weight: bold;
            font-size: 1.2rem;
        }

        .summary-box {
            background: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }

        .btn-red {
            background: var(--primary-red);
            color: white;
            width: 100%;
            padding: 12px;
            border: none;
            border-radius: 5px;
            font-weight: bold;
            text-decoration: none;
            display: block;
            text-align: center;
        }

        .btn-red:hover {
            background: var(--dark-red);
            color: white;
        }

        .btn-gray {
            background: #ccc;
            color: white;
            width: 100%;
            padding: 12px;
            border: none;
            border-radius: 5px;
            font-weight: bold;
        }

        .qty-input {
            width: 50px;
            text-align: center;
            border: 1px solid #ddd;
            border-radius: 3px;
        }

        .select-all-bar {
            background: white;
            border-radius: 10px;
            padding: 15px 20px;
            margin-bottom: 15px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .select-all-left {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .select-all-checkbox {
            width: 20px;
            height: 20px;
            accent-color: var(--primary-red);
            cursor: pointer;
        }

        .select-all-label {
            font-weight: 500;
            color: #333;
            cursor: pointer;
            user-select: none;
        }

        .select-actions {
            display: flex;
            gap: 10px;
        }

        .btn-sm-action {
            padding: 6px 16px;
            border: 1px solid #ddd;
            background: #f8f9fa;
            color: #666;
            border-radius: 4px;
            font-size: 13px;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.2s;
        }

        .btn-sm-action:hover {
            background: var(--primary-red);
            color: white;
            border-color: var(--primary-red);
        }
    </style>
</head>
<body>

<div class="container mt-4">
    <h3 class="mb-4"><i class="bi bi-cart3"></i> 我的购物车</h3>

    <!-- 根据购物车是否为空展示不同内容 -->
    <c:choose>
        <c:when test="${empty sessionScope.cart}">
            <div class="text-center py-5">
                <i class="bi bi-cart-x" style="font-size: 60px; color: #ddd;"></i>
                <p class="mt-3">购物车是空的</p>
                <a href="products" class="btn btn-danger">去购物</a>
            </div>
        </c:when>

        <c:otherwise>
            <div class="row">
                <div class="col-md-8">

                    <!-- 全选/全不选控制栏：根据当前选中状态动态切换点击行为 -->
                    <div class="select-all-bar">
                        <div class="select-all-left">
                            <c:set var="allSelected" value="true"/>
                            <c:forEach items="${sessionScope.cart}" var="item">
                                <c:if test="${!item.selected}">
                                    <c:set var="allSelected" value="false"/>
                                </c:if>
                            </c:forEach>

                            <c:choose>
                                <c:when test="${allSelected && fn:length(sessionScope.cart) > 0}">
                                    <input type="checkbox" class="select-all-checkbox"
                                           checked onclick="location.href='cart?action=unselectAll'">
                                    <label class="select-all-label" onclick="location.href='cart?action=unselectAll'">
                                        全选（已选${selectedNum}件 / 共${totalNum}件）
                                    </label>
                                </c:when>
                                <c:otherwise>
                                    <input type="checkbox" class="select-all-checkbox"
                                           onclick="location.href='cart?action=selectAll'">
                                    <label class="select-all-label" onclick="location.href='cart?action=selectAll'">
                                        全选（已选${selectedNum}件 / 共${totalNum}件）
                                    </label>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <c:forEach items="${sessionScope.cart}" var="item">
                        <div class="cart-item">
                            <!-- 商品选中状态切换表单 -->
                            <form action="cart" method="post" style="margin: 0;">
                                <input type="hidden" name="action" value="select">
                                <input type="hidden" name="productId" value="${item.productId}">
                                <input type="checkbox" class="item-check" name="checked" value="on"
                                    ${item.selected ? 'checked' : ''}
                                       onchange="this.form.submit()">
                            </form>

                            <img src="${item.productPic}" class="me-3" onerror="this.src='https://via.placeholder.com/80'">

                            <div style="flex: 1;">
                                <h5>${item.productName}</h5>
                                <div class="price">¥${item.productPrice}</div>

                                <!-- 商品数量增减表单：通过 JS 简单处理后提交 -->
                                <form action="cart" method="post" class="mt-2" style="display: inline;">
                                    <input type="hidden" name="action" value="update">
                                    <input type="hidden" name="productId" value="${item.productId}">
                                    <button type="button" onclick="var n=this.nextElementSibling; n.value=parseInt(n.value)-1; if(n.value<1)n.value=1; this.parentNode.submit()">-</button>
                                    <input type="text" name="quantity" value="${item.quantity}" class="qty-input" readonly>
                                    <button type="button" onclick="var n=this.previousElementSibling; n.value=parseInt(n.value)+1; this.parentNode.submit()">+</button>
                                </form>
                            </div>

                            <div class="text-end">
                                <div class="price">¥<fmt:formatNumber value="${item.productPrice * item.quantity}" pattern="#0.00"/></div>
                                <a href="cart?action=remove&productId=${item.productId}" class="text-muted small" onclick="return confirm('确定删除该商品？')">删除</a>
                            </div>
                        </div>
                    </c:forEach>

                    <div class="text-end">
                        <a href="cart?action=clear" class="text-danger small" onclick="return confirm('确定清空购物车？')">清空购物车</a>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="summary-box">
                        <h5 class="mb-3">订单摘要</h5>

                        <div class="d-flex justify-content-between mb-2">
                            <span>商品总数：</span>
                            <span>${totalNum} 件</span>
                        </div>

                        <div class="d-flex justify-content-between mb-2">
                            <span>选中数量：</span>
                            <span class="text-danger fw-bold">${selectedNum} 件</span>
                        </div>

                        <hr>

                        <div class="d-flex justify-content-between mb-3">
                            <span class="h5">总计：</span>
                            <span class="price h4">¥<fmt:formatNumber value="${totalMoney}" pattern="#0.00"/></span>
                        </div>

                        <!-- 结算按钮：仅在有选中商品时可用 -->
                        <c:choose>
                            <c:when test="${totalMoney > 0}">
                                <a href="checkout" class="btn-red">去结算（${selectedNum}件）</a>
                            </c:when>
                            <c:otherwise>
                                <button class="btn-gray" disabled>请选择至少一件商品</button>
                            </c:otherwise>
                        </c:choose>

                        <a href="index.jsp" class="btn btn-outline-secondary w-100 mt-2">继续购物</a>
                    </div>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

</body>
</html>