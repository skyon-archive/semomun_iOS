//
//  Problem_Core+CoreDataProperties.swift
//  Semomoon
//
//  Created by qwer on 2021/10/03.
//
//

import Foundation
import CoreData
import Alamofire
import UIKit

extension Problem_Core {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Problem_Core> {
        return NSFetchRequest<Problem_Core>(entityName: "Problem_Core")
    }

    @NSManaged public var pid: Int64 //문제 고유번호
    @NSManaged public var pName: String? //하단버튼 표시내용
    @NSManaged public var contentImage: Data? //문제 이미지
    @NSManaged public var time: Int64 //누적시간
    @NSManaged public var answer: String? //정답
    @NSManaged public var solved: String? //사용자 입력답
    @NSManaged public var correct: Bool //맞았는지 여부
    @NSManaged public var explanationImage: Data? //해설 이미지
    @NSManaged public var rate: Int64 //0~100 정답률
    @NSManaged public var drawing: Data? //펜슬데이터
    @NSManaged public var type: Int64 //문제타입: 0,1,4,5
    @NSManaged public var star: Bool //별표표시여부
}

extension Problem_Core : Identifiable {
}

@objc(Problem_Core)
public class Problem_Core: NSManagedObject {
    public override var description: String{
        return "Problem(\(self.pid), \(self.pName), \(self.contentImage), \(self.explanationImage), \(self.star)\n"
    }
    
    func setValues(prob: ProblemOfDB) {
        self.setValue(Int64(prob.pid), forKey: "pid")
        self.setValue(prob.icon_name, forKey: "pName")
        self.setValue(Int64(0), forKey: "time")
        self.setValue(prob.answer, forKey: "answer")
        self.setValue(nil, forKey: "solved")
        self.setValue(false , forKey: "correct")
        self.setValue(prob.rate, forKey: "rate")
        self.setValue(nil, forKey: "drawing")
        self.setValue(prob.type, forKey: "type")
        self.setValue(false, forKey: "star")
        
        // MARK: - contentImage
        if let contentURL = URL(string: NetworkUsecase.URL.contentImage + prob.content) {
            let contentData = try? Data(contentsOf: contentURL)
            if contentData != nil {
                self.setValue(contentData, forKey: "contentImage")
            } else {
                guard let warningImage = UIImage(named: "warningWithNoImage") else { return }
                self.setValue(warningImage.pngData(), forKey: "contentImage")
            }
        } else {
            guard let warningImage = UIImage(named: "warningWithNoImage") else { return }
            self.setValue(warningImage.pngData(), forKey: "contentImage")
        }
        
        // MARK: - explanationImage
        if let explanation = prob.explanation {
            if let explanationURL = URL(string: NetworkUsecase.URL.explanation + explanation) {
                let contentData = try? Data(contentsOf: explanationURL)
                if contentData != nil {
                    self.setValue(contentData, forKey: "explanationImage")
                } else {
                    guard let warningImage = UIImage(named: "warningWithNoImage") else { return }
                    self.setValue(warningImage.pngData(), forKey: "explanationImage")
                }
            } else {
                guard let warningImage = UIImage(named: "warningWithNoImage") else { return }
                self.setValue(warningImage.pngData(), forKey: "explanationImage")
            }
        } else {
            self.setValue(nil, forKey: "explanationImage")
        }
        print("Problem: \(prob.pid) save complete")
    }
    
    func setMocks(pid: Int, type: Int, btName: String, imgName: String, expName: String? = nil) {
        self.setValue(Int64(pid), forKey: "pid")
        self.setValue(btName, forKey: "pName")
        self.setValue(Int64(0), forKey: "time")
        self.setValue(nil, forKey: "answer")
        self.setValue(nil, forKey: "solved")
        self.setValue(false, forKey: "correct")
        self.setValue(Int64(0), forKey: "rate")
        self.setValue(nil, forKey: "drawing")
        self.setValue(Int64(type), forKey: "type")
        self.setValue(false, forKey: "star")
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
