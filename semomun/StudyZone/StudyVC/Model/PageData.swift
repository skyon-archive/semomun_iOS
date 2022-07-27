//
//  PageData.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation
import CoreData
import UIKit

final class PageData {
    enum PastLayout: String {
        case Concept
        case SingleWithNoAnswer
        case SingleWithTextAnswer
        case SingleWith4Answer
        case SingleWith5Answer
        case MultipleWithNoAnswer
        case MultipleWith5Answer
    }
    let vid: Int
    let pageCore: Page_Core
    private(set) var problems: [Problem_Core]!
    private(set) var layoutType: String!
    
    init(page: Page_Core) {
        self.pageCore = page
        self.vid = Int(page.vid)
        guard let problems = page.problemCores?.sorted(by: { $0.orderIndex < $1.orderIndex }) else {
            print("error: fetch problems")
            return
        }
        self.problems = problems
        self.layoutType = self.layoutType(from: page.layoutType)
    }
    
    private func layoutType(from type: String) -> String {
        if let pastLayout = PastLayout(rawValue: type) {
            switch pastLayout {
            // Version 1.0
            case .Concept:
                return ConceptVC.identifier
            case .SingleWithNoAnswer:
                return SingleWithNoAnswerVC.identifier
            case .SingleWithTextAnswer:
                return SingleWithTextAnswerVC.identifier
            case .SingleWith4Answer:
                return SingleWith4AnswerVC.identifier
            case .SingleWith5Answer:
                return SingleWith5AnswerVC.identifier
            case .MultipleWithNoAnswer:
                return MultipleWithNoAnswerVC.identifier
            case .MultipleWith5Answer:
                return MultipleWith5AnswerVC.identifier
            }
            // Version 2.0
        } else {
            return type
        }
    }
}
