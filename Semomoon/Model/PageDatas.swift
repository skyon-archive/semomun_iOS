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
        var page1 = Page(type: .multiple, main: UIImage(named: "test_1_0")!)
//        buf = /tmp/problems/content.png //byte array
//        fs::write(buf, "문제이미지");
        page1.addSubImage(image: UIImage(named: "test_1_1")!)
        page1.addSubImage(image: UIImage(named: "test_1_2")!)
        page1.addSubImage(image: UIImage(named: "test_1_3")!)
        page1.addSubImage(image: UIImage(named: "test_1_4")!)
        
        var page2 = Page(type: .multiple, main: UIImage(named: "test_2_0")!)
        page2.addSubImage(image: UIImage(named: "test_2_1")!)
        page2.addSubImage(image: UIImage(named: "test_2_2")!)
        page2.addSubImage(image: UIImage(named: "test_2_3")!)
        page2.addSubImage(image: UIImage(named: "test_2_4")!)
        
        var page3 = Page(type: .multiple, main: UIImage(named: "test_3_0")!)
        page3.addSubImage(image: UIImage(named: "test_3_1")!)
        page3.addSubImage(image: UIImage(named: "test_3_2")!)
        page3.addSubImage(image: UIImage(named: "test_3_3")!)
        page3.addSubImage(image: UIImage(named: "test_3_4")!)
        page3.addSubImage(image: UIImage(named: "test_3_5")!)
        
        var page4 = Page(type: .multiple, main: UIImage(named: "test_4_0")!)
        page4.addSubImage(image: UIImage(named: "test_4_1")!)
        page4.addSubImage(image: UIImage(named: "test_4_2")!)
        page4.addSubImage(image: UIImage(named: "test_4_3")!)
        page4.addSubImage(image: UIImage(named: "test_4_4")!)
        page4.addSubImage(image: UIImage(named: "test_4_5")!)
        
        let page_test1 = Page(type: .ontToFive, image: UIImage(named: "A-1")!)
        let page_test2 = Page(type: .string, image: UIImage(named: "A-2")!)
        
        add(page: page1)
        add(page: page2)
        add(page: page3)
        add(page: page4)
        add(page: page_test1)
        add(page: page_test2)
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
