//
//  Preview_Core.swift
//  semomun
//
//  Created by Kang Minsang on 2021/09/15.
//
//

import Foundation
import CoreData
import UIKit

extension Preview_Core {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Preview_Core> {
        return NSFetchRequest<Preview_Core>(entityName: "Preview_Core")
    }
    
    @NSManaged public var wid: Int64 // Workbook id
    @NSManaged public var image: Data? // Workbook Image
    @NSManaged public var title: String? // Workbook title
    @NSManaged public var subject: String? // Category 의 상단 분류값
    @NSManaged public var sids: [Int] // Sections id
    @NSManaged public var terminated: Bool // 제출된 Workbook
    @NSManaged public var category: String? // Workbook 의 category
    @NSManaged public var downloaded: Bool // 다운완료여부
    
    @NSManaged public var year: String? // 출판연도
    @NSManaged public var month: String? // 출판달
    @NSManaged public var price: Double // 가격
    @NSManaged public var detail: String? // 문제집 정보
    @NSManaged public var publisher: String? // 출판사
    @NSManaged public var grade: String? // 학년
    
    @NSManaged public var isHide: Bool // 숨김 여부
    @NSManaged public var isReproduction: Bool // 복제 여부
    @NSManaged public var isNotFree: Bool // 유료 여부
    
    @NSManaged public var maxCategory: String? // 대대대분류
    @NSManaged public var largeLargeCategory: String? // 대대분류
    @NSManaged public var largeCategory: String? // 대분류
    @NSManaged public var mediumCategory: String? // 중분류
    @NSManaged public var smallCategory: String? // 중분류
    @NSManaged public var tags: [String]? // 중분류
}

@objc(Preview_Core)
public class Preview_Core: NSManagedObject{
    
    public override var description: String {
        return "Preview(\(self.wid), \(self.image!), \(self.title!), \(self.subject!), \(self.sids), \(self.terminated), \(self.category!), \(self.downloaded)\n"
    }
    
    func setValues(preview: PreviewOfDB, workbook: WorkbookOfDB, sids: [Int], baseURL: String, category: String) {
        self.setValue(Int64(preview.wid), forKey: "wid")
        self.setValue(preview.title, forKey: "title")
        self.setValue(workbook.subject, forKey: "subject")
        self.setValue(sids, forKey: "sids")
        self.setValue(false, forKey: "terminated")
        self.setValue(false, forKey: "downloaded")
        self.setValue(category, forKey: "category")
        self.setValue(workbook.year, forKey: "year")
        self.setValue(workbook.month, forKey: "month")
        self.setValue(Double(workbook.price), forKey: "price")
        self.setValue(workbook.detail, forKey: "detail")
        self.setValue(workbook.publisher, forKey: "publisher")
        self.setValue(workbook.grade, forKey: "grade")
        
        self.setValue(false, forKey: "isHide") // default
        self.setValue(false, forKey: "isReproduction") // default
        let isNotFree = Double(workbook.price) != Double("0")
        self.setValue(isNotFree, forKey: "isNotFree") // default
        
        if let url = URL(string: baseURL + preview.bookcover) {
            let imageData = try? Data(contentsOf: url)
            if imageData != nil {
                self.setValue(imageData, forKey: "image")
            } else {
                self.setValue(UIImage(named: SemomunImage.warning)!.pngData(), forKey: "image")
            }
        } else {
            self.setValue(UIImage(named: SemomunImage.warning)!.pngData(), forKey: "image")
        }
        print("savePreview complete")
    }
}
