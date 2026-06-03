<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:if test="${empty sessionScope.userId || sessionScope.userRole != '管理员'}">
    <jsp:forward page="/login.jsp"/>
</c:if>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>商业智能仪表盘 - 归途花店</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="css/common.css">
    <style>
        body { font-family: "PingFang SC","Microsoft YaHei",sans-serif; background: #f5f6fa; }
        .admin-header { background: #2c3e50; color: white; padding: 15px 0; }
        .admin-container { max-width: 1400px; margin: 30px auto; padding: 0 15px; }
        .chart-card {
            background: white; border-radius: 12px; padding: 18px;
            box-shadow: 0 1px 4px rgba(0,0,0,.06); margin-bottom: 20px; height: 100%;
        }
        .chart-card h6 { font-size: 14px; font-weight: 600; color: #333; margin-bottom: 12px; padding-bottom: 8px; border-bottom: 1px solid #eee; display: flex; align-items: center; gap: 6px; }
        .chart-box { position: relative; height: 240px; width: 100%; }
        .stat-card {
            background: white; border-radius: 12px; padding: 20px; text-align: center;
            box-shadow: 0 1px 4px rgba(0,0,0,.06);
        }
        .stat-num { font-size: 28px; font-weight: 700; }
        .stat-label { color: #666; font-size: 13px; margin-top: 4px; }
        .refresh-bar { font-size: 12px; color: #999; display: flex; align-items: center; justify-content: flex-end; gap: 12px; }
    </style>
</head>
<body>
<nav class="admin-header">
    <div class="container d-flex justify-content-between align-items-center">
        <h5 class="mb-0"><i class="bi bi-bar-chart-line me-2"></i>商业智能仪表盘</h5>
        <div class="refresh-bar">
            <span>⏱ <span id="refreshTime"><fmt:formatDate value="<%=new java.util.Date()%>" pattern="HH:mm:ss"/></span></span>
            <span>管理员：${sessionScope.username}</span>
            <a href="${pageContext.request.contextPath}/admin/index" class="btn btn-sm btn-light">← 返回后台</a>
        </div>
    </div>
</nav>

<div class="admin-container">
    <!-- 核心 KPI -->
    <div class="row g-3 mb-4">
        <div class="col-6 col-md-3"><div class="stat-card"><div class="stat-num" style="color:#3498db;">${stats.totalUsers}</div><div class="stat-label">👤 总用户数</div></div></div>
        <div class="col-6 col-md-3"><div class="stat-card"><div class="stat-num" style="color:#27ae60;">${stats.totalOrders}</div><div class="stat-label">📦 总订单数</div></div></div>
        <div class="col-6 col-md-3"><div class="stat-card"><div class="stat-num" style="color:#f39c12;">¥<fmt:formatNumber value="${stats.totalSales}" pattern="#,##0"/></div><div class="stat-label">💰 总销售额</div></div></div>
        <div class="col-6 col-md-3"><div class="stat-card"><div class="stat-num" style="color:#9b59b6;">${stats.totalProducts}</div><div class="stat-label">🏷️ 总商品数</div></div></div>
    </div>

    <!-- 第一行图表 -->
    <div class="row g-3">
        <div class="col-md-4"><div class="chart-card">
            <h6><i class="bi bi-people" style="color:#e74c3c;"></i>性别比例</h6>
            <div class="chart-box"><canvas id="genderChart"></canvas></div>
        </div></div>
        <div class="col-md-4"><div class="chart-card">
            <h6><i class="bi bi-bar-chart" style="color:#3498db;"></i>年龄分布</h6>
            <div class="chart-box"><canvas id="ageChart"></canvas></div>
        </div></div>
        <div class="col-md-4"><div class="chart-card">
            <h6><i class="bi bi-phone" style="color:#27ae60;"></i>网购习惯</h6>
            <div class="chart-box"><canvas id="habitChart"></canvas></div>
        </div></div>
    </div>

    <!-- 第二行图表 -->
    <div class="row g-3 mt-1">
        <div class="col-md-4"><div class="chart-card">
            <h6><i class="bi bi-pie-chart" style="color:#f39c12;"></i>订单状态分布</h6>
            <div class="chart-box"><canvas id="orderChart"></canvas></div>
        </div></div>
        <div class="col-md-4"><div class="chart-card">
            <h6><i class="bi bi-geo-alt" style="color:#9b59b6;"></i>购买区域 TOP10</h6>
            <div class="chart-box"><canvas id="regionChart"></canvas></div>
        </div></div>
        <div class="col-md-4"><div class="chart-card">
            <h6><i class="bi bi-trophy" style="color:#e67e22;"></i>热销商品 TOP10</h6>
            <div class="chart-box" style="height:260px;"><canvas id="topChart"></canvas></div>
        </div></div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2.2.0/dist/chartjs-plugin-datalabels.min.js"></script>
<script>
Chart.register(ChartDataLabels);

var COLORS = ['#e74c3c','#3498db','#2ecc71','#f39c12','#9b59b6','#1abc9c','#e67e22','#95a5a6','#34495e','#16a085'];

function pct(v, total) { return total > 0 ? (v / total * 100).toFixed(1) + '%' : '0%'; }

// 1. 性别
var gLabels = [], gValues = [], gTotal = 0;
<c:forEach items="${stats.genderStats}" var="e">gLabels.push('${e.key}'); gValues.push(${e.value}); gTotal += ${e.value};</c:forEach>
if (!gLabels.length) { gLabels = ['暂无']; gValues = [1]; gTotal = 1; }
new Chart(document.getElementById('genderChart'), {
    type: 'pie', data: { labels: gLabels, datasets: [{ data: gValues, backgroundColor: ['#3498db','#e74c3c','#95a5a6'] }] },
    options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'bottom', labels: { font: { size: 11 } } }, datalabels: { color: '#fff', font: { weight: 'bold', size: 11 }, formatter: function(v) { return v + ' (' + pct(v, gTotal) + ')'; } } } }
});

// 2. 年龄
var ageLabels = [], ageValues = [], ageTotal = 0;
<c:forEach items="${stats.ageStats}" var="e">ageLabels.push('${e.key}'); ageValues.push(${e.value}); ageTotal += ${e.value};</c:forEach>
new Chart(document.getElementById('ageChart'), {
    type: 'bar', data: { labels: ageLabels, datasets: [{ data: ageValues, backgroundColor: COLORS.slice(0,5), borderRadius: 4 }] },
    options: { responsive: true, maintainAspectRatio: false,
        scales: { y: { beginAtZero: true, ticks: { stepSize: 1, font: { size: 11 } } }, x: { ticks: { font: { size: 11 } } } },
        plugins: { legend: { display: false }, datalabels: { anchor: 'end', align: 'end', font: { weight: 'bold', size: 11 }, formatter: function(v) { return v + ' (' + pct(v, ageTotal) + ')'; } } }
    }
});

// 3. 网购习惯
var hLabels = [], hValues = [], hTotal = 0;
<c:forEach items="${stats.habitStats}" var="e">hLabels.push('${e.key}'); hValues.push(${e.value}); hTotal += ${e.value};</c:forEach>
new Chart(document.getElementById('habitChart'), {
    type: 'doughnut', data: { labels: hLabels, datasets: [{ data: hValues, backgroundColor: ['#3498db','#27ae60','#f39c12'] }] },
    options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'bottom', labels: { font: { size: 11 } } }, datalabels: { color: '#fff', font: { weight: 'bold', size: 11 }, formatter: function(v) { return v + ' (' + pct(v, hTotal) + ')'; } } } }
});

