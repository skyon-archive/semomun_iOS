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
    enum PushNotification {
        static let practiceTest5min = "practiceTest5min"
    }
    @Published private(set) var sectionTitle: String = "title"
    @Published private(set) var recentTime: Int64 = 0
    @Published private(set) var currentPage: PageData?
    @Published private(set) var showTestInfo: TestInfo?
    @Published private(set) var warning: (title: String, text: String)?
    @Published private(set) var practiceTestTernimate: Bool = false
    private(set) var section: PracticeTestSection_Core
    private(set) var problems: [Problem_Core] = []
    private(set) var currentIndex: Int = 0
    /* private */
    private weak var delegate: LayoutDelegate?
    private let workbookGroup: WorkbookGroup_Core
    private let workbook: Preview_Core
    private var timer: Timer?
    private var isRunning: Bool = true
    private let networkUsecase: UserSubmissionSendable
    private let userNotificationCenter = UNUserNotificationCenter.current()
    private var remainingTime: Int64 {
        return self.section.timelimit - self.section.totalTime
    }
    
    /// WorkbookGroupDetailVC 에서 VM 생성
    init(section: PracticeTestSection_Core, workbookGroup: WorkbookGroup_Core, workbook: Preview_Core, networkUsecase: UserSubmissionSendable) {
        self.section = section
        self.workbookGroup = workbookGroup
        self.workbook = workbook
        self.networkUsecase = networkUsecase
    }
    /// StudyVC 내에서 delegate 설정 및 configure 로직 수행
    func configureDelegate(to delegate: LayoutDelegate) {
        self.delegate = delegate
        self.sectionTitle = self.section.title ?? "title"
        self.checkStartTestable()
        self.configureObservation()
        self.requestNotificationAuthorization()
    }
}

// MARK: Public
extension PracticeTestManager {
    /// 해당 응시에서 단 한번만 실행되는 로직
    func startTest() {
        guard self.section.startedDate == nil else {
            self.warning = (title: "응시 불가", text: "최신버전으로 업데이트 해주세요")
            return
        }
        // backend 에 post 하는게 필요하진 않을까?
        let startedDate = Date()
        self.section.startTest(startedDate: startedDate)
        CoreDataManager.saveCoreData()
        
        self.configureProblems()
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
    
    func pauseSection() {
        self.stopTimer()
        CoreDataManager.saveCoreData()
    }
    
    func changeNextPage() {
        let currentVid = self.currentPage?.vid
        var tempIndex = self.currentIndex
        while true {
            if tempIndex == self.problems.count-1 {
                self.delegate?.showAlert(text: "마지막 페이지 입니다.")
                break
            }
            
            tempIndex += 1
            let nextVid = Int(self.problems[tempIndex].pageCore?.vid ?? 0)
            if nextVid != currentVid {
                self.changePage(at: tempIndex)
                break
            }
        }
    }
    
    func changePreviousPage() {
        let currentVid = self.currentPage?.vid
        var tempIndex = self.currentIndex
        while true {
            if tempIndex == 0 {
                self.delegate?.showAlert(text: "첫 페이지 입니다.")
                break
            }
            
            tempIndex -= 1
            let beforeVid = Int(self.problems[tempIndex].pageCore?.vid ?? 0)
            if beforeVid != currentVid {
                self.changePage(at: tempIndex)
                break
            }
        }
    }
    
    func addScoring(pid: Int) {
        var scoringQueue = self.section.scoringQueue ?? []
        if scoringQueue.contains(pid) { return }
        
        scoringQueue.append(pid)
        self.section.setValue(scoringQueue, forKey: PracticeTestSection_Core.Attribute.scoringQueue.rawValue)
        self.addUploadProblem(pid: pid)
    }
    
    func addUploadProblem(pid: Int) {
        var uploadQueue = self.section.uploadProblemQueue ?? []
        if uploadQueue.contains(pid) { return }
        
        uploadQueue.append(pid)
        self.section.setValue(uploadQueue, forKey: PracticeTestSection_Core.Attribute.uploadProblemQueue.rawValue)
    }
    
    func addUploadPage(vid: Int) {
        var uploadQueue = self.section.uploadPageQueue ?? []
        if uploadQueue.contains(vid) { return }
        
        uploadQueue.append(vid)
        self.section.setValue(uploadQueue, forKey: PracticeTestSection_Core.Attribute.uploadPageQueue.rawValue)
    }
    
    func postProblemAndPageDatas(isDismiss: Bool) {
        let uploadProblemQueue = self.section.uploadProblemQueue ?? []
        let uploadPageQueue = self.section.uploadPageQueue ?? []
        if uploadProblemQueue.isEmpty && uploadPageQueue.isEmpty {
            if isDismiss {
                self.delegate?.dismissSection()
            }
            return
        }
        
        let taskGroup = DispatchGroup()
        
        if uploadProblemQueue.isEmpty == false {
            taskGroup.enter()
            let uploadProblems = self.problems
                .filter { uploadProblemQueue.contains(Int($0.pid)) }
                .map { SubmissionProblem(problem: $0) }
            self.postProblemDatas(uploadProblems: uploadProblems) {
                taskGroup.leave()
            }
        }
        
        if uploadPageQueue.isEmpty == false {
            taskGroup.enter()
            let uploadPages = Array(Set(self.problems.compactMap(\.pageCore)
                .filter { uploadPageQueue.contains(Int($0.vid)) }
                .map { SubmissionPage(page: $0) }))
            self.postPageDatas(uploadPages: uploadPages) {
                taskGroup.leave()
            }
        }
        
        taskGroup.notify(queue: .main) {
            // MARK: 아마도 section 나갈 때 최종 저장되는 부분
            CoreDataManager.saveCoreData()
            if isDismiss {
                self.delegate?.dismissSection()
            }
            return
        }
    }
}

// MARK: Private
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
            self.configureProblems()
            self.configureStartPage()
            self.updateRecentTime()
            
