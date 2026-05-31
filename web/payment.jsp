<!-- C:\Users\guitu\OneDrive\Desktop\guitushop\web\payment.jsp -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!-- 确定选中的支付方式：优先 URL 参数，其次 request 属性 -->
<c:set var="selectedPay" value="${not empty param.payMethod ? param.payMethod : payMethod}" />

<!-- 校验订单是否存在，若不存在则重定向至订单列表页 -->
<c:if test="${empty order}">
    <jsp:forward page="orders"/>
</c:if>

<!-- 校验订单状态是否为“待付款”，若非待付款状态则禁止进入支付页面 -->
<c:if test="${order.status != '待付款'}">
    <jsp:forward page="orders"/>
</c:if>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>订单支付 - 花店商城</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="css/common.css">
    <style>
        body { background: var(--bg-gray); }

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

        .payment-container {
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }

        .payment-card {
            background: white;
            border-radius: 12px;
            padding: 30px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            margin-bottom: 20px;
        }

        .order-summary {
            background: #f8f9fa;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 30px;
        }

        .order-info-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
            color: #666;
        }

        .order-info-row:last-child {
            margin-bottom: 0;
        }

        .order-total-amount {
            font-size: 28px;
            color: var(--primary-red);
            font-weight: bold;
            text-align: center;
            padding: 20px 0;
        }

        .payment-methods {
            margin: 30px 0;
        }

        .payment-method-title {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 20px;
            color: #333;
        }

        .payment-option {
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 15px;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
        }

        .payment-option:hover {
            border-color: var(--primary-red);
            background: #fff5f5;
        }

        .payment-option.active {
            border-color: var(--primary-red);
            background: #fff5f5;
        }

        .payment-option input[type="radio"] {
            margin-right: 15px;
            width: 20px;
            height: 20px;
        }

        .payment-icon {
            font-size: 32px;
            margin-right: 15px;
            color: var(--primary-red);
        }

        .payment-info {
            flex: 1;
        }

        .payment-name {
            font-weight: 600;
            font-size: 16px;
            color: #333;
            margin-bottom: 5px;
        }

        .payment-desc {
            font-size: 13px;
            color: #999;
        }

        .btn-pay-now {
            background: var(--primary-red);
            color: white;
            border: none;
            padding: 15px;
            width: 100%;
            border-radius: 8px;
            font-size: 18px;
            font-weight: 500;
            transition: all 0.3s;
            margin-top: 20px;
        }

        .btn-pay-now:hover {
            background: var(--dark-red);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(231, 76, 60, 0.3);
        }

        .btn-cancel {
            background: #6c757d;
            color: white;
            border: none;
            padding: 15px;
            width: 100%;
            border-radius: 8px;
            font-size: 16px;
            margin-top: 10px;
        }

        .btn-cancel:hover {
            background: #5a6268;
            color: white;
        }

        .security-tips {
            background: #d1ecf1;
            border: 1px solid #bee5eb;
            border-radius: 8px;
            padding: 15px;
            margin-top: 20px;
        }

        .security-tips i {
            color: #0c5460;
            margin-right: 8px;
        }

        .security-tips p {
            margin: 0;
            color: #0c5460;
            font-size: 14px;
        }

        @media (max-width: 576px) {
            .payment-container {
                padding: 10px;
            }
            
            .payment-card {
                padding: 20px;
            }
        }
    </style>
</head>
<body>

<nav style="background:#fff;padding:0;position:sticky;top:0;z-index:1000;box-shadow:0 2px 12px rgba(0,0,0,0.08);margin-bottom:1.5rem;">
    <div style="max-width:1200px;margin:0 auto;padding:0 20px;display:flex;align-items:center;justify-content:space-between;height:70px;">
        <a href="javascript:void(0)" onclick="showCopyright()" style="font-weight:700;font-size:22px;letter-spacing:2px;background:linear-gradient(135deg,#e74c3c,#ff6b6b);-webkit-background-clip:text;-webkit-text-fill-color:transparent;cursor:pointer;text-decoration:none;">归途</a>
        <ul style="display:flex;gap:20px;list-style:none;align-items:center;margin:0;padding:0;">
            <li><span style="color:#555;font-size:14px;">欢迎，${sessionScope.username}</span></li>
            <li><a href="orders" style="color:#555;text-decoration:none;font-size:14px;padding:6px 12px;border-radius:6px;transition:all 0.2s;" onmouseover="this.style.color='#e74c3c';this.style.background='#fff5f5'" onmouseout="this.style.color='#555';this.style.background='transparent'">我的订单</a></li>
            <c:if test="${sessionScope.userRole == '管理员'}">
            <li><a href="admin/index" style="color:#e74c3c;text-decoration:none;font-size:14px;font-weight:600;padding:6px 12px;border-radius:6px;transition:all 0.2s;" onmouseover="this.style.background='#fff5f5'" onmouseout="this.style.background='transparent'">管理中心</a></li>
            </c:if>
        </ul>
    </div>
