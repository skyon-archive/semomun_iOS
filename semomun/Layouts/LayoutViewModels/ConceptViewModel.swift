//
//  ConceptViewModel.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/15.
//

import Foundation

final class ConceptViewModel {
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
    
    func updateStar(btName pName: String, to status: Bool) {
        self.problem?.setValue(status, forKey: "star")
        self.delegate?.updateStar(btName: pName, to: status)
    }
    
    func updatePencilData(to: Data) {
        self.problem?.setValue(to, forKey: "drawing")
    }
}

