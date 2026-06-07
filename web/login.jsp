<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>用户登录 - 花店商城</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="css/common.css">
    <style>
        body { min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 20px; }
        .login-container { background: white; width: 100%; max-width: 420px; padding: 40px; border-radius: 12px; box-shadow: var(--shadow); }
        .brand-header { text-align: center; margin-bottom: 30px; }
        .brand-header h1 { color: #333; font-size: 24px; font-weight: 600; margin-bottom: 8px; }
        .brand-header p { color: #999; font-size: 14px; }
        .role-hint { font-size: 11px; margin-top: 4px; min-height: 16px; }
        .login-btn { width: 100%; padding: 14px; background: var(--primary-red); color: white; border: none; font-size: 16px; cursor: pointer; border-radius: 8px; font-weight: 500; transition: background 0.2s; }
        .login-btn:hover { background: var(--dark-red); }
        .options { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; font-size: 13px; }
    </style>
</head>
<body>
<div class="login-container">
    <div class="brand-header">
        <h1 style="background: linear-gradient(135deg, var(--primary-red) 0%, #ff6b6b 100%); -webkit-background-clip: text; -webkit-text-fill-color: transparent; font-size: 28px; font-weight: 700;">🌸 归途</h1>
        <p>登录您的花店商城账户</p>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-danger d-flex align-items-center">
            <i class="bi bi-exclamation-circle me-2"></i> ${error}
        </div>
    </c:if>

    <c:if test="${param.registered == '1'}">
        <div class="alert alert-success d-flex align-items-center">
            <i class="bi bi-check-circle me-2"></i> 注册成功！请登录
        </div>
    </c:if>

    <form action="login" method="post">
        <div class="mb-3">
            <label class="form-label">用户名</label>
            <input type="text" name="username" id="usernameInput" class="form-control" placeholder="请输入用户名" required autocomplete="off"
                   value="${not empty username ? username : (not empty rememberedUsername ? rememberedUsername : param.username)}"
                   oninput="checkUserRole()" onblur="checkUserRole()">
            <div class="role-hint" id="roleHint"></div>
        </div>
        <div class="mb-3">
            <label class="form-label">密码</label>
            <input type="password" name="password" class="form-control" placeholder="请输入密码" required>
        </div>
        <div class="mb-3 verify-group" id="verifyGroup">
            <label class="form-label">验证码</label>
            <div class="input-group">
                <input type="text" name="verifyCode" id="verifyInput" class="form-control" placeholder="验证码" maxlength="4" style="letter-spacing:4px;font-size:16px;font-weight:bold;">
                <img src="verifyCode" alt="验证码" style="height:42px;cursor:pointer;border-radius:6px;" onclick="this.src='verifyCode?'+new Date().getTime()" title="点击刷新">
            </div>
        </div>
        <div class="options">
            <label class="form-check-label" style="cursor:pointer;">
                <input type="checkbox" name="remember" class="form-check-input" ${rememberChecked ? 'checked' : ''}> 记住我
            </label>
            <a href="#" class="text-decoration-none" style="color:var(--primary-red);">忘记密码？</a>
        </div>
        <button type="submit" class="login-btn">登 录</button>
    </form>

    <div class="text-center mt-4 text-muted">
        还没有账户？<a href="reg" style="color:var(--primary-red);" class="fw-medium">立即注册</a> | <a href="index" style="color:var(--primary-red);" class="fw-medium">返回首页</a>
    </div>
</div>
<script>
var checkTimer;

function checkUserRole() {
    clearTimeout(checkTimer);
    var username = document.getElementById('usernameInput').value.trim();
    var hint = document.getElementById('roleHint');
    var verifyGroup = document.getElementById('verifyGroup');
    var verifyInput = document.getElementById('verifyInput');

    if (username.length === 0) {
        hint.innerHTML = '';
        verifyGroup.style.display = '';
        verifyInput.setAttribute('required', 'required');
        return;
    }

    checkTimer = setTimeout(function() {
        var xhr = new XMLHttpRequest();
        xhr.open('GET', 'login?action=checkRole&username=' + encodeURIComponent(username), true);
        xhr.onload = function() {
            var res = JSON.parse(xhr.responseText);
            if (!res.requireCode) {
                hint.innerHTML = '<span style="color:#27ae60;">✓ ' + res.role + '账号，免验证码</span>';
                verifyGroup.style.display = 'none';
                verifyInput.removeAttribute('required');
            } else {
                hint.innerHTML = '';
                verifyGroup.style.display = '';
                verifyInput.setAttribute('required', 'required');
            }
        };
        xhr.send();
    }, 300);
}

window.addEventListener('DOMContentLoaded', function() {
    var username = document.getElementById('usernameInput').value.trim();
    if (username) checkUserRole();
});
</script>
</body>
</html>
