//
//  JSONParameterEncoder+Extensions.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/04/08.
//

import Foundation
import Alamofire

extension JSONParameterEncoder {
    static var dateformatted: JSONParameterEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        return JSONParameterEncoder(encoder: encoder)
    }()
}
