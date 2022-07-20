//
//  JSONDecoderWithDate.swift
//  semomun
//
//  Created by Kang Minsang on 2022/02/27.
//

import Foundation

extension JSONDecoder {
    static var dateformatted: JSONDecoder = {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }()
}
