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
    <style>
        :root {
            --primary-red: #e74c3c;
            --dark-red: #c0392b;
            --bg-gray: #f5f5f5;
        }

        body {
            font-family: "PingFang SC", "Microsoft YaHei", sans-serif;
            background: var(--bg-gray);
        }

        .top-navbar {
            background: white;
            border-bottom: 1px solid #e0e0e0;
            padding: 15px 0;
            position: sticky;
            top: 0;
            z-index: 100;
        }

        .brand-logo {
            font-size: 20px;
            font-weight: 700;
            color: #333;
            text-decoration: none;
            cursor: pointer;
            background: linear-gradient(135deg, var(--primary-red) 0%, #ff6b6b 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            transition: transform 0.2s;
        }

        .brand-logo:hover {
            transform: scale(1.05);
        }

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

<nav class="top-navbar">
    <div class="container d-flex justify-content-between align-items-center">
        <a href="javascript:void(0)" onclick="showCopyright()" class="brand-logo"> 归途</a>
        <div>
            <span class="text-muted me-3">欢迎，${sessionScope.username}</span>
            <a href="usercenter" class="btn btn-outline-danger btn-sm">返回个人中心</a>
        </div>
    </div>
</nav>

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

        // 安全提示：检查是否已关闭
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
