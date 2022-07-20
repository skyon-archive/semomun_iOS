//
//  TestResultCalculator.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/06/22.
//

import Foundation

struct TestResultCalculator {
    let rank: Int
    /// 평균과 폭이 조절된, 수능 시험지에서 사용하는 표준점수
    let standardScore: Double
    /// 백분위
    let percentile: Double
    
    /// - Parameters:
    ///   - rawScore: 유저의 원점수
    ///   - groupAverage: 수험생이 속한 집단의 전체 평균 (문제집사에서 전달받은 값)
    ///   - groupStandardDeviation: 수험생이 속한 집단의 표준 편차 (문제집사에서 전달받은 값)
    ///   - area: 영역 이름
    ///   - rankCutoff: 1등급부터의 등급컷을 표현하는 길이 8의 배열. 9등급의 등급컷은 의미 없기 때문.
    init(rawScore: Int, groupAverage: Int, groupStandardDeviation: Int, area: String, rankCutoff: [Int]) {
        self.rank = (rankCutoff.firstIndex(where: { rawScore >= $0 }) ?? 8) + 1
        
        guard groupStandardDeviation > 0 else {
            self.standardScore = 0
            self.percentile = 0
            return
        }
        
        // 평균이 0인 표준점수
        let zeroAverageDeviation = Double(rawScore - groupAverage) / Double(groupStandardDeviation)
        self.standardScore = Self.standardDeviation(of: area) * zeroAverageDeviation + Self.average(of: area)
        self.percentile = Self.normalDistribution(x: zeroAverageDeviation) * 100
    }
}

// MARK: Private
extension TestResultCalculator {
    private static func standardDeviation(of area: String) -> Double {
        if ["한국사", "과학", "사회", "직업", "외국", "한문"].firstIndex(where: { area.contains($0 )}) == nil {
            return 10
        } else {
            return 20
        }
    }
    
    private static func average(of area: String) -> Double {
        if ["한국사", "과학", "사회", "직업", "외국", "한문"].firstIndex(where: { area.contains($0 )}) == nil {
            return 50
        } else {
            return 100
        }
    }
    
    private static func normalDistribution(x: Double) -> Double {
        return 0.5 * erfc(-x * 0.5.squareRoot())
    }
}
