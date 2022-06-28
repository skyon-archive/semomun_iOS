//
//  PracticeTestManager.swift
//  semomun
//
//  Created by Kang Minsang on 2022/06/27.
//

import Foundation
import Combine
import UserNotifications

final class PracticeTestManager {
    /* public */
    static let practiceTest5min = "practiceTest5min"
    @Published private(set) var sectionTitle: String = "title"
    @Published private(set) var recentTime: Int64 = 0
    @Published private(set) var currentPage: PageData?
    @Published private(set) var showTestInfo: TestInfo?
    @Published private(set) var warning: (title: String, text: String)?
    private(set) var problems: [Problem_Core] = []
    private(set) var section: PracticeTestSection_Core
    private(set) var currentIndex: Int = 0
    /* private */
    private weak var delegate: LayoutDelegate?
    private let workbook: Preview_Core
    private var timer: Timer!
    private var isRunning: Bool = true
    private let networkUsecase: UserSubmissionSendable
    private let userNotificationCenter = UNUserNotificationCenter.current()
    // 임시 변수
    private let timeLimit: Int64 = 6000 // section.timeLimit 으로 변경될 예정
    
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
        self.requestNotificationAuthorization()
    }
}

// MARK: Public
extension PracticeTestManager {
    /// 해당 응시에서 단 한번만 실행되는 로직
    func startTest() {
        // backend 에 post 하는게 필요하진 않을까?
        let startDate = Date()
        self.section.startTest(startDate: startDate)
        CoreDataManager.saveCoreData()
        
        self.configureStartPage()
        self.updateRecentTime()
        self.startTimer()
        self.setNotificationAlert() // 5분전 알림 설정, 최초 응시 시작시만 설정
    }
    /// 화면전환 로직
    func changePage(at index: Int) {
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
    
    /// 응시 도중 나가는 경우 로직
    func stopTimer() {
        if self.section.terminated { return }
        
        self.isRunning = false
        self.timer.invalidate()
    }
}

// MARK: Privagte
extension PracticeTestManager {
    /// 응시 시작시
    private func requestNotificationAuthorization() {
        let authOptions = UNAuthorizationOptions(arrayLiteral: .alert, .badge, .sound)
        
        self.userNotificationCenter.requestAuthorization(options: authOptions) { success, error in
            if let error = error {
                print("Error: \(error)")
            }
        }
    }
    /// 응시 전, 응시 진행중, 응시 완료를 확인
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
                guard self.getRecentTime() > 0 else {
                    self.configureTerminated()
                    return
                }
                self.startTimer() // 시험 계속 응시
            }
        }
    }
    /// 채점 완료 수신
    private func configureObservation() {
        NotificationCenter.default.addObserver(forName: .sectionTerminated, object: nil, queue: .current) { [weak self] _ in
            self?.configureTerminated()
        }
    }
    
    private func configureStartPage() {
        let lastPageId = 0 // 0번 인덱스 표시 로직 (마지막 index 를 표시할 경우 수정 필요)
        self.changePage(at: lastPageId)
    }
    
    private func getRecentTime() -> Int64 {
        return self.timeLimit - self.section.totalTime
    }
    
    private func updateRecentTime() {
        self.recentTime = self.getRecentTime()
        if recentTime <= 0 {
            self.configureTerminated()
        }
    }
    
    private func startTimer() {
        if self.section.terminated { return }
        
        DispatchQueue.global().async {
            let runLoop = RunLoop.current
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.updateRecentTime()
            }
            while self.isRunning {
                runLoop.run(until: Date().addingTimeInterval(0.1))
            }
        }
    }
    
    /**
     - 응시 종료로직 (종료 이후 UI 표시)
     - 진입시 응시 종료 이후 다시 들어오는 경우
     - 진입시 응시 진행중에 시간이 지나고서 들어오는 경우
     - 응시 진행중에 시간이 다된 경우
     - 응시 진행중에 채점완료를 한 경우
     */
    private func configureTerminated() {
        self.stopTimer()
        self.removeNotification()
        let terminatedDate = Date()
        self.section.terminateTest(terminatedDate: terminatedDate)
        CoreDataManager.saveCoreData()
        // MARK: UI 수정 notification 필요 및 각 VC 에서 어떤식으로 분기처리를 할 것인지가 고민 포인트
        // MARK: network post 정보가 필요
        // MARK: binding 으로 완료 전파 필요
    }
    
    private func setNotificationAlert() {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "시험 종료 5분전 입니다."
        notificationContent.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(self.timeLimit - 300), repeats: false)
        let request = UNNotificationRequest(identifier: PracticeTestManager.practiceTest5min, content: notificationContent, trigger: trigger)
        self.userNotificationCenter.add(request) { error in
            if let error = error {
                print("Notification Error: \(error)")
            }
        }
    }
    
    private func removeNotification() {
        // 응시가 종료된 경우만 불린다
        self.userNotificationCenter.removeDeliveredNotifications(withIdentifiers: [PracticeTestManager.practiceTest5min])
    }
}
