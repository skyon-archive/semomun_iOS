//
//  Page_Core+CoreDataProperties.swift
//  semomun
//
//  Created by Kang Minsang on 2022/02/19.
//
//

import Foundation
import CoreData


extension Page_Core {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Page_Core> {
        return NSFetchRequest<Page_Core>(entityName: "Page_Core")
    }

    @NSManaged public var drawing: Data?
    @NSManaged public var layoutType: String?
    @NSManaged public var materialImage: Data?
    @NSManaged public var problems: NSObject?
    @NSManaged public var time: Int64
    @NSManaged public var vid: Int64
    @NSManaged public var problemMOs: NSOrderedSet?

}

// MARK: Generated accessors for problemMOs
extension Page_Core {

    @objc(insertObject:inProblemMOsAtIndex:)
    @NSManaged public func insertIntoProblemMOs(_ value: Problem_Core, at idx: Int)

    @objc(removeObjectFromProblemMOsAtIndex:)
    @NSManaged public func removeFromProblemMOs(at idx: Int)

    @objc(insertProblemMOs:atIndexes:)
    @NSManaged public func insertIntoProblemMOs(_ values: [Problem_Core], at indexes: NSIndexSet)

    @objc(removeProblemMOsAtIndexes:)
    @NSManaged public func removeFromProblemMOs(at indexes: NSIndexSet)

    @objc(replaceObjectInProblemMOsAtIndex:withObject:)
    @NSManaged public func replaceProblemMOs(at idx: Int, with value: Problem_Core)

    @objc(replaceProblemMOsAtIndexes:withProblemMOs:)
    @NSManaged public func replaceProblemMOs(at indexes: NSIndexSet, with values: [Problem_Core])

    @objc(addProblemMOsObject:)
    @NSManaged public func addToProblemMOs(_ value: Problem_Core)

    @objc(removeProblemMOsObject:)
    @NSManaged public func removeFromProblemMOs(_ value: Problem_Core)

    @objc(addProblemMOs:)
    @NSManaged public func addToProblemMOs(_ values: NSOrderedSet)

    @objc(removeProblemMOs:)
    @NSManaged public func removeFromProblemMOs(_ values: NSOrderedSet)

}

extension Page_Core : Identifiable {

}
