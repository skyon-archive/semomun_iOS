//
//  Problem.swift
//  Problem
//
//  Created by qwer on 2021/09/05.
//

import Foundation
import UIKit

struct Problem: Codable {
    var pid: Int
    var vid: Int
    var sid: Int
    var icon_index: Int
    var icon_name: String
    var type: Int
    var answer: String
    var content: Int
    var explanation: Int?
    var attempt_total: Int
    var attempt_corrent: Int
    var rate: Int
    var elapsed_total: Int
    var note: String
}

class Problem_Real {
    var pid: Int
    var vid: Int
    var sid: Int
    var icon_index: Int
    var icon_name: String
    var type: Int
    var answer: String
    var content: Int
    var explanation: Int?
    var attempt_total: Int
    var attempt_corrent: Int
    var rate: Int
    var elapsed_total: Int
    var note: String
    
    var realImage: UIImage
    
    func getRealImage(content: Int) {
//        buf = /tmp/problems/content.png //byte array
//        fs::write(buf, "문제이미지");
//        let url = URL
    }
}
