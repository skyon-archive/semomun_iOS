//
//  SectionManager.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import UIKit
import CoreData

protocol LayoutDelegate: AnyObject {
    func changeVC(pageData: PageData)
    func reloadButtons()
    func showAlert(text: String)
    func showTitle(title: String)
    func showTime(time: Int64)
    func saveComplete()
    func terminateSection(result: SectionResult)
}

class SectionManager {
    weak var delegate: LayoutDelegate!
    var section: Section_Core?
    var buttons: [String] = []
    var stars: [Bool] = []
    var wrongs: [Bool] = []
    var dictionanry: [String: Int] = [:]
    var currentTime: Int64 = 0
    var currentIndex: Int = 0
    var currentPage: PageData?
    
    var timer: Timer!
    var isRunning: Bool = true
    
    // 1. Section 로딩
    init(delegate: LayoutDelegate, section: Section_Core?) {
        self.delegate = delegate
        self.section = section
        if section == nil {
            self.configureMock()
        }
        self.configureSection()
        self.showTitle()
        self.showTime()
        self.changePage(at: 0)
        self.startTimer()
    }
    
    func configureSection() {
        guard let section = self.section else { return }
        self.buttons = section.buttons
        self.stars = section.stars
        self.wrongs = section.wrongs
        self.dictionanry = section.dictionaryOfProblem
        self.currentTime = section.time
    }
    
    func changePage(at index: Int) {
        self.currentIndex = index
        // 2. vid 구하기
        let pageID = pageID(at: buttonTitle(at: index))
        
        if self.currentPage?.vid == pageID {
            self.delegate.reloadButtons()
            return
        }
        
        // 3. pageData 생성 -> 내부서 5까지 구현
        // 현재는 생성로직, 추후 cache 필요
        self.currentPage = nil
        let pageData = PageData(vid: pageID)
        self.currentPage = pageData
        
        // 6. 변경된 PageData 반환
        self.delegate.reloadButtons()
        self.delegate.changeVC(pageData: pageData)
    }
    
    func refreshPage() {
        guard let currentPage = currentPage else { return }
        self.delegate.changeVC(pageData: currentPage)
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
    
    func showWrongColor(at: Int) -> Bool {
        return self.wrongs[at] && self.section?.terminated ?? false
    }
    
    
    func pageID(at: String) -> Int {
        return self.dictionanry[at, default: 0]
    }
    
    func updateStar(title: String, to: Bool) {
        guard let section = self.section else { return }
        if let idx = self.buttons.firstIndex(of: title) {
            self.stars[idx] = to
            section.setValue(self.stars, forKey: "stars")
            self.delegate.reloadButtons()
        }
    }
    
    func updateWrong(title: String, to: Bool) {
        guard let section = self.section else { return }
        if let idx = self.buttons.firstIndex(of: title) {
            self.wrongs[idx] = to
            section.setValue(self.wrongs, forKey: "wrongs")
        }
    }
    
    func changeNextPage() {
        let currentVid = self.currentPage?.vid
        var tempIndex = self.currentIndex
        while true {
            if tempIndex == self.buttons.count-1 {
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
    
    func changeBeforePage() {
        let currentVid = self.currentPage?.vid
        var tempIndex = self.currentIndex
        while true {
            if tempIndex == 0 {
                self.delegate.showAlert(text: "첫 페이지 입니다.")
                break
            }
            
            tempIndex -= 1
            let beforeVid = self.pageID(at: buttonTitle(at: tempIndex))
            if beforeVid != currentVid {
                self.changePage(at: tempIndex)
                break
            }
        }
    }
    
    func showTitle() {
        guard let title = self.section?.title else { return }
        self.delegate.showTitle(title: title)
    }
    
    func showTime() {
        DispatchQueue.main.async {
            self.delegate.showTime(time: self.currentTime)
        }
    }
    
    func startTimer() {
        guard let terminated = self.section?.terminated else { return }
        if terminated { return } // 이미 종료된 문제집의 경우 시간 정지
        DispatchQueue.global().async {
            let runLoop = RunLoop.current
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                NotificationCenter.default.post(name: .seconds, object: nil) //1초당 push
                self.currentTime += 1
                self.showTime()
            }
            while self.isRunning {
                runLoop.run(until: Date().addingTimeInterval(0.1))
            }
        }
    }
    
    func stopSection() {
        self.stopTimer()
        self.delegate.saveComplete()
        CoreDataManager.saveCoreData()
    }
    
    func stopTimer() {
        guard let section = self.section else { return }
        if section.terminated { return }
        
        self.isRunning = false
        self.timer.invalidate()
        self.section?.setValue(currentTime, forKey: "time")
    }
    
    func configureMock() {
        if let section = CoreUsecase.sectionOfCoreData(sid: -3) {
            self.section = section
        } else {
            CoreUsecase.createMockDataForMulty()
            self.section = CoreUsecase.sectionOfCoreData(sid: -3)
        }
    }
    
    func terminateSection() {
        guard let section = self.section,
              let title = section.title else { return }
        // 채점 로직
        let saveSectionUsecase = SaveSectionUsecase(section: section)
        saveSectionUsecase.fetchPids()
        saveSectionUsecase.calculateSectionResult()
        // 결과
        self.stopTimer()
        section.setValue(true, forKey: "terminated")
        let result = SectionResult(title: title,
                                   perfectScore: saveSectionUsecase.perfactScore,
                                   totalScore: saveSectionUsecase.totalScore,
                                   totalTime: section.time,
                                   wrongProblems: saveSectionUsecase.wrongProblems)
        // 반환
        CoreDataManager.saveCoreData()
        self.delegate.reloadButtons()
        self.refreshPage()
        self.changePage(at: currentIndex)
        self.delegate.terminateSection(result: result)
        // test
        guard let data = try? JSONEncoder().encode(saveSectionUsecase.submissions) else {
            return
        }
        print(String(data: data, encoding: .utf8))
    }
}
