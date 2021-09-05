//
//  Submission.swift
//  Submission
//
//  Created by qwer on 2021/09/05.
//

import Foundation

struct Submission: Codable {
    var uid: Int
    var pid: Int
    var elapsed: Int
    var recent_time: Int
    var user_answer: String
    var correct: Int
}
