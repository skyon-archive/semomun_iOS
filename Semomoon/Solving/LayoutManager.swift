//
//  LayoutManager.swift
//  Semomoon
//
//  Created by qwer on 2021/10/24.
//

import UIKit
import CoreData

protocol LayoutDelegate: AnyObject {
    func changeVC(pageData: PageData)
}

class LayoutManager {
    enum Identifier {
        static let singleWith5Answer = SingleWith5Answer.identifier
        static let singleWithTextAnswer = SingleWithTextAnswer.identifier
        static let multipleWith5Answer = MultipleWith5Answer.identifier
        static let singleWith4Answer = SingleWith4Answer.identifier
        static let multipleWithNoAnswer = MultipleWithNoAnswer.identifier
    }
    
    weak var delegate: LayoutDelegate!
    let context = CoreDataManager.shared.context
    var section: Section_Core!
    var buttons: [String] = []
    var stars: [Bool] = []
    var dictionanry: [String: Int] = [:]
    
    var currentIndex: Int = 0
    var currentPage: PageData!
    
    // 1. Section 로딩
    init(delegate: LayoutDelegate, section: Section_Core) {
        self.delegate = delegate
        self.section = section
        self.configureSection()
        self.changePage(at: currentIndex)
    }
    
    func configureSection() {
        self.buttons = section.buttons
        self.stars = section.stars
        self.dictionanry = section.dictionaryOfProblem
    }
    
    func changePage(at index: Int) {
        // 2. vid 구하기
        let pageID = pageID(at: buttonTitle(at: index))
        
        // 3. pageData 생성
        self.currentPage = PageData(vid: pageID)
    }
    
    var count: Int {
        return self.buttons.count
    }
    
    func buttonTitle(at: Int) -> String {
        return self.buttons[at]
    }
    
    func pageID(at: String) -> Int {
        return self.dictionanry[at] ?? 0
    }
    
    func buttonChecked(at: Int) -> Bool {
        return self.stars[at]
    }
    
    func loadPageCore(vid: Int) -> Page_Core {
        return Page_Core()
    }
    
    func loadProblemCore(pid: Int) -> Problem_Core {
        return Problem_Core()
    }
    
//    func createPageData() -> PageData {
//        return PageData()
//    }
    
    func updateStar(title: String, to: Bool) {
        if let idx = self.buttons.firstIndex(of: title) {
            self.stars[idx] = to
            
        }
    }
}
