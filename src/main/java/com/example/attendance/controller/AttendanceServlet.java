package com.example.attendance.controller;

import com.example.attendance.dao.AttendanceDAO;
import com.example.attendance.dto.Attendance;
import com.example.attendance.dto.User;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 勤怠管理機能を担当するコントローラー
 */
public class AttendanceServlet extends HttpServlet { 
    private final AttendanceDAO attendanceDAO = new AttendanceDAO(); 
 
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { 
        String action = req.getParameter("action"); 
        HttpSession session = req.getSession(false); 
        User user = null;
        
        if (session != null) {
            user = (User) session.getAttribute("user"); 
        }

        if (user == null) { 
            resp.sendRedirect(req.getContextPath() + "/login.jsp"); 
            return; 
        } 

        String message = (String) session.getAttribute("successMessage"); 
        if (message != null) { 
            req.setAttribute("successMessage", message); 
            session.removeAttribute("successMessage"); 
        } 

        // actionパラメータが指定されている場合の処理
        if (action != null) {
            if ("export_csv".equals(action) && "admin".equals(user.getRole())) { 
                exportCsv(req, resp); 
                return;
            } else if ("filter".equals(action) && "admin".equals(user.getRole())) { 
                String filterUserId = req.getParameter("filterUserId"); 
                String startDateStr = req.getParameter("startDate"); 
                String endDateStr = req.getParameter("endDate");
                LocalDate startDate = null; 
                LocalDate endDate = null; 

                try { 
                    if (startDateStr != null && !startDateStr.isEmpty()) { 
                        startDate = LocalDate.parse(startDateStr); 
                    } 
                    if (endDateStr != null && !endDateStr.isEmpty()) { 
                        endDate = LocalDate.parse(endDateStr); 
                    } 
                } catch (DateTimeParseException e) { 
                    req.setAttribute("errorMessage", "日付の形式が不正です。"); 
                } 

                List<Attendance> filteredRecords = attendanceDAO.findFilteredRecords(filterUserId, startDate, endDate); 
                req.setAttribute("allAttendanceRecords", filteredRecords); 

                Map<String, Long> totalHoursByUser = filteredRecords.stream()
                        .collect(Collectors.groupingBy(Attendance::getUserId,
                                Collectors.summingLong(att -> {
                                    if (att.getCheckInTime() != null && att.getCheckOutTime() != null) {
                                        return java.time.temporal.ChronoUnit.HOURS.between(att.getCheckInTime(), att.getCheckOutTime());
                                    }
                                    return 0L;
                                }))); 
                req.setAttribute("totalHoursByUser", totalHoursByUser); 

                req.setAttribute("monthlyWorkingHours", attendanceDAO.getMonthlyWorkingHours(filterUserId));
                req.setAttribute("monthlyCheckInCounts", attendanceDAO.getMonthlyCheckInCounts(filterUserId)); 

                                RequestDispatcher rd = req.getRequestDispatcher("/jsp/admin_menu.jsp");
                rd.forward(req, resp);
                return;
            }
        }
        
        // デフォルトの処理（actionパラメータなし、または認識されないaction）
        if ("admin".equals(user.getRole())) { 
            req.setAttribute("allAttendanceRecords", attendanceDAO.findAll()); 
            Map<String, Long> totalHoursByUser = attendanceDAO.findAll().stream()
                    .collect(Collectors.groupingBy(Attendance::getUserId,
                            Collectors.summingLong(att -> {
                                if (att.getCheckInTime() != null && att.getCheckOutTime() != null) {
                                    return java.time.temporal.ChronoUnit.HOURS.between(att.getCheckInTime(), att.getCheckOutTime());
                                }
                                return 0L;
                            }))); 
            req.setAttribute("totalHoursByUser", totalHoursByUser);
            req.setAttribute("monthlyWorkingHours", attendanceDAO.getMonthlyWorkingHours(null));
            req.setAttribute("monthlyCheckInCounts", attendanceDAO.getMonthlyCheckInCounts(null)); 

                        RequestDispatcher rd = req.getRequestDispatcher("/jsp/admin_menu.jsp");
            rd.forward(req, resp); 
        } else { 
            try {
                List<Attendance> userRecords = attendanceDAO.findByUserId(user.getUsername());
                System.out.println("DEBUG: User records found: " + (userRecords != null ? userRecords.size() : "null"));
                req.setAttribute("user", user);
                req.setAttribute("attendanceRecords", userRecords != null ? userRecords : new ArrayList<>()); 
                RequestDispatcher rd = req.getRequestDispatcher("/jsp/employee_menu.jsp"); 
                rd.forward(req, resp); 
            } catch (Exception e) {
                System.out.println("DEBUG: Error in doGet: " + e.getMessage());
                e.printStackTrace();
                req.setAttribute("user", user);
                req.setAttribute("attendanceRecords", new ArrayList<>());
                req.setAttribute("errorMessage", "データの読み込みに失敗しました: " + e.getMessage());
                RequestDispatcher rd = req.getRequestDispatcher("/jsp/employee_menu.jsp"); 
                rd.forward(req, resp); 
            }
        } 
    } 
 
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { 
        HttpSession session = req.getSession(false); 
        User user = null;
        
        if (session != null) {
            user = (User) session.getAttribute("user"); 
        }

        if (user == null) { 
            System.out.println("DEBUG: User session is null, redirecting to login");
            resp.sendRedirect(req.getContextPath() + "/login.jsp"); 
            return; 
        } 

        String action = req.getParameter("action"); 
        System.out.println("DEBUG: POST request received with action: " + action + " for user: " + user.getUsername());

        if ("check_in".equals(action)) { 
            try {
                System.out.println("DEBUG: Attempting check-in for user: " + user.getUsername());
                System.out.println("DEBUG: User object: " + user);
                System.out.println("DEBUG: User ID: " + user.getUsername());
                attendanceDAO.checkIn(user.getUsername()); 
                System.out.println("DEBUG: Check-in successful for user: " + user.getUsername());
                session.setAttribute("successMessage", "＋ 出勤時刻を記録しました！お疲れ様です。"); 
            } catch (Exception e) {
                System.out.println("DEBUG: Check-in failed for user: " + user.getUsername() + ", Error: " + e.getMessage());
                System.out.println("DEBUG: Exception type: " + e.getClass().getName());
                e.printStackTrace();
                session.setAttribute("errorMessage", "出勤の記録に失敗しました: " + e.getMessage());
            }
        } else if ("check_out".equals(action)) { 
            try {
                System.out.println("DEBUG: Attempting check-out for user: " + user.getUsername());
                attendanceDAO.checkOut(user.getUsername()); 
                System.out.println("DEBUG: Check-out successful for user: " + user.getUsername());
                session.setAttribute("successMessage", "🏠 退勤時刻を記録しました！今日もお疲れ様でした。"); 
            } catch (Exception e) {
                System.out.println("DEBUG: Check-out failed for user: " + user.getUsername() + ", Error: " + e.getMessage());
                System.out.println("DEBUG: Exception type: " + e.getClass().getName());
                e.printStackTrace();
                session.setAttribute("errorMessage", "退勤の記録に失敗しました: " + e.getMessage());
            }
        } else if ("add_manual".equals(action) && "admin".equals(user.getRole())) { 
            String userId = req.getParameter("userId"); 
            String checkInStr = req.getParameter("checkInTime"); 
            String checkOutStr = req.getParameter("checkOutTime"); 

            try { 
                LocalDateTime checkIn = LocalDateTime.parse(checkInStr); 
                LocalDateTime checkOut = checkOutStr != null && !checkOutStr.isEmpty() ? LocalDateTime.parse(checkOutStr) : null; 
                attendanceDAO.addManualAttendance(userId, checkIn, checkOut); 
                session.setAttribute("successMessage", "勤怠記録を手動で追加しました。"); 
            } catch (DateTimeParseException e) { 
                session.setAttribute("errorMessage", "日付/時刻の形式が不正です。"); 
            } 
        } else if ("update_manual".equals(action) && "admin".equals(user.getRole())) { 
            String userId = req.getParameter("userId");
            LocalDateTime oldCheckIn = LocalDateTime.parse(req.getParameter("oldCheckInTime"));
            LocalDateTime oldCheckOut = req.getParameter("oldCheckOutTime") != null && !req.getParameter("oldCheckOutTime").isEmpty() ? 
                    LocalDateTime.parse(req.getParameter("oldCheckOutTime")) : null;
            LocalDateTime newCheckIn = LocalDateTime.parse(req.getParameter("newCheckInTime"));
            LocalDateTime newCheckOut = req.getParameter("newCheckOutTime") != null && !req.getParameter("newCheckOutTime").isEmpty() ? 
                    LocalDateTime.parse(req.getParameter("newCheckOutTime")) : null; 

            if (attendanceDAO.updateManualAttendance(userId, oldCheckIn, oldCheckOut, newCheckIn, newCheckOut)) { 
                session.setAttribute("successMessage", "勤怠記録を手動で更新しました。"); 
            } else { 
                session.setAttribute("errorMessage", "勤怠記録の更新に失敗しました。"); 
            } 
        } else if ("delete_manual".equals(action) && "admin".equals(user.getRole())) { 
            String userId = req.getParameter("userId"); 
            String checkInStr = req.getParameter("checkInTime");
            String checkOutStr = req.getParameter("checkOutTime");
            
            try {
                LocalDateTime checkIn = LocalDateTime.parse(checkInStr); 
                LocalDateTime checkOut = (checkOutStr != null && !checkOutStr.isEmpty() && !"null".equals(checkOutStr)) ? 
                        LocalDateTime.parse(checkOutStr) : null; 

                System.out.println("DEBUG: Deleting attendance record - userId: " + userId + ", checkIn: " + checkIn + ", checkOut: " + checkOut);
                
                if (attendanceDAO.deleteManualAttendance(userId, checkIn, checkOut)) { 
                    session.setAttribute("successMessage", "勤怠記録を削除しました。"); 
                    System.out.println("DEBUG: Attendance record deleted successfully");
                } else { 
                    session.setAttribute("errorMessage", "勤怠記録の削除に失敗しました。"); 
                    System.out.println("DEBUG: Failed to delete attendance record");
                } 
            } catch (Exception e) {
                System.out.println("DEBUG: Error deleting attendance record: " + e.getMessage());
                e.printStackTrace();
                session.setAttribute("errorMessage", "勤怠記録の削除中にエラーが発生しました: " + e.getMessage());
            }
        } else if ("bulk_delete".equals(action) && "admin".equals(user.getRole())) {
            int deletedCount = 0;
            int index = 0;
            
            while (req.getParameter("records[" + index + "].userId") != null) {
                String userId = req.getParameter("records[" + index + "].userId");
                String checkInStr = req.getParameter("records[" + index + "].checkInTime");
                String checkOutStr = req.getParameter("records[" + index + "].checkOutTime");
                
                try {
                    LocalDateTime checkIn = LocalDateTime.parse(checkInStr);
                    LocalDateTime checkOut = (checkOutStr != null && !checkOutStr.isEmpty() && !"null".equals(checkOutStr)) 
                        ? LocalDateTime.parse(checkOutStr) : null;
                    
                    if (attendanceDAO.deleteManualAttendance(userId, checkIn, checkOut)) {
                        deletedCount++;
                    }
                } catch (Exception e) {
                    System.out.println("DEBUG: Failed to delete record for user " + userId + ": " + e.getMessage());
                }
                
                index++;
            }
            
            if (deletedCount > 0) {
                session.setAttribute("successMessage", deletedCount + "件の勤怠記録を削除しました。");
            } else {
                session.setAttribute("errorMessage", "勤怠記録の削除に失敗しました。");
            }
        } 

        System.out.println("DEBUG: Redirecting after action: " + action);
        if ("admin".equals(user.getRole())) { 
            resp.sendRedirect(req.getContextPath() + "/attendance?action=filter&filterUserId=" + 
                    (req.getParameter("filterUserId") != null ? req.getParameter("filterUserId") : "") + 
                    "&startDate=" + (req.getParameter("startDate") != null ? req.getParameter("startDate") : "") + 
                    "&endDate=" + (req.getParameter("endDate") != null ? req.getParameter("endDate") : "")); 
        } else { 
            resp.sendRedirect(req.getContextPath() + "/attendance"); 
        } 
    } 
 
