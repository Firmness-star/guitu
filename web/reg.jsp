<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>用户注册 - 花店商城</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="css/common.css">
    <style>
        body { min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 20px; }
        .register-container { background: white; width: 100%; max-width: 500px; padding: 40px; border-radius: 12px; box-shadow: var(--shadow); }
        .brand-header { text-align: center; margin-bottom: 30px; }
        .brand-header h1 { color: #333; font-size: 24px; font-weight: 600; margin-bottom: 8px; }
        .brand-header p { color: #999; font-size: 14px; }
        .username-status { font-size: 12px; margin-top: 4px; min-height: 18px; }
        .username-status.available { color: var(--primary-green); }
        .username-status.unavailable { color: var(--primary-red); }
        .username-status.checking { color: #999; }
        .register-btn { width: 100%; padding: 14px; background: var(--primary-red); color: white; border: none; font-size: 16px; cursor: pointer; border-radius: 8px; font-weight: 500; transition: background 0.2s; }
        .register-btn:hover { background: var(--dark-red); }
        .register-btn:disabled { background: #ccc; cursor: not-allowed; }
        @media (max-width: 480px) { .form-row { grid-template-columns: 1fr !important; } }
    </style>
</head>
<body>
<div class="register-container">
    <div class="brand-header">
        <h1 style="background: linear-gradient(135deg, var(--primary-red) 0%, #ff6b6b 100%); -webkit-background-clip: text; -webkit-text-fill-color: transparent; font-size: 28px; font-weight: 700;">🌸 归途</h1>
        <p>加入花店商城，开启美好生活</p>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
    </c:if>

    <form action="reg" method="post" id="regForm">
        <div class="form-row row g-3">
            <div class="col-md-6">
                <label class="form-label">用户名<span class="text-danger">*</span></label>
                <input type="text" name="username" id="username" class="form-control" placeholder="设置用户名" required
                       value="${username}" pattern="[a-zA-Z0-9_]{3,20}">
                <div class="username-status" id="usernameStatus"></div>
                <div class="form-text">3-20位字母、数字或下划线</div>
            </div>
            <div class="col-md-6">
                <label class="form-label">手机号<span class="text-danger">*</span></label>
                <input type="tel" name="tel" id="tel" class="form-control" placeholder="11位手机号" required
                       value="${tel}" pattern="1[3-9]\d{9}">
                <div class="username-status" id="telStatus"></div>
                <div class="form-text">11位手机号</div>
            </div>
        </div>
        <div class="mb-3">
            <label class="form-label">电子邮箱<span class="text-danger">*</span></label>
            <input type="email" name="email" id="email" class="form-control" placeholder="example@email.com" required value="${email}">
            <div class="username-status" id="emailStatus"></div>
        </div>
        <div class="row g-3">
            <div class="col-md-6">
                <label class="form-label">密码<span class="text-danger">*</span></label>
                <input type="password" name="password" class="form-control" placeholder="设置密码（6-20位）" required minlength="6" maxlength="20" id="password">
                <div class="form-text">6-20位字符</div>
            </div>
            <div class="col-md-6">
                <label class="form-label">确认密码<span class="text-danger">*</span></label>
                <input type="password" name="confirmPassword" class="form-control" placeholder="再次输入密码" required minlength="6" maxlength="20" id="confirmPassword">
            </div>
        </div>
        <div class="mb-3">
            <label class="form-label">验证码<span class="text-danger">*</span></label>
            <div class="input-group">
                <input type="text" name="verifyCode" class="form-control" placeholder="验证码" required maxlength="4" style="letter-spacing:4px;font-size:16px;font-weight:bold;">
                <img src="verifyCode" alt="验证码" style="height:42px;cursor:pointer;border-radius:6px;" onclick="this.src='verifyCode?'+new Date().getTime()" title="点击刷新">
            </div>
        </div>
        <div class="form-check mb-3">
            <input class="form-check-input" type="checkbox" name="agreement" required id="agreement">
            <label class="form-check-label" for="agreement">我已阅读并同意<a href="#" class="text-decoration-none" style="color:var(--primary-red);">用户协议</a>和<a href="#" class="text-decoration-none" style="color:var(--primary-red);">隐私政策</a></label>
        </div>
        <button type="submit" class="register-btn" id="submitBtn">注 册</button>
    </form>
    <div class="text-center mt-4 text-muted">
        已有账户？<a href="login" style="color:var(--primary-red);" class="fw-medium">立即登录</a> | <a href="index" style="color:var(--primary-red);" class="fw-medium">返回首页</a>
    </div>
</div>

<script>
    var usernameCheckTimer;

    // 用户名实时检测
    document.getElementById('username').addEventListener('input', function() {
        var username = this.value.trim();
        var statusDiv = document.getElementById('usernameStatus');

        if (usernameCheckTimer) clearTimeout(usernameCheckTimer);

        if (username.length < 3) {
            statusDiv.className = 'username-status';
            statusDiv.textContent = '';
            return;
        }

        statusDiv.className = 'username-status checking';
        statusDiv.textContent = '正在检测...';

        usernameCheckTimer = setTimeout(function() {
            var xhr = new XMLHttpRequest();
            xhr.open('GET', 'reg?action=checkUsername&username=' + encodeURIComponent(username), true);
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    try {
                        var data = JSON.parse(xhr.responseText);
                        statusDiv.className = 'username-status ' + (data.available ? 'available' : 'unavailable');
                        statusDiv.textContent = (data.available ? '✓ ' : '✗ ') + data.message;
                    } catch(e) { statusDiv.textContent = ''; }
                }
            };
            xhr.send();
        }, 500);
    });

    // 手机号实时检测
    var telCheckTimer;
    document.getElementById('tel').addEventListener('input', function() {
        var tel = this.value.trim();
        var statusDiv = document.getElementById('telStatus');
        if (telCheckTimer) clearTimeout(telCheckTimer);

        if (!tel.match(/^1[3-9]\d{9}$/)) { statusDiv.textContent = ''; return; }
        statusDiv.className = 'username-status checking';
        statusDiv.textContent = '正在检测...';
        telCheckTimer = setTimeout(function() {
            var xhr = new XMLHttpRequest();
            xhr.open('GET', 'reg?action=checkTel&tel=' + encodeURIComponent(tel), true);
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    try {
                        var data = JSON.parse(xhr.responseText);
                        statusDiv.className = 'username-status ' + (data.available ? 'available' : 'unavailable');
                        statusDiv.textContent = (data.available ? '✓ ' : '✗ ') + data.message;
                    } catch(e) { statusDiv.textContent = ''; }
                }
            };
            xhr.send();
        }, 500);
    });

    // 邮箱实时检测
    var emailCheckTimer;
    document.getElementById('email').addEventListener('input', function() {
        var email = this.value.trim();
        var statusDiv = document.getElementById('emailStatus');
        if (emailCheckTimer) clearTimeout(emailCheckTimer);

        if (!email.match(/^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/)) { statusDiv.textContent = ''; return; }
        statusDiv.className = 'username-status checking';
        statusDiv.textContent = '正在检测...';
        emailCheckTimer = setTimeout(function() {
            var xhr = new XMLHttpRequest();
            xhr.open('GET', 'reg?action=checkEmail&email=' + encodeURIComponent(email), true);
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    try {
                        var data = JSON.parse(xhr.responseText);
                        statusDiv.className = 'username-status ' + (data.available ? 'available' : 'unavailable');
                        statusDiv.textContent = (data.available ? '✓ ' : '✗ ') + data.message;
                    } catch(e) { statusDiv.textContent = ''; }
                }
            };
            xhr.send();
        }, 500);
    });

    // 提交前检测：如果有重复项，阻止提交
    document.getElementById('regForm').addEventListener('submit', function(e) {
        var usernameStatus = document.getElementById('usernameStatus');
        var telStatus = document.getElementById('telStatus');
        var emailStatus = document.getElementById('emailStatus');

        // 检查是否有红色 ✗ 标记（重复）
        if (usernameStatus.className.indexOf('unavailable') >= 0) {
            e.preventDefault();
            alert('该用户名已被占用，请修改后重试');
            return false;
        }
        if (telStatus.className.indexOf('unavailable') >= 0) {
            e.preventDefault();
            alert('该手机号已被占用，请修改后重试');
            return false;
        }
        if (emailStatus.className.indexOf('unavailable') >= 0) {
            e.preventDefault();
            alert('该邮箱已被占用，请修改后重试');
            return false;
        }

        var password = document.getElementById('password').value;
        var confirmPassword = document.getElementById('confirmPassword').value;

        if (password !== confirmPassword) {
            e.preventDefault();
            alert('两次输入的密码不一致！');
            return false;
        }
        return true;
    });
</script>
</body>
</html>