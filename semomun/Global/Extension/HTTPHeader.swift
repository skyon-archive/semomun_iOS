//
//  HTTPHeader.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/03.
//

import Foundation
import Alamofire

extension HTTPHeader {
    public static func refresh(_ value: String) -> HTTPHeader {
        HTTPHeader(name: "refresh", value: value)
    }
}
