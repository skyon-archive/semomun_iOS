//
//  SectionHeader_Core+CoreDataProperties.swift
//  Semomoon
//
//  Created by qwer on 2021/10/03.
//
//

import Foundation
import CoreData


extension SectionHeader_Core {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SectionHeader_Core> {
        return NSFetchRequest<SectionHeader_Core>(entityName: "SectionHeader_Core")
    }
    
    @NSManaged public var sid: Int64
    @NSManaged public var title: String?
    @NSManaged public var detail: String?
    @NSManaged public var image: Data?
    @NSManaged public var cutoff: String?

}

@objc(SectionHeader_Core)
public class SectionHeader_Core: NSManagedObject {
    public override var description: String{
        return "SectionHeader(\(self.sid), \(self.title))"
    }
    // functions to replace the custom initialization methods
    func setValues(section: SectionOfDB) {
        self.setValue(Int64(section.sid), forKey: "sid")
        self.setValue(section.title, forKey: "title")
        self.setValue(section.detail, forKey: "detail")
        // TODO: - image 데이터형식 맞추기
        self.setValue(section.image, forKey: "image")
        self.setValue(section.cutoff, forKey: "cutoff")
    }
}

extension SectionHeader_Core : Identifiable {
}
