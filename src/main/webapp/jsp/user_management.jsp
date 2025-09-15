<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ユーザー管理 - 勤怠管理システム</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/user-management.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <script>
        function validateUserForm() {
            const username = document.getElementById('username').value.trim();
            const password = document.getElementById('password').value;
            const isEdit = document.querySelector('input[name="action"]').value === 'update';
            
            if (!username) {
                alert('ユーザーIDを入力してください。');
                return false;
            }
            
            if (!isEdit && !password) {
                alert('パスワードを入力してください。');
                return false;
            }
            
            if (username.length < 3) {
                alert('ユーザーIDは3文字以上で入力してください。');
                return false;
            }
            
            if (password && password.length < 4) {
                alert('パスワードは4文字以上で入力してください。');
                return false;
            }
            
            return true;
        }
        
        function confirmAction(action, username) {
            const messages = {
                'delete': '本当にユーザー「' + username + '」を削除しますか？',
                'toggle_enable': '本当にユーザー「' + username + '」のアカウント状態を変更しますか？',
                'reset_password': '本当にユーザー「' + username + '」のパスワードをリセットしますか？\n（デフォルトパスワード: password）'
            };
            return confirm(messages[action] || '本当に実行しますか？');
        }
        
        function clearForm() {
            document.getElementById('username').value = '';
            document.getElementById('password').value = '';
            document.getElementById('role').value = 'employee';
            document.getElementById('enabled').checked = true;
            document.querySelector('input[name="action"]').value = 'add';
            
            // readonly属性を削除
            document.getElementById('username').removeAttribute('readonly');
            
            // フォームタイトルを更新
            document.querySelector('.form-title').textContent = 'ユーザー追加';
        }
    </script>
