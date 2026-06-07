<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- 校验是否有选中商品，若无则重定向回结算页重新加载 -->
<c:if test="${empty selectedItems}">
    <jsp:forward page="/checkout"/>
</c:if>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>确认订单 - 花店商城</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="css/common.css">
    <style>
        body { background: var(--bg-gray); }


        .checkout-container { max-width: 1000px; margin: 0 auto; padding: 20px; }

        .section-card { background: white; border-radius: 12px; padding: 25px; margin-bottom: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
        .section-title { font-size: 18px; font-weight: 600; margin-bottom: 20px;
            border-left: 4px solid var(--primary-red); padding-left: 12px; }

        .product-item { display: flex; align-items: center; padding: 15px 0; border-bottom: 1px solid #f0f0f0; }
        .product-item:last-child { border-bottom: none; }
        .product-item img { width: 80px; height: 80px; object-fit: cover; border-radius: 8px; margin-right: 15px; }
        .product-info { flex: 1; }
        .product-name { font-weight: 500; margin-bottom: 5px; }
        .product-price { color: var(--primary-red); font-weight: bold; }
        .product-qty { color: #999; font-size: 14px; }

        .address-display {
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            padding: 20px;
            transition: all 0.3s;
        }

        .address-display.has-address {
            border-color: var(--primary-red);
            background: #fff5f5;
        }

        .address-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
        }

        .address-name {
            font-weight: 600;
            font-size: 16px;
        }

        .address-phone {
            color: #666;
            margin-left: 15px;
        }

        .default-badge {
            background: var(--primary-red);
            color: white;
            font-size: 12px;
            padding: 2px 8px;
            border-radius: 10px;
            margin-left: 10px;
        }

        .address-detail {
            color: #666;
            font-size: 14px;
            line-height: 1.6;
        }

        .address-actions {
            display: flex;
            gap: 10px;
            margin-top: 15px;
        }

        .btn-edit-address {
            background: white;
            border: 1px solid var(--primary-red);
            color: var(--primary-red);
            padding: 6px 16px;
            border-radius: 6px;
            font-size: 13px;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }

        .btn-edit-address:hover {
            background: var(--primary-red);
            color: white;
        }

        .btn-change-address {
            background: white;
            border: 1px solid #ddd;
            color: #666;
            padding: 6px 16px;
            border-radius: 6px;
            font-size: 13px;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }

        .btn-change-address:hover {
            border-color: var(--primary-red);
            color: var(--primary-red);
        }

        .no-address {
            text-align: center;
            padding: 20px;
            color: #999;
            min-height: 120px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
        }

        .no-address i {
            font-size: 36px;
            margin-bottom: 10px;
        }

        .no-address p {
            margin-bottom: 15px;
            font-size: 14px;
        }

        .form-group { margin-bottom: 20px; }
        .form-label { font-weight: 500; color: #333; margin-bottom: 8px; }
        .form-control { padding: 12px; border: 1px solid #ddd; border-radius: 8px; }
        .form-control:focus { border-color: var(--primary-red); box-shadow: 0 0 0 0.2rem rgba(231, 76, 60, 0.25); }

        .summary-row { display: flex; justify-content: space-between; margin-bottom: 10px; color: #666; }
        .summary-row.total { font-size: 18px; font-weight: bold; color: #333; margin-top: 15px; padding-top: 15px; border-top: 2px solid #f0f0f0; }
        .price { color: var(--primary-red); font-weight: bold; }
        .total-price { font-size: 24px; color: var(--primary-red); }

        .btn-submit { background: var(--primary-red); color: white; border: none; padding: 15px;
            width: 100%; border-radius: 8px; font-size: 16px; font-weight: 500;
            transition: all 0.3s; margin-top: 20px; }
        .btn-submit:hover { background: var(--dark-red); transform: translateY(-2px); }

        .address-item-modal:hover { border-color: var(--primary-red) !important; background: #fff5f5 !important; }

        .error-alert { background: #f8d7da; color: #721c24; padding: 12px; border-radius: 8px;
            margin-bottom: 20px; border: 1px solid #f5c6cb; }
    </style>
</head>
<body>

<jsp:include page="common/navbar.jsp"/>

<div class="checkout-container">
    <h3 class="mb-4"><i class="bi bi-credit-card"></i> 确认订单</h3>

    <!-- 展示表单验证或业务处理产生的错误信息 -->
    <c:if test="${not empty error}">
        <div class="error-alert">
            <i class="bi bi-exclamation-circle"></i> ${error}
        </div>
    </c:if>

    <div class="row">
        <div class="col-lg-8">
            <div class="section-card">
                <div class="section-title">商品清单</div>
                <c:forEach items="${selectedItems}" var="item">
                    <div class="product-item">
                        <img src="${item.productPic}" alt="${item.productName}"
                             onerror="this.src='https://via.placeholder.com/80?text=暂无图'">
                        <div class="product-info">
                            <div class="product-name">${item.productName}</div>
                            <div class="product-price">
                                ¥<fmt:formatNumber value="${item.productPrice}" pattern="#0.00"/>
                                <span class="product-qty">× ${item.quantity}</span>
                            </div>
                        </div>
                        <div class="product-price">
                            ¥<fmt:formatNumber value="${item.subtotal}" pattern="#0.00"/>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <div class="section-card">
                <div class="section-title">收货地址</div>

                <!-- 根据是否存在默认地址展示不同内容：有则显示详情，无则引导添加 -->
                <c:choose>
                    <c:when test="${not empty defaultAddress}">
                        <div class="address-display has-address" id="currentAddressDisplay">
                            <div class="address-header">
                                <div>
                                    <span class="address-name" id="displayName">${defaultAddress.receiverName}</span>
                                    <span class="address-phone" id="displayPhone">${defaultAddress.receiverPhone}</span>
                                    <span class="default-badge">默认</span>
                                </div>
                            </div>
                            <div class="address-detail" id="displayAddress">
                                ${defaultAddress.province}${defaultAddress.city}${defaultAddress.district}${defaultAddress.detailAddress}
                            </div>
                            <div class="address-actions">
                                <a href="address" class="btn-edit-address">
                                    <i class="bi bi-pencil"></i> 编辑地址
                                </a>
                                <c:if test="${fn:length(allAddresses) > 1}">
                                <a href="javascript:void(0)" class="btn-change-address" data-bs-toggle="modal" data-bs-target="#addressSelectModal">
                                    <i class="bi bi-list-ul"></i> 选择其他地址
                                </a>
                                </c:if>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="no-address">
                            <i class="bi bi-geo-alt"></i>
                            <p class="mb-3">暂无收货地址，请先添加</p>
                            <a href="address" class="btn-edit-address">
                                <i class="bi bi-plus-circle"></i> 添加收货地址
                            </a>
                        </div>
                    </c:otherwise>
                </c:choose>

                <!-- 地址选择模态框 -->
                <c:if test="${not empty allAddresses}">
                <div class="modal fade" id="addressSelectModal" tabindex="-1">
                    <div class="modal-dialog modal-dialog-scrollable">
                        <div class="modal-content">
                            <div class="modal-header" style="background:#e74c3c;color:white;">
                                <h5 class="modal-title"><i class="bi bi-geo-alt"></i> 选择收货地址</h5>
                                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                            </div>
                            <div class="modal-body">
                                <c:forEach items="${allAddresses}" var="addr">
                                <div class="address-item-modal ${addr.isDefault() ? 'selected' : ''}" onclick="selectAddress(this, '${addr.receiverName}', '${addr.receiverPhone}', '${addr.province}${addr.city}${addr.district}${addr.detailAddress}')" data-id="${addr.id}" style="border:1px solid ${addr.isDefault() ? '#e74c3c' : '#e0e0e0'};border-radius:8px;padding:15px;margin-bottom:10px;cursor:pointer;background:${addr.isDefault() ? '#fff5f5' : 'white'};">
                                    <div style="font-weight:600;margin-bottom:5px;">
                                        ${addr.receiverName}
                                        <span style="color:#666;font-weight:400;margin-left:10px;">${addr.receiverPhone}</span>
                                        <c:if test="${addr.isDefault()}"><span style="background:#e74c3c;color:white;font-size:11px;padding:2px 8px;border-radius:10px;margin-left:8px;">默认</span></c:if>
                                    </div>
                                    <div style="color:#666;font-size:14px;">${addr.province}${addr.city}${addr.district}${addr.detailAddress}</div>
                                </div>
                                </c:forEach>
                            </div>
                            <div class="modal-footer">
                                <a href="address" class="btn btn-danger btn-sm">管理地址</a>
                                <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">关闭</button>
                            </div>
                        </div>
                    </div>
                </div>
                </c:if>
            </div>

            <form action="checkout" method="post" id="orderForm" class="section-card">
                <input type="hidden" name="action" value="submit">

                <c:if test="${not empty defaultAddress}">
                    <input type="hidden" name="receiverName" value="${defaultAddress.receiverName}">
                    <input type="hidden" name="receiverPhone" value="${defaultAddress.receiverPhone}">
                    <input type="hidden" name="receiverAddress" value="${defaultAddress.fullAddress}">
                </c:if>

                <div class="form-group">
                    <label class="form-label">订单备注</label>
                    <input type="text" name="remark" class="form-control"
                           placeholder="选填：给商家的留言（如配送时间要求等）">
                </div>

                <!-- 支付方式 -->
                <div class="section-title">支付方式</div>
                <div style="display:flex;gap:16px;flex-wrap:wrap;">
                    <label style="border:1.5px solid #e74c3c;border-radius:8px;padding:12px 20px;cursor:pointer;display:flex;align-items:center;gap:8px;background:#fff5f5;" class="pay-method-label">
                        <input type="radio" name="payMethod" value="alipay" checked style="accent-color:#e74c3c;"> 支付宝
                    </label>
                    <label style="border:1.5px solid #ddd;border-radius:8px;padding:12px 20px;cursor:pointer;display:flex;align-items:center;gap:8px;" class="pay-method-label">
                        <input type="radio" name="payMethod" value="wechat" style="accent-color:#e74c3c;"> 微信支付
                    </label>
                    <label style="border:1.5px solid #ddd;border-radius:8px;padding:12px 20px;cursor:pointer;display:flex;align-items:center;gap:8px;" class="pay-method-label">
                        <input type="radio" name="payMethod" value="bank" style="accent-color:#e74c3c;"> 银行卡
                    </label>
                </div>

                <!-- 积分抵扣 -->
                <div class="form-group mt-3">
                    <label class="form-label">
                        积分抵扣
                        <c:choose>
                            <c:when test="${userJf > 0}">
                                <span style="font-size:12px;color:#999;font-weight:400;">
                                    （您有 <strong style="color:#e74c3c;">${userJf}</strong> 积分，每100积分抵 ¥1，最多可抵 ¥<fmt:formatNumber value="${totalAmount * 0.5}" pattern="#0.00"/>）
                                </span>
                            </c:when>
                            <c:otherwise>
                                <span style="font-size:12px;color:#999;font-weight:400;">（暂无可用积分）</span>
                            </c:otherwise>
                        </c:choose>
                    </label>
                    <div style="display:flex;gap:10px;align-items:center;">
                        <input type="number" id="usePoints" name="usePoints" class="form-control"
                               placeholder="0 表示不使用积分" style="flex:1;" min="0" max="${userJf}" value="0"
                               oninput="updateDiscount()" ${userJf == 0 ? 'disabled' : ''}>
                    </div>
                    <span id="pointsMsg" style="font-size:12px;color:#999;"></span>
                </div>

                <!-- 优惠券抵扣 -->
                <div class="form-group mt-3">
                    <label class="form-label">优惠券抵扣</label>
                    <c:choose>
                        <c:when test="${not empty coupons}">
                            <c:forEach items="${coupons}" var="cp" varStatus="cps">
                                <div style="display:flex;align-items:center;gap:10px;border:1.5px solid #ddd;border-radius:8px;padding:12px 16px;margin-bottom:8px;cursor:pointer;transition:all 0.2s;background:#fff;" class="coupon-item" onclick="toggleCoupon(this, ${cp.ucId}, ${cp.value}, '${cp.type}', ${cp.minAmount}, ${cps.index})" data-index="${cps.index}">
                                    <input type="radio" name="couponUcId" value="${cp.ucId}" style="display:none;">
                                    <div style="flex:1;">
                                        <div style="font-weight:600;font-size:14px;color:#333;">${cp.name}</div>
                                        <div style="font-size:12px;color:#999;">
                                            满 ¥<fmt:formatNumber value="${cp.minAmount}" pattern="#0"/> 可用
                                            <c:if test="${not empty cp.endDate}"> | 至 ${cp.endDate}</c:if>
                                        </div>
                                    </div>
                                    <div style="font-size:22px;font-weight:700;color:#e74c3c;">
                                        <c:choose>
                                            <c:when test="${cp.type == '满减' || cp.type == 'reduce'}">¥<fmt:formatNumber value="${cp.value}" pattern="#0"/></c:when>
                                            <c:otherwise>${cp.value}折</c:otherwise>
                                        </c:choose>
                                    </div>
                                    <span class="coupon-check" style="display:none;color:#27ae60;font-size:20px;"><i class="bi bi-check-circle-fill"></i></span>
                                </div>
                            </c:forEach>
                            <div style="text-align:right;margin-top:4px;">
                                <a href="javascript:void(0)" id="clearCouponBtn" style="font-size:12px;color:#999;text-decoration:none;display:none;" onclick="clearCoupon()">取消优惠券</a>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <span style="font-size:13px;color:#999;">暂无可用优惠券</span>
                            <input type="hidden" name="couponUcId" value="0">
                        </c:otherwise>
                    </c:choose>
                </div>
            </form>
        </div>

        <div class="col-lg-4">
            <div class="section-card" style="position: sticky; top: 100px;">
                <div class="section-title">订单汇总</div>

                <div class="summary-row">
                    <span>商品件数</span>
                    <span>${totalCount} 件</span>
                </div>
                <div class="summary-row">
                    <span>商品总价</span>
                    <span class="price">¥<fmt:formatNumber value="${totalAmount}" pattern="#0.00"/></span>
                </div>
                <div class="summary-row">
                    <span>运费</span>
                    <span class="text-success">免运费</span>
                </div>
                <div class="summary-row" id="pointsRow" style="display:none;">
                    <span>积分抵扣</span>
                    <span style="color:var(--primary-green);" id="pointsText">-¥0.00</span>
                </div>

                <div class="summary-row" id="couponRow" style="display:none;">
                    <span>优惠券抵扣</span>
                    <span style="color:var(--primary-green);" id="couponText">-¥0.00</span>
                </div>

                <div class="summary-row total">
                    <span>应付总额</span>
                    <span class="total-price" id="finalTotal">¥<fmt:formatNumber value="${totalAmount}" pattern="#0.00"/></span>
                </div>

                <!-- 提交订单按钮：关联到上方的 orderForm 表单 -->
                <button type="submit" form="orderForm" class="btn-submit">
                    <i class="bi bi-check-circle"></i> 提交订单
                </button>

                <div class="text-center mt-3">
                    <a href="index" class="btn btn-secondary">
                        <i class="bi bi-shop"></i> 继续购物
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>

    // 支付方式切换样式
    document.querySelectorAll('.pay-method-label').forEach(function(label) {
        label.addEventListener('click', function() {
            document.querySelectorAll('.pay-method-label').forEach(function(l) {
                l.style.borderColor = '#ddd';
                l.style.background = '#fff';
            });
            this.style.borderColor = '#e74c3c';
            this.style.background = '#fff5f5';
        });
    });

    // 优惠券交互（自由切换/取消）
    var totalAmount = ${totalAmount};
    var userJf = ${userJf};
    var selectedCouponDiscount = 0;
    var selectedCouponIndex = -1;

    function toggleCoupon(el, ucId, value, type, minAmount, index) {
        if (selectedCouponIndex === index) { clearCoupon(); return; }
        document.querySelectorAll('.coupon-item').forEach(function(item, i) {
            item.style.borderColor = '#ddd'; item.style.background = '#fff';
            var ck = item.querySelector('.coupon-check'); if (ck) ck.style.display = 'none';
        });
        el.style.borderColor = '#e74c3c'; el.style.background = '#fff5f5';
        var ck = el.querySelector('.coupon-check'); if (ck) ck.style.display = 'inline';
        var radio = el.querySelector('input[type="radio"]'); if (radio) radio.checked = true;
        ensureCouponHidden(ucId);
        selectedCouponIndex = index;
        if (totalAmount < minAmount) { selectedCouponDiscount = 0; document.getElementById('couponRow').style.display = 'none'; }
        else {
            selectedCouponDiscount = (type === '满减' || type === 'reduce') ? Math.min(value, totalAmount) : Math.round(totalAmount * (100 - value) / 100 * 100) / 100;
        }
        document.getElementById('clearCouponBtn').style.display = 'inline';
        updateDiscount();
    }

    function clearCoupon() {
        selectedCouponIndex = -1; selectedCouponDiscount = 0;
        document.querySelectorAll('.coupon-item').forEach(function(item) {
            item.style.borderColor = '#ddd'; item.style.background = '#fff';
            var ck = item.querySelector('.coupon-check'); if (ck) ck.style.display = 'none';
            var radio = item.querySelector('input[type="radio"]'); if (radio) radio.checked = false;
        });
        document.getElementById('couponRow').style.display = 'none';
        document.getElementById('clearCouponBtn').style.display = 'none';
        var hid = document.getElementById('couponUcIdInput'); if (hid) hid.value = '0';
        updateDiscount();
    }

    function ensureCouponHidden(ucId) {
        var hid = document.getElementById('couponUcIdInput');
        if (!hid) { hid = document.createElement('input'); hid.type = 'hidden'; hid.name = 'couponUcId'; hid.id = 'couponUcIdInput'; document.getElementById('orderForm').appendChild(hid); }
        hid.value = ucId;
    }

    function updateDiscount() {
        var input = document.getElementById('usePoints');
        var val = parseInt(input ? input.value : 0) || 0;
        if (val < 0) val = 0;
        if (val > userJf) val = userJf;
        var maxByAmount = Math.floor(totalAmount * 50);
        if (val > maxByAmount) val = maxByAmount;
        if (input) input.value = val;

        var pointsDiscount = val / 100;
        var pointsFix = Math.round(pointsDiscount * 100) / 100;

        var finalAmount = totalAmount - selectedCouponDiscount - pointsFix;
        if (finalAmount < 0) finalAmount = 0;
        finalAmount = Math.round(finalAmount * 100) / 100;

        var pointsRow = document.getElementById('pointsRow');
        var pointsText = document.getElementById('pointsText');
        var couponRow = document.getElementById('couponRow');
        var couponText = document.getElementById('couponText');
        var finalTotal = document.getElementById('finalTotal');
        var msg = document.getElementById('pointsMsg');

        if (selectedCouponDiscount > 0) {
            couponRow.style.display = 'flex';
            couponText.textContent = '-¥' + selectedCouponDiscount.toFixed(2);
        } else {
            couponRow.style.display = 'none';
        }

        if (val > 0) {
            pointsRow.style.display = 'flex';
            pointsText.textContent = '-¥' + pointsFix.toFixed(2);
            msg.textContent = '使用 ' + val + ' 积分，抵扣 ¥' + pointsFix.toFixed(2);
            msg.style.color = '#27ae60';
        } else {
            pointsRow.style.display = 'none';
            msg.textContent = '';
        }

        finalTotal.textContent = '¥' + finalAmount.toFixed(2);
    }

    // ── 表单提交前校验 ──
    document.getElementById('orderForm').addEventListener('submit', function(e) {
        var name = document.getElementsByName('receiverName')[0];
        var phone = document.getElementsByName('receiverPhone')[0];
        var addr = document.getElementsByName('receiverAddress')[0];
        if (!name || !name.value || name.value.trim() === '') {
            e.preventDefault(); alert('请选择收货地址'); return;
        }
        if (!phone || !phone.value || !phone.value.match(/^1[3-9]\d{9}$/)) {
            e.preventDefault(); alert('请填写有效的收货人手机号'); return;
        }
        if (!addr || !addr.value || addr.value.trim() === '') {
            e.preventDefault(); alert('请选择收货地址'); return;
        }
    });

    // ── 应付金额变化动画 ──
    var finalTotalEl = document.getElementById('finalTotal');
    var observer = new MutationObserver(function() {
        finalTotalEl.style.transition = 'all 0.3s ease';
        finalTotalEl.style.transform = 'scale(1.1)';
        finalTotalEl.style.color = '#ff6b6b';
        setTimeout(function() {
            finalTotalEl.style.transform = 'scale(1)';
            finalTotalEl.style.color = '#e74c3c';
        }, 300);
    });
    observer.observe(finalTotalEl, { childList: true, characterData: true, subtree: true });

    function selectAddress(el, name, phone, address) {
        document.querySelectorAll('.address-item-modal').forEach(function(item) {
            item.style.borderColor = '#e0e0e0';
            item.style.background = 'white';
        });
        el.style.borderColor = '#e74c3c';
        el.style.background = '#fff5f5';
        document.getElementById('displayName').textContent = name;
        document.getElementById('displayPhone').textContent = phone;
        document.getElementById('displayAddress').textContent = address;
        // 更新隐藏域
        document.getElementsByName('receiverName')[0].value = name;
        document.getElementsByName('receiverPhone')[0].value = phone;
        document.getElementsByName('receiverAddress')[0].value = address;
        // 关闭模态框
        var modal = bootstrap.Modal.getInstance(document.getElementById('addressSelectModal'));
        if (modal) modal.hide();
    }
</script>
</body>
</html>