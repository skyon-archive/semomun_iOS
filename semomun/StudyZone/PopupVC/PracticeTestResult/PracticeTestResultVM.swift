//
//  PracticeTestResultVM.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/06/21.
//

import Foundation
import Combine

final class PracticeTestResultVM {
    /* public */
    @Published private(set) var practiceTestResult: PracticeTestResult?
    @Published private(set) var publicScoreResult: ScoreResult?
    /// 인터넷이 없는 상태의 UI를 보여야하는지 여부
    @Published private(set) var notConnectedToInternet: Bool?
    /* private */
    private let wgid: Int
    private let networkUsecase: (UserTestResultFetchable & UserTestResultSendable)
    /// 채점 결과의 POST가 완료되었음을 CoreData에 저장하는 함수
    private let checkTestResultPosted: () -> ()
    // CoreData값에서 그대로 가져오는 프로퍼티
    private let testResultPosted: Bool
    private let wid: Int
    private let sid: Int
    private let title: String
    private let subject: String
    private let cutoff: [Int]
    private let area: String
    private let deviation: Int
    private let averageScore: Int
    // CoreData값에서 따로 계산되어야하는 프로퍼티
    private let correctProblemCount: Int
    private let totalProblemCount: Int
    private let perfectScore: Double
    private let rawScore: Double
    private let totalTime: Int
    
    init(wgid: Int64, practiceTestSection: PracticeTestSection_Core, networkUsecase: (UserTestResultFetchable & UserTestResultSendable)) {
        self.wgid = Int(wgid)
        self.networkUsecase = networkUsecase
        self.checkTestResultPosted = { practiceTestSection.setValue(true, forKey: PracticeTestSection_Core.Attribute.testResultPosted.rawValue )}
        
        self.testResultPosted = practiceTestSection.testResultPosted
        self.wid = Int(practiceTestSection.wid)
        self.sid = Int(practiceTestSection.sid)
        self.title = practiceTestSection.title ?? ""
        self.subject = practiceTestSection.subject ?? ""
        if let cutoffData = practiceTestSection.cutoff,
           let decodedCutoff = try? JSONDecoder().decode([Cutoff].self, from: cutoffData) {
            self.cutoff = decodedCutoff.map(\.rawScore).sorted(by: >)
        } else {
            self.cutoff = [90, 80, 70, 60, 50, 40, 30, 20]
        }
        self.area = practiceTestSection.area ?? ""
        self.deviation = Int(practiceTestSection.deviation)
        self.averageScore = Int(practiceTestSection.averageScore)
        
        guard let problemCores = practiceTestSection.problemCores else {
            self.correctProblemCount = 0
            self.totalProblemCount = 0
            self.perfectScore = 100
            self.rawScore = 0
            self.totalTime = 0
            return
        }
        
        self.correctProblemCount = problemCores.filter(\.correct).count
        self.totalProblemCount = problemCores.count
        self.perfectScore = problemCores.reduce(0, { $0 + $1.point })
        self.rawScore = problemCores.reduce(0, { $0 + ($1.correct ? $1.point : 0) })
        self.totalTime = problemCores.reduce(0, { $0 + Int($1.time) })
    }
}

// MARK: Public
extension PracticeTestResultVM {
    func fetchResult() {
        self.listenNetworkState()
        NetworkStatusManager.state()
    }
}

// MARK: Private
extension PracticeTestResultVM {
    private func listenNetworkState() {
        NotificationCenter.default.addObserver(forName: NetworkStatusManager.Notifications.connected, object: nil, queue: .current) { [weak self] _ in
            self?.notConnectedToInternet = false
            self?.makeResult()
        }
        NotificationCenter.default.addObserver(forName: NetworkStatusManager.Notifications.disconnected, object: nil, queue: .current) { [weak self] _ in
            self?.notConnectedToInternet = true
        }
    }
    
    private func makeResult() {
        self.makePracticeTestResult()
        
        // 네트워크 유무를 우선 확인
        guard NetworkStatusManager.isConnectedToInternet() else {
            self.notConnectedToInternet = true
            return
        }
        
        self.networkUsecase.getPublicTestResult(wid: Int(self.wid)) { [weak self] _, publicTestResultOfDB in
            guard let publicTestResultOfDB = publicTestResultOfDB else {
                self?.notConnectedToInternet = true
                return
            }
            self?.publicScoreResult = .init(
                rank: publicTestResultOfDB.rank,
                rawScore: publicTestResultOfDB.rawScore,
                standardScore: publicTestResultOfDB.standardScore,
                percentile: publicTestResultOfDB.percentile,
                perfectScore: Int(self?.perfectScore ?? 0)
            )
        }
    }
    
    private func makePracticeTestResult() {
        let privateScoreResult: ScoreResult = TestResultCalculator.getScoreResult(
            rawScore: Int(self.rawScore),
            groupAverage: Int(self.averageScore),
            groupStandardDeviation: Int(self.deviation),
            area: self.area,
            rankCutoff: self.cutoff,
            perfectScore: Int(self.perfectScore)
        )
        
        let title = "\(self.title) \(self.subject) 성적표"
        let totalTimeFormattedString = self.formatDateString(fromSeconds: self.totalTime)
        
        self.practiceTestResult = .init(
            title: title,
            correctProblemCount: self.correctProblemCount,
            totalProblemCount: self.totalProblemCount,
            totalTimeFormattedString: totalTimeFormattedString,
            privateScoreResult: privateScoreResult
        )
        
        self.postTestResult()
    }
    
    private func formatDateString(fromSeconds second: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        return formatter.string(from: TimeInterval(second)) ?? "00:00:00"
    }
    
    private func postTestResult() {
        guard self.testResultPosted == false else {
            print("채점 결과 POST 되어있음")
            return
        }
        
        print("채점 결과 POST 시작")
        guard let scoreResult = self.practiceTestResult?.privateScoreResult else {
            return
        }
        
        let calculatedTestResult = CalculatedTestResult(
            wgid: self.wgid,
            wid: self.wid,
            sid: self.sid,
            rank: String(scoreResult.rank),
            rawScore: scoreResult.rawScore,
            perfectScore: Int(self.perfectScore),
            standardScore: scoreResult.standardScore,
            percentile: scoreResult.percentile,
            correctProblemCount: self.correctProblemCount,
            totalProblemCount: self.totalProblemCount,
            totalTime: self.totalTime,
            subject: self.subject
        )
        self.networkUsecase.sendUserTestResult(testResult: calculatedTestResult) { result in
            print("채점결과 POST: \(result)")
            guard result == .SUCCESS else { return }
            self.checkTestResultPosted()
        }
    }
}
