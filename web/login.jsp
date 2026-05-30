<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>用户登录 - 花店商城</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <style>
        :root { --primary-red: #e74c3c; --dark-red: #c0392b; --primary-green: #27ae60; --bg-gray: #f5f5f5; }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: "PingFang SC", "Microsoft YaHei", sans-serif; background: var(--bg-gray); min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 20px; }
        .login-container { background: white; width: 100%; max-width: 400px; padding: 40px; border-radius: 4px; box-shadow: 0 2px 10px rgba(0,0,0,0.08); }
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
        .alert-success {
            background-color: #d4edda;
            color: #155724;
            padding: 12px;
            border-radius: 4px;
            margin-bottom: 20px;
            font-size: 14px;
            border: 1px solid #c3e6cb;
        }

        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; color: #666; font-size: 14px; margin-bottom: 8px; }
        .form-group input { width: 100%; padding: 12px 15px; border: 1px solid #ddd; font-size: 14px; outline: none; transition: border-color 0.2s; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .form-group input:focus { border-color: var(--primary-red); }
        .role-hint { font-size:11px; margin-top:4px; min-height:16px; }
        .verify-group { }
        .options { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; font-size: 13px; }
        .remember-me { display: flex; align-items: center; color: #666; cursor: pointer; }
        .remember-me input { margin-right: 6px; cursor: pointer; }
        .forgot-pwd { color: var(--primary-red); text-decoration: none; }
        .forgot-pwd:hover { text-decoration: underline; }
        .login-btn { width: 100%; padding: 14px; background: var(--primary-red); color: white; border: none; font-size: 16px; cursor: pointer; transition: background 0.2s; border-radius: 2px; }
        .login-btn:hover { background: var(--dark-red); }
        .register-link { text-align: center; margin-top: 25px; color: #666; font-size: 14px; }
        .register-link a { color: var(--primary-red); text-decoration: none; font-weight: 500; }
        .register-link a:hover { text-decoration: underline; }
    </style>
</head>
<body>
<div class="login-container">
    <div class="brand-header">
        <h1>欢迎回来</h1>
        <p>登录您的花店商城账户</p>
    </div>

    <!-- 展示登录失败时的错误提示信息 -->
    <c:if test="${not empty error}">
        <div class="alert-error">
            <i class="bi bi-exclamation-circle"></i> ${error}
        </div>
    </c:if>

    <!-- 展示注册成功后的引导提示信息 -->
    <c:if test="${param.registered == '1'}">
        <div class="alert-success">
            <i class="bi bi-check-circle"></i> 注册成功！请登录
        </div>
    </c:if>

    <!-- 登录表单：支持用户名密码输入及“记住我”功能 -->
    <form action="login" method="post">
        <div class="form-group">
            <label>用户名</label>
            <input type="text" name="username" id="usernameInput" placeholder="请输入用户名" required autocomplete="off"
                   value="${not empty username ? username : (not empty rememberedUsername ? rememberedUsername : param.username)}"
                   oninput="checkUserRole()" onblur="checkUserRole()">
            <div class="role-hint" id="roleHint"></div>
        </div>
        <div class="form-group">
            <label>密码</label>
            <input type="password" name="password" placeholder="请输入密码" required>
        </div>
        <div class="form-group verify-group" id="verifyGroup">
            <label>验证码</label>
            <div style="display:flex;gap:10px;align-items:center;">
                <input type="text" name="verifyCode" id="verifyInput" placeholder="验证码" maxlength="4" style="width:120px;letter-spacing:4px;font-size:16px;font-weight:bold;border:1px solid #ddd;padding:10px 12px;border-radius:4px;outline:none;">
                <img src="verifyCode" alt="验证码" style="height:38px;cursor:pointer;border-radius:4px;" onclick="this.src='verifyCode?'+new Date().getTime()" title="点击刷新">
            </div>
        </div>
        <div class="options">
            <label class="remember-me">
                <input type="checkbox" name="remember" ${rememberChecked ? 'checked' : ''}> 记住我
            </label>
            <a href="#" class="forgot-pwd">忘记密码？</a>
        </div>
        <button type="submit" class="login-btn">登 录</button>
    </form>

    <div class="register-link">
        还没有账户？<a href="reg.jsp">立即注册</a> | <a href="index.jsp">返回首页</a>
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

// 页面加载时，如果已有用户名则自动检测
window.addEventListener('DOMContentLoaded', function() {
    var username = document.getElementById('usernameInput').value.trim();
    if (username) checkUserRole();
});
</script>
</body>
</html>