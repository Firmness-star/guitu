<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<%-- 计算购物车商品总数 --%>
<c:set var="cartItemCount" value="0"/>
<c:if test="${not empty sessionScope.cart}">
  <c:forEach items="${sessionScope.cart}" var="cartItem">
    <c:set var="cartItemCount" value="${cartItemCount + cartItem.quantity}"/>
  </c:forEach>
</c:if>

<style>
  .navbar {
    background: #fff;
    padding: 0;
    position: sticky;
    top: 0;
    z-index: 1000;
    box-shadow: 0 2px 12px rgba(0,0,0,0.08);
  }
  .navbar .nav-container {
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
    color: #333;
    text-decoration: none;
    font-size: 22px;
    letter-spacing: 2px;
    background: linear-gradient(135deg, var(--primary-red, #e74c3c) 0%, #ff6b6b 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    transition: transform 0.2s;
    cursor: pointer;
  }
  .brand:hover { transform: scale(1.05); }
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
  .nav-links a:hover { color: var(--primary-red, #e74c3c); background: #fff5f5; }
  .search-box { display: flex; align-items: center; }
  .search-box input {
    border: 2px solid #e8e8e8;
    padding: 8px 15px;
    font-size: 14px;
    outline: none;
    width: 220px;
    border-radius: 8px 0 0 8px;
    transition: border-color 0.2s;
  }
  .search-box input:focus { border-color: var(--primary-red, #e74c3c); }
  .search-box button {
    border: 2px solid var(--primary-red, #e74c3c);
    border-left: none;
    background: var(--primary-red, #e74c3c);
    padding: 8px 18px;
    cursor: pointer;
    font-size: 14px;
    color: white;
    border-radius: 0 8px 8px 0;
    transition: background 0.2s;
  }
  .search-box button:hover { background: #c0392b; }
  .cart-badge {
    background: var(--primary-red, #e74c3c);
    color: white;
    font-size: 11px;
    padding: 2px 7px;
    border-radius: 10px;
    margin-left: 5px;
    display: inline-block;
    min-width: 18px;
    text-align: center;
    font-weight: 600;
  }
  /* 版权说明模态框 */
  .copyright-modal { display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 10000; align-items: center; justify-content: center; }
  .copyright-modal.show { display: flex; }
  .copyright-content { background: white; padding: 50px; border-radius: 16px; text-align: center; max-width: 550px; width: 90%; animation: modalSlideIn 0.3s ease; box-shadow: 0 20px 60px rgba(0,0,0,0.2); }
  @keyframes modalSlideIn { from { opacity: 0; transform: translateY(-20px); } to { opacity: 1; transform: translateY(0); } }
  .copyright-icon { font-size: 64px; margin-bottom: 20px; }
  .copyright-title { font-size: 28px; background: linear-gradient(135deg, var(--primary-red, #e74c3c) 0%, #ff6b6b 100%); -webkit-background-clip: text; -webkit-text-fill-color: transparent; margin-bottom: 20px; font-weight: 700; }
  .copyright-divider { width: 60px; height: 3px; background: linear-gradient(90deg, var(--primary-red, #e74c3c) 0%, #ff6b6b 100%); margin: 0 auto 20px; border-radius: 2px; }
  .copyright-message { color: #666; font-size: 16px; line-height: 1.8; margin-bottom: 15px; }
  .copyright-warning { background: linear-gradient(135deg, #fff5f5 0%, #ffffff 100%); border-left: 4px solid var(--primary-red, #e74c3c); padding: 15px 20px; border-radius: 8px; margin: 20px 0; text-align: left; }
  .copyright-warning p { color: #666; font-size: 14px; margin: 0; line-height: 1.6; }
  .copyright-warning strong { color: var(--primary-red, #e74c3c); }
  .copyright-btn { background: linear-gradient(135deg, var(--primary-red, #e74c3c) 0%, #ff6b6b 100%); color: white; border: none; padding: 14px 50px; border-radius: 8px; font-size: 16px; cursor: pointer; transition: all 0.3s; margin-top: 20px; font-weight: 600; }
  .copyright-btn:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(231, 76, 60, 0.4); }

  @media (max-width: 768px) {
    .nav-links { gap: 10px; }
    .search-box input { width: 120px; }
    .navbar .nav-container { padding: 0 10px; }
  }
</style>

<nav class="navbar">
  <div class="nav-container">
    <a class="brand" href="javascript:void(0)" onclick="showCopyright()">归途</a>
    <ul class="nav-links">
      <li><a href="${ctx}/index">首页</a></li>
      <li>
        <form class="search-box" action="${ctx}/index" method="get">
          <input type="hidden" name="action" value="search">
          <input type="search" name="keyword" placeholder="搜索商品..." required value="${searchKeyword}">
          <button type="submit">查询</button>
        </form>
      </li>
      <li>
        <c:choose>
          <c:when test="${not empty sessionScope.username}">
            <a href="${ctx}/logout">退出(${sessionScope.username})</a>
          </c:when>
          <c:otherwise>
            <a href="${ctx}/login">登录</a>
          </c:otherwise>
        </c:choose>
      </li>
      <li>
        <c:if test="${empty sessionScope.username}">
          <a href="${ctx}/reg">注册</a>
        </c:if>
      </li>
      <li class="nav-item">
        <a href="${ctx}/cart">
          我的购物车<span class="cart-badge">${cartItemCount > 0 ? cartItemCount : '0'}</span>
        </a>
      </li>
      <c:if test="${not empty sessionScope.username}">
        <li><a href="${ctx}/favorite"><i class="bi bi-heart"></i> 收藏</a></li>
      </c:if>
      <c:if test="${not empty sessionScope.username}">
        <li>
          <a href="${ctx}/orders">
            <i class="bi bi-receipt"></i> 我的订单
            <c:if test="${pendingOrderCount > 0}">
              <span class="cart-badge">${pendingOrderCount}</span>
            </c:if>
          </a>
        </li>
      </c:if>
      <c:if test="${not empty sessionScope.username}">
        <li><a href="${ctx}/usercenter"><i class="bi bi-person-circle"></i> 个人中心</a></li>
      </c:if>
      <c:if test="${sessionScope.userRole == '管理员'}">
        <li><a href="${ctx}/admin/index" style="color:var(--primary-red, #e74c3c);font-weight:600;"><i class="bi bi-gear"></i> 管理中心</a></li>
      </c:if>
    </ul>
  </div>
</nav>

<%-- 版权说明模态框 --%>
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
    var m = document.getElementById('copyrightModal');
    if (m) m.addEventListener('click', function(e) { if (e.target === m) closeCopyright(); });
  });
</script>
