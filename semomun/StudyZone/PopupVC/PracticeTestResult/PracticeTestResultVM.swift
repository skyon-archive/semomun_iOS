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
    /// 단순 인터넷 연결이 없는 상태가 아닌 기타 다른 문제가 생긴 경우
    @Published private(set) var networkError: Bool?
    /// 인터넷이 없는 상태의 UI를 보여야하는지 여부
    @Published private(set) var notConnectedToInternet: Bool?
    /* private */
    private let wgid: Int64
    private let networkUsecase: (UserTestResultFetchable & UserTestResultSendable)
    private let checkTestResultPosted: () -> ()
    // CoreData값을 가져옴
    private let testResultPosted: Bool
    private let wid: Int64
    private let sid: Int64
    private let title: String
    private let subject: String
    private let cutoff: [Int]
    private let area: String
    private let deviation: Int64
    private let averageScore: Int64
    // CoreData값에서 계산함
    private let correctProblemCount: Int
    private let totalProblemCount: Int
    private let perfectScore: Double
    private let rawScore: Double
    private let totalTime: Int64
    
    init(wgid: Int64, practiceTestSection: PracticeTestSection_Core, networkUsecase: (UserTestResultFetchable & UserTestResultSendable)) {
        self.wgid = wgid
        self.networkUsecase = networkUsecase
        self.checkTestResultPosted = { practiceTestSection.setValue(true, forKey: PracticeTestSection_Core.Attribute.testResultPosted.rawValue )}
        
        self.testResultPosted = practiceTestSection.testResultPosted
        self.wid = practiceTestSection.wid
        self.sid = practiceTestSection.sid
        self.title = practiceTestSection.title ?? ""
        self.subject = practiceTestSection.subject ?? ""
        
        if let cutoffData = practiceTestSection.cutoff,
            let decodedCutoff = try? JSONDecoder().decode([Cutoff].self, from: cutoffData) {
            self.cutoff = decodedCutoff.map(\.rawScore).sorted(by: >)
        } else {
            self.cutoff = [90, 80, 70, 60, 50, 40, 30, 20]
        }
        
        self.area = practiceTestSection.area ?? ""
        self.deviation = practiceTestSection.deviation
        self.averageScore = practiceTestSection.averageScore
        
        self.correctProblemCount = practiceTestSection.problemCores?
            .filter { $0.correct }
            .count ?? 0
        self.totalProblemCount = practiceTestSection.problemCores?.count ?? 0
        self.perfectScore = practiceTestSection.problemCores?
            .reduce(0, { $0 + $1.point }) ?? 0
        self.rawScore = practiceTestSection.problemCores?
            .reduce(0, { $0 + ($1.correct ? $1.point : 0) }) ?? 0
        self.totalTime = practiceTestSection.problemCores?
            .reduce(0, { $0 + $1.time }) ?? 0
        
        self.listenNetworkState()
    }
}

// MARK: Public
extension PracticeTestResultVM {
    func fetchResult() {
        self.makePracticeTestResult()
        
        // 네트워크 유무를 우선 확인
        guard NetworkStatusManager.isConnectedToInternet() else {
            self.notConnectedToInternet = true
            return
        }
        
        // 위에서 네트워크 유무를 확인했기에 이곳에서의 실패는 기타 다른 문제
        self.networkUsecase.getPublicTestResult(wid: Int(self.wid)) { [weak self] _, publicTestResultOfDB in
            guard let publicTestResultOfDB = publicTestResultOfDB else {
                self?.networkError = true
                return
            }
            
            self?.publicScoreResult = .init(
                rank: publicTestResultOfDB.rank,
                rawScore: publicTestResultOfDB.rawScore,
                deviation: publicTestResultOfDB.deviation,
                percentile: publicTestResultOfDB.percentile,
                perfectScore: Int(self?.perfectScore ?? 0)
            )
        }
    }
}

// MARK: Private
extension PracticeTestResultVM {
    private func listenNetworkState() {
        NetworkStatusManager.state()
        
        NotificationCenter.default.addObserver(forName: NetworkStatusManager.Notifications.connected, object: nil, queue: .current) { [weak self] _ in
            self?.notConnectedToInternet = false
            // 인터넷 연결이 재개될 경우 다시 fetch
            self?.fetchResult()
        }
        NotificationCenter.default.addObserver(forName: NetworkStatusManager.Notifications.disconnected, object: nil, queue: .current) { [weak self] _ in
            self?.notConnectedToInternet = true
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

    private func formatDateString(fromSeconds second: Int64) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        return formatter.string(from: TimeInterval(second)) ?? "00:00:00"
    }
    
    private func postTestResult() {
        guard self.testResultPosted == false else { return }
        
        guard let scoreResult = self.practiceTestResult?.privateScoreResult else { return }
        let calculatedTestResult = CalculatedTestResult(
            wgid: Int(self.wgid), wid: Int(self.wid), sid: Int(self.sid),
            rank: String(scoreResult.rank), rawScore: scoreResult.rawScore,
            perfectScore: Int(self.perfectScore), deviation: Int(self.deviation), percentile: scoreResult.percentile,
            correctProblemCount: self.correctProblemCount, totalProblemCount: self.totalProblemCount,
            totalTime: Int(self.totalTime), subject: self.subject
        )
        
        self.networkUsecase.sendUserTestResult(testResult: calculatedTestResult) { result in
            guard result == .SUCCESS else {
                self.networkError = true
                return
            }
            self.checkTestResultPosted()
        }
    }
}
