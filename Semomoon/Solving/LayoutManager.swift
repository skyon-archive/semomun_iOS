//
//  LayoutManager.swift
//  Semomoon
//
//  Created by qwer on 2021/10/24.
//

import UIKit
import CoreData

protocol LayoutDelegate: AnyObject {
    func changeVC(vc: UIViewController)
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
    
    init(delegate: LayoutDelegate, section: Section_Core) {
        self.delegate = delegate
        self.section = section
    }
    
    func loadPageCore(vid: Int) -> Page_Core {
        return Page_Core()
    }
}
