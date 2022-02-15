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
    var layoutType: String!
    var pageCore: Page_Core!
    var problems: [Problem_Core] = []
    
    init(vid: Int) {
        self.vid = vid
        self.fetchPageCore()
        self.configureProblems()
    }
    
    // 4. pageCore 로딩
    private func fetchPageCore() {
        if let pageData = CoreUsecase.fetchPage(vid: self.vid) {
            self.pageCore = pageData
            self.layoutType = self.layoutType(from: pageData.layoutType)
        }
    }
    
    // 5. page : problems 모두 로딩
    private func configureProblems() {
        for pid in self.pageCore.problems {
            if let problemCore = CoreUsecase.fetchProblem(pid: pid) {
                self.problems.append(problemCore)
            } else {
                let problem = Problem_Core(context: CoreDataManager.shared.context)
                problem.setValue(UIImage(.warning).pngData, forKey: "contentImage")
            }
        }
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
