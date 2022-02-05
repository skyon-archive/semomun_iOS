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
    func showResultViewController(result: SectionResult)
    func terminateSection(result: SectionResult, sid: Int, jsonString: String)
    func changeResultLabel()
}

final class SectionManager {
    private weak var delegate: LayoutDelegate?
    private(set) var section: Section_Core
    private(set) var currentIndex: Int = 0
    private var buttons: [String] = []
    private var dictionanry: [String: Int] = [:]
    private var currentTime: Int64 = 0
    private var currentPage: PageData?
    private var timer: Timer!
    private var isRunning: Bool = true
    
    // 1. Section 로딩
    init(delegate: LayoutDelegate, section: Section_Core, isTest: Bool = false) {
        self.delegate = delegate
        self.section = section
        if isTest {
            self.configureMock()
        }
        self.configureSection()
        self.configureSendText()
        self.showTitle()
        self.showTime()
        self.configureStartPage()
        self.startTimer()
    }
    
    private func configureSection() {
        self.buttons = self.section.buttons
        self.dictionanry = self.section.dictionaryOfProblem
        self.currentTime = self.section.time
    }
    
    private func configureStartPage() {
        let lastPageId = self.section.lastPageId
        if let key = dictionanry.first(where: {$0.value == lastPageId})?.key, let idx = buttons.firstIndex(of: key) {
                self.currentIndex = idx
            let pageData = PageData(vid: Int(lastPageId))
                self.currentPage = pageData
                self.delegate?.reloadButtons()
                self.delegate?.changeVC(pageData: pageData)
        } else {
            changePage(at: 0)
        }
    }
    
    private func configureSendText() {
        if self.section.terminated {
            self.delegate?.changeResultLabel()
        }
    }
    
    func changePage(at index: Int) {
        self.currentIndex = index
        // 2. vid 구하기
        let pageID = pageID(at: buttonTitle(at: index))
        
        if self.currentPage?.vid == pageID {
            self.delegate?.reloadButtons()
            return
        }
        
        // 3. pageData 생성 -> 내부서 5까지 구현
        // 현재는 생성로직, 추후 cache 필요
        self.currentPage = nil
        let pageData = PageData(vid: pageID)
        self.currentPage = pageData
        
        // 6. 변경된 PageData 반환
        self.delegate?.reloadButtons()
        self.delegate?.changeVC(pageData: pageData)
        
        self.section.setValue(pageID, forKey: "lastPageId")
    }
    
    private func refreshPage() {
        guard let currentPage = currentPage else { return }
        self.delegate?.changeVC(pageData: currentPage)
    }
    
    var count: Int {
        return self.buttons.count
    }
    
    func buttonTitle(at: Int) -> String {
        return self.buttons[at]
    }
    
    func isStar(at: Int) -> Bool {
        return self.section.stars[at]
    }
    
    func isWrong(at: Int) -> Bool {
        return self.section.wrongs[at] && self.section.terminated
    }
    
    func isCheckd(at: Int) -> Bool {
        return self.section.checks[at]
    }
    
    func pageID(at: String) -> Int {
        return self.dictionanry[at, default: 0]
    }
    
    func updateStar(title: String, to: Bool) {
        if let idx = self.buttons.firstIndex(of: title) {
            var stars = self.section.stars
            stars[idx] = to
            self.section.setValue(stars, forKey: "stars")
            CoreDataManager.saveCoreData()
            self.delegate?.reloadButtons()
        }
    }
    
    func updateCheck(title: String) {
        if let idx = self.buttons.firstIndex(of: title) {
            var checks = self.section.checks
            checks[idx] = true
            self.section.setValue(checks, forKey: "checks")
            CoreDataManager.saveCoreData()
            self.delegate?.reloadButtons()
        }
    }
    
    func updateWrong(title: String, to: Bool) {
        if let idx = self.buttons.firstIndex(of: title) {
            var wrongs = self.section.wrongs
            var checks = self.section.checks
            wrongs[idx] = to
            checks[idx] = true
            self.section.setValue(wrongs, forKey: "wrongs")
            self.section.setValue(checks, forKey: "checks")
            CoreDataManager.saveCoreData()
            self.delegate?.reloadButtons()
        }
    }
    
    func changeNextPage() {
        let currentVid = self.currentPage?.vid
        var tempIndex = self.currentIndex
        while true {
            if tempIndex == self.buttons.count-1 {
                self.delegate?.showAlert(text: "마지막 페이지 입니다.")
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
                self.delegate?.showAlert(text: "첫 페이지 입니다.")
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
    
    private func showTitle() {
        guard let title = self.section.title else { return }
        self.delegate?.showTitle(title: title)
    }
    
    private func showTime() {
        DispatchQueue.main.async {
            self.delegate?.showTime(time: self.currentTime)
        }
    }
    
    private func startTimer() {
        if self.section.terminated { return } // 이미 종료된 문제집의 경우 시간 정지
        
        DispatchQueue.global().async {
            let runLoop = RunLoop.current
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                NotificationCenter.default.post(name: .seconds, object: nil) //1초당 push
                guard let self = self else { return }
                self.currentTime += 1
                self.section.setValue(self.currentTime, forKey: "time")
                self.showTime()
                if self.currentTime%10 == 0 {
                    CoreDataManager.saveCoreData()
                }
            }
            while self.isRunning {
                runLoop.run(until: Date().addingTimeInterval(0.1))
            }
        }
    }
    
    func stopSection() {
        self.stopTimer()
        CoreDataManager.saveCoreData()
        self.delegate?.saveComplete()
    }
    
    func stopTimer() {
        if self.section.terminated { return }
        
        self.isRunning = false
        self.timer.invalidate()
    }
    
    func configureMock() {
        if let section = CoreUsecase.sectionOfCoreData(sid: -1) {
            self.section = section
            return
        }
        CoreUsecase.createMockDataForMulty()
        guard let section = CoreUsecase.sectionOfCoreData(sid: -1) else { return }
        self.section = section
    }
    
    func terminateSection() {
        guard let title = self.section.title else { return }
        CoreDataManager.saveCoreData()
        // 채점 로직
        let saveSectionUsecase = SaveSectionUsecase(section: section)
        self.section.setValue(saveSectionUsecase.wrongs, forKey: "wrongs")
        // 저장 및 UI 반영
        self.stopTimer()
        let result = SectionResult(title: title, totalTime: section.time, sectionUsecase: saveSectionUsecase)
        CoreDataManager.saveCoreData()
        self.delegate?.reloadButtons()
        self.refreshPage()
        // 결과창 표시
        if self.section.terminated {
            self.delegate?.showResultViewController(result: result)
        } else {
            self.section.setValue(true, forKey: "terminated")
            guard let jsonData = try? JSONEncoder().encode(saveSectionUsecase.submissions) else {
                print("Encode Error")
                return
            }
            guard let jsonStringData = String(data: jsonData, encoding: String.Encoding.utf8) else { return }
            self.delegate?.terminateSection(result: result, sid: Int(section.sid), jsonString: jsonStringData)
        }
    }
}
