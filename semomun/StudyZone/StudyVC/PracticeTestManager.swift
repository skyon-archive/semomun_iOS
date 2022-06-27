//
//  PracticeTestManager.swift
//  semomun
//
//  Created by Kang Minsang on 2022/06/27.
//

import Foundation
import Combine

final class PracticeTestManager {
    @Published private(set) var sectionTitle: String = "title"
    @Published private(set) var recentTime: Int64 = 0
    @Published private(set) var currentPage: PageData?
    @Published private(set) var showTestInfo: TestInfo?
    @Published private(set) var warning: (title: String, text: String)?
    private(set) var problems: [Problem_Core] = []
    private(set) var section: PracticeTestSection_Core
    private(set) var currentIndex: Int = 0
    private weak var delegate: LayoutDelegate?
    private let workbook: Preview_Core
    private var timer: Timer!
    private var isRunning: Bool = true
    private let networkUsecase: UserSubmissionSendable
    
    /// WorkbookGroupDetailVC 에서 VM 생성
    init(section: PracticeTestSection_Core, workbook: Preview_Core, networkUsecase: UserSubmissionSendable) {
        self.section = section
        self.workbook = workbook
        self.networkUsecase = networkUsecase
    }
    /// StudyVC 내에서 delegate 설정 및 configure 로직 수행
    func configureDelegate(to delegate: LayoutDelegate) {
        self.delegate = delegate
        self.checkStartTestable()
        self.configureObservation()
    }
}

// MARK: Public
extension PracticeTestManager {
    func startTest() {
        let startDate = Date()
        self.section.startTest(startDate: startDate)
        CoreDataManager.saveCoreData()
        
        self.configureStartPage()
        self.updateRecentTime()
        self.startTimer()
    }
}

extension PracticeTestManager {
    private func checkStartTestable() {
        if self.section.startedDate == nil { // 응시 전 상태인 경우
            guard let title = self.workbook.title,
                  let area = self.section.area,
                  let subject = self.section.subject else {
                self.warning = (title: "모의고사 정보 오류", text: "")
                return
            }
            
            self.showTestInfo = TestInfo(title: title, area: area, subject: subject)
        } else {
            self.configureStartPage()
            self.updateRecentTime()
            
            if self.section.terminated { // 채점완료 상태인 경우
                self.configureTerminated()
            } else { // 진행중인 경우
                self.startTimer()
            }
        }
    }
    
    private func configureObservation() {
        NotificationCenter.default.addObserver(forName: .sectionTerminated, object: nil, queue: .current) { [weak self] _ in
            
        }
    }
    
    private func configureStartPage() {
        // 0번 인덱스 표시 로직 (마지막 index 를 표시할 경우 수정 필요)
        let lastPageId = 0
        self.changePage(at: lastPageId)
    }
    
    private func updateRecentTime() {
        // 남은시간 표시
    }
    
    private func startTimer() {
        // 1초간 반복되는 timer 로직, 내부에서 updateRecentTime 실행
        // 만약 첫 실행시 updateRecentTime 불리는 경우 중복로직 제거 필요
    }
    
    private func configureTerminated() {
        // timer 정지, ui 수정 notification post,
    }
    
    private func changePage(at index: Int) {
        guard let page = self.problems[index].pageCore else { return }
        self.currentIndex = index // 하단 button index update
        
        if self.currentPage?.vid == Int(page.vid) {
            self.delegate?.reloadButtons() // button index update 표시
            return
        }
        
        let pageData = PageData(page: page)
        self.currentPage = pageData
        self.section.setValue(index, forKey: PracticeTestSection_Core.Attribute.lastIndex.rawValue) // 사실상 의미없는 로직
    }
}
