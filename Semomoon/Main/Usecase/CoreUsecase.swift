//
//  CoreUsecase.swift
//  Semomoon
//
//  Created by qwer on 2021/10/17.
//

import Foundation
import CoreData

struct CoreUsecase {
    static func sectionOfCoreData(sid: Int) -> Section_Core? {
        let fetchRequest: NSFetchRequest<Section_Core> = Section_Core.fetchRequest()
        let filter = NSPredicate(format: "sid = %@", "\(sid)")
        fetchRequest.predicate = filter
        
        if let sections = try? CoreDataManager.shared.context.fetch(fetchRequest) {
            guard let section = sections.first else {
                print("Error: not exist Section of \(sid)")
                return nil
            }
            return section
        }
        return nil
    }
    
    static func savePages(sid: Int, pages: [PageOfDB], completion: @escaping(Section_Core?) -> Void) {
        let context = CoreDataManager.shared.context
        DispatchQueue.global().async {
            let sectionOfCore = Section_Core(context: context)
            // Section: 1. sectionHeader 로딩, error 시 nil 반환
            guard let sectionHeader = loadSectionHeader(sid: sid) else {
                completion(nil)
                return
            }
            // Section: 2. 하단 button 타이틀 변수
            var buttons: [String] = []
            // Section: 3. 하단 button -> vid 딕셔너리 변수
            var dictOfButtonToView: [String: Int] = [:]
            
            for page in pages {
                print(page)
                let pageOfCore = Page_Core(context: context)
                // Page: 1. 페이지 내 pid들 변수
                var problems: [Int] = []
                
                for problem in page.problems {
                    let problemOfCore = Problem_Core(context: context)
                    // Problem: 1. problem 최종 저장
                    problemOfCore.setValues(prob: problem)
                    
                    buttons.append(problem.icon_name)
                    dictOfButtonToView[problem.icon_name] = page.vid
                    problems.append(problem.pid)
                }
                // Page: 2. page 최종 저장
                pageOfCore.setValues(page: page, pids: problems)
            }
            // Section: 4. section 최종 저장
            sectionOfCore.setValues(header: sectionHeader, buttons: buttons, dict: dictOfButtonToView)
            do { try context.save() } catch let error { print(error.localizedDescription) }
            completion(sectionOfCore)
        }
    }
    
    static func loadSectionHeader(sid: Int) -> SectionHeader_Core? {
        let fetchRequest: NSFetchRequest<SectionHeader_Core> = SectionHeader_Core.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "sid = %@", "\(sid)")
        
        if let sectionHeaders = try? CoreDataManager.shared.context.fetch(fetchRequest) {
            guard let sectionHeader = sectionHeaders.first else {
                print("Error: not exist SectionHeader of \(sid)")
                return nil
            }
            print("loaded: \(sectionHeader)")
            return sectionHeader
        }
        return nil
    }
}
