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

        .cart-container { max-width: 1200px; margin: 0 auto; padding: 20px; }

        .cart-header {
            background: white;
            border-radius: 12px;
            padding: 18px 24px;
            margin-bottom: 16px;
            box-shadow: 0 1px 4px rgba(0,0,0,.06);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .cart-header-left { display: flex; align-items: center; gap: 14px; }
        .cart-header-left .form-check-input { width: 20px; height: 20px; accent-color: var(--primary-red); cursor: pointer; }
        .cart-header-left label { font-size: 14px; font-weight: 500; color: #333; cursor: pointer; user-select: none; }
        .cart-header-right { display: flex; align-items: center; gap: 16px; }
        .cart-header-right .op-link {
            font-size: 13px; color: #999; cursor: pointer; text-decoration: none;
            display: inline-flex; align-items: center; gap: 4px; transition: color .2s; user-select: none;
        }
        .cart-header-right .op-link:hover { color: var(--primary-red); }
        .cart-header-right .op-link.danger:hover { color: #e74c3c; }

        .cart-item {
            background: #fff; border-radius: 12px; padding: 18px 24px; margin-bottom: 10px;
            box-shadow: 0 1px 4px rgba(0,0,0,.06);
            display: flex; align-items: center; gap: 16px; transition: all .3s;
        }
        .cart-item.deleting { opacity: .3; transform: translateX(-24px); }

        .item-check { width: 20px; height: 20px; accent-color: var(--primary-red); cursor: pointer; flex-shrink: 0; }
        .item-img { width: 80px; height: 80px; object-fit: cover; border-radius: 8px; border: 1px solid #eee; flex-shrink: 0; }
        .item-body { flex: 1; min-width: 0; }
        .item-body .name { font-size: 15px; font-weight: 600; color: #333; margin-bottom: 4px; }
        .item-body .price { font-size: 15px; color: var(--primary-red); font-weight: 600; }
        .item-right { text-align: right; flex-shrink: 0; min-width: 120px; }
        .item-right .subtotal { font-size: 17px; color: var(--primary-red); font-weight: 700; transition: all .3s; }
        .item-right .subtotal.price-updated { animation: flash 0.45s ease; }
        @keyframes flash { 0% { transform: scale(1.18); color: #ff6b6b; } 100% { transform: scale(1); } }
        .item-right .remove { font-size: 12px; color: #999; cursor: pointer; text-decoration: none; }
        .item-right .remove:hover { color: var(--primary-red); }

        .qty-group { display: inline-flex; align-items: center; border: 1px solid #ddd; border-radius: 6px; overflow: hidden; margin-top: 8px; }
        .qty-btn {
            width: 34px; height: 34px; border: none; background: #f8f9fa;
            font-size: 16px; cursor: pointer; display: flex; align-items: center; justify-content: center;
            transition: all .15s; user-select: none;
        }
        .qty-btn:hover { background: var(--primary-red); color: #fff; }
        .qty-btn:disabled { opacity: .4; cursor: not-allowed; }
        .qty-input {
            width: 48px; height: 34px; border: none; text-align: center; font-size: 14px;
            outline: none; border-left: 1px solid #ddd; border-right: 1px solid #ddd;
        }

        .summary-box {
            background: #fff; border-radius: 12px; padding: 24px;
            box-shadow: 0 1px 4px rgba(0,0,0,.06); position: sticky; top: 90px;
        }
        .summary-row { display: flex; justify-content: space-between; margin-bottom: 10px; color: #666; font-size: 14px; }
        .summary-row.total { font-size: 17px; font-weight: 700; color: #333; margin-top: 16px; padding-top: 14px; border-top: 1.5px solid #eee; }
        .summary-row .val { color: var(--primary-red); font-weight: 600; }

        .btn-checkout {
            background: var(--primary-red); color: #fff; width: 100%; padding: 14px;
            border: none; border-radius: 8px; font-size: 16px; font-weight: 600;
            display: block; text-align: center; text-decoration: none; transition: all .2s;
        }
        .btn-checkout:hover { background: var(--dark-red); color: #fff; transform: translateY(-1px); }
        .btn-checkout.disabled { background: #ccc; color: #999; cursor: not-allowed; transform: none; pointer-events: none; }

        .empty-state { text-align: center; padding: 100px 20px; }
        .empty-state i { font-size: 64px; color: #ddd; }
        .empty-state p { margin-top: 16px; color: #999; font-size: 15px; }

        .count-badge { background: var(--primary-red); color: #fff; font-size: 11px; padding: 2px 8px; border-radius: 10px; margin-left: 6px; }
    </style>
</head>
<body>

<nav style="background:#fff;position:sticky;top:0;z-index:1000;box-shadow:0 1px 4px rgba(0,0,0,.08);padding:0 20px;height:64px;display:flex;align-items:center;justify-content:space-between;">
  <a href="index.jsp" style="font-weight:700;font-size:20px;background:linear-gradient(135deg,#e74c3c,#ff6b6b);-webkit-background-clip:text;-webkit-text-fill-color:transparent;text-decoration:none;">归途</a>
  <div style="display:flex;gap:16px;align-items:center;font-size:14px;">
    <c:choose>
      <c:when test="${not empty sessionScope.username}"><span style="color:#666;">${sessionScope.username}</span><a href="logout" style="color:#555;text-decoration:none;">退出</a></c:when>
      <c:otherwise><a href="login.jsp" style="color:#555;text-decoration:none;">登录</a><a href="reg.jsp" style="color:#555;text-decoration:none;">注册</a></c:otherwise>
    </c:choose>
    <a href="orders" style="color:#555;text-decoration:none;">订单</a>
    <a href="usercenter" style="color:#555;text-decoration:none;">个人中心</a>
    <c:if test="${sessionScope.userRole == '管理员'}"><a href="admin/index" style="color:#e74c3c;text-decoration:none;font-weight:600;">管理</a></c:if>
  </div>
</nav>

<div class="cart-container">
  <h4 style="margin-bottom:18px;"><i class="bi bi-cart3" style="color:var(--primary-red);"></i> 我的购物车 <span class="count-badge" id="headerCount">${totalNum}</span></h4>

  <c:choose>
    <c:when test="${empty sessionScope.cart || fn:length(sessionScope.cart) == 0}">
      <div class="empty-state"><i class="bi bi-cart-x"></i><p>购物车是空的</p><a href="index.jsp" class="btn btn-danger mt-2">去购物</a></div>
    </c:when>

    <c:otherwise>
      <div class="row">
        <div class="col-lg-8">
          <!-- 全选操作栏 -->
          <div class="cart-header">
            <div class="cart-header-left">
              <c:set var="allSelected" value="true"/>
              <c:forEach items="${sessionScope.cart}" var="item"><c:if test="${!item.selected}"><c:set var="allSelected" value="false"/></c:if></c:forEach>
              <input type="checkbox" class="form-check-input" id="selectAllCheck"
                ${allSelected && fn:length(sessionScope.cart) > 0 ? 'checked' : ''} onchange="toggleSelectAll(this.checked)">
              <label onclick="document.getElementById('selectAllCheck').click()">
                <span id="selectAllText">${allSelected ? '取消全选' : '全选'}</span>
                <span id="selectedInfo">（<strong id="selectedNumDisplay">${selectedNum}</strong>/<strong id="totalNumDisplay">${totalNum}</strong>）</span>
              </label>
            </div>
            <div class="cart-header-right">
              <a class="op-link danger" onclick="batchDelete()"><i class="bi bi-trash"></i> 批量删除</a>
              <span style="color:#ddd;font-size:12px;">|</span>
              <a href="cart?action=clear" class="op-link" onclick="return confirm('确定清空购物车？')"><i class="bi bi-x-circle"></i> 清空</a>
            </div>
          </div>

          <!-- 商品列表 -->
          <div id="cartList">
            <c:forEach items="${sessionScope.cart}" var="item">
              <div class="cart-item" data-product-id="${item.productId}" id="item_${item.productId}">
                <input type="checkbox" class="item-check" ${item.selected ? 'checked' : ''} onchange="toggleSelect(${item.productId}, this.checked)">
                <img src="${item.productPic}" class="item-img" onerror="this.src='https://via.placeholder.com/80'">
                <div class="item-body">
                  <div class="name">${item.productName}
                    <c:if test="${item.stock <= 0}"><span class="badge bg-warning text-dark ms-1" style="font-size:11px;vertical-align:middle;">缺货</span></c:if>
                    <c:if test="${item.status != 1}"><span class="badge bg-secondary ms-1" style="font-size:11px;vertical-align:middle;">已下架</span></c:if>
                  </div>
                  <div class="price">¥${item.productPrice}</div>
                  <div class="qty-group">
                    <button class="qty-btn" onclick="updateQty(${item.productId}, -1)" ${item.stock <= 0 ? 'disabled' : ''}>−</button>
                    <input type="text" class="qty-input" id="qty_${item.productId}" value="${item.quantity}" readonly data-stock="${item.stock > 0 ? item.stock : 0}">
                    <button class="qty-btn" onclick="updateQty(${item.productId}, 1)" ${item.stock <= 0 || item.quantity >= item.stock ? 'disabled' : ''}>+</button>
                  </div>
                </div>
                <div class="item-right">
                  <div class="subtotal" id="subtotal_${item.productId}">¥<fmt:formatNumber value="${item.productPrice * item.quantity}" pattern="#0.00"/></div>
                  <a class="remove" onclick="removeItem(${item.productId})"><i class="bi bi-trash"></i> 删除</a>
                </div>
              </div>
            </c:forEach>
          </div>
        </div>

        <div class="col-lg-4">
          <div class="summary-box">
            <h6 style="font-weight:600;margin-bottom:16px;">订单摘要</h6>
            <div class="summary-row"><span>商品总数</span><span id="totalNumSummary">${totalNum} 件</span></div>
            <div class="summary-row"><span>选中数量</span><span class="val" id="selectedNumSummary">${selectedNum} 件</span></div>
            <div class="summary-row total"><span>合计</span><span class="val" id="totalMoneySummary">¥<fmt:formatNumber value="${totalMoney}" pattern="#0.00"/></span></div>
            <a href="${totalMoney > 0 ? 'checkout' : '#'}" class="btn-checkout mt-3 ${totalMoney > 0 ? '' : 'disabled'}" id="checkoutBtn">
              <c:choose>
                <c:when test="${totalMoney > 0}">去结算（<span id="checkoutCount">${selectedNum}</span>件）</c:when>
                <c:otherwise>请选择至少一件商品</c:otherwise>
              </c:choose>
            </a>
            <a href="index.jsp" class="btn btn-outline-secondary w-100 mt-2">继续购物</a>
          </div>
        </div>
      </div>
    </c:otherwise>
  </c:choose>
</div>

<script>
async function cartAjax(action, params) {
    params = params || {}; params.action = action; params.ajax = 1;
    const query = new URLSearchParams(params).toString();
    try {
        const res = await fetch('cart?' + query, { method: 'POST' });
        const json = await res.json();
        if (json.code === 200) updateTotals(json.data);
        return json;
    } catch (e) { console.error(e); }
}

function updateTotals(data) {
    document.getElementById('totalNumSummary').textContent = data.totalNum + ' 件';
    document.getElementById('selectedNumSummary').textContent = data.selectedNum + ' 件';
    document.getElementById('totalMoneySummary').innerHTML = '¥' + data.totalMoney.toFixed(2);

    // 更新头部角标和选中数量（可能在按钮内或外，安全获取）
    var hc = document.getElementById('headerCount');
    if (hc) hc.textContent = data.totalNum;
    var sd = document.getElementById('selectedNumDisplay');
    if (sd) sd.textContent = data.selectedNum;
    var td = document.getElementById('totalNumDisplay');
    if (td) td.textContent = data.totalNum;

    // ★ 先更新按钮 HTML（确保 checkoutCount 一定存在）,再设内容
    var btn = document.getElementById('checkoutBtn');
    if (data.totalMoney > 0) {
        btn.innerHTML = '去结算（<span id="checkoutCount">' + data.selectedNum + '</span>件）';
        btn.href = 'checkout';
        btn.classList.remove('disabled');
    } else {
        btn.innerHTML = '请选择至少一件商品';
        btn.removeAttribute('href');
        btn.classList.add('disabled');
    }

    // 全选状态同步
    var allChecked = document.querySelectorAll('.item-check:checked').length;
    var total = document.querySelectorAll('.item-check').length;
    var selectAll = document.getElementById('selectAllCheck');
    var selectAllText = document.getElementById('selectAllText');
    if (selectAll) {
        selectAll.checked = (allChecked === total && total > 0);
        selectAllText.textContent = selectAll.checked ? '取消全选' : '全选';
    }
    // 金额动画
    var el = document.getElementById('totalMoneySummary');
    el.classList.remove('price-updated'); void el.offsetWidth; el.classList.add('price-updated');
}

async function updateQty(productId, delta) {
    var input = document.getElementById('qty_' + productId);
    var current = parseInt(input.value) || 1;
    var maxStock = parseInt(input.dataset.stock) || 999;
    var newQty = current + delta;
    if (newQty < 1 || newQty > maxStock) return;
    input.value = newQty;
    // 更新 +/- 按钮状态
    var item = document.getElementById('item_' + productId);
    var decBtn = item.querySelector('.qty-btn:first-of-type');
    var incBtn = item.querySelector('.qty-btn:last-of-type');
    if (decBtn) decBtn.disabled = newQty <= 1;
    if (incBtn) incBtn.disabled = newQty >= maxStock;
    var json = await cartAjax('update', { productId: productId, quantity: newQty });
    if (json && json.code === 200) {
        var price = parseFloat(document.querySelector('#item_' + productId + ' .price').textContent.replace('¥', ''));
        var sub = document.getElementById('subtotal_' + productId);
        sub.innerHTML = '¥' + (price * newQty).toFixed(2);
        sub.classList.remove('price-updated'); void sub.offsetWidth; sub.classList.add('price-updated');
    }
}

async function toggleSelect(productId, checked) {
    var json = await cartAjax('select', { productId: productId, checked: checked ? 'on' : 'off' });
}

async function toggleSelectAll(checked) {
    var json = await cartAjax(checked ? 'selectAll' : 'unselectAll', {});
    if (json && json.code === 200) {
        document.querySelectorAll('.item-check').forEach(function(cb) { cb.checked = checked; });
        var selectAll = document.getElementById('selectAllCheck');
        if (selectAll) selectAll.checked = checked;
        document.getElementById('selectAllText').textContent = checked ? '取消全选' : '全选';
    }
}

async function removeItem(productId) {
    var el = document.getElementById('item_' + productId);
    el.classList.add('deleting');
    var json = await cartAjax('remove', { productId: productId });
    if (json && json.code === 200) { el.remove(); if (!document.querySelectorAll('.cart-item').length) location.reload(); }
    else { el.classList.remove('deleting'); }
}

async function batchDelete() {
    var checked = document.querySelectorAll('.item-check:checked');
    if (!checked.length) { alert('请先勾选要删除的商品'); return; }
    if (!confirm('确定删除选中的 ' + checked.length + ' 件商品？')) return;
    var ids = [];
    checked.forEach(function(cb) {
        var pid = cb.closest('.cart-item').dataset.productId;
        ids.push(pid); cb.closest('.cart-item').classList.add('deleting');
    });
    var json = await cartAjax('batchRemove', { productIds: ids.join(',') });
    if (json && json.code === 200) {
        ids.forEach(function(pid) { var e = document.getElementById('item_' + pid); if (e) e.remove(); });
        if (!document.querySelectorAll('.cart-item').length) location.reload();
    }
}
</script>
</body>
</html>
