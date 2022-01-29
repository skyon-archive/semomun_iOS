//
//  Purchase.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/26.
//

import Foundation


/// - Note: [Codable로 Date 바로 변환하기.](https://useyourloaf.com/blog/swift-codable-with-custom-dates/)
struct Purchase: Codable {
    let wid: String
    let date: Date
    let cost: Double // 가격이 중간에 변동될 수도 있을듯
}
