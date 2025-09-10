package com.example.attendance.dao;

import com.example.attendance.dto.Attendance;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.stream.Collectors;

/**
 * 勤怠情報のデータアクセスオブジェクト (DAO)
 */
public class AttendanceDAO {
    private static final List<Attendance> attendanceRecords = new CopyOnWriteArrayList<>();

    public void checkIn(String userId) {
        System.out.println("DEBUG: checkIn called with userId: " + userId);
        if (userId == null || userId.isEmpty()) {
            System.out.println("DEBUG: userId is null or empty");
            throw new IllegalArgumentException("ユーザーIDが無効です");
        }
        System.out.println("DEBUG: Creating new Attendance object");
        Attendance attendance = new Attendance(userId);
        System.out.println("DEBUG: Setting check-in time");
        attendance.setCheckInTime(LocalDateTime.now());
        System.out.println("DEBUG: Adding to attendanceRecords, current size: " + attendanceRecords.size());
        attendanceRecords.add(attendance);
        System.out.println("DEBUG: Attendance added, new size: " + attendanceRecords.size());
    }

    public void checkOut(String userId) {
        if (userId == null || userId.isEmpty()) {
            throw new IllegalArgumentException("ユーザーIDが無効です");
        }
        attendanceRecords.stream()
                .filter(att -> userId.equals(att.getUserId()) && att.getCheckOutTime() == null)
                .findFirst()
                .ifPresent(att -> att.setCheckOutTime(LocalDateTime.now()));
    }

    public List<Attendance> findByUserId(String userId) {
        System.out.println("DEBUG: findByUserId called with userId: " + userId);
        System.out.println("DEBUG: Total attendance records: " + attendanceRecords.size());
        
        if (userId == null || userId.isEmpty()) {
            System.out.println("DEBUG: userId is null or empty, returning empty list");
            return new ArrayList<>();
        }
        
        // デバッグ: 全レコードを確認
        for (int i = 0; i < attendanceRecords.size(); i++) {
            Attendance att = attendanceRecords.get(i);
            System.out.println("DEBUG: Record " + i + ": userId=" + att.getUserId() + 
                ", checkIn=" + att.getCheckInTime() + ", checkOut=" + att.getCheckOutTime());
        }
        
        List<Attendance> result = attendanceRecords.stream()
                .filter(att -> userId.equals(att.getUserId()))
                .collect(Collectors.toList());
        
        System.out.println("DEBUG: Found " + result.size() + " records for user " + userId);
        return result;
    }

    public List<Attendance> findAll() {
        return new ArrayList<>(attendanceRecords);
    }

    public List<Attendance> findFilteredRecords(String userId, LocalDate startDate, LocalDate endDate) {
        return attendanceRecords.stream()
                .filter(att -> (userId == null || userId.isEmpty() || att.getUserId().equals(userId)))
                .filter(att -> (startDate == null || (att.getCheckInTime() != null
                        && !att.getCheckInTime().toLocalDate().isBefore(startDate))))
                .filter(att -> (endDate == null || (att.getCheckInTime() != null
                        && !att.getCheckInTime().toLocalDate().isAfter(endDate))))
                .collect(Collectors.toList());
    }

    public Map<YearMonth, Long> getMonthlyWorkingHours(String userId) {
        return attendanceRecords.stream()
                .filter(att -> userId == null || userId.isEmpty() || att.getUserId().equals(userId))
                .filter(att -> att.getCheckInTime() != null && att.getCheckOutTime() != null)
                .collect(Collectors.groupingBy(
                        att -> YearMonth.from(att.getCheckInTime()),
                        Collectors.summingLong(att -> ChronoUnit.HOURS.between(att.getCheckInTime(), att.getCheckOutTime()))
                ));
    }

    public Map<YearMonth, Long> getMonthlyCheckInCounts(String userId) {
        return attendanceRecords.stream()
                .filter(att -> userId == null || userId.isEmpty() || att.getUserId().equals(userId))
                .filter(att -> att.getCheckInTime() != null)
                .collect(Collectors.groupingBy(
                        att -> YearMonth.from(att.getCheckInTime()),
                        Collectors.counting()
                ));
    }

    public void addManualAttendance(String userId, LocalDateTime checkIn, LocalDateTime checkOut) {
        Attendance newRecord = new Attendance(userId);
        newRecord.setCheckInTime(checkIn);
        newRecord.setCheckOutTime(checkOut);
        attendanceRecords.add(newRecord);
    }

    public boolean updateManualAttendance(String userId, LocalDateTime oldCheckIn, LocalDateTime oldCheckOut,
                                          LocalDateTime newCheckIn, LocalDateTime newCheckOut) {
        for (int i = 0; i < attendanceRecords.size(); i++) {
            Attendance att = attendanceRecords.get(i);
            if (att.getUserId().equals(userId) &&
                    att.getCheckInTime().equals(oldCheckIn) &&
                    (att.getCheckOutTime() == null ? oldCheckOut == null : att.getCheckOutTime().equals(oldCheckOut))) {
                att.setCheckInTime(newCheckIn);
                att.setCheckOutTime(newCheckOut);
                return true;
            }
        }
        return false;
    }

    public boolean deleteManualAttendance(String userId, LocalDateTime checkIn, LocalDateTime checkOut) {
        return attendanceRecords.removeIf(att ->
                att.getUserId().equals(userId) &&
                att.getCheckInTime().equals(checkIn) &&
                (att.getCheckOutTime() == null ? checkOut == null : att.getCheckOutTime().equals(checkOut))
        );
    }
}


// 8/9/2025