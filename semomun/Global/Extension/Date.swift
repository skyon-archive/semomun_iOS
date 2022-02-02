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
}
