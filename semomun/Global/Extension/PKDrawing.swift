//
//  PKDrawing.swift
//  semomun
//
//  Created by Kang Minsang on 2021/09/05.
//

import Foundation
import PencilKit

extension PKDrawing {
    func base64EncodedString() -> String {
        return dataRepresentation().base64EncodedString()
    }
    
    enum DecodingError: Error {
        case decodingError
    }
    
    init(base64Encoded base64: String) throws {
        guard let data = Data(base64Encoded: base64) else {
            throw DecodingError.decodingError
        }
        try self.init(data: data)
    }
}
