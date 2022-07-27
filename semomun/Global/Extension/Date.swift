//
//  Date.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/02/01.
//

import Foundation

extension Date {
    var yearMonthText: String {
        let calendarDate = Calendar.current.dateComponents([.year, .month], from: self)
        guard let year = calendarDate.year, let month = calendarDate.month else { return "20xx.xx" }
        return String(format: "%d. %02d", year, month)
    }
    var yearMonthDayText: String {
        let calendarDate = Calendar.current.dateComponents([.year, .month, .day], from: self)
        guard let year = calendarDate.year, let month = calendarDate.month, let day = calendarDate.day else { return "20xx.xx.xx" }
        return String(format: "%d.%02d.%02d", year, month, day)
    }
    var koreanYearMonthDayText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter.string(from: self)
    }
    
    func interval(to: Date) -> Int {
        let timeComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: self, to: to)
        return (timeComponents.hour ?? 0)*3600 + (timeComponents.minute ?? 0)*60 + (timeComponents.second ?? 0)
    }
}
