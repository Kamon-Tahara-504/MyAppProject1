<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>従業員メニュー - 勤怠管理システム</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css?v=2">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/employee.css?v=2">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css?v=2">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        /* 確実に大きなボタンにするためのインラインCSS */
        .attendance-buttons {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
            margin-top: 2rem;
        }
        
        .attendance-form {
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
        }
        
        .button-extra-large {
            padding: 3rem 2rem !important;
            border: none !important;
            border-radius: 20px !important;
            font-size: 2rem !important;
            font-weight: 700 !important;
            cursor: pointer !important;
            display: flex !important;
            flex-direction: column !important;
            align-items: center !important;
            gap: 1rem !important;
            transition: all 0.3s ease !important;
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15) !important;
            min-height: 200px !important;
            justify-content: center !important;
            text-transform: uppercase !important;
            letter-spacing: 2px !important;
            width: 100% !important;
        }
        
        .button-extra-large i {
            font-size: 3.5rem !important;
            margin-bottom: 1rem !important;
        }
        
        .button-extra-large .button-text {
            font-size: 2rem !important;
            font-weight: 800 !important;
            margin-bottom: 0.5rem !important;
        }
        
        .button-extra-large .button-time {
            font-size: 1.2rem !important;
            opacity: 0.9 !important;
            font-weight: 500 !important;
            margin-top: 0.5rem !important;
        }
        
        .button-extra-large.check-in {
            background: #22c55e !important;
            color: white !important;
            border: 2px solid #16a34a !important;
        }
        
        .button-extra-large.check-in:hover {
            background: #000000 !important;
            border-color: #333333 !important;
            color: white !important;
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.3) !important;
        }
        
        .button-extra-large.check-out {
            background: #ef4444 !important;
            color: white !important;
            border: 2px solid #dc2626 !important;
        }
        
        .button-extra-large.check-out:hover {
            background: #ffffff !important;
            border-color: #cccccc !important;
            color: black !important;
            box-shadow: 0 12px 30px rgba(255, 255, 255, 0.3) !important;
        }
        
        .button-extra-large:active {
            transform: translateY(1px) !important;
        }
        
        @media (max-width: 768px) {
            .attendance-buttons {
                grid-template-columns: 1fr;
                gap: 1.5rem;
            }
            
            .button-extra-large {
                padding: 2rem 1.5rem !important;
                min-height: 160px !important;
                font-size: 1.6rem !important;
            }
            
            .button-extra-large i {
                font-size: 2.8rem !important;
            }
            
            .button-extra-large .button-text {
                font-size: 1.6rem !important;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <header class="page-header">
            <div class="header-content">
                <div class="header-left">
                    <h1><i class="fas fa-clock"></i> 従業員メニュー</h1>
                </div>
                <div class="user-info">
                    <div class="user-avatar">
                        <i class="fas fa-user"></i>
                    </div>
                    <div class="user-details">
                        <h3 class="username"><c:out value="${user.username}"/></h3>
                        <span class="user-role">従業員</span>
                    </div>
                </div>
            </div>
        </header>

        <!-- ナビゲーションメニュー -->
        <nav class="main-nav">
            <a href="attendance?action=filter" class="nav-link active">
                <i class="fas fa-clock"></i> 勤怠打刻
            </a>
            <a href="logout" class="nav-link logout">
                <i class="fas fa-sign-out-alt"></i> ログアウト
            </a>
        </nav>

        <!-- メッセージ表示エリア -->
        <div class="message-area">
            <c:if test="${not empty errorMessage}">
                <div class="error-message">
                    <c:out value="${errorMessage}"/>
                </div>
            </c:if>
        </div>


        <main>
            <!-- 勤怠打刻セクション -->
            <section class="attendance-section">
                <h2>勤怠打刻</h2>
                <div class="attendance-buttons">
                    <form action="attendance" method="post" class="attendance-form">
                        <input type="hidden" name="action" value="check_in">
                        <button type="submit" class="button-extra-large check-in">
                            <i class="fas fa-sign-in-alt"></i>
                            <span class="button-text">出勤</span>
                            <small class="button-time" id="current-time"></small>
                        </button>
                    </form>
                    <form action="attendance" method="post" class="attendance-form">
                        <input type="hidden" name="action" value="check_out">
                        <button type="submit" class="button-extra-large check-out">
                            <i class="fas fa-sign-out-alt"></i>
                            <span class="button-text">退勤</span>
                            <small class="button-time" id="current-time-out"></small>
                        </button>
                    </form>
                </div>
            </section>

            <!-- 勤怠履歴 -->
            <section class="history-section">
                <h2>勤怠履歴</h2>
                <div class="table-container">
                    <table class="records-table">
                        <thead>
                            <tr>
                                <th>日付</th>
                                <th>出勤時刻</th>
                              x  <th>退勤時刻</th>
                                <th>勤務時間</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty attendanceRecords}">
                                    <c:forEach var="att" items="${attendanceRecords}">
                                        <tr>
                                            <td>
                                                <c:if test="${att.checkInTime != null}">
                                                    ${att.checkInTime.toLocalDate().toString()}
                                                </c:if>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${att.checkInTime != null}">
                                                        ${att.checkInTime.toLocalTime().toString().substring(0, 5)}
                                                    </c:when>
                                                    <c:otherwise>未記録</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${att.checkOutTime != null}">
                                                        ${att.checkOutTime.toLocalTime().toString().substring(0, 5)}
                                                    </c:when>
                                                    <c:otherwise><span class="working-status">勤務中</span></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                ${att.workingHours}
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="4" class="no-data">勤怠記録がありません</td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </section>
        </main>
        
        <footer class="page-footer">
        	<p>&copy; 2025 勤怠管理システム Clockin </p>
        </footer>
    </div>

    <script>
        // 現在時刻を更新
        function updateCurrentTime() {
            const now = new Date();
            const timeString = now.toLocaleTimeString('ja-JP', {
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit'
            });
            const dateString = now.toLocaleDateString('ja-JP', {
                month: 'short',
                day: 'numeric'
            });
            
            const timeElements = document.querySelectorAll('.button-time');
            timeElements.forEach(element => {
                element.textContent = `${dateString} ${timeString}`;
            });
        }

        function submitAttendance(action) {
            const button = document.querySelector(`[onclick="submitAttendance('${action}')"]`);
            const originalHTML = button.innerHTML;
            
            // ボタンを無効化して処理中表示
            button.disabled = true;
            button.innerHTML = '<i class="fas fa-spinner fa-spin"></i> <span class="button-text">処理中...</span>';
            
            // フォームを作成してサブミット
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = 'attendance';
            
            const actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = action;
            
            form.appendChild(actionInput);
            document.body.appendChild(form);
            form.submit();
        }

        // ページ読み込み時に時刻更新を開始
        document.addEventListener('DOMContentLoaded', function() {
            updateCurrentTime();
            setInterval(updateCurrentTime, 1000); // 1秒ごとに更新
        });
    </script>
</body>
</html>