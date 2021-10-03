//
//  Section_Core+CoreDataProperties.swift
//  Semomoon
//
//  Created by qwer on 2021/10/03.
//
//

import Foundation
import CoreData


extension Section_Core {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Section_Core> {
        return NSFetchRequest<Section_Core>(entityName: "Section_Core")
    }

    @NSManaged public var sid: Int64
    @NSManaged public var title: String?
    @NSManaged public var buttons: NSObject?
    @NSManaged public var dictionaryOfProblem: Data?
    @NSManaged public var stars: NSObject?

}

extension Section_Core : Identifiable {

}

@objc(Section_Core)
public class Section_Core: NSManagedObject {

}
