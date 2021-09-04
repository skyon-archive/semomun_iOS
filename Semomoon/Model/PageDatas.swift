//
//  PagesNotification.swift
//  PagesNotification
//
//  Created by qwer on 2021/09/04.
//

import UIKit

class PageDatas {
    var pages: [Page]
    
    init() {
        pages = []
        //test를 위한 코드
        add(page: Page(type: .ontToFive, image: UIImage(named: "A-1")!))
        add(page: Page(type: .string, image: UIImage(named: "A-2")!))
        add(page: Page(type: .multiple, main: UIImage(named: "B-0")!))
        pages[2].addSubImage(image: UIImage(named: "B-1")!)
        pages[2].addSubImage(image: UIImage(named: "B-2")!)
        pages[2].addSubImage(image: UIImage(named: "B-3")!)
    }
    
    func add(page: Page) {
        pages.append(page)
    }
}

struct Page {
    enum PageType {
        case ontToFive
        case string
        case multiple
    }
    
    var type: PageType
    var mainImage: UIImage
    var subImages: [UIImage]?
    
    init(type: PageType, image: UIImage) {
        self.type = type
        self.mainImage = image
        subImages = nil
    }
    
    init(type: PageType, main: UIImage) {
        self.type = type
        self.mainImage = main
        subImages = []
    }
    
    mutating func addSubImage(image: UIImage) {
        subImages?.append(image)
    }
}
