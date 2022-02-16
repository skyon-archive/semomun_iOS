//
//  Section_Core.swift
//  semomun
//
//  Created by Kang Minsang on 2021/10/03.
//
//

import Foundation
import CoreData

public class ButtonData: NSObject, NSCoding {
    public func encode(with coder: NSCoder) {
        coder.encode(pName, forKey: "pName")
        coder.encode(pid, forKey: "pid")
        coder.encode(vid, forKey: "vid")
        coder.encode(wrong, forKey: "wrong")
        coder.encode(check, forKey: "check")
        coder.encode(terminated, forKey: "terminated")
    }
    
    public required init?(coder: NSCoder) {
        self.pName = coder.decodeObject(forKey: "pName") as! String
        self.pid = coder.decodeInteger(forKey: "pid")
        self.vid = coder.decodeInteger(forKey: "vid")
        self.wrong = coder.decodeBool(forKey: "wrong")
        self.check = coder.decodeBool(forKey: "check")
        self.terminated = coder.decodeBool(forKey: "terminated")
    }
    
    let pName: String
    let pid: Int // 혹시 추가정보를 반영하기 위해 접근가능하도록 key값을 저장하는 역할
    var vid: Int
    var wrong: Bool
    var check: Bool
    var terminated: Bool
    
    init(problem: Problem_Core, vid: Int) {
        self.pName = problem.pName ?? "1"
        self.pid = Int(problem.pid)
        self.vid = vid
        self.wrong = problem.correct
        self.check = problem.solved != nil
                self.terminated = problem.terminated
    }
}

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
    @NSManaged public var lastPageId: Int64 //마지막 화면 id
    @NSManaged public var terminated: Bool //채점여부
    @NSManaged public var wrongs: [Bool] //채점 이후 문제별 틀림여부
    @NSManaged public var checks: [Bool] //푼 문제인지 여부
    @NSManaged public var buttonDatas: [ButtonData] //하단 버튼내용들
}

extension Section_Core : Identifiable {
}

@objc(Section_Core)
public class Section_Core: NSManagedObject {
    public override var description: String{
        return "Section(\(self.sid), \(self.buttons), \(self.stars), \(self.wrongs), \(self.dictionaryOfProblem), \(self.buttonDatas))"
    }
    
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
