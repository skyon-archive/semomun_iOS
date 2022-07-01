//
//  Int64.swift
//  semomun
//
//  Created by Kang Minsang on 2021/10/31.
//

import Foundation

extension Int64 {
    var toTimeString: String {
        if self > 3599 {
            return String(format: "%d:%02d:%02d", (self/3600), ((self%3600)/60), ((self%3600)%60))
        } else if self > 0 {
            return String(format: "%d:%02d", ((self%3600)/60), ((self%3600)%60))
        } else {
            return "0:00"
        }
    }
}
