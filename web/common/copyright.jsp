<%-- 版权说明模态框 - 公共组件 --%>
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
