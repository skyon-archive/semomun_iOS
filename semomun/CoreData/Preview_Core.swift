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
    
    enum Attribute: String {
        case productID
        case wid
        case title
        case detail
        case isbn
        case author
        case publisher
        case publishedDate
        case publishMan
        case originalPrice
        case updatedDate
        case sids
        case price
        case tags
        case fileSize
        case image
        case purchasedDate
        case recentDate
        case progressCount
        case wgid
        case cutoff
        case subject
        case area
        case standardDeviation
        case averageScore
        case downloaded
        case terminated
        case timelimit
    }
    
    @NSManaged public var productID: Int64 // NEW: 상품 식별자
    @NSManaged public var wid: Int64 // identifier
    @NSManaged public var title: String?
    @NSManaged public var detail: String? // 문제집 정보
    @NSManaged public var isbn: String? // ISBN값
    @NSManaged public var author: String? // 저자
    @NSManaged public var publisher: String? // 출판사 (publishCompany)
    @NSManaged public var publishedDate: Date? // 발행일
    @NSManaged public var publishMan: String? // 발행인
    @NSManaged public var originalPrice: Int64 // 정가
    @NSManaged public var updatedDate: Date? // 반영일자
    @NSManaged public var sids: [Int] // Sections id
    @NSManaged public var price: Double // 가격
    @NSManaged public var tags: [String]
    @NSManaged public var fileSize: Int64 // sections size 합산
    @NSManaged public var image: Data? // Workbook Image
    @NSManaged public var purchasedDate: Date? // 구매일자
    @NSManaged public var recentDate: Date? // 접근일
    @NSManaged public var progressCount: Int64 // 책장 진도율값
    @NSManaged public var downloaded: Bool // 부활: WorkbookGroup 내에서 사용
    @NSManaged public var terminated: Bool // 부활: WorkbookGroup 진도율 계산에서 사용
    /* practiceTest */
    @NSManaged public var wgid: Int64 // NEW: 상위 group 정보값
    @NSManaged public var cutoff: Data? // NEW: 등급컷
    @NSManaged public var subject: String? // 부활: 같은 명이나, 다른 역할로 부활
    @NSManaged public var area: String? // NEW: 영역
    @NSManaged public var standardDeviation: Int64 // NEW: 표준 편차
    @NSManaged public var averageScore: Int64 // NEW: 평균 점수
    @NSManaged public var timelimit: Int64 // NEW: 제한시간
    
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var category: String? //Deprecated(1.1.3)
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var year: String? //Deprecated(1.1.3)
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var month: String? //Deprecated(1.1.3)
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var grade: String? //Deprecated(1.1.3)
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var isHide: Bool //Deprecated(1.1.3)
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var isReproduction: Bool //Deprecated(1.1.3)
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var isNotFree: Bool //Deprecated(1.1.3)
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var maxCategory: String? //Deprecated(1.1.3)
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var largeLargeCategory: String? //Deprecated(1.1.3)
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var largeCategory: String? //Deprecated(1.1.3)
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var mediumCategory: String? //Deprecated(1.1.3)
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var smallCategory: String? //Deprecated(1.1.3)
    
}

@objc(Preview_Core)
public class Preview_Core: NSManagedObject{
    
    public override var description: String {
        return "Preview(\(self.wid), \(optional: self.image), \(optional: self.title), \(self.sids), wgid: \(self.wgid)"
    }
    
