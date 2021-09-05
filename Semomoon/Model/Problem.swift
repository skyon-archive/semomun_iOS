//
//  Problem.swift
//  Problem
//
//  Created by qwer on 2021/09/05.
//

import Foundation

struct Problem: Codable {
    var pid: Int
    var vid: Int
    var sid: Int
    var icon_index: Int
    var icon_name: String
    var type: Int
    var answer: String
    var content: Int
    var explanation: Int?
    var attempt_total: Int
    var attempt_corrent: Int
    var rate: Int
    var elapsed_total: Int
    var note: String
}
