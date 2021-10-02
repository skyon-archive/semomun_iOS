//
//  View.swift
//  View
//
//  Created by qwer on 2021/09/05.
//

import Foundation

struct ViewOfDB: Codable, CustomStringConvertible {
    var description: String {
        return "View[\(vid), \(!(material?.isEmpty ?? true)), \(problems)]"
    }
    
    let vid: Int //뷰어의 고유 번호
    let index_start: Int //뷰어에 포함될 문제의 시작 인덱스
    let index_end: Int //뷰어에 포함될 문제의 끝 인덱스
    let material: String? //뷰어의 자료로 쓰일 이미지 정보
    let form: Int //0: 세로선 기준, 1: 가로선 기준 구분형태
    let problems: [ProblemOfDB]
}

//ViewController 는 이 클래스 하나만 지니면 되는 형태

class View_Real {
    enum ViewType {
        case notProblem
        case oneToFive
        case string
    }
    
    var view: ViewOfDB
    var url: URL
    var imageData: Data
    var problems: [Problem_Real]
    var type: ViewType
    
    init(view: ViewOfDB) {
        self.view = view
        self.url = URL(string: "http://semomoonDB/tmp/section/\(view.material).png")!
        self.imageData = Data()
//        loadImage()
        self.problems = []
        self.type = .notProblem
    }
    
    func loadImage() {
        do {
            try self.imageData = Data(contentsOf: url)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    var count: Int {
        return problems.count
    }
    
    func addProblem(_ problem: Problem_Real) {
        problems.append(problem)
    }
}
