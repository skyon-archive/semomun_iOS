//
//  PublicTestResultInfoOfDB.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/06/21.
//

import Foundation

struct PublicTestResultInfoOfDB: Decodable {
    let id: Int
    let wid: Int
    let wgid: Int
    let sid: Int
    
    let rank: Int // 등급
    let rawScore: Int // 원점수
    let deviation: Int // 표준 점수
    let percentile: Int // 백분위
    
    let createdDate: Date
    let updatedDate: Date
    
    enum CodingKeys: String, CodingKey {
        case id, wid, wgid, sid, rank, rawScore, deviation, percentile
        case createdDate = "createdAt"
        case updatedDate = "updatedAt"
    }
}
