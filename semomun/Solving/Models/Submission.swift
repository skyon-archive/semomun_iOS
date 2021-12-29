//
//  Submission.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation

struct Submission: Codable {
    var pid: Int // 문제 pid
    var elapsed: Int // 걸린 시간
    var recent_time: String // 현재 시각
    var user_answer: String? // 제출한 답
    var correct: Int? // 정답 여부
    var note: Data? // 필기데이터
    
    init(problem: Problem_Core) {
        self.pid = Int(problem.pid)
        self.elapsed = Int(problem.time)
        self.recent_time = Self.nowTime(at: Date())
        self.user_answer = problem.solved
        if let _ = problem.answer {
            self.correct = problem.correct == true ? 1 : 0
        } else {
            self.correct = nil
        }
        self.note = problem.drawing
    }
    
    static func nowTime(at: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale.current
        return formatter.string(from: at)
    }
}
