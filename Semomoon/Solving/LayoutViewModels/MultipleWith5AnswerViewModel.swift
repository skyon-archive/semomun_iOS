//
//  MultipleWith5AnswerViewModel.swift
//  Semomoon
//
//  Created by qwer on 2021/11/27.
//

import Foundation

final class MultipleWith5AnswerViewModel {
    weak var delegate: PageDelegate?
    
    private(set) var pageData: PageData
    private(set) var problems: [Problem_Core]?
    private var time: Int64
    
    init(delegate: PageDelegate, pageData: PageData) {
        self.delegate = delegate
        self.pageData = pageData
        self.problems = self.pageData.problems
        self.time = 0
    }
    
    func configureObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateTime), name: .seconds, object: nil)
    }
    
    func cancelObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func updateTime() {
        self.time = self.time + 1
        
        self.saveCoreData()
    }
    
    func saveCoreData() {
        do { try CoreDataManager.shared.context.save() } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func updatePencilData(to: Data) {
        self.pageData.pageCore.setValue(to, forKey: "drawing")
        self.saveCoreData()
    }
    
    var count: Int {
        return self.problems?.count ?? 0
    }
    
    func problem(at: Int) -> Problem_Core? {
        return self.problems?[at] ?? nil
    }
}
