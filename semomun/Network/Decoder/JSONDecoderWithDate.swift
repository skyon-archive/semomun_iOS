//
//  JSONDecoderWithDate.swift
//  semomun
//
//  Created by Kang Minsang on 2022/02/27.
//

import Foundation

final class JSONDecoderWithDate: JSONDecoder {
    override init() {
        super.init()
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_kr")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "YYYY-MM-DD'T'HH:mm:ss.SSS'Z'"
        
        self.dateDecodingStrategy = .formatted(formatter)
    }
}
