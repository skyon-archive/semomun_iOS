//
//  Section_Core+CoreDataProperties.swift
//  Semomoon
//
//  Created by Yoonho Shin on 2021/09/22.
//
//

import Foundation
import CoreData


extension Section_Core {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Section_Core> {
        return NSFetchRequest<Section_Core>(entityName: "Section_Core")
    }

    @NSManaged public var views: [View_core]
    @NSManaged public var sid: Int64

}

extension Section_Core : Identifiable {

}
