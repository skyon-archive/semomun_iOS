//
//  PageVM.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/02/20.
//

import Foundation

/// - Note: pageData.pageCore.time를 어떻게 사용하는지 확인 필요
class PageVM {
    weak var delegate: PageDelegate?
    
    private(set) var problems: [Problem_Core]
    private(set) var timeSpentOnPage: Int64 = 0
    
    private var isTimeRecording = false
    
    private let pageData: PageData
    private let timeSpentPerProblems: [Int64]
    
    /// - Note: 문제가 하나인 VC를 위한 편의 프로퍼티
    var problem: Problem_Core? {
        assert(problems.count == 1, "문제수가 하나인 페이지에서 사용되는 프로퍼티입니다.")
        return problems.first
    }
    
    var pagePencilData: Data? {
        return pageData.pageCore.drawing
    }
    
    var pagePencilDataWidth: Int {
        return Int(pageData.pageCore.drawingWidth)
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
    
    /// - Returns: 사용자에게 보여주기 위한 answer값
    func answer(of problem: Problem_Core? = nil) -> String? {
        assertionFailure("override가 필요한 함수입니다.")
        return nil
    }
    
    /// - Parameters:
    ///   - input: VC에서 전달받은 사용자가 선택한 정답 값
    ///   - answer: 정답 여부를 판별하고 싶은 Problem_Core의 answer 프로퍼티 값
    func isCorrect(input: String, answer: String) -> Bool {
        assertionFailure("override가 필요한 함수입니다.")
        return false
    }
    
    func startTimeRecord() {
        guard self.isTimeRecording == false else {
            assertionFailure("타이머가 중복 실행되려고합니다.")
            return
        }
        // 모든 문제가 terminated 된 상태일 경우 timer를 반영 안한다
        if self.problems.allSatisfy(\.terminated) { return }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTime), name: .seconds, object: nil)
        self.isTimeRecording = true
    }
    
    func endTimeRecord() {
        NotificationCenter.default.removeObserver(self)
        self.isTimeRecording = false
    }
    
    @objc func updateTime() {
//        print("timer active")
        self.timeSpentOnPage += 1
        if self.problems.count == 1 {
            let time = self.timeSpentPerProblems[0] + self.timeSpentOnPage
            self.problem?.setValue(time, forKey: "time")
        } else {
            let targetProblemsCount = self.problems.filter({ $0.terminated == false }).count
            // MARK: ChangeVC 되기 전에 실행되는 경우 0으로 나뉠 수 있는 경우가 생김에 따라 코드 추가
            guard targetProblemsCount != 0 else { return }
            
            let timeSpentPerProblems = Double(self.timeSpentOnPage) / Double(targetProblemsCount)
            let perTime = Int64(ceil(timeSpentPerProblems))
            
            for (idx, problem) in problems.enumerated() where problem.terminated == false {
                let time = self.timeSpentPerProblems[idx] + perTime
                problem.setValue(time, forKey: "time")
            }
        }
    }
    
    func updateSolved(withSelectedAnswer selectedAnswer: String, problem: Problem_Core? = nil) {
        guard let problem = problem ?? self.problem else { return }
        problem.setValue(selectedAnswer, forKey: "solved") // 사용자 입력 값 저장
        
        if let answer = problem.answer { // 정답이 있는 경우 정답여부 업데이트
            let correct = self.isCorrect(input: selectedAnswer, answer: answer)
            problem.setValue(correct, forKey: "correct")
        }
        self.delegate?.addScoring(pid: Int(problem.pid))
    }
    
    func updateStar(to status: Bool, problem: Problem_Core? = nil) {
        guard let problem = problem ?? self.problem else { return }
        problem.setValue(status, forKey: "star")
        self.delegate?.reload()
    }
    
    func updatePencilData(to data: Data, width: Double, problem: Problem_Core? = nil) {
        guard let problem = problem ?? self.problem else { return }
        problem.setValue(width, forKey: Problem_Core.Attribute.drawingWidth.rawValue)
        problem.setValue(data, forKey: Problem_Core.Attribute.drawing.rawValue)
        self.delegate?.addUploadProblem(pid: Int(problem.pid))
    }
    
    func updatePagePencilData(to data: Data, width: Double) {
        self.pageData.pageCore.setValue(width, forKey: Page_Core.Attribute.drawingWidth.rawValue)
        self.pageData.pageCore.setValue(data, forKey: Page_Core.Attribute.drawing.rawValue)
        self.delegate?.addUploadPage(vid: pageData.vid)
    }
}

