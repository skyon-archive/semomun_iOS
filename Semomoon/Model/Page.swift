//
//  View.swift
//  View
//
//  Created by qwer on 2021/09/05.
//

import Foundation



//ViewController 는 이 클래스 하나만 지니면 되는 형태

class View_Real {
    enum ViewType {
        case notProblem
        case oneToFive
        case string
    }
    
    var view: PageOfDB
    var url: URL
    var imageData: Data
    var problems: [Problem_Real]
    var type: ViewType
    
    init(view: PageOfDB) {
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
