//
//  Problem.swift
//  Problem
//
//  Created by qwer on 2021/09/05.
//

import Foundation
import UIKit

//Backend 에서 받아올 문제 데이터
struct Problem: Codable {
    var pid: Int //문제 고유의 번호
    var vid: Int //문제가 속한 View의 vid
    var sid: Int //문제가 속한 Section의 vid
    var icon_index: Int //문제에 대응되는 하단 아이콘의 순서
    var icon_name: String //문제에 대응되는 하단 아이콘의 이름
    var type: Int //0: 채점 불가, 1: 객관식, 2: 주관식
    var answer: String //문제의 정답
    var content: Int //문제 내용 이미지의 숫자값, content.png 식으로 접근되는 식
    var explanation: Int? //문제의 해설 이미지의 숫자값
    var attempt_total: Int //문제에 답이 제출된 총 횟수
    var attempt_corrent: Int //문제에 정답이 제출된 총 횟수
    var rate: Int //문제의 외부 정답률
    var elapsed_total: Int //걸린 시간의 합
    var note: String //PKDrawing 데이터
}

// 실제 ipad 에서 지닐 문제 데이터, reference 타입이라 해당 객체를 ViewController 에서 지닌 채로 값을 수정하면 같이 수정되는 식
class Problem_Real {
    enum ProblemType {
        case notProblem
        case oneToFive
        case string
    }
    
    var problem: Problem
    var contentUrl: URL
    var contentData: Data
    var explanationUrl: URL? = nil
    var explanationData: Data? = nil
    var totalTime: Int
    
    init(problem: Problem) {
        self.problem = problem
        self.contentUrl = URL(string: "http://semomoonDB/tmp/problem/\(problem.content).png")!
        self.contentData = Data()
        if problem.explanation != nil {
            self.explanationUrl = URL(string: "http://semomoonDB/tmp/explanation/\(problem.explanation).png")!
            self.explanationData = Data()
        }
        self.totalTime = self.problem.elapsed_total
    }
}
