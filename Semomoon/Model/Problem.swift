//
//  Problem.swift
//  Problem
//
//  Created by qwer on 2021/09/05.
//

import Foundation
import UIKit

//Backend 에서 받아올 문제 데이터


// 실제 ipad 에서 지닐 문제 데이터, reference 타입이라 해당 객체를 ViewController 에서 지닌 채로 값을 수정하면 같이 수정되는 식
public class Problem_Real: NSObject {
    enum ProblemType {
        case notProblem
        case oneToFive
        case string
    }
    
    var problem: ProblemOfDB
    var contentUrl: URL
    var contentData: Data
    var explanationUrl: URL? = nil
    var explanationData: Data? = nil
    var totalTime: Int
    
    init(problem: ProblemOfDB) {
        self.problem = problem
        self.contentUrl = URL(string: "http://semomoonDB/tmp/problem/\(problem.content).png")!
        self.contentData = Data()
        if problem.explanation != nil {
            self.explanationUrl = URL(string: "http://semomoonDB/tmp/explanation/\(problem.explanation).png")!
            self.explanationData = Data()
        }
        self.totalTime = self.problem.elapsed_total ?? 0
    }
}