    func setValues(workbook: WorkbookOfDB, info: BookshelfInfo) {
        self.setValue(Int64(workbook.productID), forKey: Attribute.productID.rawValue)
        self.setValue(Int64(workbook.wid), forKey: Attribute.wid.rawValue)
        self.setValue(workbook.title, forKey: Attribute.title.rawValue)
        self.setValue(workbook.detail, forKey: Attribute.detail.rawValue)
        self.setValue(workbook.isbn, forKey: Attribute.isbn.rawValue)
        self.setValue(workbook.author, forKey: Attribute.author.rawValue)
        self.setValue(workbook.publishCompany, forKey: Attribute.publisher.rawValue)
        self.setValue(workbook.publishedDate, forKey: Attribute.publishedDate.rawValue)
        self.setValue(workbook.publishMan, forKey: Attribute.publishMan.rawValue)
        self.setValue(workbook.originalPrice, forKey: Attribute.originalPrice.rawValue)
        self.setValue(workbook.updatedDate, forKey: Attribute.updatedDate.rawValue)
        self.setValue(workbook.sections.map(\.sid), forKey: Attribute.sids.rawValue)
        self.setValue(Double(workbook.price), forKey: Attribute.price.rawValue)
        self.setValue(workbook.tags.map(\.name), forKey: Attribute.tags.rawValue)
        self.setValue(Int64(workbook.sections.reduce(0, { $0 + $1.fileSize })), forKey: Attribute.fileSize.rawValue)
        self.setValue(info.purchased, forKey: Attribute.purchasedDate.rawValue)
        self.setValue(info.recentDate, forKey: Attribute.recentDate.rawValue)
        self.setValue(max(0, self.progressCount), forKey: Attribute.progressCount.rawValue)
        /* PracticeTest 용 property 저장 */
        let wgid = workbook.wgid != nil ? Int64(workbook.wgid!) : nil
        let deviation = workbook.standardDeviation != nil ? Int64(workbook.standardDeviation!) : nil
        let averageScore = workbook.averageScore != nil ? Int64(workbook.averageScore!) : nil
        self.setValue(wgid, forKey: Attribute.wgid.rawValue)
        if let jsonData = try? JSONEncoder().encode(workbook.cutoff) {
            self.setValue(jsonData, forKey: Attribute.cutoff.rawValue)
        }
        self.setValue(workbook.subject, forKey: Attribute.subject.rawValue)
        self.setValue(workbook.area, forKey: Attribute.area.rawValue)
        self.setValue(deviation, forKey: Attribute.standardDeviation.rawValue)
        self.setValue(averageScore, forKey: Attribute.averageScore.rawValue)
        self.setValue(false, forKey: Attribute.downloaded.rawValue)
        self.setValue(false, forKey: Attribute.terminated.rawValue)
        self.setValue(workbook.timelimit, forKey: Attribute.timelimit.rawValue)
    }
    
    func fetchBookcover(uuid: UUID, networkUsecase: S3ImageFetchable?, completion: @escaping (() -> Void)) {
        networkUsecase?.getImageFromS3(uuid: uuid, type: .bookcover) { [weak self] status, data in
            guard status == .SUCCESS, let data = data else {
                print("Error: fetchBookcover")
                completion()
                return
            }
            self?.setValue(data, forKey: Attribute.image.rawValue)
            completion()
        }
    }
    
    func setDownloadedSection() {
        guard self.downloaded == false else {
            assertionFailure("Error: 중복 확인 필요")
            return
        }
        self.setValue(true, forKey: Attribute.downloaded.rawValue)
    }
    
    func setTerminatedSection() {
        guard self.terminated == false else {
            assertionFailure("Error: 중복 확인 필요")
            return
        }
        self.setValue(true, forKey: Attribute.terminated.rawValue)
    }
    
    func updateDate(info: BookshelfInfo, networkUsecase: UserLogSendable) {
        if self.purchasedDate == nil {
            self.setValue(info.purchased, forKey: Attribute.purchasedDate.rawValue)
        }
        
        if let recentDate = self.recentDate,
           let serverDate = info.recentDate,
           recentDate > serverDate {
            networkUsecase.sendWorkbookEnterLog(wid: info.wid, datetime: recentDate)
        } else {
            self.setValue(info.recentDate, forKey: Attribute.recentDate.rawValue)
        }
    }
    
    func updateProgress() {
        let count = min(Int(self.progressCount)+1, self.sids.count)
        self.setValue(count, forKey: Attribute.progressCount.rawValue)
    }
}
