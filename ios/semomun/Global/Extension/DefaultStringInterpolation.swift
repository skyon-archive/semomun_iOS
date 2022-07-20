//
//  DefaultStringInterpolation.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/02/04.
//

import Foundation

extension DefaultStringInterpolation {
  mutating func appendInterpolation<T>(optional: T?) {
    appendInterpolation(String(describing: optional))
  }
}
