//
//  Alamofire+Extensions.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/06.
//

import Foundation
import Alamofire

extension HTTPHeader {
    public static func refresh(token: String) -> HTTPHeader {
        HTTPHeader(name: "refresh", value: token)
    }
}

extension HTTPMethod: CustomStringConvertible {
    public var description: String {
        return self.rawValue
    }
}
