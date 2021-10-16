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

    @NSManaged public var vid: Int64
    @NSManaged public var materialImage: Data?
    @NSManaged public var layoutType: Int64
    @NSManaged public var problems: NSObject?

}

extension Page_Core : Identifiable {

}

@objc(Page_Core)
public class Page_Core: NSManagedObject {
    func updateImage(data: Data?) {
        self.setValue(data, forKey: "materialImage")
    }
}
