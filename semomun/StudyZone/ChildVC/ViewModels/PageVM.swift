//
//  PageVM.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/02/20.
//

import Foundation

/// - Note: pageData.pageCore.time를 어떻게 사용하는지 확인 필요
class PageVM {
    /* public */
    weak var delegate: PageDelegate?
    private(set) var problems: [Problem_Core]
    private(set) var mode: StudyVC.Mode = .default
    /* private */
    private var beforePid: Int64?
    private var startTime: Date? // 페이지 진입시점 시각 및 input 마지막 시각 (term 계산 기준값)
    private var problemsBaseTimes: [Int64] = [] // 페이지 진입시점 문제별 기존 누적시간값 (term값과 합산을 위한 값)
    private var isTimeRecording = false
    private var pageData: PageData
    
    /// - Note: 문제가 하나인 VC를 위한 편의 프로퍼티
    var problem: Problem_Core? {
        assert(problems.count == 1, "문제수가 하나인 페이지에서 사용되는 프로퍼티입니다.")
        return problems.first
    }
    
    var pagePencilData: Data? {
        return pageData.pageCore.drawing
    }
    
    var pagePencilDataWidth: Double {
        return pageData.pageCore.drawingWidth
    }
    
    init(delegate: PageDelegate, pageData: PageData, mode: StudyVC.Mode?) {
        self.delegate = delegate
        self.problems = pageData.problems
        self.mode = mode ?? .default
        self.pageData = pageData
        
        guard problems.isEmpty == false else {
            assertionFailure("문제수가 0인 페이지가 존재합니다.")
            return
        }
        self.configureObservation()
    }
    
    func updatePageData(_ pageData: PageData) {
        self.pageData = pageData
        self.problems = pageData.problems
        self.problemsBaseTimes = self.problems.map(\.time)
        
        guard problems.isEmpty == false else {
            assertionFailure("문제수가 0인 페이지가 존재합니다.")
            return
        }
    }
    
    private func configureObservation() {
        NotificationCenter.default.addObserver(forName: .saveCoreData, object: nil, queue: .main) { [weak self] _ in
            self?.endTimeRecord()
        }
    }
    
    /// - Returns: 사용자에게 보여주기 위한 answer값
    func answerStringForUser(_ problem: Problem_Core? = nil) -> String? {
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
        print("start time record")
        guard self.isTimeRecording == false else {
            return
        }
        // 모든 문제가 terminated 된 상태일 경우 timer를 반영 안한다
        if self.problems.allSatisfy(\.terminated) {
            print("timer not working")
            return
        }
        
        self.updateStartTime(pid: nil)
        self.isTimeRecording = true
    }
    
    func updateStartTime(pid: Int64?) {
        self.beforePid = pid
        self.startTime = Date()
        self.problemsBaseTimes = self.problems.map(\.time)
    }
    
    func updateSolved(withSelectedAnswer selectedAnswer: String, problem: Problem_Core? = nil) {
        guard let problem = problem ?? self.problem else { return }
        problem.setValue(selectedAnswer, forKey: "solved") // 사용자 입력 값 저장
        
        if let answer = problem.answer { // 정답이 있는 경우 정답여부 업데이트
            let correct = self.isCorrect(input: selectedAnswer, answer: answer)
            problem.setValue(correct, forKey: "correct")
        }
        self.updateTime(problem: problem)
        self.delegate?.addScoring(pid: Int(problem.pid))
    }
    
    func updateTime(problem: Problem_Core) {
        // term 계산하여 시간 update
        let term = self.startTime?.interval(to: Date()) ?? 0
        if self.problems.count == 1 {
            print("timeUpdate: \(self.problemsBaseTimes[0]+Int64(term))")
            problem.setValue(self.problemsBaseTimes[0]+Int64(term), forKey: Problem_Core.Attribute.time.rawValue)
        } else {
            guard let targetIndex = self.problems.firstIndex(of: problem) else { return }
            print("timeUpdate: \(self.problemsBaseTimes[targetIndex]+Int64(term))")
            problem.setValue(self.problemsBaseTimes[targetIndex]+Int64(term), forKey: Problem_Core.Attribute.time.rawValue)
        }
        CoreDataManager.saveCoreData()
        // 같은문제의 경우 기준값 reset 패스
        if self.beforePid == nil || self.beforePid == problem.pid { return }
        self.updateStartTime(pid: problem.pid)
    }
    
    func endTimeRecord() {
        print("end time record")
        self.startTime = nil
        self.problemsBaseTimes = []
        self.beforePid = nil
        self.startTime = nil
        self.isTimeRecording = false
        CoreDataManager.saveCoreData()
    }
    
    func updateStar(to status: Bool, problem: Problem_Core? = nil) {
        guard let problem = problem ?? self.problem else { return }
        problem.setValue(status, forKey: "star")
        self.delegate?.refreshPageButtons()
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

