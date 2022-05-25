//
//  Page_Core.swift
//  semomun
//
//  Created by Kang Minsang on 2021/10/03.
//
//

import Foundation
import CoreData

struct PageUUID {
    let material: UUID?
}

@objc(Page_Core)
public class Page_Core: NSManagedObject {
    public override var description: String{
        return "Page(\(vid)) \(problemCores ?? [])"
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Page_Core> {
        return NSFetchRequest<Page_Core>(entityName: "Page_Core")
    }
    
    enum Attribute: String {
        case vid
        case layoutType
        case materialImage
        case updatedDate
        case drawing
        case time
        case problemCores
        case drawingWidth
    }

    @NSManaged public var vid: Int64 //뷰어의 고유 번호
    @NSManaged public var layoutType: String //뷰컨트롤러 타입
    @NSManaged public var materialImage: Data? //좌측 이미지
    @NSManaged public var updatedDate: Date? // NEW: 반영일자
    
    @NSManaged public var drawing: Data? //Pencil 데이터
    @NSManaged public var drawingWidth: Double // Pencil 데이터 가로 폭
    @NSManaged public var time: Int64 // 좌우형 시간계산을 위한 화면단위 누적 시간
    @NSManaged public var problemCores: [Problem_Core]? //relation으로 인해 생긴 problemCore들
    
    @available(*, deprecated, message: "이전 버전의 CoreData")
    @NSManaged public var problems: [Int] //Deprecated(1.1.3)
    
    func setValues(page: PageOfDB, type: Int) -> PageUUID {
        self.setValue(Int64(page.vid), forKey: Attribute.vid.rawValue)
        self.setValue(self.getLayout(form: page.form, type: type), forKey: Attribute.layoutType.rawValue)
        self.setValue(page.updatedDate, forKey: Attribute.updatedDate.rawValue)
        self.setValue(nil, forKey: Attribute.drawing.rawValue)
        self.setValue(0, forKey: Attribute.time.rawValue)
        print("Page: \(page.vid) save complete")
        
        return PageUUID(material: page.material)
    }
    
    func setMaterial(uuid: PageUUID, networkUsecase: S3ImageFetchable, completion: @escaping(() -> Void)) {
        guard let material = uuid.material else { return }
        // MARK: - materialImage
        networkUsecase.getImageFromS3(uuid: material, type: .material) { [weak self] status, data in
            print(data ?? "Error: \(self?.vid ?? 0) - can't get material Image")
            if data != nil {
                self?.setValue(data, forKey: Attribute.materialImage.rawValue)
                print("Page: \(self?.vid ?? 0) save material")
                completion()
            } else {
                self?.setValue(nil, forKey: Attribute.materialImage.rawValue)
                print("Page: \(self?.vid ?? 0) save material fail")
                completion()
            }
        }
    }
    
    private func getLayout(form: Int, type: Int) -> String {
        print("VC FORM: from=\(form) && type=\(type)")
        if form == 0 {
            switch type {
            case -1: return ConceptVC.identifier
            case 0: return SingleWithNoAnswerVC.identifier
            case 1: return SingleWithTextAnswerVC.identifier
            case 4: return SingleWith4AnswerVC.identifier
            case 5: return SingleWith5AnswerVC.identifier
            case 6: return SingleWithSubProblemsVC.identifier
            default:
                assertionFailure()
                return SingleWith5AnswerVC.identifier
            }
        }
        else if form == 1 {
            switch type {
            case 0: return MultipleWithNoAnswerVC.identifier
            case 5: return MultipleWith5AnswerVC.identifier
            default:
                assertionFailure()
                return MultipleWith5AnswerVC.identifier
            }
        }
        else if form == 2 {
            switch type {
            case -1: return MultipleWithConceptWideVC.identifier
            case 0: return MultipleWithNoAnswerWideVC.identifier
            case 5: return MultipleWith5AnswerWideVC.identifier
            case 6: return MultipleWithSubProblemsWideVC.identifier
            default:
                assertionFailure()
                return MultipleWith5AnswerWideVC.identifier
            }
        }
        return SingleWith5AnswerVC.identifier
    }
    
    func setMocks(vid: Int, form: Int, type: Int, pids: [Int], mateImgName: String?) {
        self.setValue(Int64(vid), forKey: "vid")
        self.setValue(getLayout(form: form, type: type), forKey: "layoutType")
        self.setValue(pids, forKey: "problems")
        self.setValue(nil, forKey: "drawing")
        self.setValue(Int64(0), forKey: "time")
        if let _ = mateImgName {
//            let imgData = UIImage(named: mateImgName)!.pngData()
//            self.setValue(imgData, forKey: "materialImage")
        } else {
            self.setValue(nil, forKey: "materialImage")
        }
        print("MOCK Page: \(vid) save complete")
    }
}

// MARK: Generated accessors for problemCores
extension Page_Core {
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
