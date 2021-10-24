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
    var section: Section_Core!
    var buttons: [String] = []
    var stars: [Bool] = []
    
    init(delegate: LayoutDelegate, section: Section_Core) {
        self.delegate = delegate
        self.section = section
    }
    
    var count: Int {
        return self.buttons.count
    }
    
    func buttonTitle(at: Int) -> String {
        return self.buttons[at]
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
    
    func createPageData() -> PageData {
        return PageData()
    }
    
    func updateStar(title: String, to: Bool) {
        if let idx = self.buttons.firstIndex(of: title) {
            self.stars[idx] = to
        }
    }
}
