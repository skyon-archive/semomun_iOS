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

    @NSManaged public var sid: Int64 //식별 고유값
    @NSManaged public var title: String? //섹션 제목
    @NSManaged public var time: Int64 //누적 시간
    @NSManaged public var buttons: [String] //하단 버튼내용들
    @NSManaged public var stars: [Bool] //하단 버튼 스타표시여부
    @NSManaged public var dictionaryOfProblem: [String: Int] //버튼 - vid 간 관계
}

extension Section_Core : Identifiable {
}

@objc(Section_Core)
public class Section_Core: NSManagedObject {
    func setValues(header: SectionHeader_Core, buttons: [String], dict: [String: Int]) {
        self.setValue(header.sid, forKey: "sid")
        self.setValue(header.title, forKey: "title")
        self.setValue(0, forKey: "time")
        self.setValue(buttons, forKey: "buttons")
        let stars = Array(repeating: false, count: buttons.count)
        self.setValue(stars, forKey: "start")
        self.setValue(dict, forKey: "dictionaryOfProblem")
    }
}
