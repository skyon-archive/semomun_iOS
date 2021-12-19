//
//  SingleWith5Answer.swift
//  Semomoon
//
//  Created by Kang Minsang on 2021/11/27.
//

import Foundation

final class SingleWith5AnswerViewModel {
    weak var delegate: PageDelegate?
    
    private(set) var pageData: PageData
    private(set) var problem: Problem_Core?
    private var time: Int64?
    
    init(delegate: PageDelegate, pageData: PageData) {
        self.delegate = delegate
        self.pageData = pageData
        self.problem = self.pageData.problems.first
        self.time = self.problem?.time ?? 0
    }
    
    func configureObserver() {
        print("setting")
        NotificationCenter.default.addObserver(self, selector: #selector(updateTime), name: .seconds, object: nil)
    }
    
    func cancelObserver() {
        print("cancle")
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func updateTime() {
        guard let problem = self.problem,
              let time = self.time else { return }
        let resultTime = time+1
        self.time = resultTime
        problem.setValue(resultTime, forKey: "time")
        self.saveCoreData()
    }
    
    func saveCoreData() {
        DispatchQueue.global().async {
            do { try CoreDataManager.shared.context.save() } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func updateSolved(input: String) {
        guard let problem = self.problem,
              let pName = problem.pName else { return }
        problem.setValue(input, forKey: "solved") // 사용자 입력 값 저장
        saveCoreData()
        
        if let answer = problem.answer { // 정답이 있는 경우 정답여부 업데이트
            let correct = input == answer
            problem.setValue(correct, forKey: "correct")
            saveCoreData()
            self.delegate?.updateWrong(btName: pName, to: !correct) // 하단 표시 데이터 업데이트
        }
    }
    
    func updateStar(btName pName: String, to status: Bool) {
        self.problem?.setValue(status, forKey: "star")
        self.delegate?.updateStar(btName: pName, to: status)
    }
    
    func updatePencilData(to: Data) {
        self.problem?.setValue(to, forKey: "drawing")
        self.saveCoreData()
    }
}
