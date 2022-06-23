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
    private let networkUsecase: UserTestResultFetchable
    private let wid: Int
    
    init(wid: Int, networkUsecase: UserTestResultFetchable) {
        self.networkUsecase = networkUsecase
        self.wid = wid
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
        self.networkUsecase.getPublicTestResult(wid: wid) { [weak self] _, publicTestResultOfDB in
            
            guard let publicTestResultOfDB = publicTestResultOfDB else {
                self?.networkError = true
                return
            }
            
            // CoreData에서 가져오는 임시 코드
            let perfectScore = 100
            
            self?.publicScoreResult = .init(
                rank: publicTestResultOfDB.rank,
                rawScore: publicTestResultOfDB.rawScore,
                deviation: publicTestResultOfDB.deviation,
                percentile: publicTestResultOfDB.percentile,
                perfectScore: perfectScore
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
        // CoreData에서 workbook 가져오는 부분 생략된 임시 로직
        let workbookTitle = "임시 workbook"
        let cutoff = [90, 80, 70, 60, 50, 40, 30, 20]
        let subject = "미적분"
        let area = "수학 영역"
        let deviation = 30
        let averageScore = 44
        // 여기 아래는 CoreData를 바탕으로 따로 계산이 필요할 것 같은 변수들
        let correctProblemCount = 41
        let totalProblemCount = 45
        let perfectScore = 100
        let rawScore = 40
        let totalTime = 123456
        
        let title = self.formatTitle(fromWorkbookName: workbookTitle, subjectName: subject)
        let privateScoreResult: ScoreResult = TestResultCalculator.getScoreResult(
            rawScore: rawScore,
            groupAverage: averageScore,
            groupStandardDeviation: deviation,
            area: area,
            rankCutoff: cutoff,
            perfectScore: perfectScore
        )
        
        let totalTimeFormattedString = self.formatDateString(fromSeconds: totalTime)
        
        self.practiceTestResult = .init(
            title: title,
            correctProblemCount: correctProblemCount,
            totalProblemCount: totalProblemCount,
            totalTimeFormattedString: totalTimeFormattedString,
            privateScoreResult: privateScoreResult
        )
    }
    
    private func formatTitle(fromWorkbookName workbookName: String, subjectName: String) -> String {
        return "\(workbookName) \(subjectName) 성적표"
    }
    
    private func formatDateString(fromSeconds second: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        return formatter.string(from: TimeInterval(second)) ?? "00:00:00"
    }
}
