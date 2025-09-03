package com.example.attendance.filter;

import com.example.attendance.dto.User;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * 認証フィルター - ログイン状態をチェックし、未ログインユーザーをログイン画面にリダイレクト
 */
public class AuthenticationFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // 初期化処理（必要に応じて）
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        
        // ログイン画面とスタイルシート、ログイン処理はフィルターを通さない
        if (requestURI.endsWith("login.jsp") || 
            requestURI.endsWith("style.css") || 
            requestURI.endsWith("/login") ||
            requestURI.endsWith("/login.jsp") ||
            requestURI.equals(contextPath + "/")) {
            chain.doFilter(request, response);
            return;
        }
        
        HttpSession session = httpRequest.getSession(false);
        User user = null;
        
        if (session != null) {
            user = (User) session.getAttribute("user");
        }
        
        if (user != null && user.isEnabled()) {
            // ログイン済みかつ有効なユーザーの場合は次の処理に進む
            chain.doFilter(request, response);
        } else {
            // ログインしていない場合またはアカウントが無効な場合はログイン画面にリダイレクト
            httpResponse.sendRedirect(contextPath + "/login.jsp");
        }
    }

    @Override
    public void destroy() {
        // 終了処理（必要に応じて）
    }
}