//
//  Preview_Core+CoreDataProperties.swift
//  Preview_Core
//
//  Created by qwer on 2021/09/15.
//
//

import Foundation
import CoreData


extension Preview_Core {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Preview_Core> {
        return NSFetchRequest<Preview_Core>(entityName: "Preview_Core")
    }
    
    @NSManaged public var wid: Int64
    @NSManaged public var image: Data?
    @NSManaged public var title: String?
}
