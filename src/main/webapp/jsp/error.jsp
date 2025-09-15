<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>エラー - 勤怠管理システム</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/error.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0;
            padding: 2rem;
        }
        
        .error-container {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 15px;
            padding: 3rem;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            max-width: 500px;
            width: 100%;
            text-align: center;
        }
        
        .error-icon {
            font-size: 4rem;
            color: #e74c3c;
            margin-bottom: 1.5rem;
        }
        
        .error-title {
            color: #2c3e50;
            font-size: 1.8rem;
            font-weight: 600;
            margin-bottom: 1rem;
        }
        
        .error-message {
            color: #7f8c8d;
            font-size: 1rem;
            line-height: 1.6;
            margin-bottom: 1.5rem;
        }
        
        .error-details {
            background: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 8px;
            padding: 1rem;
            margin-bottom: 2rem;
            color: #6c757d;
            font-size: 0.9rem;
            font-family: monospace;
            text-align: left;
        }
        
        .error-actions {
            display: flex;
            gap: 1rem;
            justify-content: center;
            flex-wrap: wrap;
        }
        
        .error-action-btn {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            text-decoration: none;
            padding: 0.8rem 1.5rem;
            border-radius: 8px;
            font-weight: 500;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .error-action-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
            text-decoration: none;
            color: white;
        }
        
        .error-action-btn.secondary {
            background: #6c757d;
        }
        
        .error-action-btn.secondary:hover {
            background: #5a6268;
            box-shadow: 0 4px 15px rgba(108, 117, 125, 0.4);
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-icon">
            <i class="fas fa-exclamation-triangle"></i>
        </div>
        
        <h1 class="error-title">エラーが発生しました</h1>
        
        <p class="error-message">
            申し訳ありませんが、処理中にエラーが発生しました。<br>
            しばらく時間をおいてから再度お試しください。
        </p>
        
        <% if (exception != null && exception.getMessage() != null) { %>
        <div class="error-details">
            <strong>エラー詳細:</strong><br>
            <%= exception.getMessage() %>
        </div>
        <% } %>
        
        <div class="error-actions">
            <a href="../login.jsp" class="error-action-btn">
                <i class="fas fa-home"></i>
                ログインページに戻る
            </a>
            <a href="javascript:history.back()" class="error-action-btn secondary">
                <i class="fas fa-arrow-left"></i>
                前のページに戻る
            </a>
        </div>
    </div>
</body>
</html>