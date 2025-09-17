<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>管理者メニュー - 勤怠管理システム</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
    <div class="container">
        <header class="page-header">
            <div class="header-content">
                <div class="header-left">
                    <h1><i class="fas fa-user-cog"></i> 管理者メニュー</h1>
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
            <a href="attendance?action=filter" class="nav-link active">
                <i class="fas fa-chart-line"></i> 勤怠履歴管理
            </a>
            <a href="user?action=list" class="nav-link">
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
            <!-- 勤怠履歴フィルター -->
            <section class="card-section">
                <h2 class="card-title">＋ 勤怠履歴フィルター</h2>
                <form action="attendance" method="get" class="filter-form">
                    <input type="hidden" name="action" value="filter">
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="filterUserId">ユーザーID:</label>
                            <input type="text" 
                                   id="filterUserId" 
                                   name="filterUserId" 
                                   value="<c:out value="${param.filterUserId}"/>"
                                   placeholder="すべてのユーザー">
                        </div>
                        
                        <div class="form-group">
                            <label for="startDate">開始日:</label>
                            <input type="date" 
                                   id="startDate" 
                                   name="startDate" 
                                   value="<c:out value="${param.startDate}"/>">
                        </div>
                        
                        <div class="form-group">
                            <label for="endDate">終了日:</label>
                            <input type="date" 
                                   id="endDate" 
                                   name="endDate" 
                                   value="<c:out value="${param.endDate}"/>">
                        </div>
                        
                        <div class="form-group">
                            <button type="submit" class="button primary">＋ フィルタ実行</button>
                        </div>
                    </div>
                </form>
            </section>

             <!-- 勤怠サマリー -->
            <section class="card-section">
                <h2 class="card-title">＋ 勤怠サマリー</h2>
                
                <div class="summary-card">
                    <h3>合計労働時間</h3>
                    <div class="table-container">
                        <table class="summary-table">
                            <thead>
                                <tr>
                                    <th>ユーザーID</th>
                                    <th>合計労働時間 (時間)</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="entry" items="${totalHoursByUser}">
                                    <tr>
                                        <td><c:out value="${entry.key}"/></td>
                                        <td>
                                            <span class="hours-value">${entry.value}</span> 時間
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty totalHoursByUser}">
                                    <tr>
                                        <td colspan="2" class="no-data">データがありません。</td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>

            <!-- 月別統計グラフ -->
            <section class="card-section">
                <h2 class="card-title">＋ 月別統計 (簡易グラフ)</h2>
                
                <div class="chart-container">
                    <div class="chart-item">
                        <h3>月別合計労働時間</h3>
                        <div class="bar-chart">
                            <c:forEach var="entry" items="${monthlyWorkingHours}">
                                <div class="chart-row">
                                    <span class="chart-label">${entry.key}:</span>
                                    <div class="chart-bar">
                                        <c:choose>
                                            <c:when test="${entry.value >= 25}">
                                                <c:forEach begin="1" end="5">
                                                    <span class="bar-unit">█</span>
                                                </c:forEach>
                                            </c:when>
                                            <c:when test="${entry.value >= 20}">
                                                <c:forEach begin="1" end="4">
                                                    <span class="bar-unit">█</span>
                                                </c:forEach>
                                            </c:when>
                                            <c:when test="${entry.value >= 15}">
                                                <c:forEach begin="1" end="3">
                                                    <span class="bar-unit">█</span>
                                                </c:forEach>
                                            </c:when>
                                            <c:when test="${entry.value >= 10}">
                                                <c:forEach begin="1" end="2">
                                                    <span class="bar-unit">█</span>
                                                </c:forEach>
                                            </c:when>
                                            <c:when test="${entry.value >= 5}">
                                                <span class="bar-unit">█</span>
                                            </c:when>
                                            <c:when test="${entry.value > 0}">
                                                <span class="bar-unit">█</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="no-data">-</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <span class="chart-value">${entry.value}時間</span>
                                </div>
                            </c:forEach>
                            <c:if test="${empty monthlyWorkingHours}">
                                <div class="no-data">データがありません。</div>
                            </c:if>
                        </div>
                    </div>

                    <div class="chart-item">
                        <h3>月別出勤日数</h3>
                        <div class="bar-chart">
                            <c:forEach var="entry" items="${monthlyCheckInCounts}">
                                <div class="chart-row">
                                    <span class="chart-label">${entry.key}:</span>
                                    <div class="chart-bar">
                                        <c:choose>
                                            <c:when test="${entry.value > 0}">
                                                <c:forEach begin="1" end="${entry.value}">
                                                    <span class="bar-unit">■</span>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="no-data">-</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <span class="chart-value">${entry.value}日</span>
                                </div>
                            </c:forEach>
                            <c:if test="${empty monthlyCheckInCounts}">
                                <div class="no-data">データがありません。</div>
                            </c:if>
                        </div>
                    </div>
                </div>
            </section> 
             <!-- 詳細勤怠履歴 -->
            <section class="card-section">
                <div class="section-header-with-button">
                    <h2 class="card-title">＋ 詳細勤怠履歴</h2>
                    <a href="attendance?action=export_csv&filterUserId=<c:out value="${param.filterUserId}"/>&startDate=<c:out value="${param.startDate}"/>&endDate=<c:out value="${param.endDate}"/>" 
                       class="button secondary">
                        ＋ CSV エクスポート
                    </a>
                </div>
                
                <div class="table-container">
                    <table class="records-table">
                        <thead>
                            <tr>
                                <th>
                                    <input type="checkbox" id="selectAll" onclick="toggleAllCheckboxes()">
                                    全選択
                                </th>
                                <th>従業員ID</th>
                                <th>出勤時刻</th>
                                <th>退勤時刻</th>
                                <th>勤務時間</th>
                                <th>操作</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="att" items="${allAttendanceRecords}">
                                <tr>
                                    <td>
                                        <input type="checkbox" class="record-checkbox" 
                                               value="${att.userId}|${att.checkInTime}|${att.checkOutTime}">
                                    </td>
                                    <td><c:out value="${att.userId}"/></td>
                                    <td>
                                        <c:if test="${att.checkInTime != null}">
                                            ${att.checkInTime.toLocalDate().toString()} ${att.checkInTime.toLocalTime().toString().substring(0, 5)}
                                        </c:if>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${att.checkOutTime != null}">
                                                ${att.checkOutTime.toLocalDate().toString()} ${att.checkOutTime.toLocalTime().toString().substring(0, 5)}
                                            </c:when>
                                            <c:otherwise>
                                                <span class="working-status">勤務中</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <span class="work-hours">${att.workingHours}</span>
                                    </td>
                                    <td class="table-actions">
                                        <form action="attendance" method="post" class="inline-form">
                                            <input type="hidden" name="action" value="delete_manual">
                                            <input type="hidden" name="userId" value="${att.userId}">
                                            <input type="hidden" name="checkInTime" value="${att.checkInTime}">
                                            <input type="hidden" name="checkOutTime" value="${att.checkOutTime != null ? att.checkOutTime : ''}">
                                            <button type="submit" 
                                                    class="button danger small"
                                                    onclick="return confirm('本当にこの勤怠記録を削除しますか？');">
                                                削除
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty allAttendanceRecords}">
                                <tr>
                                    <td colspan="6" class="no-data">データがありません。</td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
                
                <!-- 一括削除ボタン -->
                <div class="bulk-actions" style="margin-top: 1rem;">
                    <button type="button" id="bulkDeleteBtn" class="button danger" onclick="bulkDeleteRecords()">
                        選択した記録を削除
                    </button>
                </div>
            </section>

            <!-- 勤怠記録の手動追加 -->
            <section class="card-section">
                <h2 class="card-title">➕ 勤怠記録の手動追加</h2>
                
                <form action="attendance" method="post" class="manual-form">
                    <input type="hidden" name="action" value="add_manual">
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="manualUserId">ユーザーID *</label>
                            <input type="text" 
                                   id="manualUserId" 
                                   name="userId" 
                                   required
                                   placeholder="例: employee1">
                        </div>
                        
                        <div class="form-group">
                            <label for="manualCheckInTime">出勤時刻 *</label>
                            <input type="datetime-local" 
                                   id="manualCheckInTime" 
                                   name="checkInTime" 
                                   required>
                        </div>
                        
                        <div class="form-group">
                            <label for="manualCheckOutTime">退勤時刻</label>
                            <input type="datetime-local" 
                                   id="manualCheckOutTime" 
                                   name="checkOutTime">
                        </div>
                    </div>
                    
                    <div class="button-group">
                        <button type="submit" class="button primary">
                            ➕ 勤怠記録を追加
                        </button>
                    </div>
                </form>
            </section>
        </main>
        
        <footer class="page-footer">
            <p>&copy; 2025 勤怠管理システム Clockin</p>
        </footer>
    </div>
    
    <script>
        function toggleAllCheckboxes() {
            const selectAllCheckbox = document.getElementById('selectAll');
            const recordCheckboxes = document.querySelectorAll('.record-checkbox');
            
            recordCheckboxes.forEach(checkbox => {
                checkbox.checked = selectAllCheckbox.checked;
            });
        }
        
        function bulkDeleteRecords() {
            const checkedBoxes = document.querySelectorAll('.record-checkbox:checked');
            
            if (checkedBoxes.length === 0) {
                alert('削除する記録を選択してください。');
                return;
            }
            
            if (!confirm(`選択した${checkedBoxes.length}件の勤怠記録を削除しますか？`)) {
                return;
            }
            
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = 'attendance';
            
            const actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'bulk_delete';
            form.appendChild(actionInput);
            
            checkedBoxes.forEach((checkbox, index) => {
                const parts = checkbox.value.split('|');
                const userId = parts[0];
                const checkInTime = parts[1];
                const checkOutTime = parts[2];
                
                const userIdInput = document.createElement('input');
                userIdInput.type = 'hidden';
                userIdInput.name = `records[${index}].userId`;
                userIdInput.value = userId;
                form.appendChild(userIdInput);
                
                const checkInInput = document.createElement('input');
                checkInInput.type = 'hidden';
                checkInInput.name = `records[${index}].checkInTime`;
                checkInInput.value = checkInTime;
                form.appendChild(checkInInput);
                
                if (checkOutTime !== 'null') {
                    const checkOutInput = document.createElement('input');
                    checkOutInput.type = 'hidden';
                    checkOutInput.name = `records[${index}].checkOutTime`;
                    checkOutInput.value = checkOutTime;
                    form.appendChild(checkOutInput);
                }
            });
            
            document.body.appendChild(form);
            form.submit();
        }
    </script>
</body>
</html>
