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
  <link rel="stylesheet" href="css/common.css">
  <style>
    :root { --sidebar-width: 240px; }
    body { background: var(--bg-gray); }
    .sidebar { width: var(--sidebar-width); }
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
        <!-- 首次地址积分奖励提示 -->
        <c:if test="${firstAddressBonus == '1'}">
          <div style="background:linear-gradient(135deg,#d4edda,#c3e6cb);border:1px solid #b8daff;border-radius:10px;padding:16px 20px;margin-bottom:20px;display:flex;align-items:center;gap:12px;">
            <i class="bi bi-gift-fill" style="font-size:24px;color:#28a745;"></i>
            <div>
              <strong style="color:#155724;">首次添加地址送积分！</strong>
              <span style="color:#155724;font-size:14px;">添加您的第一个收货地址即可获得 <strong>50 积分</strong> 奖励 🎉</span>
            </div>
          </div>
        </c:if>

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
              <select name="province" class="form-select" required onchange="onProvinceChange(this, 'add')">
                <option value="">请选择省份</option>
              </select>
            </div>
            <div class="col-md-4 mb-3">
              <label class="form-label">城市 <span class="text-danger">*</span></label>
              <select name="city" class="form-select" required onchange="onCityChange(this, 'add')">
                <option value="">请先选择省份</option>
              </select>
            </div>
            <div class="col-md-4 mb-3">
              <label class="form-label">区县 <span class="text-danger">*</span></label>
              <select name="district" class="form-select" required>
                <option value="">请先选择城市</option>
              </select>
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
              <select name="province" id="editProvince" class="form-select" required onchange="onProvinceChange(this, 'edit')">
                <option value="">请选择省份</option>
              </select>
            </div>
            <div class="col-md-4 mb-3">
              <label class="form-label">城市 <span class="text-danger">*</span></label>
              <select name="city" id="editCity" class="form-select" required onchange="onCityChange(this, 'edit')">
                <option value="">请先选择省份</option>
              </select>
            </div>
            <div class="col-md-4 mb-3">
              <label class="form-label">区县 <span class="text-danger">*</span></label>
              <select name="district" id="editDistrict" class="form-select" required>
                <option value="">请先选择城市</option>
              </select>
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
  // ── 全国省市区数据 ──
  const REGIONS = {
    "北京市":{"北京市":["东城区","西城区","朝阳区","海淀区","丰台区","石景山区","通州区","大兴区","昌平区","顺义区","房山区","门头沟区","怀柔区","密云区","延庆区","平谷区"]},
    "上海市":{"上海市":["黄浦区","徐汇区","长宁区","静安区","普陀区","虹口区","杨浦区","浦东新区","闵行区","宝山区","嘉定区","金山区","松江区","青浦区","奉贤区","崇明区"]},
    "天津市":{"天津市":["和平区","河东区","河西区","南开区","河北区","红桥区","滨海新区","东丽区","西青区","津南区","北辰区","武清区","宝坻区","宁河区","静海区","蓟州区"]},
    "重庆市":{"重庆市":["渝中区","江北区","南岸区","沙坪坝区","九龙坡区","大渡口区","北碚区","渝北区","巴南区","万州区","涪陵区","黔江区","长寿区","江津区","永川区","合川区"]},
    "河北省":{"石家庄市":["长安区","桥西区","新华区","裕华区","井陉矿区","藁城区","鹿泉区","栾城区"],"唐山市":["路北区","路南区","古冶区","开平区","丰润区","丰南区"],"保定市":["竞秀区","莲池区","满城区","清苑区","徐水区"]},
    "山西省":{"太原市":["杏花岭区","小店区","迎泽区","尖草坪区","万柏林区","晋源区"],"大同市":["平城区","云冈区","新荣区","云州区"],"运城市":["盐湖区","永济市","河津市"]},
    "内蒙古自治区":{"呼和浩特市":["新城区","回民区","玉泉区","赛罕区"],"包头市":["昆都仑区","青山区","东河区","九原区"],"赤峰市":["红山区","元宝山区","松山区"]},
    "辽宁省":{"沈阳市":["和平区","沈河区","大东区","皇姑区","铁西区","浑南区","于洪区"],"大连市":["中山区","西岗区","沙河口区","甘井子区","旅顺口区","金州区"]},
    "吉林省":{"长春市":["南关区","宽城区","朝阳区","二道区","绿园区","净月区"],"吉林市":["昌邑区","龙潭区","船营区","丰满区"]},
    "黑龙江省":{"哈尔滨市":["道里区","南岗区","道外区","平房区","松北区","香坊区","呼兰区"],"齐齐哈尔市":["龙沙区","建华区","铁锋区"]},
    "江苏省":{"南京市":["玄武区","秦淮区","建邺区","鼓楼区","浦口区","栖霞区","雨花台区","江宁区"],"苏州市":["姑苏区","虎丘区","吴中区","相城区","吴江区","苏州工业园区"],"无锡市":["梁溪区","锡山区","惠山区","滨湖区","新吴区"],"常州市":["天宁区","钟楼区","新北区","武进区","金坛区"]},
    "浙江省":{"杭州市":["上城区","拱墅区","西湖区","滨江区","萧山区","余杭区","临平区","钱塘区","富阳区","临安区"],"宁波市":["海曙区","江北区","北仑区","镇海区","鄞州区","奉化区"],"温州市":["鹿城区","龙湾区","瓯海区","洞头区"]},
    "安徽省":{"合肥市":["瑶海区","庐阳区","蜀山区","包河区","肥西县","肥东县","长丰县"],"芜湖市":["镜湖区","弋江区","鸠江区","三山区"]},
    "福建省":{"福州市":["鼓楼区","台江区","仓山区","马尾区","晋安区","长乐区"],"厦门市":["思明区","湖里区","集美区","海沧区","同安区","翔安区"],"泉州市":["鲤城区","丰泽区","洛江区","泉港区","晋江市","石狮市"]},
    "江西省":{"南昌市":["东湖区","西湖区","青云谱区","青山湖区","新建区","红谷滩区"],"赣州市":["章贡区","南康区","赣县区"]},
    "山东省":{"济南市":["历下区","市中区","槐荫区","天桥区","历城区","长清区","章丘区"],"青岛市":["市南区","市北区","李沧区","崂山区","黄岛区","城阳区","即墨区"],"烟台市":["芝罘区","福山区","牟平区","莱山区"]},
    "河南省":{"郑州市":["中原区","二七区","管城回族区","金水区","惠济区","上街区","郑东新区"],"洛阳市":["老城区","西工区","瀍河区","涧西区","洛龙区"],"开封市":["龙亭区","顺河区","鼓楼区","禹王台区","祥符区"]},
    "湖北省":{"武汉市":["江岸区","江汉区","硚口区","汉阳区","武昌区","青山区","洪山区","东西湖区","汉南区","蔡甸区","江夏区","黄陂区"],"宜昌市":["西陵区","伍家岗区","点军区","猇亭区","夷陵区"]},
    "湖南省":{"长沙市":["芙蓉区","天心区","岳麓区","开福区","雨花区","望城区"],"株洲市":["荷塘区","芦淞区","石峰区","天元区"],"衡阳市":["珠晖区","雁峰区","石鼓区","蒸湘区"]},
    "广东省":{"广州市":["越秀区","荔湾区","海珠区","天河区","白云区","黄埔区","番禺区","花都区","南沙区","从化区","增城区"],"深圳市":["罗湖区","福田区","南山区","宝安区","龙岗区","盐田区","龙华区","坪山区","光明区"],"珠海市":["香洲区","斗门区","金湾区"],"佛山市":["禅城区","南海区","顺德区","三水区","高明区"],"东莞市":["南城街道","莞城街道","东城街道","万江街道","虎门镇","长安镇","厚街镇"],"中山市":["石岐街道","东区街道","西区街道","南区街道","火炬开发区"]},
    "广西壮族自治区":{"南宁市":["兴宁区","青秀区","江南区","西乡塘区","良庆区","邕宁区"],"桂林市":["秀峰区","叠彩区","象山区","七星区","雁山区","临桂区"]},
    "海南省":{"海口市":["秀英区","龙华区","琼山区","美兰区"],"三亚市":["海棠区","吉阳区","天涯区","崖州区"]},
    "四川省":{"成都市":["锦江区","青羊区","金牛区","武侯区","成华区","龙泉驿区","青白江区","新都区","温江区","双流区","郫都区"],"绵阳市":["涪城区","游仙区","安州区"],"德阳市":["旌阳区","罗江区","广汉市","什邡市"]},
    "贵州省":{"贵阳市":["南明区","云岩区","花溪区","乌当区","白云区","观山湖区"],"遵义市":["红花岗区","汇川区","播州区"]},
    "云南省":{"昆明市":["五华区","盘龙区","官渡区","西山区","呈贡区","东川区"],"大理市":["大理市"]},
    "西藏自治区":{"拉萨市":["城关区","堆龙德庆区","达孜区"],"日喀则市":["桑珠孜区"]},
    "陕西省":{"西安市":["新城区","碑林区","莲湖区","灞桥区","未央区","雁塔区","阎良区","长安区","临潼区","高陵区","鄠邑区"],"咸阳市":["秦都区","渭城区","杨陵区"]},
    "甘肃省":{"兰州市":["城关区","七里河区","西固区","安宁区","红古区"],"天水市":["秦州区","麦积区"]},
    "青海省":{"西宁市":["城东区","城中区","城西区","城北区","湟中区"]},
    "宁夏回族自治区":{"银川市":["兴庆区","金凤区","西夏区","灵武市"],"石嘴山市":["大武口区","惠农区"]},
    "新疆维吾尔自治区":{"乌鲁木齐市":["天山区","沙依巴克区","新市区","水磨沟区","头屯河区","达坂城区"],"克拉玛依市":["独山子区","克拉玛依区","白碱滩区","乌尔禾区"]},
    "台湾省":{"台北市":["中正区","大同区","中山区","万华区","信义区","松山区","大安区","南港区","北投区","内湖区","士林区","文山区"],"高雄市":["盐埕区","鼓山区","左营区","楠梓区","三民区","新兴区","前金区","苓雅区","前镇区","旗津区","小港区","凤山区"]},
    "香港特别行政区":{"香港岛":["中西区","湾仔区","东区","南区"],"九龙":["油尖旺区","深水埗区","九龙城区","黄大仙区","观塘区"],"新界":["沙田区","大埔区","北区","西贡区","荃湾区","屯门区","元朗区","离岛区"]},
    "澳门特别行政区":{"澳门半岛":["花地玛堂区","圣安多尼堂区","大堂区","望德堂区","风顺堂区"],"氹仔":["嘉模堂区"],"路环":["圣方济各堂区"]}
  };

  // 获取 select 元素（前缀区分新增/编辑）
  function sel(prefix, name) {
    return document.getElementById((prefix === 'add' ? '' : 'edit') + name.charAt(0).toUpperCase() + name.slice(1))
        || document.querySelector('#' + (prefix === 'add' ? 'addAddressModal' : 'editAddressModal') + ' select[name="' + name + '"]');
  }

  // 省份变更 → 加载城市
  function onProvinceChange(select, prefix) {
    var prov = select.value;
    var citySel = sel(prefix, 'city');
    var distSel = sel(prefix, 'district');
    citySel.innerHTML = '<option value="">请选择城市</option>';
    distSel.innerHTML = '<option value="">请先选择城市</option>';
    if (prov && REGIONS[prov]) {
      Object.keys(REGIONS[prov]).forEach(function(city) {
        citySel.innerHTML += '<option value="' + city + '">' + city + '</option>';
      });
    }
  }

  // 城市变更 → 加载区县
  function onCityChange(select, prefix) {
    var prov = sel(prefix, 'province').value;
    var city = select.value;
    var distSel = sel(prefix, 'district');
    distSel.innerHTML = '<option value="">请选择区县</option>';
    if (prov && city && REGIONS[prov] && REGIONS[prov][city]) {
      REGIONS[prov][city].forEach(function(d) {
        distSel.innerHTML += '<option value="' + d + '">' + d + '</option>';
      });
    }
  }

  // 初始化所有省市区下拉框
  function initRegionSelects() {
    document.querySelectorAll('.form-select[name="province"]').forEach(function(sel) {
      sel.innerHTML = '<option value="">请选择省份</option>';
      Object.keys(REGIONS).forEach(function(prov) {
        sel.innerHTML += '<option value="' + prov + '">' + prov + '</option>';
      });
    });
  }

  // 设置编辑模态框的省市区值
  function setEditRegion(province, city, district) {
    var provSel = document.getElementById('editProvince');
    // 先选中省份
    for (var i = 0; i < provSel.options.length; i++) {
      if (provSel.options[i].value === province) {
        provSel.selectedIndex = i;
        break;
      }
    }
    // 触发城市加载
    onProvinceChange(provSel, 'edit');
    var citySel = document.getElementById('editCity');
    // 选中城市
    for (var i = 0; i < citySel.options.length; i++) {
      if (citySel.options[i].value === city) {
        citySel.selectedIndex = i;
        break;
      }
    }
    // 触发区县加载
    onCityChange(citySel, 'edit');
    var distSel = document.getElementById('editDistrict');
    // 选中区县
    for (var i = 0; i < distSel.options.length; i++) {
      if (distSel.options[i].value === district) {
        distSel.selectedIndex = i;
        break;
      }
    }
  }

  // 页面加载时初始化
  document.addEventListener('DOMContentLoaded', function() {
    initRegionSelects();
    const modal = document.getElementById('copyrightModal');
    if (modal) { modal.addEventListener('click', function(e) { if (e.target === modal) closeCopyright(); }); }
  });

  // 监听编辑模态框弹出事件，填充数据
  document.getElementById('editAddressModal').addEventListener('show.bs.modal', function (event) {
    const button = event.relatedTarget;
    const modal = this;

    modal.querySelector('#editId').value = button.getAttribute('data-id');
    modal.querySelector('#editName').value = button.getAttribute('data-name');
    modal.querySelector('#editPhone').value = button.getAttribute('data-phone');
    modal.querySelector('#editDetail').value = button.getAttribute('data-detail');
    modal.querySelector('#editDefault').checked = button.getAttribute('data-default') === 'true';

    var prov = button.getAttribute('data-province');
    var city = button.getAttribute('data-city');
    var dist = button.getAttribute('data-district');
    if (prov) setEditRegion(prov, city, dist);
  });

  function showCopyright() { document.getElementById('copyrightModal').classList.add('show'); }
  function closeCopyright() { document.getElementById('copyrightModal').classList.remove('show'); }
</script>
</body>
</html>