</head>
<body>
    <div class="container">
        <header class="page-header">
            <div class="header-content">
                <div class="header-left">
                    <h1><i class="fas fa-users-cog"></i> ユーザー管理</h1>
                </div>
                <div class="user-info">
                    <div class="user-avatar">
                        <i class="fas fa-user-shield"></i>
                    </div>
                    <div class="user-details">
                        <h3 class="username"><c:out value="${user.username}"/></h3>
                        <span class="user-role">管理者</span>
                    </div>
                </div>
            </div>
        </header>

        <!-- ナビゲーションメニュー -->
        <nav class="main-nav">
            <a href="attendance?action=filter" class="nav-link">
                <i class="fas fa-chart-line"></i> 勤怠履歴管理
            </a>
            <a href="user?action=list" class="nav-link active">
                <i class="fas fa-users"></i> ユーザー管理
            </a>
            <a href="logout" class="nav-link logout">
                <i class="fas fa-sign-out-alt"></i> ログアウト
            </a>
        </nav>

        <!-- メッセージ表示エリア -->
        <div class="message-area">
            <c:if test="${not empty sessionScope.successMessage}">
                <div class="success-message">
                    <c:out value="${sessionScope.successMessage}"/>
                </div>
                <c:remove var="successMessage" scope="session"/>
            </c:if>
            
            <c:if test="${not empty errorMessage}">
                <div class="error-message">
                    <c:out value="${errorMessage}"/>
                </div>
            </c:if>
        </div> 
         <main>
            <!-- ユーザー追加/編集フォーム -->
            <section class="user-form-section">
                <h2 class="form-title">
                    <c:choose>
                        <c:when test="${userToEdit != null}">
                            👤 ユーザー編集: <c:out value="${userToEdit.username}"/>
                        </c:when>
                        <c:otherwise>
                            ユーザー追加
                            ➕ ユーザー追加
                        </c:otherwise>
                    </c:choose>
                </h2>
                
                <form action="user" method="post" class="user-form" onsubmit="return validateUserForm()">
                    <input type="hidden" name="action" value="<c:choose><c:when test="${userToEdit != null}">update</c:when><c:otherwise>add</c:otherwise></c:choose>">
                    <c:if test="${userToEdit != null}">
                        <input type="hidden" name="username" value="${userToEdit.username}">
                    </c:if>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="username">ユーザーID *</label>
                            <input type="text" 
                                   id="username" 
                                   name="username" 
                                   value="<c:out value="${userToEdit.username}"/>" 
                                   <c:if test="${userToEdit != null}">readonly</c:if>
                                   required
                                   placeholder="例: employee3"
                                   minlength="3"
                                   maxlength="20">
                            <small>3-20文字の英数字で入力してください</small>
                        </div>

                        <div class="form-group">
                            <label for="password">
                                パスワード
                                <c:if test="${userToEdit == null}"> *</c:if>
                            </label>
                            <input type="password" 
                                   id="password" 
                                   name="password" 
                                   <c:if test="${userToEdit == null}">required</c:if>
                                   placeholder="4文字以上で入力"
                                   minlength="4">
                            <c:choose>
                                <c:when test="${userToEdit != null}">
                                    <small class="warning-text">※編集時はパスワードは変更されません。リセットする場合は下のボタンを使用してください。</small>
                                </c:when>
                                <c:otherwise>
                                    <small>4文字以上で入力してください</small>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div class="form-group">
                            <label for="role">役割 *</label>
                            <select id="role" name="role" required>
                                <option value="employee" <c:if test="${userToEdit.role == 'employee'}">selected</c:if>>
                                    👨‍💼 従業員
                                </option>
                                <option value="admin" <c:if test="${userToEdit.role == 'admin'}">selected</c:if>>
                                    👨‍💻 管理者
                                </option>
                            </select>
                            <small>役割を選択してください</small>
                        </div>

                        <div class="form-group checkbox-form-group">
                        </div>

                        <div class="form-group">
                            <div class="checkbox-group">
                                <input type="checkbox" 
                                       id="enabled" 
                                       name="enabled" 
                                       value="true" 
                                       <c:if test="${userToEdit == null || userToEdit.enabled}">checked</c:if>>
                                <label for="enabled" class="checkbox-label">
                                    <span class="checkbox-text">アカウントを有効にする</span>
                                    <small>無効にするとログインできなくなります</small>
                                </label>
                            </div>
                        </div>
                    </div>

                    <div class="button-group">
                        <button type="submit" class="button primary">
                            <c:choose>
                                <c:when test="${userToEdit != null}">
                                    💾 更新
                                </c:when>
                                <c:otherwise>
                                    ➕ 追加
                                </c:otherwise>
                            </c:choose>
                        </button>
                        
                        <c:if test="${userToEdit != null}">
                            <button type="button" class="button secondary" onclick="clearForm()">
                                🆕 新規追加モード
                            </button>
                        </c:if>
                        
                        <button type="reset" class="button secondary">
                            🔄 リセット
                        </button>
                    </div>
                </form>
                
                <!-- パスワードリセット（編集時のみ） -->
                <c:if test="${userToEdit != null}">
                    <div class="password-reset-section">
                        <h3>パスワード管理</h3>
                        <h3>🔑 パスワード管理</h3>
                        <form action="user" method="post" class="reset-form">
                            <input type="hidden" name="action" value="reset_password">
                            <input type="hidden" name="username" value="${userToEdit.username}">
                            <input type="hidden" name="newPassword" value="password">
                            <button type="submit" 
                                    class="button warning"
                                    onclick="return confirmAction('reset_password', '${userToEdit.username}')">
                                パスワードを「password」にリセット
                                🔑 パスワードを「password」にリセット
                            </button>
                        </form>
                    </div>
                </c:if>
            </section>
            <!-- ユーザーリスト -->
            <section class="user-list-section">
                <h2>既存ユーザー一覧</h2>
                <h2>👥 既存ユーザー一覧</h2>
                
                <div class="user-stats">
                    <div class="stat-item">
                        <span class="stat-value">${fn:length(users)}</span>
                        <span class="stat-label">総ユーザー数</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-value">
                            <c:set var="activeCount" value="0"/>
                            <c:forEach var="u" items="${users}">
                                <c:if test="${u.enabled}">
                                    <c:set var="activeCount" value="${activeCount + 1}"/>
                                </c:if>
                            </c:forEach>
                            ${activeCount}
                        </span>
                        <span class="stat-label">有効ユーザー</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-value">
                            <c:set var="adminCount" value="0"/>
                            <c:forEach var="u" items="${users}">
                                <c:if test="${u.role == 'admin'}">
                                    <c:set var="adminCount" value="${adminCount + 1}"/>
                                </c:if>
                            </c:forEach>
                            ${adminCount}
                        </span>
                        <span class="stat-label">管理者</span>
                    </div>
                </div>
                
                <div class="table-container">
                    <table class="users-table">
                        <thead>
                            <tr>
                                <th>ユーザーID</th>
                                <th>役割</th>
                                <th>ステータス</th>
                                <th>操作</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="u" items="${users}">
                                <tr class="${u.enabled ? 'user-active' : 'user-inactive'}">
                                    <td>
                                        <div class="user-info">
                                            <strong><c:out value="${u.username}"/></strong>
                                            <c:if test="${u.username == user.username}">
                                                <span class="current-user-badge">現在のユーザー</span>
                                            </c:if>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="role-badge ${u.role}">
                                            <c:choose>
                                                <c:when test="${u.role == 'admin'}">
                                                    👨‍💻 管理者
                                                </c:when>
                                                <c:otherwise>
                                                    👨‍💼 従業員
                                                </c:otherwise>
                                            </c:choose>
                                        </span>
                                    </td>
                                    <td>
                                        <div class="status-controls">
                                            <span class="status-badge ${u.enabled ? 'active' : 'inactive'}">
                                                ${u.enabled ? '有効' : '無効'}
                                            </span>
                                            <form action="user" method="post" class="toggle-form">
                                                ${u.enabled ? '✅ 有効' : '❌ 無効'}
                                            </span>
                                                                                            <form action="user" method="post" class="toggle-form">
                                                <input type="hidden" name="action" value="toggle_enabled">
                                                <input type="hidden" name="username" value="${u.username}">
                                                <input type="hidden" name="enabled" value="${!u.enabled}">
                                                <button type="submit" 
                                                        class="button small ${u.enabled ? 'warning' : 'success'}"
                                                        onclick="return confirmAction('toggle_enable', '${u.username}')"
                                                        <c:if test="${u.username == user.username}">disabled title="自分のアカウントは変更できません"</c:if>>
                                                    <c:choose>
                                                        <c:when test="${u.enabled}">
                                                            🚫 無効化
                                                        </c:when>
                                                        <c:otherwise>
                                                            ✅ 有効化
                                                        </c:otherwise>
                                                    </c:choose>
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                    <td class="table-actions">
                                        <div class="action-buttons">
                                            <a href="user?action=edit&username=${u.username}" 
                                               class="button small primary">
                                                編集
                                                ✏️ 編集
                                            </a>
                                            <form action="user" method="post" class="delete-form">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="username" value="${u.username}">
                                                <button type="submit" 
                                                        class="button small danger"
                                                        onclick="return confirmAction('delete', '${u.username}')"
                                                        <c:if test="${u.username == user.username}">disabled title="自分のアカウントは削除できません"</c:if>>
                                                    削除
                                                    🗑️ 削除
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty users}">
                                <tr>
                                    <td colspan="4" class="no-data">
                                        <div class="empty-state">
                                            <div class="empty-icon">👥</div>
                                            <div class="empty-text">ユーザーがいません</div>
                                            <div class="empty-subtext">上のフォームから新しいユーザーを追加してください</div>
                                        </div>
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </section>
        </main>
        
        <footer class="page-footer">
            <p>&copy; 2025 勤怠管理システム Clockin</p>
        </footer>
    </div>
</body>
</html>