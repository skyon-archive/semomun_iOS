//
//  Int64.swift
//  Semomoon
//
//  Created by Kang Minsang on 2021/10/31.
//

import Foundation

extension Int64 {
    func toTimeString() -> String {
        let formatter = DateComponentsFormatter()
        return formatter.string(from: Double(self)) ?? "0:00:00"
    }
}
