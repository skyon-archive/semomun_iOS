//
//  PublicTestResultOfDB.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/06/21.
//

import Foundation

struct PublicTestResultOfDB: Decodable {
    let id: Int
    let wid: Int
    let wgid: Int
    let sid: Int
    
    let rank: String // 등급
    let rawScore: Int // 원점수
    let standardScore: Int // 표준 점수
    let percentile: Int // 백분위
    
    let createdDate: Date
    let updatedDate: Date
    
    enum CodingKeys: String, CodingKey {
        case id, wid, wgid, sid, rank, rawScore, standardScore, percentile
        case createdDate = "createdAt"
        case updatedDate = "updatedAt"
    }
}
