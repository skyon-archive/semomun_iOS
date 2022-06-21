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
    @Published private(set) var practiceTestResult: PracticeTestResult? = nil
    @Published private(set) var alert: (title: String, message: String)? = nil
    /// 인터넷이 없는 상태의 UI를 보여야하는지 여부
    @Published private(set) var notConnectedToInternet: Bool? = nil
    /* private */
    private let networkUsecase: UserTestResultFetchable
    private let wid: Int
    
    init(wid: Int, networkUsecase: UserTestResultFetchable) {
        self.networkUsecase = networkUsecase
        self.wid = wid
    }
}

extension PracticeTestResultVM {
    func fetchResult() {
        guard NetworkStatusManager.isConnectedToInternet() else {
            self.notConnectedToInternet = true
            return
        }
        
        self.networkUsecase.getPrivateTestResult(wid: self.wid) { [weak self] privateStatus, privateTestResultOfDB in
            guard let wid = self?.wid else { return }
            
            self?.networkUsecase.getPublicTestResult(wid: wid) { [weak self] publicStatus, publicTestResultOfDB in
                
                guard let privateTestResultOfDB = privateTestResultOfDB,
                      let publicTestResultOfDB = publicTestResultOfDB else {
                    // 단순 인터넷 연결이 없는 상태가 아닌 기타 다른 문제가 생긴 경우
                    self?.alert = ("네트워크 에러", "네트워크 연결을 확인 후 다시 시도하세요")
                    return
                }
                
                self?.practiceTestResult = self?.makeModel(privateTestResultOfDB: privateTestResultOfDB, publicTestResultOfDB: publicTestResultOfDB)
            }
        }
    }
}

extension PracticeTestResultVM {
    private func makeModel(privateTestResultOfDB: PrivateTestResultOfDB, publicTestResultOfDB: PublicTestResultOfDB) -> PracticeTestResult {
        let title = self.formatTitle(fromWorkbookName: privateTestResultOfDB.title, subjectName: privateTestResultOfDB.subject)
        
        let correctProblemCount = privateTestResultOfDB.correctProblemCount
        let totalProblemCount = privateTestResultOfDB.totalProblemCount
        
        let perfectScore = privateTestResultOfDB.perfectScore
        let privateScoreResult: ScoreResult = .init(
            rank: privateTestResultOfDB.rank,
            rawScore: privateTestResultOfDB.rawScore,
            deviation: privateTestResultOfDB.deviation,
            percentile: privateTestResultOfDB.percentile,
            perfectScore: perfectScore
        )
        let publicScoreResult: ScoreResult = .init(
            rank: publicTestResultOfDB.rank,
            rawScore: publicTestResultOfDB.rawScore,
            deviation: publicTestResultOfDB.deviation,
            percentile: publicTestResultOfDB.percentile,
            perfectScore: perfectScore
        )
        
        let totalTimeFormattedString = self.formatDateString(fromSeconds: privateTestResultOfDB.totalTime)
        
        return .init(
            title: title,
            correctProblemCount: correctProblemCount,
            totalProblemCount: totalProblemCount,
            totalTimeFormattedString: totalTimeFormattedString,
            privateScoreResult: privateScoreResult,
            publicScoreResult: publicScoreResult
        )
    }
    
    private func formatTitle(fromWorkbookName workbookName: String, subjectName: String) -> String {
        return "\(workbookName) \(subjectName) 성적표"
    }
    
    private func formatDateString(fromSeconds second: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        return formatter.string(from: TimeInterval(second)) ?? "00-00-00"
    }
}
