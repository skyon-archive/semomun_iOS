//
//  Query.swift
//  Semomoon
//
//  Created by qwer on 2021/09/22.
//

import Foundation

class Query {
    static let shared = Query()
    
    let buttonTitles: [String] = ["과목 선택", "학년 선택", "년도 선택", "월 선택"]
    let queryTitle: [String] = ["s", "g", "y", "m"]
    var popupButtons: [[String]] = []
    var queryOfItems: [[String]] = []
    let titlesOfSubject: [String] = ["국어", "수학", "영어", "과탐"]
    let itemsOfSubject: [String] = ["국어", "수학", "영어", "과탐"]
    
    
    let titlesOfGrade: [String] = ["1학년", "2학년", "3학년"]
    let itemsOfGrade: [String] = ["1", "2", "3"]
    
    let titlesOfYear: [String] = ["2021년"]
    let itemsOfYear: [String] = ["2021"]
    
    let titlesOfMonth: [String] = ["1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "수능", "12월"]
    let itemsOfMonth: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
    
    init() {
        self.popupButtons.append(titlesOfSubject)
        self.popupButtons.append(titlesOfGrade)
        self.popupButtons.append(titlesOfYear)
        self.popupButtons.append(titlesOfMonth)
        
        self.queryOfItems.append(itemsOfSubject)
        self.queryOfItems.append(itemsOfGrade)
        self.queryOfItems.append(itemsOfYear)
        self.queryOfItems.append(itemsOfMonth)
    }
}
