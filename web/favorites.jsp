<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:if test="${empty sessionScope.userId}">
  <c:redirect url="login.jsp?redirect=favorite"/>
</c:if>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>我的收藏 - 归途花店</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
  <link rel="stylesheet" href="css/common.css">
  <style>
    body { background: #f8f9fa; font-family: "PingFang SC","Microsoft YaHei",sans-serif; }

    .fav-container { max-width: 1200px; margin: 0 auto; padding: 20px; }

    .page-title { font-size: 22px; font-weight: 700; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; }
    .page-title i { color: var(--primary-red); }

    /* 商品网格 */
    .fav-grid {
      display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
      gap: 16px;
    }
    .fav-card {
      background: #fff; border-radius: 12px; overflow: hidden;
      box-shadow: 0 1px 4px rgba(0,0,0,.06); transition: all .25s;
    }
    .fav-card:hover { transform: translateY(-3px); box-shadow: 0 4px 16px rgba(0,0,0,.1); }

    .fav-img-wrap {
      position: relative; width: 100%; padding-top: 100%; overflow: hidden; background: #f5f5f5;
    }
    .fav-img-wrap img {
      position: absolute; top: 0; left: 0; width: 100%; height: 100%; object-fit: cover;
      transition: transform .3s;
    }
    .fav-card:hover .fav-img-wrap img { transform: scale(1.06); }

    /* 取消收藏按钮（心形，图片右上角） */
    .fav-heart {
      position: absolute; top: 10px; right: 10px;
      width: 36px; height: 36px; border-radius: 50%;
      background: rgba(255,255,255,.9); border: none;
      display: flex; align-items: center; justify-content: center;
      cursor: pointer; font-size: 18px; transition: all .2s;
      box-shadow: 0 2px 6px rgba(0,0,0,.12);
    }
    .fav-heart:hover { background: #fff; transform: scale(1.1); }
    .fav-heart i { color: #e74c3c; }

    .fav-body { padding: 12px 14px 14px; }
    .fav-body .name {
      font-size: 14px; font-weight: 600; color: #333;
      white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
      margin-bottom: 6px; display: block; text-decoration: none;
    }
    .fav-body .name:hover { color: var(--primary-red); }
    .fav-body .price { font-size: 16px; font-weight: 700; color: var(--primary-red); margin-bottom: 10px; }

    .fav-actions { display: flex; gap: 8px; }
    .fav-actions .btn-add-cart {
      flex: 1; padding: 8px 0; border-radius: 6px; font-size: 13px; font-weight: 500;
      background: var(--primary-red); color: #fff; border: none; cursor: pointer;
      text-align: center; text-decoration: none; transition: all .2s;
    }
    .fav-actions .btn-add-cart:hover { background: var(--dark-red); }
    .fav-actions .btn-remove {
      padding: 8px 14px; border-radius: 6px; font-size: 13px;
      background: #f8f9fa; color: #999; border: 1px solid #eee; cursor: pointer;
      text-decoration: none; transition: all .2s;
    }
    .fav-actions .btn-remove:hover { background: #fff5f5; color: #e74c3c; border-color: #ffcdd2; }

    /* 空状态 */
    .empty-state { text-align: center; padding: 100px 20px; }
    .empty-state i { font-size: 64px; color: #ddd; }
    .empty-state p { margin-top: 16px; color: #999; font-size: 15px; }

    .fav-summary { font-size: 14px; color: #999; margin-bottom: 16px; }
  </style>
</head>
<body>

<nav style="background:#fff;position:sticky;top:0;z-index:1000;box-shadow:0 1px 4px rgba(0,0,0,.08);padding:0 20px;height:64px;display:flex;align-items:center;justify-content:space-between;">
  <a href="index.jsp" style="font-weight:700;font-size:20px;background:linear-gradient(135deg,#e74c3c,#ff6b6b);-webkit-background-clip:text;-webkit-text-fill-color:transparent;text-decoration:none;">归途</a>
  <div style="display:flex;gap:16px;align-items:center;font-size:14px;">
    <c:if test="${not empty sessionScope.username}"><span style="color:#666;">${sessionScope.username}</span><a href="logout" style="color:#555;text-decoration:none;">退出</a></c:if>
    <a href="cart" style="color:#555;text-decoration:none;"><i class="bi bi-cart3"></i> 购物车</a>
    <a href="orders" style="color:#555;text-decoration:none;">订单</a>
    <a href="usercenter" style="color:#555;text-decoration:none;">个人中心</a>
    <c:if test="${sessionScope.userRole == '管理员'}"><a href="admin/index" style="color:#e74c3c;text-decoration:none;font-weight:600;">管理</a></c:if>
  </div>
</nav>

<div class="fav-container">
  <div class="page-title">
    <i class="bi bi-heart-fill"></i> 我的收藏
    <span style="font-size:14px;font-weight:400;color:#999;margin-left:4px;">（共 <strong id="favCount">${favoriteCount}</strong> 件）</span>
  </div>

  <c:choose>
    <c:when test="${empty sessionScope.favorites || fn:length(sessionScope.favorites) == 0}">
      <div class="empty-state">
        <i class="bi bi-heartbreak"></i>
        <p>还没有收藏任何商品</p>
        <a href="index.jsp" class="btn btn-danger mt-2">去逛逛</a>
      </div>
    </c:when>

    <c:otherwise>
      <div class="fav-grid" id="favGrid">
        <c:forEach items="${sessionScope.favorites}" var="fav">
          <div class="fav-card" data-product-id="${fav.productId}" id="fav_${fav.productId}">
            <div class="fav-img-wrap">
              <a href="product/detail?id=${fav.productId}">
                <img src="${fav.productPic}" alt="${fav.productName}" onerror="this.src='https://via.placeholder.com/400x300?text=暂无图片'">
              </a>
              <button class="fav-heart" onclick="removeFav(${fav.productId})" title="取消收藏">
                <i class="bi bi-heart-fill"></i>
              </button>
            </div>
            <div class="fav-body">
              <a href="product/detail?id=${fav.productId}" class="name">${fav.productName}</a>
              <div class="price">¥<fmt:formatNumber value="${fav.productPrice}" pattern="#0.00"/></div>
              <div class="fav-actions">
                <a href="cart?action=add&productId=${fav.productId}&quantity=1" class="btn-add-cart">
                  <i class="bi bi-cart-plus"></i> 加入购物车
                </a>
                <a href="favorite?action=remove&productId=${fav.productId}" class="btn-remove" onclick="return confirm('确定取消收藏？')">
                  <i class="bi bi-trash"></i>
                </a>
              </div>
            </div>
          </div>
        </c:forEach>
      </div>
    </c:otherwise>
  </c:choose>
</div>

<script>
async function removeFav(productId) {
  if (!confirm('确定取消收藏？')) return;
  try {
    var res = await fetch('favorite?action=remove&productId=' + productId + '&ajax=1');
    var json = await res.json();
    if (json.code === 200) {
      var el = document.getElementById('fav_' + productId);
      if (el) { el.style.opacity = '0'; setTimeout(function() { el.remove(); checkEmpty(); }, 300); }
      var fc = document.getElementById('favCount');
      if (fc) fc.textContent = json.data.count;
    }
  } catch (e) { console.error(e); }
}

function checkEmpty() {
  if (!document.querySelectorAll('.fav-card').length) {
    location.reload();
  }
}
</script>

</body>
</html>
