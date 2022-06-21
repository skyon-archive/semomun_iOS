//
//  PrivateTestResultInfoOfDB.swift
//  semomun
//
//  Created by Kang Minsang on 2022/06/20.
//

import Foundation

struct PrivateTestResultInfoOfDB: Decodable {
    let id: Int
    let wid: Int
    let wgid: Int
    let sid: Int
    let uid: Int
    
    let title: String // 회차 이름
    let subject: String // 과목명
    let area: String // 영역명
    
    let totalTime: Int
    let currentProblemCount: Int
    let totalProblemCount: Int
    
    let rank: Int // 등급
    let rawScore: Int // 원점수
    let perfectScore: Int // 만점 점수
    let deviation: Int // 표준 점수
    let percentile: Int // 백분위
    
    let createdDate: Date
    let updatedDate: Date
    
    enum CodingKeys: String, CodingKey {
        case id, wid, wgid, sid, uid, title, subject, area, totalTime,
             currentProblemCount, totalProblemCount, rank, rawScore, perfectScore, deviation, percentile
        case createdDate = "createdAt"
        case updatedDate = "updatedAt"
    }
}
