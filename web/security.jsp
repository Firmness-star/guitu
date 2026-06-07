<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:if test="${empty sessionScope.username}">
    <jsp:forward page="login.jsp"/>
</c:if>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>账号安全 - 花店商城</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="css/common.css">
    <style>
        .security-container {
            max-width: 900px;
            margin: 30px auto;
            padding: 0 15px;
        }

        .security-card {
            background: white;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            overflow: hidden;
            margin-bottom: 20px;
        }

        .card-header {
            padding: 20px;
            border-bottom: 1px solid #f0f0f0;
        }

        .card-title {
            font-size: 18px;
            font-weight: 600;
            color: #333;
            margin: 0;
        }

        .card-body {
            padding: 20px;
        }

        .nav-tabs {
            border-bottom: 2px solid #f0f0f0;
            margin-bottom: 20px;
        }

        .nav-tabs .nav-link {
            border: none;
            color: #666;
            font-weight: 500;
            padding: 12px 20px;
            position: relative;
        }

        .nav-tabs .nav-link.active {
            color: var(--primary-red);
            background: transparent;
        }

        .nav-tabs .nav-link.active::after {
            content: '';
            position: absolute;
            bottom: -2px;
            left: 0;
            right: 0;
            height: 2px;
            background: var(--primary-red);
        }

        .info-item {
            display: flex;
            padding: 15px 0;
            border-bottom: 1px solid #f5f5f5;
        }

        .info-item:last-child {
            border-bottom: none;
        }

        .info-label {
            width: 120px;
            color: #666;
            font-size: 14px;
        }

        .info-value {
            flex: 1;
            color: #333;
            font-weight: 500;
        }

        .btn-edit {
            color: var(--primary-red);
            font-size: 13px;
            text-decoration: none;
            cursor: pointer;
        }

        .btn-edit:hover {
            text-decoration: underline;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-label {
            font-weight: 500;
            color: #333;
            margin-bottom: 8px;
        }

        .btn-save {
            background: var(--primary-red);
            border: none;
            padding: 10px 30px;
            border-radius: 6px;
            color: white;
            font-weight: 500;
        }

        .btn-save:hover {
            background: var(--dark-red);
        }

        .btn-cancel {
            background: #95a5a6;
            border: none;
            padding: 10px 30px;
            border-radius: 6px;
            color: white;
            font-weight: 500;
            margin-left: 10px;
        }

        .btn-cancel:hover {
            background: #7f8c8d;
        }

        .alert {
            border-radius: 8px;
            margin-bottom: 20px;
        }

        .log-table {
            width: 100%;
            border-collapse: collapse;
        }

        .log-table th {
            background: #f8f9fa;
            padding: 12px;
            text-align: left;
            font-weight: 600;
            color: #333;
            border-bottom: 2px solid #dee2e6;
        }

        .log-table td {
            padding: 12px;
            border-bottom: 1px solid #f0f0f0;
            color: #666;
        }

        .log-table tr:hover {
            background: #f8f9fa;
        }

        .ip-badge {
            background: #e3f2fd;
            color: #1976d2;
            padding: 4px 10px;
            border-radius: 4px;
            font-size: 12px;
            font-family: monospace;
        }

        .device-info {
            font-size: 12px;
            color: #999;
        }

        .empty-state {
            text-align: center;
            padding: 40px 20px;
            color: #999;
        }

        .empty-icon {
            font-size: 48px;
            margin-bottom: 15px;
            color: #ddd;
        }

        .edit-form {
            display: none;
            margin-top: 15px;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 8px;
        }

        .edit-form.show {
            display: block;
        }
    </style>
</head>
<body>

<jsp:include page="common/navbar.jsp"/>

<div class="security-container">
    <!-- 显示错误或成功消息 -->
    <c:if test="${not empty error}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>${error}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <c:if test="${not empty success}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i>${success}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <!-- Tab 导航 -->
    <ul class="nav nav-tabs">
        <li class="nav-item">
            <a class="nav-link ${activeTab == 'password' || empty activeTab ? 'active' : ''}" href="?tab=password">
                <i class="bi bi-key me-1"></i>修改密码
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${activeTab == 'logs' ? 'active' : ''}" href="?tab=logs">
                <i class="bi bi-clock-history me-1"></i>登录日志
            </a>
        </li>
    </ul>

    <!-- 账号安全提示 -->
    <div class="security-card" id="securityTip" style="display:none;">
        <div class="card-body" style="padding: 15px 20px; background: linear-gradient(135deg, #fff5f5 0%, #ffffff 100%); border-left: 3px solid var(--primary-red);">
            <div style="display: flex; align-items: center; justify-content: space-between;">
                <div style="display: flex; align-items: center;">
                    <i class="bi bi-shield-check" style="font-size: 24px; color: var(--primary-red); margin-right: 15px;"></i>
                    <div>
                        <div style="font-weight: 600; color: #333; margin-bottom: 4px;">账号安全管理</div>
                        <div style="font-size: 13px; color: #666;">请定期修改密码，保护您的账号安全。如需修改手机号或邮箱，请前往<a href="usercenter" style="color: var(--primary-red); text-decoration: underline;">个人中心</a></div>
                    </div>
                </div>
                <button type="button" style="border:none;background:none;color:#999;cursor:pointer;font-size:12px;white-space:nowrap;" onclick="dismissSecurityTip()">不再显示 ✕</button>
            </div>
        </div>
    </div>

    <!-- 修改密码 Tab -->
    <c:if test="${activeTab == 'password' || empty activeTab}">
        <div class="security-card">
            <div class="card-header">
                <h5 class="card-title">修改密码</h5>
            </div>
            <div class="card-body">
                <form action="security" method="POST">
                    <input type="hidden" name="action" value="changePassword"/>

                    <div class="form-group">
                        <label class="form-label">原密码</label>
                        <input type="password" class="form-control" name="oldPassword" required
                               placeholder="请输入当前密码"/>
                    </div>

                    <div class="form-group">
                        <label class="form-label">新密码</label>
                        <input type="password" class="form-control" name="newPassword" required
                               minlength="6" placeholder="新密码至少6位"/>
                        <small class="text-muted">密码长度不能少于6位</small>
                    </div>

                    <div class="form-group">
                        <label class="form-label">确认新密码</label>
                        <input type="password" class="form-control" name="confirmPassword" required
                               minlength="6" placeholder="请再次输入新密码"/>
                    </div>

                    <button type="submit" class="btn btn-save">确认修改</button>
                </form>
            </div>
        </div>
    </c:if>

    <!-- 登录日志 Tab -->
    <c:if test="${activeTab == 'logs'}">
        <div class="security-card">
            <div class="card-header">
                <h5 class="card-title">最近登录记录</h5>
            </div>
            <div class="card-body">
                <c:choose>
                    <c:when test="${not empty loginLogs}">
                        <table class="log-table">
                            <thead>
                                <tr>
                                    <th>登录时间</th>
                                    <th>IP 地址</th>
                                    <th>设备信息</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${loginLogs}" var="log">
                                    <tr>
                                        <td>
                                            <fmt:formatDate value="${log.loginTime}"
                                                           pattern="yyyy-MM-dd HH:mm:ss"/>
                                        </td>
                                        <td>
                                            <span class="ip-badge">${log.loginIp}</span>
                                        </td>
                                        <td>
                                            <div class="device-info">
                                                <c:choose>
                                                    <c:when test="${fn:contains(log.userAgent, 'Chrome')}">
                                                        <i class="bi bi-browser-chrome"></i> Chrome
                                                    </c:when>
                                                    <c:when test="${fn:contains(log.userAgent, 'Firefox')}">
                                                        <i class="bi bi-browser-firefox"></i> Firefox
                                                    </c:when>
                                                    <c:when test="${fn:contains(log.userAgent, 'Safari')}">
                                                        <i class="bi bi-browser-safari"></i> Safari
                                                    </c:when>
                                                    <c:when test="${fn:contains(log.userAgent, 'Edge')}">
                                                        <i class="bi bi-browser-edge"></i> Edge
                                                    </c:when>
                                                    <c:otherwise>
                                                        <i class="bi bi-laptop"></i> 其他浏览器
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:when>
                    <c:otherwise>
                        <div class="empty-state">
                            <div class="empty-icon"><i class="bi bi-inbox"></i></div>
                            <p>暂无登录记录</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </c:if>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        if (!localStorage.getItem('securityTipDismissed')) {
            document.getElementById('securityTip').style.display = '';
        }
    });

    function dismissSecurityTip() {
        localStorage.setItem('securityTipDismissed', '1');
        document.getElementById('securityTip').style.display = 'none';
    }

    /**
     * 切换编辑表单的显示状态
     * @param {string} formType - 表单类型（目前未使用，保留扩展性）
     */
    function toggleEditForm(formType) {
        const form = document.getElementById('editInfoForm');
        form.classList.toggle('show');
    }

    /**
     * 取消编辑并隐藏表单
     */
    function cancelEdit() {
        const form = document.getElementById('editInfoForm');
        form.classList.remove('show');
        // 重置表单值
        form.reset();
    }
</script>
</body>
</html>
