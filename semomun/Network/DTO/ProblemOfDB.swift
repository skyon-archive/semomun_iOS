//
//  ProblemOfDB.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation

struct ProblemOfDB: Codable, CustomStringConvertible {
    var description: String {
        return "Problem(\(pid)) {btNum: \(btNum), answer: \(answer ?? "none")}"
    }
    
    let vid: Int
    let pid: Int //고유 번호
    let index: Int //Page 내의 순서
    let btType: String //문제 유형 (개념, 문제)
    let btNum: String //하단 아이콘 표시내용
    let type: Int //선지 유형
    let answer: String? //문제 정답
    let content: String //문제 내용 이미지의 숫자값, content.png 식으로 접근되는 식
    let explanation: String? //문제의 해설 이미지의 숫자값
    let point: Double?
    
    enum CodingKeys: String, CodingKey {
        case vid, pid, index
        case btType = "labelType"
        case btNum = "labelNum"
        case type, answer, content, explanation, point
    }
}
