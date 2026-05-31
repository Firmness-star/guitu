<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!-- 检查用户登录状态，未登录则重定向至登录页 -->
<c:if test="${empty sessionScope.username}">
  <jsp:forward page="login.jsp?redirect=address"/>
</c:if>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>收货地址 - 花店商城</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
  <style>
    :root {
      --primary-red: #e74c3c;
      --dark-red: #c0392b;
      --primary-green: #27ae60;
      --bg-gray: #f5f5f5;
      --sidebar-width: 240px;
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

    .center-container {
      max-width: 1200px;
      margin: 30px auto;
      display: flex;
      gap: 20px;
      padding: 0 15px;
    }

    .sidebar {
      width: var(--sidebar-width);
      flex-shrink: 0;
    }

    .user-card {
      background: white;
      border-radius: 12px;
      padding: 25px;
      text-align: center;
      box-shadow: 0 2px 8px rgba(0,0,0,0.05);
      margin-bottom: 15px;
    }

    .user-avatar {
      width: 80px;
      height: 80px;
      background: linear-gradient(135deg, var(--primary-red), #ff6b6b);
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      color: white;
      font-size: 32px;
      margin: 0 auto 15px;
    }

    .user-name {
      font-size: 18px;
      font-weight: 600;
      color: #333;
      margin-bottom: 5px;
    }

    .user-email {
      font-size: 13px;
      color: #999;
    }

    .nav-menu {
      background: white;
      border-radius: 12px;
      overflow: hidden;
      box-shadow: 0 2px 8px rgba(0,0,0,0.05);
    }

    .nav-item {
      border-bottom: 1px solid #f0f0f0;
    }

    .nav-item:last-child {
      border-bottom: none;
    }

    .nav-link {
      display: flex;
      align-items: center;
      padding: 15px 20px;
      color: #666;
      text-decoration: none;
      transition: all 0.2s;
    }

    .nav-link:hover,
    .nav-link.active {
      background: #fff5f5;
      color: var(--primary-red);
    }

    .nav-link i {
      font-size: 18px;
      margin-right: 12px;
      width: 24px;
      text-align: center;
    }

    .nav-badge {
      margin-left: auto;
      background: var(--primary-red);
      color: white;
      font-size: 11px;
      padding: 2px 8px;
      border-radius: 10px;
    }

    .main-content {
      flex: 1;
      min-width: 0;
    }

    .content-card {
      background: white;
      border-radius: 12px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.05);
      overflow: hidden;
    }

    .card-header {
      padding: 20px;
      border-bottom: 1px solid #f0f0f0;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    .card-title {
      font-size: 16px;
      font-weight: 600;
      color: #333;
      margin: 0;
    }

    .card-body {
      padding: 20px;
    }

    .address-list {
      display: grid;
      gap: 15px;
    }

    .address-item {
      border: 1px solid #e0e0e0;
      border-radius: 8px;
      padding: 20px;
      position: relative;
      transition: all 0.2s;
    }

    .address-item:hover {
      border-color: var(--primary-red);
      box-shadow: 0 2px 8px rgba(231, 76, 60, 0.1);
    }

    .address-item.default {
      border-color: var(--primary-red);
      background: #fff5f5;
    }

    .default-badge {
      position: absolute;
      top: 10px;
      right: 10px;
      background: var(--primary-red);
      color: white;
      font-size: 12px;
      padding: 2px 10px;
      border-radius: 10px;
    }

    .address-name {
      font-size: 16px;
      font-weight: 600;
      color: #333;
      margin-bottom: 8px;
    }

    .address-phone {
      color: #666;
      font-size: 14px;
      margin-left: 15px;
    }

    .address-detail {
      color: #666;
      font-size: 14px;
      line-height: 1.6;
      margin-bottom: 15px;
    }

    .address-actions {
      display: flex;
      gap: 10px;
    }

    .btn-action {
      padding: 4px 12px;
      border-radius: 4px;
      font-size: 12px;
      border: none;
      cursor: pointer;
      text-decoration: none;
      display: inline-flex;
      align-items: center;
      gap: 4px;
    }

    .btn-edit {
      background: #e3f2fd;
      color: #1976d2;
    }

    .btn-edit:hover {
      background: #bbdefb;
      color: #1976d2;
    }

    .btn-delete {
      background: #ffebee;
      color: #d32f2f;
    }

    .btn-delete:hover {
      background: #ffcdd2;
      color: #d32f2f;
    }

    .btn-set-default {
      background: #fff3e0;
      color: #f57c00;
    }

    .btn-set-default:hover {
      background: #ffe0b2;
      color: #f57c00;
    }

    .btn-add {
      background: var(--primary-red);
      color: white;
      border: none;
      padding: 8px 20px;
      border-radius: 6px;
      font-size: 14px;
      cursor: pointer;
      text-decoration: none;
      display: inline-flex;
      align-items: center;
      gap: 6px;
    }

    .btn-add:hover {
      background: var(--dark-red);
      color: white;
    }

    .empty-state {
      text-align: center;
      padding: 60px 20px;
    }

    .empty-icon {
      font-size: 48px;
      color: #ddd;
      margin-bottom: 15px;
    }

    .empty-text {
      color: #999;
      font-size: 14px;
    }

    .modal-header {
      background: var(--primary-red);
      color: white;
      border-radius: 12px 12px 0 0;
    }

    .modal-header .btn-close {
      filter: invert(1);
    }

    .form-label {
      font-weight: 500;
      color: #333;
    }

    .form-control:focus {
      border-color: var(--primary-red);
      box-shadow: 0 0 0 0.2rem rgba(231, 76, 60, 0.25);
    }

    @media (max-width: 768px) {
      .center-container {
        flex-direction: column;
      }

      .sidebar {
        width: 100%;
      }
    }
  </style>
</head>
<body>

<nav class="top-navbar">
  <div class="container d-flex justify-content-between align-items-center">
    <a href="javascript:void(0)" onclick="showCopyright()" class="brand-logo"> 归途</a>
    <div>
      <span class="text-muted me-3">欢迎，${sessionScope.username}</span>
      <a href="index.jsp" class="btn btn-outline-danger btn-sm">返回首页</a>
    </div>
  </div>
</nav>

<div class="center-container">
  <aside class="sidebar">
    <div class="user-card">
      <div class="user-avatar">
        <c:choose>
          <c:when test="${not empty sessionScope.userAvatar}">
            <img src="${pageContext.request.contextPath}/${sessionScope.userAvatar}" style="width:80px;height:80px;border-radius:50%;object-fit:cover;" alt="头像">
          </c:when>
          <c:otherwise>
            <i class="bi bi-person-fill"></i>
          </c:otherwise>
        </c:choose>
      </div>
      <div class="user-name">${sessionScope.username}</div>
      <div class="user-email">${sessionScope.userEmail}</div>
    </div>

    <nav class="nav-menu">
      <div class="nav-item">
        <a href="usercenter" class="nav-link">
          <i class="bi bi-house-door"></i>
          个人中心
        </a>
      </div>
      <div class="nav-item">
        <a href="orders" class="nav-link">
          <i class="bi bi-receipt"></i>
          我的订单
        </a>
      </div>
      <div class="nav-item">
        <a href="address" class="nav-link active">
          <i class="bi bi-geo-alt"></i>
          收货地址
        </a>
      </div>
      <div class="nav-item">
        <a href="security" class="nav-link">
          <i class="bi bi-shield-lock"></i>
          账号安全
        </a>
      </div>
      <div class="nav-item">
        <a href="logout" class="nav-link text-danger">
          <i class="bi bi-box-arrow-right"></i>
          退出登录
        </a>
      </div>
    </nav>
  </aside>

  <main class="main-content">
    <div class="content-card">
      <div class="card-header">
        <h5 class="card-title">
          <i class="bi bi-geo-alt"></i> 收货地址管理
        </h5>
        <button class="btn-add" data-bs-toggle="modal" data-bs-target="#addAddressModal">
          <i class="bi bi-plus-circle"></i> 新增地址
        </button>
      </div>

      <div class="card-body">
        <!-- 展示操作成功或失败的提示信息 -->
        <c:if test="${not empty sessionScope.message}">
          <div class="alert alert-success alert-dismissible fade show" role="alert">
              ${sessionScope.message}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
          </div>
          <c:remove var="message" scope="session"/>
        </c:if>

        <c:if test="${not empty sessionScope.error}">
          <div class="alert alert-danger alert-dismissible fade show" role="alert">
              ${sessionScope.error}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
          </div>
          <c:remove var="error" scope="session"/>
        </c:if>

        <c:choose>
          <c:when test="${empty addressList}">
            <div class="empty-state">
              <div class="empty-icon">
                <i class="bi bi-inbox"></i>
              </div>
              <p class="empty-text">暂无收货地址，请添加</p>
            </div>
          </c:when>

          <c:otherwise>
                        <div class="address-list">
                            <c:forEach items="${addressList}" var="addr">
                                <div class="address-item ${addr.isDefault() ? 'default' : ''}">
                                    <c:if test="${addr.isDefault()}">
                                        <span class="default-badge">默认地址</span>
                                    </c:if>

                                    <div class="address-name">
                                        ${addr.receiverName}
                                        <span class="address-phone">${addr.receiverPhone}</span>
                                    </div>

                                    <div class="address-detail">
                                        ${addr.province}${addr.city}${addr.district}${addr.detailAddress}
                                    </div>

                                    <div class="address-actions">
                                        <!-- 编辑按钮：通过 data 属性传递当前地址信息给模态框 -->
                                        <button class="btn-action btn-edit"
                                                data-bs-toggle="modal"
                                                data-bs-target="#editAddressModal"
                                                data-id="${addr.id}"
                                                data-name="${addr.receiverName}"
                                                data-phone="${addr.receiverPhone}"
                                                data-province="${addr.province}"
                                                data-city="${addr.city}"
                                                data-district="${addr.district}"
                                                data-detail="${addr.detailAddress}"
                                                data-default="${addr.isDefault()}">
                                            <i class="bi bi-pencil"></i> 编辑
                                        </button>

                                        <c:if test="${!addr.isDefault()}">
                                            <form action="address" method="post" style="display: inline;">
                                                <input type="hidden" name="action" value="setDefault">
                                                <input type="hidden" name="id" value="${addr.id}">
                                                <button type="submit" class="btn-action btn-set-default">
                                                    <i class="bi bi-check-circle"></i> 设为默认
                                                </button>
                                            </form>
                                        </c:if>

                                        <form action="address" method="post" style="display: inline;"
                                              onsubmit="return confirm('确定要删除该地址吗？');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="${addr.id}">
                                            <button type="submit" class="btn-action btn-delete">
                                                <i class="bi bi-trash"></i> 删除
                                            </button>
                                        </form>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
          </c:otherwise>
        </c:choose>
      </div>
    </div>
  </main>
</div>

<!-- 新增地址模态框 -->
<div class="modal fade" id="addAddressModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">新增收货地址</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <form action="address" method="post">
        <input type="hidden" name="action" value="add">
        <div class="modal-body">
          <div class="mb-3">
            <label class="form-label">收货人姓名 <span class="text-danger">*</span></label>
            <input type="text" name="receiverName" class="form-control" placeholder="请输入收货人姓名" required>
          </div>
          <div class="mb-3">
            <label class="form-label">联系电话 <span class="text-danger">*</span></label>
            <input type="tel" name="receiverPhone" class="form-control" placeholder="请输入11位手机号"
                   required pattern="1[3-9]\d{9}">
          </div>
          <div class="row">
            <div class="col-md-4 mb-3">
              <label class="form-label">省份 <span class="text-danger">*</span></label>
              <input type="text" name="province" class="form-control" placeholder="如：广东省" required>
            </div>
            <div class="col-md-4 mb-3">
              <label class="form-label">城市 <span class="text-danger">*</span></label>
              <input type="text" name="city" class="form-control" placeholder="如：深圳市" required>
            </div>
            <div class="col-md-4 mb-3">
              <label class="form-label">区县 <span class="text-danger">*</span></label>
              <input type="text" name="district" class="form-control" placeholder="如：南山区" required>
            </div>
          </div>
          <div class="mb-3">
            <label class="form-label">详细地址 <span class="text-danger">*</span></label>
            <textarea name="detailAddress" class="form-control" rows="3"
                      placeholder="请输入街道、门牌号等详细信息" required></textarea>
          </div>
          <div class="form-check">
            <input class="form-check-input" type="checkbox" name="isDefault" id="addDefault">
            <label class="form-check-label" for="addDefault">
              设为默认地址
            </label>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">取消</button>
          <button type="submit" class="btn btn-danger">保存</button>
        </div>
      </form>
    </div>
  </div>
</div>

<!-- 编辑地址模态框 -->
<div class="modal fade" id="editAddressModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">编辑收货地址</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <form action="address" method="post">
        <input type="hidden" name="action" value="update">
        <input type="hidden" name="id" id="editId">
        <div class="modal-body">
          <div class="mb-3">
            <label class="form-label">收货人姓名 <span class="text-danger">*</span></label>
            <input type="text" name="receiverName" id="editName" class="form-control" required>
          </div>
          <div class="mb-3">
            <label class="form-label">联系电话 <span class="text-danger">*</span></label>
            <input type="tel" name="receiverPhone" id="editPhone" class="form-control"
                   required pattern="1[3-9]\d{9}">
          </div>
          <div class="row">
            <div class="col-md-4 mb-3">
              <label class="form-label">省份 <span class="text-danger">*</span></label>
              <input type="text" name="province" id="editProvince" class="form-control" required>
            </div>
            <div class="col-md-4 mb-3">
              <label class="form-label">城市 <span class="text-danger">*</span></label>
              <input type="text" name="city" id="editCity" class="form-control" required>
            </div>
            <div class="col-md-4 mb-3">
              <label class="form-label">区县 <span class="text-danger">*</span></label>
              <input type="text" name="district" id="editDistrict" class="form-control" required>
            </div>
          </div>
          <div class="mb-3">
            <label class="form-label">详细地址 <span class="text-danger">*</span></label>
            <textarea name="detailAddress" id="editDetail" class="form-control" rows="3" required></textarea>
          </div>
          <div class="form-check">
            <input class="form-check-input" type="checkbox" name="isDefault" id="editDefault">
            <label class="form-check-label" for="editDefault">
              设为默认地址
            </label>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">取消</button>
          <button type="submit" class="btn btn-danger">保存</button>
        </div>
      </form>
    </div>
  </div>
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
  });

  // 监听编辑模态框弹出事件，将当前行的地址数据填充到表单中
  document.getElementById('editAddressModal').addEventListener('show.bs.modal', function (event) {
    const button = event.relatedTarget;
    const modal = this;

    modal.querySelector('#editId').value = button.getAttribute('data-id');
    modal.querySelector('#editName').value = button.getAttribute('data-name');
    modal.querySelector('#editPhone').value = button.getAttribute('data-phone');
    modal.querySelector('#editProvince').value = button.getAttribute('data-province');
    modal.querySelector('#editCity').value = button.getAttribute('data-city');
    modal.querySelector('#editDistrict').value = button.getAttribute('data-district');
    modal.querySelector('#editDetail').value = button.getAttribute('data-detail');
    modal.querySelector('#editDefault').checked = button.getAttribute('data-default') === 'true';
  });
</script>
</body>
</html>
