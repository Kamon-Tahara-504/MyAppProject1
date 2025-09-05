<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>勤怠管理システム - ログイン</title>
<<<<<<< HEAD
    <link rel="stylesheet" href="${pageContext.request.contextPath}/style.css">
=======
    <link rel="stylesheet" href="style.css">
>>>>>>> dfb2b5f9b5c3c0cf3d5f1b510fb8dd5669aaedcd
</head>
<body>
    <div class="login-container">
        <header class="login-header">
            <h1>勤怠管理システム</h1>
        </header>
        
        <main class="login-main">
            <!-- メッセージ表示エリア -->
            <div class="message-area">
                <!-- エラーメッセージ -->
                <c:if test="${not empty errorMessage}">
                    <p class="error-message"><c:out value="${errorMessage}"/></p>
                </c:if>
                
                <!-- 成功メッセージ -->
                <c:if test="${not empty sessionScope.successMessage}">
                    <p class="success-message"><c:out value="${sessionScope.successMessage}"/></p>
                    <c:remove var="successMessage" scope="session"/>
                </c:if>
            </div>
            
            <!-- ログインフォーム -->
            <div class="login-form-container">
                <form action="${pageContext.request.contextPath}/login" method="post" class="login-form">
                    <fieldset>
                        <legend>ログイン情報</legend>
                        
                        <div class="input-group">
                            <label for="username">ユーザーID:</label>
                            <input type="text" 
                                   id="username" 
                                   name="username" 
                                   required 
                                   autocomplete="username"
                                   placeholder="ユーザーIDを入力してください">
                        </div>
                        
                        <div class="input-group">
                            <label for="password">パスワード:</label>
                            <input type="password" 
                                   id="password" 
                                   name="password" 
                                   required 
                                   autocomplete="current-password"
                                   placeholder="パスワードを入力してください">
                        </div>
                        
                        <div class="button-group">
                            <input type="submit" value="ログイン" class="login-button">
                        </div>
                    </fieldset>
                </form>
            </div>
            
            <!-- デモ用ユーザー情報 -->
            <div class="demo-info">
                <h3>デモ用アカウント</h3>
                <ul>
                    <li><strong>管理者:</strong> admin1 / adminpass</li>
                    <li><strong>従業員:</strong> employee1 / password</li>
                    <li><strong>従業員:</strong> employee2 / password</li>
                </ul>
            </div>
        </main>
        
        <footer class="login-footer">
            <p>&copy; 2025 勤怠管理システム</p>
        </footer>
    </div>
</body>
</html>