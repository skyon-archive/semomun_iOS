//
//  Section.swift
//  Semomoon
//
//  Created by qwer on 2021/10/03.
//

import Foundation

struct SectionOfDB: Codable {
    let sid: Int
    let wid: Int
    let index: Int
    let title: String
    let detail: String?
    let image: String
    let cutoff: String?
}
