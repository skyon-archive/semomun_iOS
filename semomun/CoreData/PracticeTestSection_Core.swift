//
//  PracticeTestSection_Core+CoreDataProperties.swift
//  semomun
//
//  Created by Kang Minsang on 2022/06/23.
//
//

import Foundation
import CoreData


@objc(PracticeTestSection_Core)
public class PracticeTestSection_Core: NSManagedObject {
    public override var description: String{
        return "PracticeTestSection(\(sid))\n" + (problemCores ?? []).map(\.description).joined(separator: "\n")
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PracticeTestSection_Core> {
        return NSFetchRequest<PracticeTestSection_Core>(entityName: "PracticeTestSection_Core")
    }
    
    enum Attribute: String {
        case wid
        case sid
        case title
        case sectionNum
        case downloaded
        case fileSize
        case image
        case time
        case lastIndex
        case terminated
        case scoringQueue
        case uploadProblemQueue
        case uploadPageQueue
        case updatedDate
        case audio
        case audioDetail
        case problemCores
        case cutoff
        case detail
    }
    /* sectionHeader */
    @NSManaged public var wid: Int64
    @NSManaged public var sid: Int64
    @NSManaged public var title: String?
    @NSManaged public var sectionNum: Int64
    @NSManaged public var downloaded: Bool
    @NSManaged public var fileSize: Int64
    @NSManaged public var image: Data?
    /* section */
    @NSManaged public var time: Int64
    @NSManaged public var lastIndex: Int64
    @NSManaged public var terminated: Bool
    @NSManaged public var scoringQueue: [Int]?
    @NSManaged public var uploadProblemQueue: [Int]?
    @NSManaged public var uploadPageQueue: [Int]?
    @NSManaged public var updatedDate: Date?
    @NSManaged public var audio: Data?
    @NSManaged public var audioDetail: String?
    @NSManaged public var problemCores: [Problem_Core]?
    /* practiceTest */
    @NSManaged public var cutoff: String?
    @NSManaged public var detail: String?
}

// MARK: Generated accessors for problemCores
extension PracticeTestSection_Core {

    @objc(insertObject:inProblemCoresAtIndex:)
    @NSManaged public func insertIntoProblemCores(_ value: Problem_Core, at idx: Int)

    @objc(removeObjectFromProblemCoresAtIndex:)
    @NSManaged public func removeFromProblemCores(at idx: Int)

    @objc(insertProblemCores:atIndexes:)
    @NSManaged public func insertIntoProblemCores(_ values: [Problem_Core], at indexes: NSIndexSet)

    @objc(removeProblemCoresAtIndexes:)
    @NSManaged public func removeFromProblemCores(at indexes: NSIndexSet)

    @objc(replaceObjectInProblemCoresAtIndex:withObject:)
    @NSManaged public func replaceProblemCores(at idx: Int, with value: Problem_Core)

    @objc(replaceProblemCoresAtIndexes:withProblemCores:)
    @NSManaged public func replaceProblemCores(at indexes: NSIndexSet, with values: [Problem_Core])

    @objc(addProblemCoresObject:)
    @NSManaged public func addToProblemCores(_ value: Problem_Core)

    @objc(removeProblemCoresObject:)
    @NSManaged public func removeFromProblemCores(_ value: Problem_Core)

    @objc(addProblemCores:)
    @NSManaged public func addToProblemCores(_ values: NSOrderedSet)

    @objc(removeProblemCores:)
    @NSManaged public func removeFromProblemCores(_ values: NSOrderedSet)

}