    private void exportCsv(HttpServletRequest req, HttpServletResponse resp) throws IOException { 
        resp.setContentType("text/csv; charset=UTF-8"); 
        resp.setHeader("Content-Disposition", "attachment; filename=\"attendance_records.csv\""); 
 
        PrintWriter writer = resp.getWriter(); 
        writer.append("User ID,Check-in Time,Check-out Time\n"); 
 
        String filterUserId = req.getParameter("filterUserId"); 
        String startDateStr = req.getParameter("startDate"); 
        String endDateStr = req.getParameter("endDate");
        LocalDate startDate = null; 
        LocalDate endDate = null; 
 
        try { 
            if (startDateStr != null && !startDateStr.isEmpty()) { 
                startDate = LocalDate.parse(startDateStr); 
            } 
            if (endDateStr != null && !endDateStr.isEmpty()) { 
                endDate = LocalDate.parse(endDateStr); 
            } 
        } catch (DateTimeParseException e) { 
            System.err.println("Invalid date format for CSV export: " + e.getMessage()); 
        } 
 
        List<Attendance> records = attendanceDAO.findFilteredRecords(filterUserId, startDate, endDate); 
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"); 
 
        for (Attendance record : records) { 
            writer.append(String.format("%s,%s,%s\n",
                    record.getUserId(),
                    record.getCheckInTime() != null ? record.getCheckInTime().format(formatter) : "",
                    record.getCheckOutTime() != null ? record.getCheckOutTime().format(formatter) : "")); 
        } 
        writer.flush(); 
    } 
}