//
//  ProblemOfDB.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation

struct ProblemOfDB: Decodable, CustomStringConvertible {
    var description: String {
        return "Problem(\(pid)) {btNum: \(btName), answer: \(answer ?? "none")}"
    }
    
    let vid: Int
    let pid: Int //고유 번호
    let index: Int //Page 내의 순서
    let btType: String //문제 유형 (개념, 문제)
    let btName: String //하단 아이콘 표시내용
    let type: Int //선지 유형
    let answer: String? //문제 정답
    let content: UUID //문제 이미지의 uuid
    let explanation: UUID? //문제의 해설 이미지의 uuid
    let point: Double? //문제 배점
    
    enum CodingKeys: String, CodingKey {
        case vid, pid, index, btType, btName, type, answer, content, explanation
        case point = "score"
    }
}
