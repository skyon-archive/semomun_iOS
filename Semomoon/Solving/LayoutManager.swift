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
    func reloadButtons()
    func showAlert(text: String)
    func showTitle(title: String)
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
    var dictionanry: [String: Int] = [:]
    
    var currentIndex: Int = 0
    var currentPage: PageData!
    
    // 1. Section 로딩
    init(delegate: LayoutDelegate, section: Section_Core) {
        self.delegate = delegate
        self.section = section
        self.showTitle()
        self.configureSection()
        self.changePage(at: 0)
    }
    
    func configureSection() {
        self.buttons = section.buttons
        self.stars = section.stars
        self.dictionanry = section.dictionaryOfProblem
    }
    
    func changePage(at index: Int) {
        self.currentIndex = index
        // 2. vid 구하기
        let pageID = pageID(at: buttonTitle(at: index))
        
        // 3. pageData 생성 -> 내부서 5까지 구현
        // 현재는 생성로직, 추후 cache 필요
        self.currentPage = nil
        self.currentPage = PageData(vid: pageID)
        
        // 6. 변경된 PageData 반환
        self.delegate.reloadButtons()
        self.delegate.changeVC(pageData: self.currentPage)
    }
    
    var count: Int {
        return self.buttons.count
    }
    
    func buttonTitle(at: Int) -> String {
        return self.buttons[at]
    }
    
    func showStarColor(at: Int) -> Bool {
        return self.stars[at]
    }
    
    func pageID(at: String) -> Int {
        return self.dictionanry[at] ?? 0
    }
    
    func updateStar(title: String, to: Bool) {
        if let idx = self.buttons.firstIndex(of: title) {
            self.stars[idx] = to
            self.section.setValue(self.stars, forKey: "stars")
            self.saveCoreData()
            self.delegate.reloadButtons()
        }
    }
    
    func changeNextPage() {
        let currentVid = self.currentPage.vid
        var tempIndex = self.currentIndex
        while true {
            if self.currentIndex == self.buttons.count-1 {
                self.delegate.showAlert(text: "마지막 페이지 입니다.")
                break
            }
            
            tempIndex += 1
            let nextVid = self.pageID(at: buttonTitle(at: tempIndex))
            if nextVid != currentVid {
                self.changePage(at: tempIndex)
                break
            }
        }
    }
    
    func showTitle() {
        guard let title = self.section.title else { return }
        self.delegate.showTitle(title: title)
    }
    
    func saveCoreData() {
        do { try CoreDataManager.shared.context.save() } catch let error {
            print(error.localizedDescription)
        }
    }
}
