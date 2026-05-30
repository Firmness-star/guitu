<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>用户注册 - 花店商城</title>
    <style>
        :root { --primary-red: #e74c3c; --dark-red: #c0392b; --primary-green: #27ae60; --bg-gray: #f5f5f5; }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: "PingFang SC", "Microsoft YaHei", sans-serif; background: var(--bg-gray); min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 20px; }
        .register-container { background: white; width: 100%; max-width: 450px; padding: 40px; border-radius: 4px; box-shadow: 0 2px 10px rgba(0,0,0,0.08); }
        .brand-header { text-align: center; margin-bottom: 30px; }
        .brand-header h1 { color: #333; font-size: 24px; font-weight: 600; margin-bottom: 8px; }
        .brand-header p { color: #999; font-size: 14px; }

        .alert-error {
            background-color: #f8d7da;
            color: #721c24;
            padding: 12px;
            border-radius: 4px;
            margin-bottom: 20px;
            font-size: 14px;
            border: 1px solid #f5c6cb;
        }

        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; }
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; color: #666; font-size: 14px; margin-bottom: 8px; }
        .form-group label .required { color: var(--primary-red); margin-left: 2px; }
        .form-group input { width: 100%; padding: 12px 15px; border: 1px solid #ddd; font-size: 14px; outline: none; transition: border-color 0.2s; }
        .form-group input:focus { border-color: var(--primary-red); }
        .form-group input.error { border-color: var(--primary-red); background-color: #fff5f5; }
        .agreement { display: flex; align-items: flex-start; margin-bottom: 25px; font-size: 13px; color: #666; }
        .agreement input { margin-right: 8px; margin-top: 2px; cursor: pointer; }
        .agreement a { color: var(--primary-red); text-decoration: none; }
        .agreement a:hover { text-decoration: underline; }
        .register-btn { width: 100%; padding: 14px; background: var(--primary-red); color: white; border: none; font-size: 16px; cursor: pointer; transition: background 0.2s; border-radius: 2px; }
        .register-btn:hover { background: var(--dark-red); }
        .register-btn:disabled { background: #ccc; cursor: not-allowed; }
        .login-link { text-align: center; margin-top: 25px; color: #666; font-size: 14px; }
        .login-link a { color: var(--primary-red); text-decoration: none; font-weight: 500; }
        .login-link a:hover { text-decoration: underline; }
        .form-hint { font-size: 12px; color: #999; margin-top: 4px; }
        .username-status { font-size: 12px; margin-top: 4px; min-height: 18px; }
        .username-status.available { color: var(--primary-green); }
        .username-status.unavailable { color: var(--primary-red); }
        .username-status.checking { color: #999; }
        @media (max-width: 480px) { .form-row { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
<div class="register-container">
    <div class="brand-header">
        <h1>创建账户</h1>
        <p>加入花店商城，开启美好生活</p>
    </div>

    <!-- 展示注册失败时的错误提示信息 -->
    <c:if test="${not empty error}">
        <div class="alert-error">
                ${error}
        </div>
    </c:if>

    <!-- 用户注册表单：包含用户名、手机号、邮箱及密码输入 -->
    <form action="reg" method="post" id="regForm">
        <div class="form-row">
            <div class="form-group">
                <label>用户名<span class="required">*</span></label>
                <input type="text" name="username" id="username" placeholder="设置用户名" required
                       value="${username}" pattern="[a-zA-Z0-9_]{3,20}"
                       title="3-20位字母、数字或下划线">
                <div class="username-status" id="usernameStatus"></div>
                <div class="form-hint">3-20位字母、数字或下划线</div>
            </div>
            <div class="form-group">
                <label>手机号<span class="required">*</span></label>
                <input type="tel" name="tel" id="tel" placeholder="11位手机号" required
                       value="${tel}" pattern="1[3-9]\d{9}"
                       title="请输入有效的11位手机号">
                <div class="username-status" id="telStatus"></div>
                <div class="form-hint">11位手机号</div>
            </div>
        </div>
        <div class="form-group">
            <label>电子邮箱<span class="required">*</span></label>
            <input type="email" name="email" id="email" placeholder="example@email.com" required
                   value="${email}">
            <div class="username-status" id="emailStatus"></div>
        </div>
        <div class="form-row">
            <div class="form-group">
                <label>密码<span class="required">*</span></label>
                <input type="password" name="password" placeholder="设置密码（6-20位）"
                       required minlength="6" maxlength="20" id="password">
                <div class="form-hint">6-20位字符</div>
            </div>
            <div class="form-group">
                <label>确认密码<span class="required">*</span></label>
                <input type="password" name="confirmPassword" placeholder="再次输入密码"
                       required minlength="6" maxlength="20" id="confirmPassword">
            </div>
        </div>
        <div class="form-group">
            <label>验证码<span class="required">*</span></label>
            <div style="display:flex;gap:10px;align-items:center;">
                <input type="text" name="verifyCode" placeholder="验证码" required maxlength="4"
                       style="width:110px;letter-spacing:4px;font-size:16px;font-weight:bold;border:1px solid #ddd;padding:10px 12px;border-radius:4px;outline:none;">
                <img src="verifyCode" alt="验证码" style="height:40px;cursor:pointer;border-radius:4px;" onclick="this.src='verifyCode?'+new Date().getTime()" title="点击刷新">
            </div>
        </div>
        <div class="agreement">
            <input type="checkbox" name="agreement" required id="agreement">
            <span>我已阅读并同意<a href="#">用户协议</a>和<a href="#">隐私政策</a></span>
        </div>
        <button type="submit" class="register-btn" id="submitBtn">注 册</button>
    </form>
    <div class="login-link">
        已有账户？<a href="login.jsp">立即登录</a> | <a href="index.jsp">返回首页</a>
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