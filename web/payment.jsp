<!-- C:\Users\guitu\OneDrive\Desktop\guitushop\web\payment.jsp -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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

<jsp:include page="common/navbar.jsp"/>

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
