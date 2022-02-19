//
//  Section_Core.swift
//  semomun
//
//  Created by Kang Minsang on 2021/10/03.
//
//

import Foundation
import CoreData

@objc(Section_Core)
public class Section_Core: NSManagedObject {
    public override var description: String{
        return "Section(\(self.sid), \(self.buttons), \(self.stars), \(self.wrongs), \(self.dictionaryOfProblem))"
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Section_Core> {
        return NSFetchRequest<Section_Core>(entityName: "Section_Core")
    }

    @NSManaged public var sid: Int64 //식별 고유값
    @NSManaged public var title: String? //섹션 제목
    @NSManaged public var time: Int64 //누적 시간
    @NSManaged public var buttons: [String] //하단 버튼내용들
    @NSManaged public var stars: [Bool] //하단 버튼 스타표시여부
    @NSManaged public var dictionaryOfProblem: [String: Int] //버튼 - vid 간 관계
    @NSManaged public var lastPageId: Int64 //마지막 화면 id
    @NSManaged public var terminated: Bool //채점여부
    @NSManaged public var wrongs: [Bool] //채점 이후 문제별 틀림여부
    @NSManaged public var checks: [Bool] //푼 문제인지 여부
    @NSManaged public var problemCores: [Problem_Core]? //relation으로 생긴 ProblemCore들
    
    func setValues(header: SectionHeader_Core, buttons: [String], dict: [String: Int]) {
        self.setValue(header.sid, forKey: "sid")
        self.setValue(header.title, forKey: "title")
        self.setValue(0, forKey: "time")
        self.setValue(buttons, forKey: "buttons")
        let stars = Array(repeating: false, count: buttons.count)
        let wrongs = Array(repeating: true, count: buttons.count)
        let checks = Array(repeating: false, count: buttons.count)
        self.setValue(stars, forKey: "stars")
        self.setValue(wrongs, forKey: "wrongs")
        self.setValue(dict, forKey: "dictionaryOfProblem")
        self.setValue(dict[buttons[0]], forKey: "lastPageId")
        self.setValue(false, forKey: "terminated")
        self.setValue(checks, forKey: "checks")
        print("Section: \(header.sid) save complete")
    }
    
    func setMocks(sid: Int, buttons: [String], dict: [String: Int]) {
        self.setValue(sid, forKey: "sid")
        self.setValue("MOCK_DATA", forKey: "title")
        self.setValue(0, forKey: "time")
        self.setValue(buttons, forKey: "buttons")
        let stars = Array(repeating: false, count: buttons.count)
        let wrongs = Array(repeating: true, count: buttons.count)
        let checks = Array(repeating: false, count: buttons.count)
        self.setValue(stars, forKey: "stars")
        self.setValue(wrongs, forKey: "wrongs")
        self.setValue(dict, forKey: "dictionaryOfProblem")
        self.setValue(dict[buttons[0]], forKey: "lastPageId")
        self.setValue(checks, forKey: "checks")
        print("MOCK Section: \(sid) save complete")
    }
}

// MARK: Generated accessors for problemCores
extension Section_Core {
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
