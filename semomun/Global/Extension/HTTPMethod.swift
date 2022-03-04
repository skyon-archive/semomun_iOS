//
//  HTTPMethod.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/05.
//

import Foundation
import Alamofire

extension HTTPMethod: CustomStringConvertible {
    public var description: String {
        return self.rawValue
    }
}
