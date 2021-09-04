//
//  PagesNotification.swift
//  PagesNotification
//
//  Created by qwer on 2021/09/04.
//

import UIKit

class PageDatas {
    var pages: [Page]
    var count: Int {
        return pages.count
    }
    
    init() {
        pages = []
        //test를 위한 코드
//        add(page: Page(type: .ontToFive, image: UIImage(named: "A-1")!))
//        add(page: Page(type: .string, image: UIImage(named: "A-2")!))
//        add(page: Page(type: .multiple, main: UIImage(named: "B-0")!))
//        pages[2].addSubImage(image: UIImage(named: "B-1")!)
//        pages[2].addSubImage(image: UIImage(named: "B-2")!)
//        pages[2].addSubImage(image: UIImage(named: "B-3")!)
        var page1 = Page(type: .multiple, main: UIImage(named: "국어-1-0")!)
        page1.addSubImage(image: UIImage(named: "국어-1-1")!)
        page1.addSubImage(image: UIImage(named: "국어-1-2")!)
        page1.addSubImage(image: UIImage(named: "국어-1-3")!)
        page1.addSubImage(image: UIImage(named: "국어-1-4")!)
        
        var page2 = Page(type: .multiple, main: UIImage(named: "국어-2-0")!)
        page2.addSubImage(image: UIImage(named: "국어-2-1")!)
        page2.addSubImage(image: UIImage(named: "국어-2-2")!)
        page2.addSubImage(image: UIImage(named: "국어-2-3")!)
        page2.addSubImage(image: UIImage(named: "국어-2-4")!)
        
        let page3 = Page(type: .ontToFive, image: UIImage(named: "A-1")!)
        let page4 = Page(type: .ontToFive, image: UIImage(named: "A-2")!)
        
        add(page: page1)
        add(page: page2)
        add(page: page3)
        add(page: page4)
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
