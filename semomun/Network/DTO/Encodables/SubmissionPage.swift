//
//  SubmissionPage.swift
//  semomun
//
//  Created by Kang Minsang on 2022/04/06.
//

import Foundation

struct SubmissionPage: Encodable {
    let vid: Int
    let attempt: Int
    let note: Data?
    
    init(page: Page_Core, attempt: Int = 1) {
        self.vid = Int(page.vid)
        self.attempt = attempt
        self.note = page.drawing
    }
}
