//
//  Problem.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation
import UIKit

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
