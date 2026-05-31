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
    <style>
        :root { --primary-red: #e74c3c; --dark-red: #c0392b; --primary-green: #27ae60; --bg-gray: #f8f9fa;}

        body { font-family: "PingFang SC", "Microsoft YaHei", sans-serif; background: var(--bg-gray); }

        .navbar-brand { font-weight: 700; font-size: 22px; letter-spacing: 2px; background: linear-gradient(135deg, var(--primary-red) 0%, #ff6b6b 100%); -webkit-background-clip: text; -webkit-text-fill-color: transparent; transition: transform 0.2s; cursor: pointer; }
        .navbar-brand:hover { transform: scale(1.05); }
        .navbar-brand i { -webkit-text-fill-color: var(--primary-red); }

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

<nav class="navbar navbar-expand-lg bg-white border-bottom sticky-top mb-4">
    <div class="container">
        <a class="navbar-brand" href="javascript:void(0)" onclick="showCopyright()"> 归途</a>
        <div class="collapse navbar-collapse">
            <ul class="navbar-nav ms-auto">
                <li class="nav-item">
                    <a class="nav-link" href="cart"><i class="bi bi-cart3"></i> 返回购物车</a>
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
                               oninput="updatePointsDiscount()" ${userJf == 0 ? 'disabled' : ''}>
                    </div>
                    <span id="pointsMsg" style="font-size:12px;color:#999;"></span>
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

                <div class="summary-row total">
                    <span>应付总额</span>
                    <span class="total-price" id="finalTotal">¥<fmt:formatNumber value="${totalAmount}" pattern="#0.00"/></span>
                </div>

                <!-- 提交订单按钮：关联到上方的 orderForm 表单 -->
                <button type="submit" form="orderForm" class="btn-submit">
                    <i class="bi bi-check-circle"></i> 提交订单
                </button>

                <div class="text-center mt-3">
                    <a href="index.jsp" class="btn btn-secondary">
                        <i class="bi bi-shop"></i> 继续购物
                    </a>
                </div>
            </div>
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
            <p><strong>️ 声明：</strong>本项目仅供个人学习与技术研究使用，所有代码、设计及内容版权归开发者本人所有。</p>
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

    // 积分抵扣实时计算
    var totalAmount = ${totalAmount};
    var userJf = ${userJf};

    function updatePointsDiscount() {
        var input = document.getElementById('usePoints');
        var val = parseInt(input.value) || 0;
        if (val < 0) val = 0;
        if (val > userJf) val = userJf;
        // 最多抵50%订单金额 = totalAmount * 0.5 * 100 积分
        var maxByAmount = Math.floor(totalAmount * 50);
        if (val > maxByAmount) val = maxByAmount;
        input.value = val;

        var discount = val / 100;  // 100积分 = 1元
        var discountFix = Math.round(discount * 100) / 100;
        var finalAmount = totalAmount - discountFix;
        if (finalAmount < 0) finalAmount = 0;
        finalAmount = Math.round(finalAmount * 100) / 100;

        var pointsRow = document.getElementById('pointsRow');
        var pointsText = document.getElementById('pointsText');
        var finalTotal = document.getElementById('finalTotal');
        var msg = document.getElementById('pointsMsg');

        if (val > 0) {
            pointsRow.style.display = 'flex';
            pointsText.textContent = '-¥' + discountFix.toFixed(2);
            finalTotal.textContent = '¥' + finalAmount.toFixed(2);
            msg.textContent = '使用 ' + val + ' 积分，抵扣 ¥' + discountFix.toFixed(2);
            msg.style.color = '#27ae60';
        } else {
            pointsRow.style.display = 'none';
            finalTotal.textContent = '¥' + totalAmount.toFixed(2);
            msg.textContent = '';
        }
    }

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