</nav>

<div class="payment-container">
    <h3 class="mb-4">
        <i class="bi bi-credit-card"></i> 订单支付
    </h3>

    <div class="payment-card">
        <!-- 订单信息摘要：展示订单号、时间、数量及收货详情 -->
        <div class="order-summary">
            <h5 class="mb-3">订单信息</h5>
            <div class="order-info-row">
                <span>订单号：</span>
                <span class="fw-bold">${order.orderId}</span>
            </div>
            <div class="order-info-row">
                <span>下单时间：</span>
                <span><fmt:formatDate value="${order.createTime}" pattern="yyyy-MM-dd HH:mm"/></span>
            </div>
            <div class="order-info-row">
                <span>商品数量：</span>
                <span>${order.totalCount} 件</span>
            </div>
            <div class="order-info-row">
                <span>收货人：</span>
                <span>${order.receiverName} ${order.receiverPhone}</span>
            </div>
            <div class="order-info-row">
                <span>收货地址：</span>
                <span>${order.receiverAddress}</span>
            </div>
        </div>

        <div class="order-total-amount">
            ¥<fmt:formatNumber value="${order.totalAmount}" pattern="#0.00"/>
        </div>

        <!-- 支付方式选择区域：支持支付宝、微信及银行卡支付 -->
        <div class="payment-methods">
            <div class="payment-method-title">选择支付方式</div>
            
            <form action="payment" method="post" id="paymentForm">
                <input type="hidden" name="orderId" value="${order.orderId}">
                <input type="hidden" name="action" value="pay">
                
                <label class="payment-option ${empty selectedPay || selectedPay == 'alipay' ? 'active' : ''}">
                    <input type="radio" name="payMethod" value="alipay" ${empty selectedPay || selectedPay == 'alipay' ? 'checked' : ''}>
                    <i class="bi bi-qr-code payment-icon"></i>
                    <div class="payment-info">
                        <div class="payment-name">支付宝支付</div>
                        <div class="payment-desc">推荐使用，安全快捷</div>
                    </div>
                </label>

                <label class="payment-option ${selectedPay == 'wechat' ? 'active' : ''}">
                    <input type="radio" name="payMethod" value="wechat" ${selectedPay == 'wechat' ? 'checked' : ''}>
                    <i class="bi bi-chat-dots payment-icon"></i>
                    <div class="payment-info">
                        <div class="payment-name">微信支付</div>
                        <div class="payment-desc">微信扫码支付</div>
                    </div>
                </label>

                <label class="payment-option ${selectedPay == 'bank' ? 'active' : ''}">
                    <input type="radio" name="payMethod" value="bank" ${selectedPay == 'bank' ? 'checked' : ''}>
                    <i class="bi bi-bank payment-icon"></i>
                    <div class="payment-info">
                        <div class="payment-name">银行卡支付</div>
                        <div class="payment-desc">支持各大银行借记卡/信用卡</div>
                    </div>
                </label>
            </form>
        </div>

        <!-- 提交支付按钮：关联到上方的 paymentForm 表单 -->
        <button type="submit" form="paymentForm" class="btn-pay-now">
            <i class="bi bi-shield-check"></i> 立即支付 ¥<fmt:formatNumber value="${order.totalAmount}" pattern="#0.00"/>
        </button>

        <a href="orders" class="btn btn-cancel">
            <i class="bi bi-arrow-left"></i> 返回订单列表
        </a>

        <div class="security-tips">
            <p>
                <i class="bi bi-shield-lock"></i>
                安全提示：请确认订单信息无误后再进行支付，支付过程受银行级别安全保护
            </p>
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

    // 监听支付方式选项点击事件，切换选中状态的视觉样式
    document.querySelectorAll('.payment-option').forEach(option => {
        option.addEventListener('click', function() {
            document.querySelectorAll('.payment-option').forEach(opt => {
                opt.classList.remove('active');
            });
            this.classList.add('active');
        });
    });
</script>
</body>
</html>
