<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!-- 若商品列表为空且无搜索/筛选条件，则转发至首页控制器加载初始数据 -->
<c:if test="${productList == null && empty searchKeyword && empty selectedCategoryId}">
  <jsp:forward page="/index"/>
</c:if>

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
  <title>${empty searchKeyword ? (empty selectedCategoryId ? '花店商城' : pageTitle) : '搜索：'.concat(searchKeyword)}</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
  <style>
    :root { --primary-red: #e74c3c; --dark-red: #c0392b; --primary-green: #27ae60; }
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: "PingFang SC", "Microsoft YaHei", sans-serif; background: #fff; }

    /* 导航栏 */
    .navbar {
      background: #fff;
      padding: 0;
      position: sticky;
      top: 0;
      z-index: 1000;
      box-shadow: 0 2px 12px rgba(0,0,0,0.08);
    }
    .container {
      max-width: 1200px;
      margin: 0 auto;
      padding: 0 20px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      height: 70px;
    }
    .brand {
      font-weight: 700;
      color: #333;
      text-decoration: none;
      font-size: 22px;
      letter-spacing: 2px;
      background: linear-gradient(135deg, var(--primary-red) 0%, #ff6b6b 100%);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      transition: transform 0.2s;
      cursor: pointer;
    }
    .brand:hover {
      transform: scale(1.05);
    }
    .nav-links {
      display: flex;
      gap: 20px;
      list-style: none;
      align-items: center;
    }
    .nav-links a {
      color: #555;
      text-decoration: none;
      font-size: 14px;
      transition: all 0.2s;
      padding: 6px 12px;
      border-radius: 6px;
    }
    .nav-links a:hover {
      color: var(--primary-red);
      background: #fff5f5;
    }

    /* 搜索框 */
    .search-box { display: flex; align-items: center; }
    .search-box input {
      border: 2px solid #e8e8e8;
      padding: 8px 15px;
      font-size: 14px;
      outline: none;
      width: 220px;
      border-radius: 8px 0 0 8px;
      transition: border-color 0.2s;
    }
    .search-box input:focus {
      border-color: var(--primary-red);
    }
    .search-box button {
      border: 2px solid var(--primary-red);
      border-left: none;
      background: var(--primary-red);
      padding: 8px 18px;
      cursor: pointer;
      font-size: 14px;
      color: white;
      border-radius: 0 8px 8px 0;
      transition: background 0.2s;
    }
    .search-box button:hover {
      background: var(--dark-red);
    }

    /* 购物车角标 */
    .cart-badge {
      background: var(--primary-red);
      color: white;
      font-size: 11px;
      padding: 2px 7px;
      border-radius: 10px;
      margin-left: 5px;
      display: inline-block;
      min-width: 18px;
      text-align: center;
      font-weight: 600;
    }

    /* 分类筛选栏 */
    .category-filter-bar {
      background: #fff;
      border-bottom: 1px solid #f0f0f0;
      padding: 20px 0;
      box-shadow: 0 2px 8px rgba(0,0,0,0.04);
    }
    .category-filter-bar .container {
      height: auto;
      display: block;
    }
    .filter-row {
      display: flex;
      align-items: center;
      margin-bottom: 12px;
    }
    .filter-row:last-child {
      margin-bottom: 0;
    }
    .filter-label {
      font-size: 14px;
      color: #888;
      font-weight: 500;
      min-width: 80px;
      margin-right: 15px;
    }
    .filter-options {
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
      flex: 1;
    }
    .filter-option {
      padding: 8px 18px;
      font-size: 14px;
      color: #666;
      text-decoration: none;
      border: 1px solid #e8e8e8;
      border-radius: 20px;
      background: #fafafa;
      transition: all 0.25s;
      cursor: pointer;
      font-weight: 500;
    }
    .filter-option:hover {
      border-color: var(--primary-red);
      color: var(--primary-red);
      background: #fff5f5;
      transform: translateY(-2px);
      box-shadow: 0 4px 8px rgba(231, 76, 60, 0.1);
    }
    .filter-option.active {
      background: var(--primary-red);
      color: white;
      border-color: var(--primary-red);
      box-shadow: 0 4px 12px rgba(231, 76, 60, 0.2);
      transform: translateY(-2px);
    }

    /* 搜索提示栏 */
    .search-bar-hint { background: #f8f9fa; border-bottom: 1px solid #e0e0e0; padding: 12px 0; }
    .search-bar-hint .container { height: auto; display: flex; justify-content: center; align-items: center; }
    .search-info { color: #666; font-size: 14px; }
    .search-info strong { color: var(--primary-red); }
    .search-keyword { color: var(--primary-red); font-weight: bold; }
    .back-btn { margin-left: 15px; color: #666; text-decoration: none; font-size: 14px; }
    .back-btn:hover { color: var(--primary-red); text-decoration: underline; }

    /* 主体区域 */
    .main { max-width: 1200px; margin: 30px auto 50px; padding: 0 15px; }

    /* 横向滚动布局 */
    .products-scroll-container {
      position: relative;
      width: 100%;
    }

    .products {
      display: flex;
      flex-wrap: nowrap;
      overflow-x: auto;
      overflow-y: hidden;
      gap: 24px;
      padding: 20px 0;
      scroll-behavior: smooth;
      -webkit-overflow-scrolling: touch;

      scrollbar-width: thin;
      scrollbar-color: #ccc #f1f1f1;
    }

    .products::-webkit-scrollbar {
      height: 8px;
    }
    .products::-webkit-scrollbar-track {
      background: #f1f1f1;
      border-radius: 4px;
    }
    .products::-webkit-scrollbar-thumb {
      background: #ccc;
      border-radius: 4px;
    }
    .products::-webkit-scrollbar-thumb:hover {
      background: #999;
    }

    .product-card {
      flex: 0 0 calc(33.333% - 16px);
      min-width: 300px;
      max-width: 380px;
      border: 1px solid #e0e0e0;
      background: white;
      transition: all 0.15s ease;
      overflow: hidden;
    }

    .product-card:hover {
      transform: translateY(-4px);
      box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    }

    /* 海报轮播 */
    .banner-section { max-width:1200px; margin:20px auto 0; padding:0 15px; }
    .banner-wrapper { position:relative; border-radius:12px; overflow:hidden; }
    .banner-slide { display:none; }
    .banner-slide.active { display:block; }
    .banner-slide img { width:100%; height:380px; object-fit:cover; cursor:pointer; border-radius:12px; transition:opacity 0.5s; }
    .banner-dots { display:flex; justify-content:center; gap:8px; margin-top:10px; }
    .banner-dot { width:10px; height:10px; border-radius:50%; background:#ccc; cursor:pointer; transition:background 0.3s; }
    .banner-dot.active { background:var(--primary-red); }
    @media (max-width:768px) { .banner-slide img { height:200px; } }

    @media (max-width: 768px) {
      .product-card {
        flex: 0 0 calc(50% - 12px);
        min-width: 220px;
      }
    }

    @media (max-width: 480px) {
      .product-card {
        flex: 0 0 85%;
        min-width: 260px;
      }
    }

    .product-image-wrapper { position: relative; overflow: hidden; aspect-ratio: 4/3; }
    .product-image { width: 100%; height: 100%; object-fit: cover; transition: transform 0.2s ease; }
    .product-card:hover .product-image { transform: scale(1.05); }

    .product-label {
      position: absolute;
      top: 10px;
      right: -34px;
      width: 140px;
      background: linear-gradient(135deg, #e74c3c, #ff6b6b);
      color: white;
      text-align: center;
      padding: 4px 0;
      font-size: 12px;
      font-weight: 600;
      transform: rotate(45deg);
      box-shadow: 0 2px 8px rgba(231, 76, 60, 0.25);
      z-index: 1;
      letter-spacing: 1px;
    }

    .product-label-hot {
      background: linear-gradient(135deg, #f39c12, #e67e22);
    }

    .product-content { padding: 15px; text-align: center; }
    .product-name { font-size: 16px; font-weight: 600; color: #333; margin-bottom: 8px; }
    .product-desc { font-size: 14px; color: #666; line-height: 1.6; margin-bottom: 12px; min-height: 44px; }
    .product-price { font-size: 18px; color: var(--primary-red); font-weight: 600; margin-bottom: 4px; }
    .product-stock { font-size: 12px; color: #999; margin-bottom: 15px; }
    .stock-low { color: var(--primary-red); font-weight: 500; }
    .stock-enough { color: var(--primary-green); }

    .add-cart-btn {
      background: var(--primary-red);
      color: white;
      border: none;
      padding: 8px 20px;
      font-size: 14px;
      width: 100%;
      cursor: pointer;
      transition: background 0.2s;
    }
    .add-cart-btn:hover { background: var(--dark-red); }
    .add-cart-btn:disabled { background: #ccc; cursor: not-allowed; }
    .add-cart-form { width: 100%; }

    @keyframes fadeInUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
    .animate-fade-in { animation: fadeInUp 0.5s ease forwards; opacity: 0; }

    .empty-state {
      text-align: center;
      padding: 100px 20px;
      background: #fff;
      border: 1px solid #e0e0e0;
      margin-top: 20px;
    }
    .empty-state h4 { color: #666; font-weight: normal; margin-bottom: 10px; font-size: 18px; }
    .empty-state p { color: #999; font-size: 14px; margin-top: 15px; }
    .empty-state .back-btn-large {
      display: inline-block;
      margin-top: 20px;
      padding: 8px 20px;
      border: 1px solid var(--primary-red);
      color: var(--primary-red);
      text-decoration: none;
      border-radius: 4px;
      transition: all 0.2s;
    }
    .empty-state .back-btn-large:hover {
      background: var(--primary-red);
      color: white;
    }

    .footer { background: #f5f5f5; padding: 40px 0; margin-top: 50px; }
    .footer-content { max-width: 1200px; margin: 0 auto; padding: 0 15px; display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 30px; }
    .footer-title { font-size: 16px; font-weight: 600; color: #333; margin-bottom: 20px; }
    .footer-links { list-style: none; }
    .footer-links li { margin-bottom: 10px; }
    .footer-links a { color: #666; font-size: 13px; text-decoration: none; transition: color 0.2s; }
    .footer-links a:hover { color: var(--primary-red); }
    .qr-code { width: 100px; height: 100px; }

    /* 登录成功弹窗 */
    .welcome-modal {
      display: none;
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: rgba(0, 0, 0, 0.5);
      z-index: 9999;
      align-items: center;
      justify-content: center;
    }

    .welcome-modal.show {
      display: flex;
    }

    .welcome-content {
      background: white;
      padding: 40px;
      border-radius: 12px;
      text-align: center;
      max-width: 400px;
      animation: modalSlideIn 0.3s ease;
    }

    @keyframes modalSlideIn {
      from {
        opacity: 0;
        transform: translateY(-50px);
      }
      to {
        opacity: 1;
        transform: translateY(0);
      }
    }

    .welcome-icon {
      font-size: 48px;
      margin-bottom: 15px;
    }

    .welcome-title {
      font-size: 24px;
      color: #333;
      margin-bottom: 10px;
    }

    .welcome-message {
      color: #666;
      font-size: 14px;
      margin-bottom: 25px;
    }

    .welcome-btn {
      background: var(--primary-red);
      color: white;
      border: none;
      padding: 12px 40px;
      border-radius: 6px;
      font-size: 16px;
      cursor: pointer;
      transition: background 0.2s;
    }

    .welcome-btn:hover {
      background: var(--dark-red);
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
  </style>
</head>
<body>

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

<!-- 登录成功欢迎弹窗：仅在 URL 携带 welcome=1 参数时显示 -->
<c:if test="${not empty sessionScope.username && param.welcome == '1'}">
  <div class="welcome-modal show" id="welcomeModal">
    <div class="welcome-content">
      <div class="welcome-icon">🎉</div>
      <h2 class="welcome-title">欢迎回来，${sessionScope.username}！</h2>
      <p class="welcome-message">登录成功，祝您购物愉快</p>
      <button class="welcome-btn" onclick="closeWelcome()">好的</button>
    </div>
  </div>
</c:if>

<nav class="navbar">
  <div class="container">
    <a class="brand" href="javascript:void(0)" onclick="showCopyright()">归途</a>
    <ul class="nav-links">
      <li><a href="index.jsp">首页</a></li>
      <li>
        <!-- 顶部全局搜索框 -->
        <form class="search-box" action="index" method="get">
          <input type="hidden" name="action" value="search">
          <input type="search" name="keyword" placeholder="搜索商品..." required value="${searchKeyword}">
          <button type="submit">查询</button>
        </form>
      </li>
      <li>
        <c:choose>
          <c:when test="${not empty sessionScope.username}">
            <a href="logout">退出(${sessionScope.username})</a>
          </c:when>
          <c:otherwise>
            <a href="login.jsp">登录</a>
          </c:otherwise>
        </c:choose>
      </li>
      <li>
        <c:if test="${empty sessionScope.username}">
          <a href="reg.jsp">注册</a>
        </c:if>
      </li>
      <li class="nav-item">
        <a class="nav-link" href="cart">
          我的购物车<span class="cart-badge">${cartItemCount > 0 ? cartItemCount : '0'}</span>
        </a>
      </li>
      <c:if test="${not empty sessionScope.username}">
        <li class="nav-item">
          <a href="orders">
            <i class="bi bi-receipt"></i> 我的订单
          </a>
        </li>
      </c:if>
      <c:if test="${not empty sessionScope.username}">
        <li><a href="usercenter">
          <i class="bi bi-person-circle"></i> 个人中心
        </a></li>
      </c:if>
      <c:if test="${sessionScope.userRole == '管理员'}">
        <li><a href="admin/index" style="color:var(--primary-red);font-weight:600;">
          <i class="bi bi-gear"></i> 管理中心
        </a></li>
      </c:if>
    </ul>
  </div>
</nav>

<!-- 海报轮播：热卖商品 + 管理员上传的海报 -->
<c:set var="carouselItems" value="${hotProducts}"/>
<c:set var="showHotFlag" value="${empty sessionScope.showHot ? 1 : sessionScope.showHot}"/>
<c:if test="${not empty carouselItems}">
  <div class="banner-section">
    <div class="banner-wrapper">
      <c:forEach items="${carouselItems}" var="item" varStatus="s">
        <div class="banner-slide ${s.index == 0 ? 'active' : ''}">
          <a href="${pageContext.request.contextPath}/product/detail?id=${item.id}">
            <div style="position:relative;">
              <img src="${item.pic}" alt="${item.name}" style="width:100%;height:380px;object-fit:cover;border-radius:12px;" onerror="this.src='https://via.placeholder.com/1200x380?text=热卖商品'">
              <div style="position:absolute;bottom:0;left:0;right:0;background:linear-gradient(transparent,rgba(0,0,0,0.6));padding:30px 24px 20px;border-radius:0 0 12px 12px;">
                <span style="color:white;font-size:14px;opacity:0.8;">销量TOP${s.index + 1}</span>
                <h3 style="color:white;margin:4px 0;font-size:20px;">${item.name}</h3>
                <span style="color:#f39c12;font-size:22px;font-weight:700;">￥<fmt:formatNumber value="${item.price}" pattern="#0.00"/></span>
              </div>
            </div>
          </a>
        </div>
      </c:forEach>
      <!-- 管理员上传的海报（仅在非"仅热卖"模式下显示） -->
      <c:if test="${showHotFlag != 1}">
        <c:forEach items="${banners}" var="b" varStatus="bs">
          <div class="banner-slide">
            <a href="${pageContext.request.contextPath}/product/detail?id=${b.productId}">
              <img src="${pageContext.request.contextPath}/${b.imgUrl}" alt="海报" style="width:100%;height:380px;object-fit:cover;border-radius:12px;" onerror="this.style.display='none'">
            </a>
          </div>
        </c:forEach>
      </c:if>
    </div>
    <div class="banner-dots">
      <c:set var="totalBannerCount" value="${fn:length(carouselItems) + (showHotFlag != 1 ? fn:length(banners) : 0)}"/>
      <c:forEach begin="0" end="${totalBannerCount - 1}" varStatus="ds">
        <span class="banner-dot ${ds.index == 0 ? 'active' : ''}" onclick="showBanner(${ds.index})"></span>
      </c:forEach>
    </div>
  </div>
  <script>
    var totalBanners = ${totalBannerCount};
    var autoPlaySpeed = ${empty sessionScope.bannerSpeed ? 1500 : sessionScope.bannerSpeed};
    var currentBanner = parseInt(sessionStorage.getItem('bannerIndex')) || 0;
    if (currentBanner >= totalBanners) currentBanner = 0;

    function showBanner(n) {
      var slides = document.querySelectorAll('.banner-slide');
      var dots = document.querySelectorAll('.banner-dot');
      if (slides.length === 0) return;
      slides.forEach(function(s) { s.classList.remove('active'); });
      dots.forEach(function(d) { d.classList.remove('active'); });
      if (n >= 0 && n < totalBanners) {
        slides[n].classList.add('active');
        if (dots[n]) dots[n].classList.add('active');
        currentBanner = n;
        sessionStorage.setItem('bannerIndex', n);
      }
    }

    // 恢复上次位置
    if (totalBanners > 1 && currentBanner > 0) {
      showBanner(currentBanner);
    }

    if (totalBanners > 1) {
      setInterval(function() { showBanner((currentBanner + 1) % totalBanners); }, autoPlaySpeed);
    }
  </script>
</c:if>

<!-- 分类筛选区域：支持一级和二级分类联动筛选 -->
<c:if test="${empty searchKeyword}">
  <div class="category-filter-bar">
    <div class="container">
      <!-- 一级分类 -->
      <div class="filter-row">
        <span class="filter-label">一级分类：</span>
        <div class="filter-options">
          <a href="index" class="filter-option ${empty selectedParentId && empty selectedCategoryId ? 'active' : ''}">全部</a>
          <c:forEach items="${parentCategories}" var="parentCat">
            <a href="index?categoryId=${parentCat.id}"
               class="filter-option ${selectedParentId == parentCat.id ? 'active' : ''}">
              ${parentCat.name}
            </a>
          </c:forEach>
        </div>
      </div>

      <!-- 二级分类（仅当选择了一级分类时显示） -->
      <c:if test="${not empty childCategories && selectedParentId != null}">
        <div class="filter-row">
          <span class="filter-label">二级分类：</span>
          <div class="filter-options">
            <a href="index?categoryId=${selectedParentId}"
               class="filter-option ${selectedCategoryId == selectedParentId ? 'active' : ''}">
              全部
            </a>
            <c:forEach items="${childCategories}" var="childCat">
              <a href="index?categoryId=${childCat.id}"
                 class="filter-option ${selectedCategoryId == childCat.id ? 'active' : ''}">
                ${childCat.name}
              </a>
            </c:forEach>
          </div>
        </div>
      </c:if>
    </div>
  </div>
</c:if>

<!-- 搜索结果提示栏：展示搜索关键词及匹配到的商品总数 -->
<c:if test="${not empty searchKeyword}">
  <div class="search-bar-hint">
    <div class="container">
      <span class="search-info">
        搜索 <span class="search-keyword">"${searchKeyword}"</span> 找到 <strong>${productCount}</strong> 件商品
      </span>
      <a href="index" class="back-btn">← 返回全部商品</a>
    </div>
  </div>
</c:if>

<div class="main">
  <!-- 针对不同情况展示空状态提示：搜索无结果、分类无商品或系统无上架商品 -->
  <c:if test="${not empty searchKeyword && empty productList}">
    <div class="empty-state animate-fade-in">
      <h4>未找到与 "${searchKeyword}" 相关的商品</h4>
      <p>换个关键词试试，或者浏览全部商品</p>
      <a href="index" class="back-btn-large">查看全部商品</a>
    </div>
  </c:if>

  <c:if test="${not empty selectedCategoryId && empty productList && empty searchKeyword}">
    <div class="empty-state animate-fade-in">
      <h4>该分类下暂无商品</h4>
      <p>请切换其他分类或浏览全部商品</p>
      <a href="index" class="back-btn-large">查看全部商品</a>
    </div>
  </c:if>

  <c:if test="${empty searchKeyword && empty selectedCategoryId && empty productList}">
    <div class="empty-state animate-fade-in">
      <h4>暂无商品上架</h4>
      <p>商品正在补货中，请稍后再来</p>
    </div>
  </c:if>

  <!-- 商品横向滚动展示区 -->
  <div class="products-scroll-container">
    <div class="products">
      <c:forEach items="${productList}" var="product" varStatus="status">
        <div class="product-card animate-fade-in" style="animation-delay: ${(status.index % 6) * 0.1}s;">
          <a href="product/detail?id=${product.id}" style="text-decoration: none; color: inherit;">
            <div class="product-image-wrapper">
              <c:set var="isHot" value="false"/>
              <c:forEach items="${hotProducts}" var="hp">
                <c:if test="${hp.id == product.id}"><c:set var="isHot" value="true"/></c:if>
              </c:forEach>
              <c:if test="${isHot}">
                <span class="product-label">热卖</span>
              </c:if>
              <img src="${product.pic}" alt="${product.name}" class="product-image"
                   onerror="this.src='https://via.placeholder.com/400x300?text=暂无图片'">
            </div>
          </a>
          <div class="product-content">
            <h3 class="product-name"><a href="product/detail?id=${product.id}" style="text-decoration: none; color: inherit;">${product.name}</a></h3>
            <p class="product-desc">${product.intro}</p>
            <div class="product-price">
              ￥<fmt:formatNumber value="${product.price}" pattern="#0.00"/>元
            </div>
            <div class="product-stock">
              库存:
              <c:choose>
                <c:when test="${product.stock < 20}">
                  <span class="stock-low">${product.stock}件（库存紧张）</span>
                </c:when>
                <c:otherwise>
                  <span class="stock-enough">${product.stock}件（库存充足）</span>
                </c:otherwise>
              </c:choose>
            </div>

            <!-- 加入购物车表单：库存为 0 时禁用提交按钮 -->
            <form action="cart" method="post" class="add-cart-form">
              <input type="hidden" name="action" value="add">
              <input type="hidden" name="productId" value="${product.id}">
              <input type="hidden" name="quantity" value="1">
              <button type="submit" class="add-cart-btn"
                ${product.stock == 0 ? 'disabled style="background:#ccc;cursor:not-allowed;"' : ''}>
                  ${product.stock == 0 ? '暂时缺货' : '加入购物车'}
              </button>
            </form>
          </div>
        </div>
      </c:forEach>
    </div>
  </div>
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

  // 关闭欢迎弹窗并清理 URL 中的 welcome 参数
  function closeWelcome() {
    document.getElementById('welcomeModal').classList.remove('show');
    const url = new URL(window.location);
    url.searchParams.delete('welcome');
    window.history.replaceState({}, '', url);
  }

  // 监听鼠标滚轮事件，实现商品列表区域的水平滚动
  document.addEventListener('DOMContentLoaded', function() {
    const container = document.querySelector('.products');

    container.addEventListener('wheel', function(e) {
      if (e.deltaY !== 0) {
        e.preventDefault();
        this.scrollLeft += e.deltaY;
      }
    });
  });
</script>

</body>
</html>