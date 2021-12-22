//
//  String.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2021/12/22.
//

import Foundation

extension String {
    static var randomUserNumber: String {
        let randomVal = Int.random(in: 0...99999)
        return String(format: "%05d", randomVal)
    }
}
