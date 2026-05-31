<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!-- 若商品信息为空，则转发至首页 -->
<c:if test="${empty product}">
  <jsp:forward page="/index"/>
</c:if>

<!-- 获取项目上下文路径 -->
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<!-- 计算购物车中商品的总数量，用于导航栏角标展示 -->
<c:set var="cartItemCount" value="0"/>
<c:if test="${not empty sessionScope.cart}">
  <c:forEach items="${sessionScope.cart}" var="item">
    <c:set var="cartItemCount" value="${cartItemCount + item.quantity}"/>
  </c:forEach>
</c:if>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${product.name} - 商品详情</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
  <link rel="stylesheet" href="css/common.css">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { background: #fff; }
    a { text-decoration: none; }

    .navbar { border-bottom: 1px solid #e0e0e0; padding: 0; background: #fff; }
    .nav-container { max-width: 1200px; margin: 0 auto; padding: 0 15px; display: flex; align-items: center; justify-content: space-between; height: 60px; }
    .brand { font-weight: 700; color: #333; font-size: 22px; letter-spacing: 2px; background: linear-gradient(135deg, var(--primary-red) 0%, #ff6b6b 100%); -webkit-background-clip: text; -webkit-text-fill-color: transparent; transition: transform 0.2s; cursor: pointer; }
    .brand:hover { transform: scale(1.05); }

    .nav-links { display: flex; gap: 24px; list-style: none; align-items: center; }
    .nav-links a { color: #666; text-decoration: none; font-size: 14px; transition: color 0.2s; }
    .nav-links a:hover { color: var(--primary-red); }

    .search-box { display: flex; }
    .search-box input { border: 1px solid #ddd; padding: 6px 12px; font-size: 14px; outline: none; width: 200px; }
    .search-box input:focus { border-color: var(--primary-red); }
    .search-box button { border: 1px solid #ddd; background: #f5f5f5; padding: 6px 16px; cursor: pointer; font-size: 14px; }
    .search-box button:hover { background: #e8e8e8; }

    .cart-badge { background: var(--primary-green); color: white; font-size: 11px; padding: 2px 6px; border-radius: 50%; margin-left: 4px; display: inline-block; min-width: 18px; text-align: center; }

    .main { max-width: 1200px; margin: 30px auto 50px; padding: 0 15px; }

    .breadcrumb {
      padding: 15px 0; 
      font-size: 14px; 
      color: #666;
    }
    .breadcrumb a { color: #666; text-decoration: none; }
    .breadcrumb a:hover { color: var(--primary-red); }
    .breadcrumb span { margin: 0 8px; color: #999; }

    .product-detail-container {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 40px;
      margin-top: 20px;
      padding: 30px;
      border: 1px solid #e0e0e0;
      border-radius: 8px;
      background: white;
    }

    .product-image-section { position: relative; }

    .product-main-image {
      width: 100%;
      aspect-ratio: 1/1;
      object-fit: cover;
      border-radius: 8px;
      border: 1px solid #e0e0e0;
    }

    .product-info-section {
      display: flex;
      flex-direction: column;
      gap: 20px;
    }

    .product-title {
      font-size: 24px;
      font-weight: 600;
      color: #333;
      line-height: 1.4;
    }

    .product-price-section {
      background: #f8f9fa;
      padding: 20px;
      border-radius: 8px;
    }

    .price-label { font-size: 14px; color: #666; margin-bottom: 8px; }
    .current-price { font-size: 28px; color: var(--primary-red); font-weight: 600; }

    .product-description {
      font-size: 14px;
      color: #666;
      line-height: 1.6;
    }

    .stock-status {
      font-size: 14px;
      padding: 8px 12px;
      border-radius: 4px;
      display: inline-block;
    }
    .stock-low { background: #fff5f5; color: var(--primary-red); border: 1px solid #ffebee; }
    .stock-enough { background: #f0f9f0; color: var(--primary-green); border: 1px solid #e8f5e8; }

    .quantity-selector {
      display: flex;
      align-items: center;
      gap: 15px;
    }
    .quantity-label { font-size: 14px; color: #666; font-weight: 500; }

    .quantity-controls {
      display: flex;
      align-items: center;
      border: 1px solid #ddd;
      border-radius: 4px;
      overflow: hidden;
    }

    .quantity-btn {
      width: 40px;
      height: 40px;
      border: none;
      background: #f5f5f5;
      cursor: pointer;
      font-size: 18px;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .quantity-btn:hover { background: #e0e0e0; }

    .quantity-input {
      width: 60px;
      height: 40px;
      border: none;
      text-align: center;
      font-size: 16px;
      outline: none;
    }

    .action-buttons {
      display: flex;
      gap: 15px;
      margin-top: 10px;
    }

    .action-buttons form { flex: 1; }

    .add-cart-btn {
      display: block !important;
      width: 100% !important;
      background: #e74c3c !important;
      color: #fff !important;
      -webkit-text-fill-color: #fff !important;
      border: none !important;
      padding: 14px 20px !important;
      font-size: 16px !important;
      border-radius: 6px !important;
      cursor: pointer !important;
      font-weight: 500 !important;
      text-align: center !important;
      min-height: 48px !important;
      line-height: 1.4 !important;
    }
    .add-cart-btn:hover { background: #c0392b !important; }
    .add-cart-btn:disabled { background: #ccc !important; color: #999 !important; cursor: not-allowed !important; }

    .buy-now-btn {
      display: block !important;
      width: 100% !important;
      background: #27ae60 !important;
      color: #fff !important;
      -webkit-text-fill-color: #fff !important;
      border: none !important;
      padding: 14px 20px !important;
      font-size: 16px !important;
      border-radius: 6px !important;
      cursor: pointer !important;
      font-weight: 500 !important;
      text-align: center !important;
      min-height: 48px !important;
      line-height: 1.4 !important;
    }
    .buy-now-btn:hover { background: #219a52 !important; }
    .buy-now-btn:disabled { background: #ccc !important; color: #999 !important; cursor: not-allowed !important; }

    .related-products {
      margin-top: 50px;
      padding: 30px;
      border: 1px solid #e0e0e0;
      border-radius: 8px;
      background: white;
    }

    .section-title {
      font-size: 20px;
      font-weight: 600;
      color: #333;
      margin-bottom: 25px;
      padding-bottom: 15px;
      border-bottom: 2px solid #e0e0e0;
    }

    .products-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
      gap: 20px;
    }

    .product-card {
      border: 1px solid #e0e0e0;
      border-radius: 8px;
      overflow: hidden;
      transition: all 0.3s ease;
      background: white;
    }
    .product-card:hover {
      transform: translateY(-4px);
      box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    }

    .product-image-wrapper { position: relative; overflow: hidden; aspect-ratio: 4/3; }
    .product-image { width: 100%; height: 100%; object-fit: cover; transition: transform 0.4s ease; }
    .product-card:hover .product-image { transform: scale(1.05); }

    .product-content { padding: 15px; text-align: center; }
    .product-name { font-size: 14px; font-weight: 500; color: #333; margin-bottom: 8px; height: 40px; overflow: hidden; text-overflow: ellipsis; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; }
    .product-price { font-size: 16px; color: var(--primary-red); font-weight: 600; margin-bottom: 8px; }
    .product-sales { font-size: 12px; color: #999; }

    .product-stock { font-size: 12px; color: #999; margin-bottom: 15px; }
    .stock-low-text { color: var(--primary-red); font-weight: 500; }
    .stock-enough-text { color: var(--primary-green); }

    .add-cart-form { width: 100%; }
    .add-cart-form-btn {
      background: var(--primary-red);
      color: white;
      border: none;
      padding: 8px 20px;
      font-size: 14px;
      width: 100%;
      cursor: pointer;
      transition: background 0.2s;
    }
    .add-cart-form-btn:hover { background: var(--dark-red); }
    .add-cart-form-btn:disabled { background: #ccc; cursor: not-allowed; }

    .footer { background: #f5f5f5; padding: 40px 0; margin-top: 50px; }
    .footer-content { max-width: 1200px; margin: 0 auto; padding: 0 15px; display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 30px; }
    .footer-title { font-size: 16px; font-weight: 600; color: #333; margin-bottom: 20px; }
    .footer-links { list-style: none; }
    .footer-links li { margin-bottom: 10px; }
    .footer-links a { color: #666; font-size: 13px; text-decoration: none; transition: color 0.2s; }
    .footer-links a:hover { color: var(--primary-red); }
    .qr-code { width: 100px; height: 100px; }

    /* 评论模块 */
    .comment-section { margin-top: 30px; padding: 30px; border: 1px solid #e0e0e0; border-radius: 8px; background: white; }
    .comment-stats { display: flex; align-items: center; gap: 16px; margin-bottom: 20px; padding-bottom: 20px; border-bottom: 1px solid #eee; }
    .comment-avg { font-size: 36px; font-weight: bold; color: var(--primary-red); }
    .comment-count { color: #666; font-size: 14px; }
    .comment-form-row { display: flex; gap: 12px; margin-bottom: 16px; align-items: flex-end; }
    .comment-form-row textarea { flex: 1; border: 1px solid #ddd; border-radius: 6px; padding: 12px; font-size: 14px; outline: none; resize: vertical; min-height: 60px; font-family: inherit; }
    .comment-form-row textarea:focus { border-color: var(--primary-red); }
    .comment-item { padding: 16px 0; border-bottom: 1px solid #f0f0f0; }
    .comment-item:last-child { border-bottom: none; }
    .comment-header { display: flex; justify-content: space-between; margin-bottom: 8px; }
    .comment-user { font-weight: 600; color: #333; }
    .comment-time { font-size: 12px; color: #999; }
    .comment-content { font-size: 14px; color: #555; line-height: 1.6; }
    .comment-rating { color: #f39c12; font-size: 13px; }
    .rating-select { display: flex; gap: 4px; direction: rtl; }
    .rating-select input { display: none; }
    .rating-select label { font-size: 20px; color: #ddd; cursor: pointer; transition: color 0.2s; }
    .rating-select label:hover,
    .rating-select label:hover ~ label,
    .rating-select input:checked ~ label { color: #f39c12; }

    @media (max-width: 768px) {
      .product-detail-container { grid-template-columns: 1fr; gap: 30px; padding: 20px; }
      .action-buttons { flex-direction: column; }
      .products-grid { grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); }
    }
  </style>
</head>
<body>

<nav class="navbar">
  <div class="nav-container">
    <a class="brand" href="javascript:void(0)" onclick="showCopyright()"> 归途</a>
    <ul class="nav-links">
      <li><a href="${ctx}/index">首页</a></li>
      <li>
        <form class="search-box" action="${ctx}/index" method="get">
          <input type="hidden" name="action" value="search">
          <input type="search" name="keyword" placeholder="搜索商品..." required>
          <button type="submit">查询</button>
        </form>
      </li>
      <li>
        <c:choose>
          <c:when test="${not empty sessionScope.username}">
            <a href="${ctx}/logout">退出(${sessionScope.username})</a>
          </c:when>
          <c:otherwise>
            <a href="${ctx}/login.jsp">登录</a>
          </c:otherwise>
        </c:choose>
      </li>
      <li>
        <c:if test="${empty sessionScope.username}">
          <a href="${ctx}/reg.jsp">注册</a>
        </c:if>
      </li>
      <li class="nav-item">
        <a class="nav-link" href="${ctx}/cart">
          我的购物车<span class="cart-badge">${cartItemCount > 0 ? cartItemCount : '0'}</span>
        </a>
      </li>
      <c:if test="${not empty sessionScope.username}">
        <li class="nav-item">
          <a href="${ctx}/orders">
            <i class="bi bi-receipt"></i> 我的订单
          </a>
        </li>
      </c:if>
      <c:if test="${not empty sessionScope.username}">
        <li><a href="${ctx}/usercenter">
          <i class="bi bi-person-circle"></i> 个人中心
        </a></li>
      </c:if>
      <c:if test="${sessionScope.userRole == '管理员'}">
        <li><a href="${ctx}/admin/index" style="color:var(--primary-red);font-weight:600;">
          <i class="bi bi-gear"></i> 管理中心
        </a></li>
      </c:if>
    </ul>
  </div>
</nav>

<div class="main">
  <!-- 面包屑导航 -->
  <div class="breadcrumb">
    <a href="${ctx}/index">首页</a>
    <span>&gt;</span>
    <c:choose>
      <c:when test="${not empty parentCategory}">
        <a href="${ctx}/index?categoryId=${parentCategory.id}">${parentCategory.name}</a>
        <span>&gt;</span>
        <a href="${ctx}/index?categoryId=${category.id}">${category.name}</a>
        <span>&gt;</span>
      </c:when>
      <c:when test="${not empty category}">
        <a href="${ctx}/index?categoryId=${category.id}">${category.name}</a>
        <span>&gt;</span>
      </c:when>
      <c:otherwise>
        <a href="${ctx}/index">全部商品</a>
        <span>&gt;</span>
      </c:otherwise>
    </c:choose>
    <span>${product.name}</span>
  </div>

  <!-- 商品详情主体 -->
  <div class="product-detail-container">
    <!-- 商品图片区域 -->
    <div class="product-image-section">
      <img src="${product.pic}" alt="${product.name}" class="product-main-image"
           onerror="this.src='https://via.placeholder.com/500x500?text=暂无图片'">
    </div>

    <!-- 商品信息区域 -->
    <div class="product-info-section">
      <h1 class="product-title">${product.name}</h1>
      
      <!-- 价格区域 -->
      <div class="product-price-section">
        <div class="price-label">商品价格</div>
        <div>
          <span class="current-price">￥<fmt:formatNumber value="${product.price}" pattern="#0.00"/></span>
        </div>
      </div>

      <!-- 商品描述 -->
      <div class="product-description">
        <strong>商品介绍：</strong><br>
        ${product.intro}
      </div>

      <!-- 库存状态 -->
      <div>
        <strong>库存状态：</strong>
        <c:choose>
          <c:when test="${product.stock <= 0}">
            <span class="stock-status stock-low">暂时缺货</span>
          </c:when>
          <c:when test="${product.stock < 20}">
            <span class="stock-status stock-low">库存紧张（仅剩${product.stock}件）</span>
          </c:when>
          <c:otherwise>
            <span class="stock-status stock-enough">库存充足（${product.stock}件）</span>
          </c:otherwise>
        </c:choose>
      </div>

      <!-- 销量信息 -->
      <div>
        <strong>销量：</strong>
        <span>${product.sales}件</span>
      </div>

      <!-- 数量选择器 -->
      <div class="quantity-selector">
        <span class="quantity-label">购买数量：</span>
        <div class="quantity-controls">
          <button type="button" class="quantity-btn" onclick="decreaseQuantity()">-</button>
          <input type="number" id="quantityInput" class="quantity-input" value="1" min="1" max="${product.stock}">
          <button type="button" class="quantity-btn" onclick="increaseQuantity()">+</button>
        </div>
        <span id="stockHint" style="font-size: 12px; color: #999;">
          （最多可买${product.stock > 0 ? product.stock : 0}件）
        </span>
      </div>

      <!-- 操作按钮 -->
      <div class="action-buttons">
        <form action="${ctx}/cart" method="post" id="addToCartForm">
          <input type="hidden" name="action" value="add">
          <input type="hidden" name="productId" value="${product.id}">
          <input type="hidden" name="quantity" id="cartQuantity" value="1">
          <button type="submit" class="add-cart-btn" ${product.stock <= 0 ? 'disabled' : ''}>
            <i class="bi bi-cart-plus"></i> ${product.stock <= 0 ? '暂时缺货' : '加入购物车'}
          </button>
        </form>

        <form action="${ctx}/checkout" method="post" id="buyNowForm">
          <input type="hidden" name="productId" value="${product.id}">
          <input type="hidden" name="quantity" id="buyNowQuantity" value="1">
          <input type="hidden" name="action" value="directBuy">
          <button type="submit" class="buy-now-btn" ${product.stock <= 0 ? 'disabled' : ''}>
            <i class="bi bi-lightning-charge"></i> ${product.stock <= 0 ? '暂时缺货' : '立即购买'}
          </button>
        </form>
      </div>
    </div>
  </div>

  <!-- 评论模块 -->
  <div class="comment-section">
    <div class="comment-stats">
      <div class="comment-avg">
        <c:choose>
          <c:when test="${avgRating > 0}"><fmt:formatNumber value="${avgRating}" pattern="#0.0"/></c:when>
          <c:otherwise>0.0</c:otherwise>
        </c:choose>
      </div>
      <div>
        <div class="star-display" style="color:#f39c12;font-size:14px;">
          <c:forEach begin="1" end="5" var="i">
            <c:choose>
              <c:when test="${i <= avgRating}">★</c:when>
              <c:when test="${i - 0.5 <= avgRating}">★</c:when>
              <c:otherwise>☆</c:otherwise>
            </c:choose>
          </c:forEach>
        </div>
        <div class="comment-count">共 ${commentCount} 条评论</div>
      </div>
    </div>

    <!-- 评论提交表单 -->
    <c:choose>
      <c:when test="${not empty sessionScope.username}">
        <c:if test="${not empty sessionScope.commentSuccess}">
          <div style="background:#d4edda;color:#155724;padding:10px 15px;border-radius:4px;margin-bottom:12px;font-size:14px;">
            <i class="bi bi-check-circle"></i> ${sessionScope.commentSuccess}
          </div>
          <c:remove var="commentSuccess" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.commentError}">
          <div style="background:#f8d7da;color:#721c24;padding:10px 15px;border-radius:4px;margin-bottom:12px;font-size:14px;">
            <i class="bi bi-exclamation-circle"></i> ${sessionScope.commentError}
          </div>
          <c:remove var="commentError" scope="session"/>
        </c:if>
        <form action="${ctx}/comment" method="post">
          <input type="hidden" name="productId" value="${product.id}">
          <div class="comment-form-row">
            <textarea name="content" placeholder="写下您对这件商品的评价..." required></textarea>
            <div style="display:flex;flex-direction:column;align-items:center;gap:4px;">
              <div class="rating-select">
                <input type="radio" name="rating" value="5" id="star5" checked><label for="star5">★</label>
                <input type="radio" name="rating" value="4" id="star4"><label for="star4">★</label>
                <input type="radio" name="rating" value="3" id="star3"><label for="star3">★</label>
                <input type="radio" name="rating" value="2" id="star2"><label for="star2">★</label>
                <input type="radio" name="rating" value="1" id="star1"><label for="star1">★</label>
              </div>
              <button type="submit" class="btn btn-sm" style="background:var(--primary-red);color:white;border:none;padding:6px 20px;border-radius:4px;cursor:pointer;font-size:14px;white-space:nowrap;">发表评论</button>
            </div>
          </div>
        </form>
      </c:when>
      <c:otherwise>
        <div style="text-align:center;padding:20px;color:#999;font-size:14px;">
          请<a href="${ctx}/login.jsp" style="color:var(--primary-red);">登录</a>后发表评论
        </div>
      </c:otherwise>
    </c:choose>

    <!-- 评论列表 -->
    <c:choose>
      <c:when test="${not empty comments}">
        <c:forEach items="${comments}" var="comment">
          <div class="comment-item">
            <div class="comment-header">
              <span class="comment-user">${comment.username}</span>
              <div>
                <span class="comment-rating">
                  <c:forEach begin="1" end="5" var="i">
                    <c:choose>
                      <c:when test="${i <= comment.rating}">★</c:when>
                      <c:otherwise>☆</c:otherwise>
                    </c:choose>
                  </c:forEach>
                </span>
                <span class="comment-time"><fmt:formatDate value="${comment.createTime}" pattern="yyyy-MM-dd HH:mm"/></span>
              </div>
            </div>
            <div class="comment-content">${comment.content}</div>
          </div>
        </c:forEach>
      </c:when>
      <c:otherwise>
        <div style="text-align:center;padding:30px;color:#999;">暂无评论，成为第一个评价的人吧</div>
      </c:otherwise>
    </c:choose>
  </div>

  <!-- 相关商品推荐 -->
  <c:if test="${not empty hotProducts}">
    <div class="related-products">
      <h2 class="section-title">热销推荐</h2>
      <div class="products-grid">
        <c:forEach items="${hotProducts}" var="hotProduct">
          <div class="product-card">
            <a href="${ctx}/product/detail?id=${hotProduct.id}" style="text-decoration: none; color: inherit;">
              <div class="product-image-wrapper">
                <img src="${hotProduct.pic}" alt="${hotProduct.name}" class="product-image"
                     onerror="this.src='https://via.placeholder.com/300x225?text=暂无图片'">
              </div>
              <div class="product-content">
                <h3 class="product-name">${hotProduct.name}</h3>
                <div class="product-price">
                  ￥<fmt:formatNumber value="${hotProduct.price}" pattern="#0.00"/>元
                </div>
                <div class="product-stock">
                  库存:
                  <c:choose>
                    <c:when test="${hotProduct.stock < 20}">
                      <span class="stock-low-text">${hotProduct.stock}件（库存紧张）</span>
                    </c:when>
                    <c:otherwise>
                      <span class="stock-enough-text">${hotProduct.stock}件（库存充足）</span>
                    </c:otherwise>
                  </c:choose>
                </div>
              </div>
            </a>
            <form action="${ctx}/cart" method="post" class="add-cart-form">
              <input type="hidden" name="action" value="add">
              <input type="hidden" name="productId" value="${hotProduct.id}">
              <input type="hidden" name="quantity" value="1">
              <button type="submit" class="add-cart-form-btn"
                ${hotProduct.stock == 0 ? 'disabled style="background:#ccc;cursor:not-allowed;"' : ''}>
                  ${hotProduct.stock == 0 ? '暂时缺货' : '加入购物车'}
              </button>
            </form>
          </div>
        </c:forEach>
      </div>
    </div>
  </c:if>
</div>

<!-- 页脚信息区 -->
<footer class="footer">
  <div class="footer-content">
    <div>
      <h5 class="footer-title">关于公司</h5>
      <ul class="footer-links">
        <li><a href="#">公司简介</a></li>
        <li><a href="#">可持续发展</a></li>
        <li><a href="#">信任中心</a></li>
        <li><a href="#">管理层信息</a></li>
        <li><a href="#">招贤纳士</a></li>
        <li><a href="#">供应商</a></li>
      </ul>
    </div>
    <div>
      <h5 class="footer-title">技术支持</h5>
      <ul class="footer-links">
        <li><a href="#">消费者技术支持</a></li>
        <li><a href="#">商城云技术支持</a></li>
        <li><a href="#">运营商技术支持</a></li>
        <li><a href="#">产品安全通告</a></li>
      </ul>
    </div>
    <div style="text-align: right;">
      <img src="https://api.qrserver.com/v1/create-qr-code/?size=100x100&data=https://example.com" alt="二维码" class="qr-code">
    </div>
  </div>
</footer>

<script>
  function increaseQuantity() {
    const input = document.getElementById('quantityInput');
    const maxStock = ${product.stock > 0 ? product.stock : 1};
    let currentValue = parseInt(input.value) || 1;
    
    if (currentValue < maxStock) {
      currentValue++;
      input.value = currentValue;
      updateHiddenInputs(currentValue);
    }
  }

  function decreaseQuantity() {
    const input = document.getElementById('quantityInput');
    let currentValue = parseInt(input.value) || 1;
    
    if (currentValue > 1) {
      currentValue--;
      input.value = currentValue;
      updateHiddenInputs(currentValue);
    }
  }

  function updateHiddenInputs(quantity) {
    document.getElementById('cartQuantity').value = quantity;
    document.getElementById('buyNowQuantity').value = quantity;
  }

  document.getElementById('quantityInput').addEventListener('change', function() {
    const maxStock = ${product.stock > 0 ? product.stock : 1};
    let value = parseInt(this.value) || 1;
    
    if (value < 1) {
      value = 1;
    } else if (value > maxStock) {
      value = maxStock;
    }
    
    this.value = value;
    updateHiddenInputs(value);
  });

  document.getElementById('addToCartForm').addEventListener('submit', function(e) {
    const quantity = parseInt(document.getElementById('cartQuantity').value);
    const maxStock = ${product.stock > 0 ? product.stock : 1};
    
    if (quantity <= 0 || quantity > maxStock) {
      e.preventDefault();
      alert('请输入有效的购买数量！');
      return false;
    }
  });

  document.getElementById('buyNowForm').addEventListener('submit', function(e) {
    const quantity = parseInt(document.getElementById('buyNowQuantity').value);
    const maxStock = ${product.stock > 0 ? product.stock : 1};
    
    if (quantity <= 0 || quantity > maxStock) {
      e.preventDefault();
      alert('请输入有效的购买数量！');
      return false;
    }
  });
</script>

<jsp:include page="common/copyright.jsp"/>

</body>
</html>
