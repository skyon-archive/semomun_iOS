//
//  SectionHeader_Core.swift
//  semomun
//
//  Created by Kang Minsang on 2021/10/03.
//
//

import Foundation
import CoreData
import UIKit

extension SectionHeader_Core {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SectionHeader_Core> {
        return NSFetchRequest<SectionHeader_Core>(entityName: "SectionHeader_Core")
    }
    
    enum Attribute: String {
        case wid
        case sid
        case index
        case title
        case detail
        case size
        case audio
        case audioDetail
        case updatedAt
        case cutoff
        case downloaded
        case terminated
        case image
    }
    
    @NSManaged public var wid: Int64
    @NSManaged public var sid: Int64
    @NSManaged public var index: Int64 //NEW: section number 값
    @NSManaged public var title: String?
    @NSManaged public var detail: String?
    @NSManaged public var size: Int64 //NEW: section 파일크기
    @NSManaged public var audio: Data? //NEW: audio 파일
    @NSManaged public var audioDetail: String? //NEW: audio 파일의 timestemp 값
    @NSManaged public var updatedAt: Date? //NEW: 반영일자
    @NSManaged public var cutoff: String? // json 형식의 커트라인
    
    @NSManaged public var downloaded: Bool
    @NSManaged public var terminated: Bool
    @NSManaged public var image: Data?
}

@objc(SectionHeader_Core)
public class SectionHeader_Core: NSManagedObject {
    public override var description: String {
        return "SectionHeader(\(self.sid), \(optional: self.title), \(optional: self.image))"
    }
    
    func setValues(section: SectionOfDB) {
        self.setValue(Int64(section.wid), forKey: Attribute.wid.rawValue)
        self.setValue(Int64(section.sid), forKey: Attribute.sid.rawValue)
        self.setValue(Int64(section.index), forKey: Attribute.index.rawValue)
        self.setValue(section.title, forKey: Attribute.title.rawValue)
        self.setValue(section.detail, forKey: Attribute.detail.rawValue)
        self.setValue(nil, forKey: Attribute.cutoff.rawValue)
        self.setValue(Int64(section.size), forKey: Attribute.size.rawValue)
        self.setValue(nil, forKey: Attribute.audio.rawValue) // TODO: 추후 Data 형식으로 가져오는 로직이 필요
        self.setValue(nil, forKey: Attribute.audioDetail.rawValue) // TODO: 추후 반영될 값
        self.setValue(section.updatedAt, forKey: Attribute.updatedAt.rawValue)
        self.setValue(false, forKey: Attribute.downloaded.rawValue)
        self.setValue(false, forKey: Attribute.terminated.rawValue)
        self.setValue(nil, forKey: Attribute.image.rawValue)
        print("save Header complete")
    }
}

extension SectionHeader_Core : Identifiable {
}
