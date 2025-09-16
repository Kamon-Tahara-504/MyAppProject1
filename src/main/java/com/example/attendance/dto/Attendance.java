package com.example.attendance.dto;

import java.time.LocalDateTime;
import java.time.Duration;

/**
 * 勤怠情報を保持するDTOクラス
 */
public class Attendance { 
    private String userId; 
    private LocalDateTime checkInTime; 
    private LocalDateTime checkOutTime; 
 
    public Attendance(String userId) { 
        this.userId = userId; 
    } 
 
    public String getUserId() { 
        return userId; 
    }

    public void setUserId(String userId) {
        this.userId = userId;
    } 
 
    public LocalDateTime getCheckInTime() { 
        return checkInTime; 
    } 
 
    public void setCheckInTime(LocalDateTime checkInTime) { 
        this.checkInTime = checkInTime; 
    } 
 
    public LocalDateTime getCheckOutTime() { 
        return checkOutTime; 
    } 
 
    public void setCheckOutTime(LocalDateTime checkOutTime) {
        this.checkOutTime = checkOutTime;
    }
    
    public String getWorkingHours() {
        if (checkInTime == null || checkOutTime == null) {
            return "-";
        }
        
        Duration duration = Duration.between(checkInTime, checkOutTime);
        long hours = duration.toHours();
        long minutes = duration.toMinutesPart();
        
        return hours + "時間" + minutes + "分";
    }
}

// 8/9/2025

