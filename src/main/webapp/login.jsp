<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>勤怠管理システム - ログイン</title>
    <style>
        /* === ログイン画面専用スタイル === */
        
        /* リセット（ログイン画面のみ） */
        .login-container * {
            box-sizing: border-box;
        }
        
        /* ログイン画面専用スタイル */
        .login-container {
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            overflow: hidden;
            margin: 0;
            padding: 0;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Helvetica Neue', Arial, sans-serif;
        }
        
        .login-main {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: #ffffff;
            border-radius: 15px;
            padding: 2rem;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
            width: 420px;
            max-width: 90vw;
            max-height: 90vh;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            z-index: 1000;
        }
        
        .login-form-container {
            width: 100%;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }
        
        .login-title {
            color: #2196f3;
            font-size: 1.8rem;
            font-weight: 700;
            text-align: center;
            margin: 0 0 2rem 0;
            padding-bottom: 1rem;
            border-bottom: 2px solid #e3f2fd;
        }
        
        .login-form fieldset {
            border: none;
            margin: 0;
            padding: 0;
        }
        
        .login-form legend {
            font-size: 1.3rem;
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 1.5rem;
        }
        
        .input-group {
            margin-bottom: 1.2rem;
        }
        
        .input-group label {
            display: block;
            font-weight: 500;
            color: #2c3e50;
            margin-bottom: 0.5rem;
        }
        
        .input-group input[type="text"],
        .input-group input[type="password"] {
            width: 100%;
            padding: 0.8rem;
            border: 2px solid #e9ecef;
            border-radius: 4px;
            font-size: 1rem;
            transition: border-color 0.2s ease;
            box-sizing: border-box;
        }
        
        .input-group input[type="text"]:focus,
        .input-group input[type="password"]:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        
        .button-group {
            margin-top: 2rem;
            text-align: center;
            margin-bottom: 0.5rem;
        }
        
        .login-button {
            width: 100%;
            background: #667eea;
            color: #ffffff;
            padding: 1rem;
            border: none;
            border-radius: 4px;
            font-size: 1.1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        
        .login-button:hover {
            background: #5a67d8;
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
        }
        
        .demo-info {
            margin-top: 1.5rem;
            padding: 1rem;
            background-color: #e3f2fd;
            border-radius: 4px;
            border: 1px solid #bbdefb;
            width: 100%;
            box-sizing: border-box;
        }
        
        .demo-info h3 {
            color: #1565c0;
            font-size: 1rem;
            margin: 0 0 0.75rem 0;
        }
        
        .demo-info ul {
            list-style: none;
            margin: 0;
            padding: 0;
            font-size: 0.9rem;
        }
        
        .demo-info li {
            margin-bottom: 0.5rem;
            color: #1976d2;
        }
        
        .demo-info strong {
            color: #2c3e50;
        }
        
        .login-footer {
            margin-top: 1.5rem;
            text-align: center;
            padding-top: 15px;
            border-top: 1px solid #e0e0e0;
        }
        
        .login-footer p {
            color: #7f8c8d;
            font-size: 0.9rem;
            margin: 0;
        }
        
        /* メッセージエリア */
        .message-area {
            margin-bottom: 1rem;
            width: 100%;
        }
        
        .error-message,
        .success-message {
            padding: 0.8rem 1rem;
            border-radius: 4px;
            margin-bottom: 0.5rem;
            font-size: 0.9rem;
            font-weight: 500;
        }
        
        .error-message {
            background-color: #ffebee;
            color: #c62828;
            border: 1px solid #ef9a9a;
        }
        
        .success-message {
            background-color: #e8f5e8;
            color: #2e7d32;
            border: 1px solid #c3e6cb;
        }
        
        /* レスポンシブ対応 */
        @media (max-width: 768px) {
            .login-main {
                width: 380px;
                max-height: 85vh;
                padding: 1.5rem;
            }
            
            .login-title {
                font-size: 1.5rem;
                margin-bottom: 1.5rem;
            }
        }
        
        @media (max-width: 480px) {
            .login-main {
                width: 320px;
                max-height: 90vh;
                padding: 1.25rem;
            }
            
            .login-title {
                font-size: 1.3rem;
                margin-bottom: 1rem;
            }
        }
    </style>
</head>
<body>
    <div class="login-container">
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
                <h1 class="login-title">Clockin</h1>
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
            
            <!-- 著作権表示 -->
            <footer class="login-footer">
                <p>&copy; 2025 勤怠管理システム Clockin</p>
            </footer>
		</main>
    </div>
</body>
</html>