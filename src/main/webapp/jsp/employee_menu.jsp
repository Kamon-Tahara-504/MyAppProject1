<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>従業員メニュー - 勤怠管理システム</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/employee-style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body class="employee-layout">
    <div class="employee-container">
        <!-- ヘッダーセクション -->
        <header class="employee-header">
            <div class="employee-header-content">
                <div class="employee-header-left">
                    <h1><i class="fas fa-clock"></i> 勤怠管理システム</h1>
                    <div class="employee-user-info">
                        <div class="employee-user-avatar">
                            <i class="fas fa-user-circle"></i>
                        </div>
                        <div class="employee-user-details">
                        <div class="user-details">
                            <h3 class="employee-username">${user.username}</h3>
                            <span class="employee-user-role">従業員</span>
                        </div>
                    </div>
                </div>
                <div class="employee-header-right">
                    <div class="employee-current-time">
                        <i class="fas fa-clock"></i>
                        <span id="current-time">読み込み中...</span>
                    </div>
                    <div class="header-actions">
                        <button class="employee-theme-toggle" onclick="toggleTheme()" title="テーマ切り替え">
                            <i class="fas fa-moon" id="theme-icon"></i>
                        </button>
                        <a href="logout" class="employee-logout-btn">
                            <i class="fas fa-sign-out-alt"></i>
                            ログアウト
                        </a>
                    </div>
                </div>
            </div>
        </header>

        <!-- メッセージ表示エリア -->
        <div class="employee-message-area">
            <c:if test="${not empty successMessage}">
                <div class="success-message" id="successMessage">
                    <i class="fas fa-check-circle"></i>
                    <span>${successMessage}</span>
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="error-message" id="errorMessage">
                    <i class="fas fa-exclamation-triangle"></i>
                    <span>${errorMessage}</span>
                </div>
            </c:if>
        </div>

        <!-- メインコンテンツエリア -->
        <div class="employee-main-content">
            <!-- 左メインエリア -->
            <div class="employee-main-left">
                <!-- 勤怠打刻セクション -->
                <section class="employee-clock-section">
                    <div class="employee-section-header">
                        <h2><i class="fas fa-fingerprint"></i> 勤怠打刻</h2>
                        <p class="employee-section-description">出勤・退勤の記録を行います</p>
                    </div>
                    
                    <div class="employee-clock-buttons">
                        <div class="employee-clock-button-container">
                            <button type="button" class="employee-clock-button check-in" onclick="submitAttendance('check_in')">
                                <i class="fas fa-sign-in-alt employee-button-icon"></i>
                                <div class="employee-button-text">出勤</div>
                            </button>
                        </div>
                        
                        <div class="employee-clock-button-container">
                            <button type="button" class="employee-clock-button check-out" onclick="submitAttendance('check_out')">
                                <i class="fas fa-sign-out-alt employee-button-icon"></i>
                                <div class="employee-button-text">退勤</div>
                            </button>
                        </div>
                    </div>
                    
                    <div class="employee-clock-info">
                        <div class="employee-info-card">
                            <i class="fas fa-info-circle"></i>
                            <div class="employee-info-content">
                                <h4>勤怠打刻について</h4>
                                <p>出勤時は「出勤」ボタン、退勤時は「退勤」ボタンを押してください。システムが自動的に時刻を記録します。</p>
                            </div>
                        </div>
                    </div>
                </section>

                <!-- 勤怠履歴セクション -->
                <section class="employee-history-section">
                    <div class="employee-section-header">
                        <h2><i class="fas fa-history"></i> 勤怠履歴</h2>
                        <p class="employee-section-description">過去の勤怠記録を確認できます</p>
                    </div>
                    
                    <div class="employee-table-container">
                        <div class="employee-table-header">
                            <div class="employee-table-title">
                                <i class="fas fa-table"></i>
                                勤怠記録一覧
                            </div>
                            <button class="employee-refresh-btn" onclick="location.reload()" title="更新">
                                <i class="fas fa-sync-alt"></i>
                            </button>
                        </div>
                        
                        <c:choose>
                            <c:when test="${not empty attendanceRecords and attendanceRecords.size() > 0}">
                                <table class="employee-attendance-table">
                                    <thead>
                                        <tr>
                                            <th><i class="fas fa-calendar"></i> 日付</th>
                                            <th><i class="fas fa-sign-in-alt"></i> 出勤時刻</th>
                                            <th><i class="fas fa-sign-out-alt"></i> 退勤時刻</th>
                                            <th><i class="fas fa-clock"></i> 勤務時間</th>
                                            <th><i class="fas fa-info-circle"></i> ステータス</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="att" items="${attendanceRecords}" varStatus="status">
                                            <tr class="attendance-row ${status.first ? 'employee-recent-record' : ''}">
                                                <td class="date-cell">
                                                    <div class="date-info">
                                                        <c:set var="checkInTime" value="${att.checkInTime.toLocalDateTime()}"/>
                                                        <c:set var="checkInDate" value="${checkInTime.toLocalDate()}"/>
                                                        <div class="date-main">
                                                            <c:out value="${checkInDate.year}年${checkInDate.monthValue}月${checkInDate.dayOfMonth}日"/>
                                                        </div>
                                                        <div class="day-of-week">
                                                            <c:out value="${checkInDate.dayOfWeek}"/>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td class="time-cell">
                                                    <c:choose>
                                                        <c:when test="${att.checkInTime != null}">
                                                            <div class="time-display">
                                                                <i class="fas fa-clock"></i>
                                                                <c:set var="checkInTime" value="${att.checkInTime.toLocalDateTime()}"/>
                                                                <c:set var="checkInLocalTime" value="${checkInTime.toLocalTime()}"/>
                                                                <span class="time-value">
                                                                    <c:out value="${checkInLocalTime.hour}:${checkInLocalTime.minute < 10 ? '0' : ''}${checkInLocalTime.minute}"/>
                                                                </span>
                                                            </div>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="no-record">未記録</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="time-cell">
                                                    <c:choose>
                                                        <c:when test="${att.checkOutTime != null}">
                                                            <div class="time-display">
                                                                <i class="fas fa-clock"></i>
                                                                <c:set var="checkOutTime" value="${att.checkOutTime.toLocalDateTime()}"/>
                                                                <c:set var="checkOutLocalTime" value="${checkOutTime.toLocalTime()}"/>
                                                                <span class="time-value">
                                                                    <c:out value="${checkOutLocalTime.hour}:${checkOutLocalTime.minute < 10 ? '0' : ''}${checkOutLocalTime.minute}"/>
                                                                </span>
                                                            </div>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="working-status">勤務中</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="workhours-cell">
                                                    <c:choose>
                                                        <c:when test="${att.checkInTime != null and att.checkOutTime != null}">
                                                            <div class="work-hours">
                                                                <i class="fas fa-clock"></i>
                                                                <c:set var="checkInTime" value="${att.checkInTime.toLocalDateTime().toLocalTime()}"/>
                                                                <c:set var="checkOutTime" value="${att.checkOutTime.toLocalDateTime().toLocalTime()}"/>
                                                                <c:set var="duration" value="${checkOutTime.toSecondOfDay() - checkInTime.toSecondOfDay()}"/>
                                                                <c:choose>
                                                                    <c:when test="${duration >= 0}">
                                                                        <c:set var="hours" value="${duration / 3600}"/>
                                                                        <c:set var="minutes" value="${(duration % 3600) / 60}"/>
                                                                        <span class="hours"><c:out value="${hours.intValue()}"/>時間</span>
                                                                        <span class="minutes"><c:out value="${minutes.intValue()}"/>分</span>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="error-status">計算エラー</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="no-record">
                                                                <i class="fas fa-hourglass"></i>
                                                                <span>計算中</span>
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="status-cell">
                                                    <c:choose>
                                                        <c:when test="${att.checkInTime != null and att.checkOutTime != null}">
                                                            <span class="status-badge completed">
                                                                <i class="fas fa-check-circle"></i>
                                                                完了
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${att.checkInTime != null and att.checkOutTime == null}">
                                                            <span class="status-badge working">
                                                                <i class="fas fa-spinner"></i>
                                                                勤務中
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="status-badge incomplete">
                                                                <i class="fas fa-exclamation-circle"></i>
                                                                未完了
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </c:when>
                            <c:otherwise>
                                <div class="empty-state">
                                    <div class="empty-icon">
                                        <i class="fas fa-inbox"></i>
                                    </div>
                                    <div class="empty-text">勤怠記録がありません</div>
                                    <div class="empty-subtext">まだ勤怠記録が登録されていません</div>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </section>
            </div>

            <!-- 右サイドバー -->
            <div class="employee-main-right">
                <!-- 今日の勤怠状況セクション -->
                <section class="employee-today-status-section">
                    <div class="employee-section-header">
                        <h2><i class="fas fa-chart-line"></i> 今日の勤怠状況</h2>
                        <p class="employee-section-description">本日の勤怠記録と勤務時間を確認できます</p>
                    </div>
                    
                    <div class="employee-status-cards">
                        <div class="employee-status-card employee-checkin-card">
                            <div class="employee-card-header">
                                <i class="fas fa-sign-in-alt"></i>
                                出勤時刻
                            </div>
                            <div class="employee-card-value">
                                <c:choose>
                                    <c:when test="${not empty todayAttendance and todayAttendance.checkInTime != null}">
                                        <div class="employee-time-display">
                                            <c:set var="checkInTime" value="${todayAttendance.checkInTime.toLocalDateTime()}"/>
                                            <c:set var="checkInDate" value="${checkInTime.toLocalDate()}"/>
                                            <c:set var="checkInLocalTime" value="${checkInTime.toLocalTime()}"/>
                                            <div class="employee-time-value">
                                                <c:out value="${checkInLocalTime.hour}:${checkInLocalTime.minute < 10 ? '0' : ''}${checkInLocalTime.minute}"/>
                                            </div>
                                            <div class="employee-date-display">
                                                <c:out value="${checkInDate.year}年${checkInDate.monthValue}月${checkInDate.dayOfMonth}日"/>
                                            </div>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="employee-no-record">
                                            <i class="fas fa-clock"></i>
                                            <span>未打刻</span>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        
                        <div class="employee-status-card employee-checkout-card">
                            <div class="employee-card-header">
                                <i class="fas fa-sign-out-alt"></i>
                                退勤時刻
                            </div>
                            <div class="employee-card-value">
                                <c:choose>
                                    <c:when test="${not empty todayAttendance and todayAttendance.checkOutTime != null}">
                                        <div class="employee-time-display">
                                            <c:set var="checkOutTime" value="${todayAttendance.checkOutTime.toLocalDateTime()}"/>
                                            <c:set var="checkOutDate" value="${checkOutTime.toLocalDate()}"/>
                                            <c:set var="checkOutLocalTime" value="${checkOutTime.toLocalTime()}"/>
                                            <div class="employee-time-value">
                                                <c:out value="${checkOutLocalTime.hour}:${checkOutLocalTime.minute < 10 ? '0' : ''}${checkOutLocalTime.minute}"/>
                                            </div>
                                            <div class="employee-date-display">
                                                <c:out value="${checkOutDate.year}年${checkOutDate.monthValue}月${checkOutDate.dayOfMonth}日"/>
                                            </div>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="employee-working-status">
                                            <i class="fas fa-spinner"></i>
                                            <span>勤務中</span>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        
                        <div class="employee-status-card employee-workhours-card">
                            <div class="employee-card-header">
                                <i class="fas fa-hourglass-half"></i>
                                勤務時間
                            </div>
                            <div class="employee-card-value">
                                <c:choose>
                                    <c:when test="${not empty todayAttendance and todayAttendance.checkInTime != null and todayAttendance.checkOutTime != null}">
                                        <div class="work-hours">
                                            <i class="fas fa-clock"></i>
                                            <c:set var="checkInTime" value="${todayAttendance.checkInTime.toLocalDateTime().toLocalTime()}"/>
                                            <c:set var="checkOutTime" value="${todayAttendance.checkOutTime.toLocalDateTime().toLocalTime()}"/>
                                            <c:set var="duration" value="${checkOutTime.toSecondOfDay() - checkInTime.toSecondOfDay()}"/>
                                            <c:choose>
                                                <c:when test="${duration >= 0}">
                                                    <c:set var="hours" value="${duration / 3600}"/>
                                                    <c:set var="minutes" value="${(duration % 3600) / 60}"/>
                                                    <span class="hours"><c:out value="${hours.intValue()}"/>時間</span>
                                                    <span class="minutes"><c:out value="${minutes.intValue()}"/>分</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="error-status">計算エラー</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="employee-no-record">
                                            <i class="fas fa-hourglass"></i>
                                            <span>計算中</span>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </section>

                <!-- クイックアクションセクション -->
                <section class="employee-quick-actions-section">
                    <div class="employee-section-header">
                        <h2><i class="fas fa-bolt"></i> クイックアクション</h2>
                        <p class="employee-section-description">よく使用する機能に素早くアクセス</p>
                    </div>
                    
                    <div class="employee-quick-actions">
                        <a href="#" class="employee-quick-action-btn" onclick="location.reload()">
                            <i class="fas fa-sync-alt"></i>
                            <span>更新</span>
                        </a>
                        <a href="#" class="employee-quick-action-btn" onclick="window.print()">
                            <i class="fas fa-print"></i>
                            <span>印刷</span>
                        </a>
                        <a href="#" class="employee-quick-action-btn" onclick="exportData()">
                            <i class="fas fa-download"></i>
                            <span>エクスポート</span>
                        </a>
                    </div>
                </section>
            </div>
        </div>

        <!-- ページフッター -->
        <footer class="employee-footer">
            <div class="employee-footer-content">
                <div class="employee-footer-info">
                    <p>&copy; 2025 勤怠管理システム. All rights reserved.</p>
                </div>
                <div class="employee-footer-links">
                    <a href="#" class="employee-footer-link">ヘルプ</a>
                    <a href="#" class="employee-footer-link">お問い合わせ</a>
                    <a href="#" class="employee-footer-link">プライバシーポリシー</a>
                </div>
            </div>
        </footer>
    </div>

    <!-- JavaScript -->
    <script>
        // ログインメッセージを8秒で自動消去
        document.addEventListener('DOMContentLoaded', function() {
            const successMessage = document.getElementById('successMessage');
            const errorMessage = document.getElementById('errorMessage');
            
            if (successMessage) {
                setTimeout(function() {
                    successMessage.style.transition = 'opacity 0.5s ease-out';
                    successMessage.style.opacity = '0';
                    setTimeout(function() {
                        successMessage.remove();
                    }, 500);
                }, 8000);
            }
            
            if (errorMessage) {
                setTimeout(function() {
                    errorMessage.style.transition = 'opacity 0.5s ease-out';
                    errorMessage.style.opacity = '0';
                    setTimeout(function() {
                        errorMessage.remove();
                    }, 500);
                }, 8000);
            }
        });

        // 勤怠打刻のAjax送信
        function submitAttendance(action) {
            const button = event.target;
            const originalText = button.innerHTML;
            
            // ボタンを無効化してローディング表示
            button.disabled = true;
            button.innerHTML = '<i class="fas fa-spinner fa-spin"></i> 処理中...';
            
            // フォームデータを作成
            const formData = new FormData();
            formData.append('action', action);
            
            // Ajax送信
            fetch('${pageContext.request.contextPath}/attendance', {
                method: 'POST',
                body: formData
            })
            .then(response => response.text())
            .then(data => {
                // 成功メッセージを表示
                showMessage('勤怠打刻が完了しました', 'success');
                
                // ボタンを元に戻す
                button.disabled = false;
                button.innerHTML = originalText;
                
                // 3秒後にページをリロード（勤怠履歴を更新）
                setTimeout(() => {
                    location.reload();
                }, 3000);
            })
            .catch(error => {
                // エラーメッセージを表示
                showMessage('エラーが発生しました: ' + error.message, 'error');
                
                // ボタンを元に戻す
                button.disabled = false;
                button.innerHTML = originalText;
            });
        }

        // メッセージ表示関数
        function showMessage(message, type) {
            const messageArea = document.querySelector('.employee-message-area');
            const messageDiv = document.createElement('div');
            messageDiv.className = type === 'success' ? 'success-message' : 'error-message';
            messageDiv.id = 'tempMessage';
            
            const iconClass = type === 'success' ? 'check-circle' : 'exclamation-triangle';
            messageDiv.innerHTML = '<i class="fas fa-' + iconClass + '"></i><span>' + message + '</span>';
            
            messageArea.appendChild(messageDiv);
            
            // 8秒後に自動消去
            setTimeout(() => {
                messageDiv.style.transition = 'opacity 0.5s ease-out';
                messageDiv.style.opacity = '0';
                setTimeout(() => {
                    messageDiv.remove();
                }, 500);
            }, 8000);
        }

        // 現在時刻の表示
        function updateCurrentTime() {
            const now = new Date();
            const options = {
                year: 'numeric',
                month: '2-digit',
                day: '2-digit',
                weekday: 'long',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit'
            };
            const timeString = now.toLocaleDateString('ja-JP', options);
            document.getElementById('current-time').textContent = timeString;
        }

        // 1秒ごとに時刻を更新
        setInterval(updateCurrentTime, 1000);
        updateCurrentTime();

        // テーマ切り替え
        function toggleTheme() {
            const body = document.body;
            const themeIcon = document.getElementById('theme-icon');
            
            if (body.classList.contains('dark-theme')) {
                body.classList.remove('dark-theme');
                themeIcon.className = 'fas fa-moon';
            } else {
                body.classList.add('dark-theme');
                themeIcon.className = 'fas fa-sun';
            }
        }

        // データエクスポート機能
        function exportData() {
            alert('エクスポート機能は準備中です。');
        }
    </script>
</body>
</html>