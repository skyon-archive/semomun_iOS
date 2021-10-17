//
//  Page_Core+CoreDataProperties.swift
//  Semomoon
//
//  Created by qwer on 2021/10/03.
//
//

import Foundation
import CoreData


extension Page_Core {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Page_Core> {
        return NSFetchRequest<Page_Core>(entityName: "Page_Core")
    }

    @NSManaged public var vid: Int64 //뷰어의 고유 번호
    @NSManaged public var materialImage: Data? //좌측 이미지
    @NSManaged public var layoutType: Int64 //뷰컨트롤러 타입
    @NSManaged public var problems: [Int] //Problem: pid 값들

}

extension Page_Core : Identifiable {

}

@objc(Page_Core)
public class Page_Core: NSManagedObject {
    func setValues(page: PageOfDB) {
        self.setValue(page.vid, forKey: "vid")
        self.setValue(nil, forKey: "materialImage")
        self.setValue(page.form, forKey: "layoutType") //수정될 부분
        let problems = page.problems.map { $0.pid }
        self.setValue(problems, forKey: "problems")
    }
    
    func updateMaterialImage(data: Data?) {
        self.setValue(data, forKey: "materialImage")
    }
}