// 4. 订单状态
var oLabels = [], oValues = [], oTotal = 0;
<c:forEach items="${stats.orderStatusStats}" var="e">oLabels.push('${e.key}'); oValues.push(${e.value}); oTotal += ${e.value};</c:forEach>
new Chart(document.getElementById('orderChart'), {
    type: 'doughnut', data: { labels: oLabels, datasets: [{ data: oValues, backgroundColor: ['#f39c12','#3498db','#9b59b6','#2ecc71','#e74c3c','#95a5a6'] }] },
    options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'bottom', labels: { font: { size: 11 } } }, datalabels: { color: '#fff', font: { weight: 'bold', size: 11 }, formatter: function(v) { return v + ' (' + pct(v, oTotal) + ')'; } } } }
});

// 5. 区域
var rLabels = [], rValues = [], rTotal = 0;
<c:forEach items="${stats.regionStats}" var="e" begin="0" end="9">rLabels.push('${e.key}'); rValues.push(${e.value}); rTotal += ${e.value};</c:forEach>
if (!rLabels.length) { rLabels = ['暂无']; rValues = [0]; }
new Chart(document.getElementById('regionChart'), {
    type: 'bar', data: { labels: rLabels, datasets: [{ data: rValues, backgroundColor: COLORS.slice(0, Math.max(rLabels.length, 1)), borderRadius: 4 }] },
    options: { responsive: true, maintainAspectRatio: false, indexAxis: 'y',
        scales: { x: { beginAtZero: true, ticks: { stepSize: 1, font: { size: 10 } } }, y: { ticks: { font: { size: 10 } } } },
        plugins: { legend: { display: false }, datalabels: { anchor: 'end', align: 'end', font: { weight: 'bold', size: 10 }, formatter: function(v) { return v + (rTotal > 0 ? ' (' + pct(v, rTotal) + ')' : ''); } } }
    }
});

// 6. 热销商品
var pLabels = [], pSales = [], pRevenue = [], pMax = 0;
<c:forEach items="${stats.topProducts}" var="p">pLabels.push('${p.name}'); var s = ${p.sales}; var r = ${p.sales} * ${p.price}; pSales.push(s); pRevenue.push(r); pMax = Math.max(pMax, r);</c:forEach>
new Chart(document.getElementById('topChart'), {
    type: 'bar', data: { labels: pLabels, datasets: [
        { label: '销量', data: pSales, backgroundColor: '#e74c3c', borderRadius: 3, order: 1 },
        { label: '销售额(¥)', data: pRevenue, backgroundColor: '#f39c12', borderRadius: 3, order: 2 }
    ]},
    options: { responsive: true, maintainAspectRatio: false,
        scales: { y: { beginAtZero: true, ticks: { font: { size: 10 } } }, x: { ticks: { font: { size: 9 } } } },
        plugins: { legend: { position: 'top', labels: { font: { size: 11 } } }, datalabels: { font: { size: 10, weight: 'bold' }, anchor: 'end', align: 'end', formatter: function(v) { return v >= 0 ? v : ''; } } }
    }
});

// 30s 自动刷新
setTimeout(function() { location.reload(); }, 30000);
</script>
</body>
</html>
