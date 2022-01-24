//
//  MultipleWithNoAnswerViewModel.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation

final class MultipleWithNoAnswerVM {
    weak var delegate: PageDelegate?
    
    private(set) var pageData: PageData
    private(set) var problems: [Problem_Core]?
    private var time: Int64?
    private var baseTimes: [Int64] = []
    
    init(delegate: PageDelegate, pageData: PageData) {
        self.delegate = delegate
        self.pageData = pageData
        self.problems = self.pageData.problems
        self.time = self.pageData.pageCore.time
        self.configureTimes()
    }
    
    func configureTimes() {
        guard let problems = self.problems else { return }
        let tempTimes = problems.map { $0.time }
        self.baseTimes = tempTimes
    }
    
    func configureObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateTime), name: .seconds, object: nil)
    }
    
    func cancelObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func updateTime() {
        guard let problems = problems,
              let time = self.time else { return }
        let resultTime = time+1
        self.time = resultTime
        let perTime = Int64(ceil(Double(resultTime)/Double(problems.count)))
        for (idx, problem) in problems.enumerated() {
            problem.setValue(baseTimes[idx] + perTime, forKey: "time")
        }
    }
    
    func updatePencilData(to: Data) {
        self.pageData.pageCore.setValue(to, forKey: "drawing")
    }
    var count: Int {
        return self.problems?.count ?? 0
    }
    
    func problem(at: Int) -> Problem_Core? {
        return self.problems?[at] ?? nil
    }
}