            if self.section.terminated { // 채점완료 상태인 경우
                self.terminatedUI()
            } else { // 진행중인 경우
                guard self.remainingTime > 0 else {
                    self.sectionTerminate()
                    return
                }
                self.startTimer() // 시험 계속 응시
            }
        }
    }
    /// 채점 완료 수신
    private func configureObservation() {
        NotificationCenter.default.addObserver(forName: .sectionTerminated, object: nil, queue: .current) { [weak self] _ in
            self?.sectionTerminate()
        }
    }
    
    private func configureStartPage() {
        let lastPageId = 0 // 0번 인덱스 표시 로직 (마지막 index 를 표시할 경우 수정 필요)
        self.changePage(at: lastPageId)
    }
    
    private func updateRecentTime() {
        self.recentTime = self.remainingTime
    }
    
    private func configureProblems() {
        guard let problems = self.section.problemCores?.sorted(by: { $0.orderIndex < $1.orderIndex }) else {
            print("error: fetch problems")
            return
        }
        self.problems = problems
    }
    
    private func startTimer() {
        guard self.section.terminated == false else { return }
        
        DispatchQueue.global().async {
            let runLoop = RunLoop.current
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.updateRecentTime()
                if let recentTime = self?.recentTime, recentTime <= 0 {
                    self?.sectionTerminate()
                }
            }
            while self.isRunning {
                runLoop.run(until: Date().addingTimeInterval(0.1))
            }
        }
    }
    
    /**
     - 응시 종료로직 (단 한번만 불리는 로직)
     - case 1: 진입시 응시 진행중에 시간이 지나고서 들어오는 경우
     - case 2: 응시 진행중에 시간이 다된 경우
     - case 3: 응시 진행중에 채점완료를 한 경우
     */
    private func sectionTerminate() {
        self.terminateProblems()
        self.terminatedUI()
        self.removeNotification()
        let terminatedDate = Date()
        self.section.terminateTest(terminatedDate: terminatedDate)
        self.workbookGroup.updateProgress()
        self.workbook.setTerminatedSection()
        CoreDataManager.saveCoreData()
    }
    
    private func terminateProblems() {
        // scoringQueue 모든 Problem -> terminate 처리
        self.problems.forEach { problem in
            problem.setValue(true, forKey: Problem_Core.Attribute.terminated.rawValue)
        }
        // scoringQueue = []
        self.section.setValue([], forKey: PracticeTestSection_Core.Attribute.scoringQueue.rawValue)
        CoreDataManager.saveCoreData()
        self.practiceTestTernimate = true
    }
    
    /**
     - 응시 종료 UI 표시 (여러번 불릴 수 있는 로직)
     - case 1: sectionTerminate 로 불리는 경우
     - case 2: 진입시 응시 종료 이후 다시 들어오는 경우
     */
    private func terminatedUI() {
        self.stopTimer()
        print("///////////// terminated!!!!!!!!!")
        // MARK: UI 수정 notification 필요 및 각 VC 에서 어떤식으로 분기처리를 할 것인지가 고민 포인트
        // MARK: network post 정보가 필요
        // MARK: binding 으로 완료 전파 필요
    }
    
    private func stopTimer() {
        if self.section.terminated { return }
        
        self.isRunning = false
        self.timer?.invalidate()
    }
    
    private func setNotificationAlert() {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "시험 종료 5분전 입니다."
        notificationContent.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(self.section.timelimit - 300), repeats: false)
        let request = UNNotificationRequest(identifier: PushNotification.practiceTest5min, content: notificationContent, trigger: trigger)
        self.userNotificationCenter.add(request) { error in
            if let error = error {
                print("Notification Error: \(error)")
            }
        }
    }
    
    private func removeNotification() {
        // 응시가 종료된 경우만 불린다
        self.userNotificationCenter.removeDeliveredNotifications(withIdentifiers: [PushNotification.practiceTest5min])
    }
}

// MARK: Network post
extension PracticeTestManager {
    private func postProblemDatas(uploadProblems: [SubmissionProblem], completion: @escaping (() -> Void)) {
        self.networkUsecase.postProblemSubmissions(problems: uploadProblems) { [weak self] status in
            if status == .SUCCESS {
                self?.section.setValue([], forKey: PracticeTestSection_Core.Attribute.uploadProblemQueue.rawValue)
            }
            completion()
        }
    }
    
    private func postPageDatas(uploadPages: [SubmissionPage], completion: @escaping (() -> Void)) {
        self.networkUsecase.postPageSubmissions(pages: uploadPages) { [weak self] status in
            if status == .SUCCESS {
                self?.section.setValue([], forKey: PracticeTestSection_Core.Attribute.uploadPageQueue.rawValue)
            }
            completion()
        }
    }
}
