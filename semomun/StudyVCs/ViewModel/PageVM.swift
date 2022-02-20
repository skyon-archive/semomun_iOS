//
//  PageVM.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/02/20.
//

import Foundation

/// - Note: 사용자의 input값과 answer 타입이 같음을 가정.
///
/// pageData.pageCore.time를 어떻게 사용하는지 확인 필요
class PageVM<Answer: Equatable> {
    weak var delegate: PageDelegate?
    
    private(set) var pageData: PageData
    private(set) var problems: [Problem_Core]
    private(set) var timeSpentOnPage: Int64 = 0
    private let timeSpentPerProblems: [Int64]
    
    // 문제가 하나인 VC의 편의성을 위함
    var problem: Problem_Core? {
        return problems.first
    }
    
    init(delegate: PageDelegate, pageData: PageData) {
        self.delegate = delegate
        self.pageData = pageData
        self.problems = pageData.problems
        self.timeSpentPerProblems = self.problems.map(\.time)
        guard problems.isEmpty == false else {
            assertionFailure("문제수가 0인 페이지가 존재합니다.")
            return
        }
    }
    
    func answer(of problem: Problem_Core? = nil) -> Answer? {
        assertionFailure("override가 필요한 함수입니다.")
        return nil
    }
    
    func isCorrect(input: Answer, answer: Answer) -> Bool {
        assertionFailure("override가 필요한 함수입니다.")
        return false
    }
    
    func startTimeRecord() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateTime), name: .seconds, object: nil)
    }
    
    func stopTimeRecord() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func updateTime() {
        self.timeSpentOnPage += 1
        let perTime = Int64(ceil(Double(self.timeSpentOnPage)/Double(problems.count)))
        for (idx, problem) in problems.enumerated() {
            let time = self.timeSpentPerProblems[idx] + perTime
            problem.setValue(time, forKey: "time")
        }
    }
    
    func updateSolved(withAnswer input: Answer, problem: Problem_Core? = nil) {
        guard let problem = problem ?? problems.first else { return }
        problem.setValue(input, forKey: "solved") // 사용자 입력 값 저장
        
        if let answer = self.answer(of: problem) {
            let correct = self.isCorrect(input: input, answer: answer)
            problem.setValue(correct, forKey: "correct")
        }
        self.delegate?.reload()
    }
    
    func updateStar(to status: Bool, problem: Problem_Core? = nil) {
        guard let problem = problem ?? problems.first else { return }
        problem.setValue(status, forKey: "star")
        self.delegate?.reload()
    }
    
    func updatePencilData(to data: Data, problem: Problem_Core? = nil) {
        guard let problem = problem ?? problems.first else { return }
        problem.setValue(data, forKey: "drawing")
    }
}

