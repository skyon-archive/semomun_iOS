//
//  SectionManager.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import CoreData
import Combine

protocol LayoutDelegate: AnyObject {
    func reloadButtons()
    func showAlert(text: String)
    func dismissSection()
    func changeResultLabel()
}

final class SectionManager {
    @Published private(set) var sectionTitle: String = "title"
    @Published private(set) var currentTime: Int64 = 0
    @Published private(set) var currentPage: PageData?
    private(set) var problems: [Problem_Core] = []
    private(set) var section: Section_Core
    private(set) var currentIndex: Int = 0
    private weak var delegate: LayoutDelegate?
    private let sectionHeader: SectionHeader_Core
    private let preview: Preview_Core
    private var timer: Timer!
    private var isRunning: Bool = true
    private let networkUsecase: UserSubmissionSendable
    
    init(delegate: LayoutDelegate, section: Section_Core, sectionHeader: SectionHeader_Core, preview: Preview_Core, networkUsecase: UserSubmissionSendable) {
        self.delegate = delegate
        self.section = section
        self.sectionHeader = sectionHeader
        self.preview = preview
        self.networkUsecase = networkUsecase
        self.configure()
        self.configureStartPage()
        self.startTimer()
        self.configureObservation()
    }
    
    private func configure() {
        self.sectionTitle = self.section.title ?? "title"
        self.currentTime = self.section.time
        guard let problems = self.section.problemCores?.sorted(by: { $0.orderIndex < $1.orderIndex }) else {
            print("error: fetch problems")
            return
        }
        self.problems = problems
        
        if self.section.terminated {
            self.delegate?.changeResultLabel()
        }
    }
    
    private func configureStartPage() {
        let lastPageId = Int(self.section.lastPageId) // TODO: lastIndex로 수정 예정
        let lastIndex = lastPageId < self.problems.count ? lastPageId : 0 // TODO: lastIndex 기준 임시로직, 사라질 예정
        self.changePage(at: lastIndex)
    }
    
    func changePage(at index: Int) {
        guard let page = self.problems[index].pageCore else { return }
        self.currentIndex = index
        
        if self.currentPage?.vid == Int(page.vid) {
            self.delegate?.reloadButtons()
            return
        }
        
        let pageData = PageData(page: page)
        self.currentPage = pageData
        self.section.setValue(index, forKey: "lastPageId") // TODO: lastIndex로 수정 예정
    }
    
    func title(at index: Int) -> String {
        return self.problems[index].pName ?? "-"
    }
    
    func isStar(at index: Int) -> Bool {
        return self.problems[index].star
    }
    
    func isTerminated(at index: Int) -> Bool {
        return self.problems[index].terminated
    }
    
    func isWrong(at index: Int) -> Bool {
        let problem = self.problems[index]
        return problem.correct == false && problem.terminated
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
    
    func changeBeforePage() {
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
        self.section.setValue(scoringQueue, forKey: Section_Core.Attribute.scoringQueue.rawValue)
        self.addUploadProblem(pid: pid)
    }
    
    func addUploadProblem(pid: Int) {
        var uploadQueue = self.section.uploadProblemQueue ?? []
        if uploadQueue.contains(pid) { return }
        
        uploadQueue.append(pid)
        self.section.setValue(uploadQueue, forKey: Section_Core.Attribute.uploadProblemQueue.rawValue)
    }
    
    func addUploadPage(vid: Int) {
        var uploadQueue = self.section.uploadPageQueue ?? []
        if uploadQueue.contains(vid) { return }
        
        uploadQueue.append(vid)
        self.section.setValue(uploadQueue, forKey: Section_Core.Attribute.uploadPageQueue.rawValue)
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
                
                if self.currentTime%10 == 0 {
                    CoreDataManager.saveCoreData() // 10초 간격으로 저장
                }
            }
            while self.isRunning {
                runLoop.run(until: Date().addingTimeInterval(0.1))
            }
        }
    }
    
    private func configureObservation() {
        NotificationCenter.default.addObserver(forName: .sectionTerminated, object: nil, queue: .current) { [weak self] _ in
            self?.stopTimer()
            self?.section.setValue(true, forKey: "terminated")
            self?.sectionHeader.setValue(true, forKey: SectionHeader_Core.Attribute.terminated.rawValue)
            
            self?.preview.updateProgress()
            CoreDataManager.saveCoreData() // section 풀이 종료시 저장
            self?.delegate?.changeResultLabel()
        }
    }
    
    func pauseSection() {
        self.stopTimer()
        CoreDataManager.saveCoreData() // 뒤로나갈시 저장
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
    
    func postProblemAndPageDatas(isDismiss: Bool) {
        let uploadProblemQueue = self.section.uploadProblemQueue ?? []
        let uploadPageQueue = self.section.uploadPageQueue ?? []
        var completeCount: Int = [uploadProblemQueue.isEmpty == false, uploadPageQueue.isEmpty == false].filter { $0 }.count
        if completeCount == 0 {
            if isDismiss {
                self.delegate?.dismissSection()
            }
            return
        }
        
        if uploadProblemQueue.isEmpty == false {
            let uploadProblems = self.problems
                .filter { uploadProblemQueue.contains(Int($0.pid)) }
                .map { SubmissionProblem(problem: $0) }
            self.postProblemDatas(uploadProblems: uploadProblems) { [weak self] in
                completeCount -= 1
                if completeCount == 0 {
                    if isDismiss {
                        self?.delegate?.dismissSection()
                    }
                    return
                }
            }
        }
        
        if uploadPageQueue.isEmpty == false {
            let uploadPages = Array(Set(self.problems.compactMap(\.pageCore)
                .filter { uploadPageQueue.contains(Int($0.vid)) }
                .map { SubmissionPage(page: $0) }))
            self.postPageDatas(uploadPages: uploadPages) { [weak self] in
                completeCount -= 1
                if completeCount == 0 {
                    if isDismiss {
                        self?.delegate?.dismissSection()
                    }
                    return
                }
            }
        }
    }
    
    private func postProblemDatas(uploadProblems: [SubmissionProblem], completion: @escaping (() -> Void)) {
        self.networkUsecase.postProblemSubmissions(problems: uploadProblems) { [weak self] status in
            if status == .SUCCESS {
                self?.section.setValue([], forKey: Section_Core.Attribute.uploadProblemQueue.rawValue)
                CoreDataManager.saveCoreData()
            }
            completion()
        }
    }
    
    private func postPageDatas(uploadPages: [SubmissionPage], completion: @escaping (() -> Void)) {
        self.networkUsecase.postPageSubmissions(pages: uploadPages) { [weak self] status in
            if status == .SUCCESS {
                self?.section.setValue([], forKey: Section_Core.Attribute.uploadPageQueue.rawValue)
                CoreDataManager.saveCoreData()
            }
            completion()
        }
    }
}
