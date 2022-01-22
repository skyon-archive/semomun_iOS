//
//  SingleWith5AnswerViewModel.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation

final class SingleWith5AnswerVM {
    weak var delegate: PageDelegate?
    
    private(set) var pageData: PageData
    private(set) var problem: Problem_Core?
    private(set) var time: Int64?
    
    init(delegate: PageDelegate, pageData: PageData) {
        self.delegate = delegate
        self.pageData = pageData
        self.problem = self.pageData.problems.first
        self.time = self.problem?.time ?? 0
    }
    
    func configureObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateTime), name: .seconds, object: nil)
    }
    
    func cancelObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func updateTime() {
        guard let problem = self.problem,
              let time = self.time else { return }
        let resultTime = time+1
        self.time = resultTime
        problem.setValue(resultTime, forKey: "time")
    }
    
    func updateSolved(input: String) {
        guard let problem = self.problem,
              let pName = problem.pName else { return }
        problem.setValue(input, forKey: "solved") // 사용자 입력 값 저장
        
        if let answer = problem.answer { // 정답이 있는 경우 정답여부 업데이트
            let correct = self.isCorrect(input: input, answer: answer)
            problem.setValue(correct, forKey: "correct")
            self.delegate?.updateWrong(btName: pName, to: !correct) // 하단 표시 데이터 업데이트
        }
    }
    
    private func isCorrect(input: String, answer: String) -> Bool {
        if answer.contains("|") {
            let answers = answer.split(separator: "|").map { String($0) }
            return answers.contains(input)
        } else {
            return input == answer
        }
    }
    
    var answer: String? {
        guard let answer = self.problem?.answer else { return  nil }
        if answer.contains("|") {
            return "복수"
        } else {
            return answer
        }
    }
    
    func updateStar(btName pName: String, to status: Bool) {
        self.problem?.setValue(status, forKey: "star")
        self.delegate?.updateStar(btName: pName, to: status)
    }
    
    func updatePencilData(to: Data) {
        self.problem?.setValue(to, forKey: "drawing")
    }
}
