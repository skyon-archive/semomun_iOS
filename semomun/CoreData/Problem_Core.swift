//
//  Problem_Core.swift
//  semomun
//
//  Created by Kang Minsang on 2021/10/03.
//
//

import Foundation
import CoreData
import Alamofire
import UIKit

struct ProblemUUIDs {
    let pid: Int
    let content: String
    let explanation: String?
    let imageCount: Int
    
    init(pid: Int, content: String, explanation: String?) {
        self.pid = pid
        self.content = content
        self.explanation = explanation
        self.imageCount = explanation == nil ? 1 : 2
    }
}

@objc(Problem_Core)
public class Problem_Core: NSManagedObject {
    public override var description: String{
        return "Problem(\(pid)) {btNum: \(pName ?? "-"), answer: \(answer ?? "none")}"
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Problem_Core> {
        return NSFetchRequest<Problem_Core>(entityName: "Problem_Core")
    }
    
    enum Attribute: String {
        case pid
        case orderIndex
        case btType
        case pName
        case type
        case answer
        case contentImage
        case explanationImage
        case point
        case sectionCore
        case pageCore
        case time
        case solved
        case correct
        case drawing
        case star
        case terminated
    }

    @NSManaged public var pid: Int64 //문제 고유번호
    @NSManaged public var orderIndex: Int64 //NEW: section 내 정렬을 위한 고유순서값
    @NSManaged public var btType: String? //NEW: 문제 유형 (개념, 문제)
    @NSManaged public var pName: String? //하단 버튼 표시내용
    @NSManaged public var type: Int64 //선지 유형
    @NSManaged public var answer: String? //문제 정답
    @NSManaged public var contentImage: Data? //문제 이미지
    @NSManaged public var explanationImage: Data? //해설 이미지
    
    @NSManaged public var point: Double //문제 배점
    @NSManaged public var sectionCore: Section_Core? //relation으로 인해 생긴 SectionCore
    @NSManaged public var pageCore: Page_Core? //relation으로 인해 생긴 PageCore
    
    @NSManaged public var time: Int64 //누적시간
    @NSManaged public var solved: String? //사용자 입력답
    @NSManaged public var correct: Bool //맞았는지 여부
    @NSManaged public var drawing: Data? //펜슬데이터
    @NSManaged public var star: Bool //별표표시여부
    @NSManaged public var terminated: Bool //채점여부
    
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var rate: Int64 //Deprecated(1.1.3)
    
    func setValues(prob: ProblemOfDB, index: Int) -> ProblemUUIDs {
        self.setValue(Int(prob.pid), forKey: Attribute.pid.rawValue)
        self.setValue(Int(index), forKey: Attribute.orderIndex.rawValue)
        self.setValue(prob.btType, forKey: Attribute.btType.rawValue)
        self.setValue(prob.btName, forKey: Attribute.pName.rawValue)
        self.setValue(prob.type, forKey: Attribute.type.rawValue)
        self.setValue(prob.answer, forKey: Attribute.answer.rawValue)
        self.setValue(prob.point, forUndefinedKey: Attribute.point.rawValue)
        self.setValue(Int64(0), forKey: Attribute.time.rawValue)
        self.setValue(nil, forKey: Attribute.solved.rawValue)
        self.setValue(false, forKey: Attribute.correct.rawValue)
        self.setValue(nil, forKey: Attribute.drawing.rawValue)
        self.setValue(false, forKey: Attribute.star.rawValue)
        self.setValue(false, forKey: Attribute.terminated.rawValue)
        print("Problem: \(prob.pid) save complete")
        
        return ProblemUUIDs(pid: prob.pid, content: prob.content, explanation: prob.explanation)
    }
    
    func fetchImages(uuids: ProblemUUIDs, completion: @escaping(() -> Void)) {
        let network = Network()
        let networkUsecase = NetworkUsecase(network: Network())
        // MARK: - contentImage
//        networkUsecase.getImageURLFromS3(uuid: uuids.content, type: .content) { status, stringURL in
//            <#code#>
//        }
//
//
//
//
//
//        Network().get(url: problemResult.content, param: nil) { requestResult in
//            print(requestResult.data ?? "no data")
//            if requestResult.data != nil {
//                self.setValue(requestResult.data, forKey: "contentImage")
//                print("Problem: \(problemResult.pid) save contentImage")
//                completion()
//            } else {
//                let warningImage = UIImage(.warning)
//                self.setValue(warningImage.pngData(), forKey: "contentImage")
//                print("Problem: \(problemResult.pid) save contentImage fail")
//                completion()
//            }
//        }
//
//        // MARK: - explanationImage
//        if let explanationURL = problemResult.explanation {
//            Network().get(url: explanationURL, param: nil) { requestResult in
//                print(requestResult.data ?? "no data")
//                if requestResult.data != nil {
//                    self.setValue(requestResult.data, forKey: "explanationImage")
//                    print("Problem: \(problemResult.pid) save explanationImage")
//                    completion()
//                } else {
//                    let warningImage = UIImage(.warning)
//                    self.setValue(warningImage.pngData(), forKey: "explanationImage")
//                    print("Problem: \(problemResult.pid) save explanationImage")
//                    completion()
//                }
//            }
//        } else { return }
    }
    
    func setMocks(pid: Int, type: Int, btName: String, imgName: String, expName: String? = nil, answer: String? = nil) {
        self.setValue(Int64(pid), forKey: "pid")
        self.setValue(btName, forKey: "pName")
        self.setValue(Int64(0), forKey: "time")
        self.setValue(answer, forKey: "answer")
        self.setValue(false, forKey: "correct")
        self.setValue(Int64(0), forKey: "rate")
        self.setValue(nil, forKey: "drawing")
        self.setValue(Int64(type), forKey: "type")
        self.setValue(false, forKey: "star")
        self.setValue(Double(5), forKey: "point")
        let imgData = UIImage(named: imgName)!.pngData()
        self.setValue(imgData, forKey: "contentImage")
        if let expName = expName {
            let expData = UIImage(named: expName)!.pngData()
            self.setValue(expData, forKey: "explanationImage")
        } else {
            self.setValue(nil, forKey: "explanationImage")
        }
        print("MOCK Problem: \(pid) save complete")
    }
}
