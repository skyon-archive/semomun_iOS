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
    enum PastLayout {
        static let Concept = "Concept"
        static let SingleWithNoAnswer = "SingleWithNoAnswer"
        static let SingleWithTextAnswer = "SingleWithTextAnswer"
        static let SingleWith4Answer = "SingleWith4Answer"
        static let SingleWith5Answer = "SingleWith5Answer"
        static let MultipleWithNoAnswer = "MultipleWithNoAnswer"
        static let MultipleWith5Answer = "MultipleWith5Answer"
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
                problem.setValue(UIImage(named: SemomunImage.warning)!.pngData, forKey: "contentImage")
            }
        }
    }
    
    private func layoutType(from type: String) -> String {
        switch type {
        // Version 2.0
        case ConceptVC.identifier,
            SingleWithNoAnswerVC.identifier,
            SingleWithTextAnswerVC.identifier,
            SingleWith4AnswerVC.identifier,
            SingleWith5AnswerVC.identifier,
            MultipleWithNoAnswerVC.identifier,
            MultipleWith5AnswerVC.identifier:
            return type
        // Version 1.0
        case PastLayout.Concept:
            return ConceptVC.identifier
        case PastLayout.SingleWithNoAnswer:
            return SingleWithNoAnswerVC.identifier
        case PastLayout.SingleWith4Answer:
            return SingleWith4AnswerVC.identifier
        case PastLayout.SingleWith5Answer:
            return SingleWith5AnswerVC.identifier
        case PastLayout.MultipleWithNoAnswer:
            return MultipleWithNoAnswerVC.identifier
        case PastLayout.MultipleWith5Answer:
            return MultipleWith5AnswerVC.identifier
        default:
            return MultipleWith5AnswerVC.identifier
        }
    }
}
