//
//  SubmissionProblem.swift
//  semomun
//
//  Created by Kang Minsang on 2022/04/06.
//

import Foundation

struct SubmissionProblem: Encodable {
    let pid: Int
    let elapsed: Int
    let answer: String?
    let attempt: Int
    let note: Data?
    
    init(problem: Problem_Core, attempt: Int = 1) {
        self.pid = Int(problem.pid)
        self.elapsed = Int(problem.time)
        self.answer = problem.solved ?? nil
        self.attempt = attempt
        self.note = problem.drawing
    }
}
