package com.example.attendance.controller;

import com.example.attendance.dao.AttendanceDAO;
import com.example.attendance.dao.UserDAO;
import com.example.attendance.dto.User;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Collection;

/**
 * ユーザー管理画面のコントローラー
 */
public class UserServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        HttpSession session = req.getSession(false);
        User currentUser = null;
        
        if (session != null) {
            currentUser = (User) session.getAttribute("user");
        }

        if (currentUser == null || !"admin".equals(currentUser.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        // Retrieve and clear message from session
        String message = (String) session.getAttribute("successMessage");
        if (message != null) {
            req.setAttribute("successMessage", message);
            session.removeAttribute("successMessage");
        }

        if ("list".equals(action) || action == null) {
            Collection<User> users = userDAO.getAllUsers();
            req.setAttribute("users", users);
            RequestDispatcher rd = req.getRequestDispatcher("/jsp/user_management.jsp");
            rd.forward(req, resp);
        } else if ("edit".equals(action)) {
            String username = req.getParameter("username");
            User user = userDAO.findByUsername(username);
            req.setAttribute("userToEdit", user);
            Collection<User> users = userDAO.getAllUsers();
            req.setAttribute("users", users);
            RequestDispatcher rd = req.getRequestDispatcher("/jsp/user_management.jsp");
            rd.forward(req, resp);
        } else {
            resp.sendRedirect("user?action=list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        HttpSession session = req.getSession(false);
        User currentUser = null;
        
        if (session != null) {
            currentUser = (User) session.getAttribute("user");
        }

        if (currentUser == null || !"admin".equals(currentUser.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        if ("add".equals(action)) {
            String username = req.getParameter("username");
            String password = req.getParameter("password");
            String role = req.getParameter("role");
            
            if (userDAO.findByUsername(username) == null) {
                userDAO.addUser(new User(username, UserDAO.hashPassword(password), role));
                session.setAttribute("successMessage", "ユーザーを追加しました。");
            } else {
                session.setAttribute("errorMessage", "ユーザーIDは既に存在します。");
            }
        } else if ("update".equals(action)) {
            String originalUsername = req.getParameter("originalUsername");
            String username = req.getParameter("username");
            String role = req.getParameter("role");
            boolean enabled = req.getParameter("enabled") != null;

            User existingUser = userDAO.findByUsername(originalUsername);
            if (existingUser != null) {
                // ユーザーIDが変更された場合
                if (!originalUsername.equals(username)) {
                    // 新しいユーザーIDが既に存在するかチェック
                    if (userDAO.findByUsername(username) != null) {
                        session.setAttribute("errorMessage", "ユーザーID「" + username + "」は既に存在します。");
                    } else {
                        // 古いユーザーを削除して新しいユーザーを追加
                        userDAO.deleteUser(originalUsername);
                        userDAO.addUser(new User(username, existingUser.getPassword(), role, enabled));
                        
                        // 勤怠記録のユーザーIDも更新
                        AttendanceDAO attendanceDAO = new AttendanceDAO();
                        attendanceDAO.updateUserId(originalUsername, username);
                        
                        session.setAttribute("successMessage", "ユーザー情報を更新しました。（ユーザーID: " + originalUsername + " → " + username + "）");
                    }
                } else {
                    // ユーザーIDが変更されていない場合は通常の更新
                    userDAO.updateUser(new User(username, existingUser.getPassword(), role, enabled));
                    session.setAttribute("successMessage", "ユーザー情報を更新しました。");
                }
            } else {
                session.setAttribute("errorMessage", "ユーザーが見つかりません。");
            }
        } else if ("delete".equals(action)) {
            String username = req.getParameter("username");
            userDAO.deleteUser(username);
            session.setAttribute("successMessage", "ユーザーを削除しました。");
        } else if ("reset_password".equals(action)) {
            String username = req.getParameter("username");
            String newPassword = req.getParameter("newPassword");
            userDAO.resetPassword(username, newPassword);
            session.setAttribute("successMessage", username + "のパスワードをリセットしました。(デフォルトパスワード: " + newPassword + ")");
        } else if ("toggle_enabled".equals(action)) {
            String username = req.getParameter("username");
            boolean enabled = Boolean.parseBoolean(req.getParameter("enabled"));
            userDAO.toggleUserEnabled(username, enabled);
            session.setAttribute("successMessage", username + " のアカウントを" + (enabled ? "有効" : "無効") + "にしました。");
        }
        
        resp.sendRedirect(req.getContextPath() + "/user?action=list");
    }
}

