<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>限时秒杀 - 花店商城</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="css/common.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { background: #f5f5f5; }

        /* 导航栏 */
        .navbar {
            background: #fff;
            position: sticky;
            top: 0;
            z-index: 1000;
            box-shadow: 0 2px 12px rgba(0,0,0,0.08);
        }
        .navbar .container {
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
            font-size: 22px;
            letter-spacing: 2px;
            background: linear-gradient(135deg, var(--primary-red) 0%, #ff6b6b 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-decoration: none;
            cursor: pointer;
        }
        .nav-links {
            display: flex;
            gap: 20px;
            list-style: none;
            align-items: center;
            margin: 0;
            padding: 0;
        }
        .nav-links a {
            color: #555;
            text-decoration: none;
            font-size: 14px;
            transition: all 0.2s;
            padding: 6px 12px;
            border-radius: 6px;
        }
        .nav-links a:hover { color: var(--primary-red); background: #fff5f5; }
        .nav-links .active-link { color: var(--primary-red); font-weight: 600; }

        /* 页面头部 */
        .page-header {
            background: linear-gradient(135deg, #e74c3c 0%, #ff6b6b 100%);
            color: white;
            padding: 40px 0;
            text-align: center;
        }
        .page-header h1 {
            font-size: 32px;
            font-weight: 700;
            margin-bottom: 8px;
        }
        .page-header p {
            font-size: 16px;
            opacity: 0.9;
        }

        /* 主体区域 */
        .main {
            max-width: 1200px;
            margin: 30px auto;
            padding: 0 15px;
        }

        /* 秒杀卡片 */
        .seckill-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 24px;
        }

        .seckill-card {
            background: white;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            transition: all 0.3s;
            position: relative;
        }
        .seckill-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 8px 24px rgba(0,0,0,0.12);
        }

        .seckill-card .card-image {
            position: relative;
            aspect-ratio: 4/3;
            overflow: hidden;
        }
        .seckill-card .card-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.3s;
        }
        .seckill-card:hover .card-image img {
            transform: scale(1.05);
        }

        /* 秒杀标签 */
        .seckill-tag {
            position: absolute;
            top: 10px;
            left: 10px;
            background: linear-gradient(135deg, #e74c3c, #ff6b6b);
            color: white;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 4px;
            z-index: 2;
        }

        .seckill-card .card-body {
            padding: 16px;
        }

        .seckill-card .product-name {
            font-size: 16px;
            font-weight: 600;
            color: #333;
            margin-bottom: 10px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .seckill-card .product-name a {
            color: inherit;
            text-decoration: none;
        }
        .seckill-card .product-name a:hover {
            color: var(--primary-red);
        }

        /* 价格区域 */
        .price-row {
            display: flex;
            align-items: baseline;
            gap: 10px;
            margin-bottom: 10px;
        }
        .seckill-price {
            font-size: 24px;
            font-weight: 700;
            color: var(--primary-red);
        }
        .original-price {
            font-size: 14px;
            color: #999;
            text-decoration: line-through;
        }

        /* 库存和倒计时 */
        .info-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 12px;
            font-size: 13px;
            color: #666;
        }
        .stock-info { color: #999; }
        .stock-low { color: var(--primary-red); font-weight: 500; }
        .countdown {
            color: var(--primary-red);
            font-weight: 600;
            font-family: monospace;
        }

        /* 进度条 */
        .progress-bar-wrapper {
            height: 6px;
            background: #f0f0f0;
            border-radius: 3px;
            margin-bottom: 12px;
            overflow: hidden;
        }
        .progress-bar-inner {
            height: 100%;
            background: linear-gradient(90deg, #e74c3c, #ff6b6b);
            border-radius: 3px;
            transition: width 0.5s;
        }

        /* 按钮 */
        .seckill-btn {
            width: 100%;
            padding: 10px;
            border: none;
            border-radius: 8px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
        }
        .seckill-btn.active {
            background: linear-gradient(135deg, #e74c3c, #ff6b6b);
            color: white;
        }
        .seckill-btn.active:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(231, 76, 60, 0.4);
        }
        .seckill-btn.disabled {
            background: #e0e0e0;
            color: #999;
            cursor: not-allowed;
        }
        .seckill-btn.sold-out {
            background: #f5f5f5;
            color: #ccc;
            cursor: not-allowed;
        }

        /* 状态标签 */
        .status-badge {
            position: absolute;
            top: 10px;
            right: 10px;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            z-index: 2;
        }
        .badge-waiting {
            background: rgba(0,0,0,0.6);
            color: white;
        }
        .badge-ended {
            background: rgba(0,0,0,0.5);
            color: white;
        }
        .badge-soldout {
            background: #999;
            color: white;
        }

        /* 错误/成功提示 */
        .alert-message {
            max-width: 1200px;
            margin: 15px auto;
            padding: 0 15px;
        }

        /* 空状态 */
        .empty-state {
            text-align: center;
            padding: 80px 20px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
        }
        .empty-state .empty-icon {
            font-size: 64px;
            color: #ddd;
            margin-bottom: 20px;
        }
        .empty-state h4 {
            color: #666;
            font-weight: normal;
            margin-bottom: 10px;
        }
        .empty-state p {
            color: #999;
            font-size: 14px;
        }

        @media (max-width: 576px) {
            .seckill-grid {
                grid-template-columns: 1fr;
            }
            .page-header h1 { font-size: 24px; }
        }

        /* 版权说明模态框 */
        .copyright-modal {
            display: none;
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.5);
            z-index: 10000;
            align-items: center;
            justify-content: center;
        }
        .copyright-modal.show { display: flex; }
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
        .copyright-icon { font-size: 64px; margin-bottom: 20px; }
        .copyright-title {
            font-size: 28px;
            background: linear-gradient(135deg, var(--primary-red) 0%, #ff6b6b 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 20px;
            font-weight: 700;
        }
        .copyright-divider {
            width: 60px; height: 3px;
            background: linear-gradient(90deg, var(--primary-red) 0%, #ff6b6b 100%);
            margin: 0 auto 20px;
            border-radius: 2px;
        }
        .copyright-message { color: #666; font-size: 16px; line-height: 1.8; margin-bottom: 15px; }
        .copyright-warning {
            background: linear-gradient(135deg, #fff5f5 0%, #ffffff 100%);
            border-left: 4px solid var(--primary-red);
            padding: 15px 20px;
            border-radius: 8px;
            margin: 20px 0;
            text-align: left;
        }
        .copyright-warning p { color: #666; font-size: 14px; margin: 0; line-height: 1.6; }
        .copyright-warning strong { color: var(--primary-red); }
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
        .copyright-btn:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(231,76,60,0.4); }
    </style>
</head>
<body>

<!-- 导航栏 -->
<nav class="navbar">
    <div class="container">
        <a href="javascript:void(0)" onclick="showCopyright()" class="brand">归途</a>
        <ul class="nav-links">
            <li><a href="index.jsp">首页</a></li>
            <li><a href="seckill?action=list" class="active-link"><i class="bi bi-lightning-charge-fill"></i> 限时秒杀</a></li>
            <c:if test="${not empty sessionScope.username}">
                <li><a href="cart"><i class="bi bi-cart3"></i> 购物车</a></li>
                <li><a href="usercenter">${sessionScope.username}</a></li>
            </c:if>
            <c:if test="${empty sessionScope.username}">
                <li><a href="login.jsp">登录</a></li>
            </c:if>
        </ul>
    </div>
</nav>

<!-- 页面头部 -->
<div class="page-header">
    <h1><i class="bi bi-lightning-charge-fill"></i> 限时秒杀</h1>
    <p>超值好物限时抢，手快有手慢无！</p>
</div>

<!-- 错误/成功提示 -->
<c:if test="${not empty sessionScope.seckillError}">
    <div class="alert-message">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>${sessionScope.seckillError}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </div>
    <% session.removeAttribute("seckillError"); %>
</c:if>

<div class="main">
    <c:choose>
        <c:when test="${empty seckillList}">
            <div class="empty-state">
                <div class="empty-icon"><i class="bi bi-lightning"></i></div>
                <h4>暂无秒杀活动</h4>
                <p>敬请期待下一场秒杀活动</p>
                <a href="index.jsp" class="btn btn-outline-danger mt-3">返回首页</a>
            </div>
        </c:when>
        <c:otherwise>
            <div class="seckill-grid">
                <c:forEach items="${seckillList}" var="activity">
                    <div class="seckill-card" data-end-time="${activity.endTime.time}" data-start-time="${activity.startTime.time}" data-activity-id="${activity.id}">
                        <div class="card-image">
                            <!-- 秒杀标签 -->
                            <span class="seckill-tag">
                                <i class="bi bi-lightning-charge-fill"></i> 秒杀
                            </span>

                            <!-- 状态标签 -->
                            <c:choose>
                                <c:when test="${activity.status == 0}">
                                    <span class="status-badge badge-ended">已关闭</span>
                                </c:when>
                                <c:when test="${!activity.started}">
                                    <span class="status-badge badge-waiting">即将开始</span>
                                </c:when>
                                <c:when test="${activity.ended}">
                                    <span class="status-badge badge-ended">已结束</span>
                                </c:when>
                                <c:when test="${activity.seckillStock <= 0}">
                                    <span class="status-badge badge-soldout">已抢光</span>
                                </c:when>
                            </c:choose>

                            <a href="product/detail?id=${activity.productId}">
                                <img src="${activity.productPic}" alt="${activity.productName}"
                                     onerror="this.src='https://via.placeholder.com/400x300?text=暂无图片'">
                            </a>
                        </div>

                        <div class="card-body">
                            <div class="product-name">
                                <a href="product/detail?id=${activity.productId}">${activity.productName}</a>
                            </div>

                            <div class="price-row">
                                <span class="seckill-price">
                                    <small style="font-size:14px;">秒杀价</small>
                                    <fmt:formatNumber value="${activity.seckillPrice}" pattern="#0.00"/>
                                </span>
                                <span class="original-price">
                                    <fmt:formatNumber value="${activity.productPrice}" pattern="#0.00"/>
                                </span>
                            </div>

                            <div class="info-row">
                                <span class="stock-info">
                                    库存:
                                    <c:choose>
                                        <c:when test="${activity.seckillStock <= 0}">
                                            <span class="stock-low">已抢光</span>
                                        </c:when>
                                        <c:when test="${activity.seckillStock < 20}">
                                            <span class="stock-low">${activity.seckillStock}件</span>
                                        </c:when>
                                        <c:otherwise>
                                            ${activity.seckillStock}件
                                        </c:otherwise>
                                    </c:choose>
                                </span>
                                <c:if test="${activity.ongoing && activity.seckillStock > 0}">
                                    <span class="countdown" data-remaining="${activity.remainingSeconds}"></span>
                                </c:if>
                                <c:if test="${!activity.started && activity.status == 1}">
                                    <span class="countdown" data-start-remaining="${activity.startRemainingSeconds}">即将开始</span>
                                </c:if>
                            </div>

                            <!-- 进度条 -->
                            <c:if test="${activity.seckillStock > 0}">
                                <c:set var="totalSeckillStock" value="${activity.seckillStock + activity.soldCount}"/>
                                <c:set var="soldPercent" value="${totalSeckillStock > 0 ? (activity.soldCount * 100 / totalSeckillStock) : 0}"/>
                                <div class="progress-bar-wrapper">
                                    <div class="progress-bar-inner" style="width: ${soldPercent}%"></div>
                                </div>
                            </c:if>

                            <!-- 按钮 -->
                            <c:choose>
                                <c:when test="${activity.status == 0 || activity.ended}">
                                    <button class="seckill-btn disabled" disabled>
                                        <i class="bi bi-clock-history"></i> 活动已结束
                                    </button>
                                </c:when>
                                <c:when test="${!activity.started}">
                                    <button class="seckill-btn disabled" disabled>
                                        <i class="bi bi-hourglass-split"></i> 即将开始
                                    </button>
                                </c:when>
                                <c:when test="${activity.seckillStock <= 0}">
                                    <button class="seckill-btn sold-out" disabled>
                                        <i class="bi bi-emoji-frown"></i> 已抢光
                                    </button>
                                </c:when>
                                <c:otherwise>
                                    <a href="seckill?action=buy&seckillId=${activity.id}&quantity=1"
                                       class="seckill-btn active"
                                       onclick="return confirmBuy(this)">
                                        <i class="bi bi-lightning-charge-fill"></i> 立即抢购
                                    </a>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // 倒计时更新
    function updateCountdowns() {
        document.querySelectorAll('.countdown[data-remaining]').forEach(function(el) {
            var remaining = parseInt(el.getAttribute('data-remaining'));
            if (remaining > 0) {
                remaining--;
                el.setAttribute('data-remaining', remaining);
                el.textContent = formatTime(remaining);
            } else {
                el.textContent = '已结束';
                el.closest('.seckill-card').querySelector('.seckill-btn').className = 'seckill-btn disabled';
                el.closest('.seckill-card').querySelector('.seckill-btn').disabled = true;
                el.closest('.seckill-card').querySelector('.seckill-btn').innerHTML = '<i class="bi bi-clock-history"></i> 活动已结束';
            }
        });

        document.querySelectorAll('.countdown[data-start-remaining]').forEach(function(el) {
            var remaining = parseInt(el.getAttribute('data-start-remaining'));
            if (remaining > 0) {
                remaining--;
                el.setAttribute('data-start-remaining', remaining);
                el.textContent = '距开始 ' + formatTime(remaining);
            } else {
                location.reload();
            }
        });
    }

    function formatTime(seconds) {
        var h = Math.floor(seconds / 3600);
        var m = Math.floor((seconds % 3600) / 60);
        var s = seconds % 60;
        var parts = [];
        if (h > 0) parts.push(h + '时');
        parts.push(m + '分');
        parts.push(s + '秒');
        return parts.join('');
    }

    // 初始化倒计时显示
    document.querySelectorAll('.countdown[data-remaining]').forEach(function(el) {
        el.textContent = formatTime(parseInt(el.getAttribute('data-remaining')));
    });
    document.querySelectorAll('.countdown[data-start-remaining]').forEach(function(el) {
        el.textContent = '距开始 ' + formatTime(parseInt(el.getAttribute('data-start-remaining')));
    });

    setInterval(updateCountdowns, 1000);

    // 确认抢购
    function confirmBuy(el) {
        if (!confirm('确定要抢购此商品吗？')) return false;
        el.innerHTML = '<i class="bi bi-hourglass-split"></i> 抢购中...';
        el.className = 'seckill-btn disabled';
        return true;
    }
</script>

<!-- 版权说明模态框 -->
<div class="copyright-modal" id="copyrightModal">
    <div class="copyright-content">
        <div class="copyright-icon">🌸</div>
        <h2 class="copyright-title">关于「归途」</h2>
        <div class="copyright-divider"></div>
        <p class="copyright-message">「归途花店」是一款基于 Java Web 技术开发的电商学习项目</p>
        <div class="copyright-warning">
            <p><strong>⚠️ 声明：</strong>本项目仅供个人学习与技术研究使用，所有代码、设计及内容版权归开发者本人所有。</p>
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
        var modal = document.getElementById('copyrightModal');
        if (modal) { modal.addEventListener('click', function(e) { if (e.target === modal) closeCopyright(); }); }
    });
</script>
</body>
</html>
