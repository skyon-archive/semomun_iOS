//
//  Problem.swift
//  Semomoon
//
//  Created by qwer on 2021/10/03.
//

import Foundation

struct ProblemOfDB: Codable, CustomStringConvertible {
    var description: String {
        return "Problem(\(pid), type: \(type), \(!content.isEmpty), \(answer ?? "none"))"
    }
    
    let pid: Int //문제 고유의 번호
    let icon_index: Int //문제에 대응되는 하단 아이콘의 순서
    let icon_name: String //문제에 대응되는 하단 아이콘의 이름
    let type: Int //0: 채점 불가, 1: 객관식, 2: 주관식
    let answer: String? //문제의 정답
    let content: String //문제 내용 이미지의 숫자값, content.png 식으로 접근되는 식
    let explanation: String? //문제의 해설 이미지의 숫자값
    let attempt_total: Int? //문제에 답이 제출된 총 횟수
    let attempt_corrent: Int? //문제에 정답이 제출된 총 횟수
    let rate: Int? //문제의 외부 정답률
    let elapsed_total: Int? //걸린 시간의 합
}
