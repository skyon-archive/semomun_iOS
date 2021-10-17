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
        var sections: [Section_Core] = []
        let fetchRequest: NSFetchRequest<Section_Core> = Section_Core.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "sid = %@", sid)
        
        do {
            sections = try CoreDataManager.shared.context.fetch(fetchRequest)
            return !sections.isEmpty ? sections[0] : nil
        } catch let error {
            print(error.localizedDescription)
        }
        return nil
    }
    
    static func savePages(sid: Int, pages: [PageOfDB], completion: @escaping(Section_Core?) -> Void) {
        DispatchQueue.global().async {
            //section
            let sectionOfCore = Section_Core(context: CoreDataManager.shared.context)
            guard let sectionHeader = loadSectionHeader(sid: sid) else {
                completion(nil)
                return
            }
            sectionOfCore.setValues(header: sectionHeader)
            var buttons: [String] = []
            var dictOfButtonToView: [String: Int] = [:]
            
            for page in pages {
                //page
                let pageOfCore = Page_Core(context: CoreDataManager.shared.context)
                var problems: [Int] = []
                
                for problem in page.problems {
                    //problem
                    let problemOfCore = Problem_Core(context: CoreDataManager.shared.context)
                    problemOfCore.setValues(prob: problem)
                    
                    buttons.append(problem.icon_name)
                    dictOfButtonToView[problem.icon_name] = page.vid
                    problems.append(problem.pid)
                }
                
                pageOfCore.setValues(page: page, pids: problems)
            }
            
            sectionOfCore.updateButtons(buttons: buttons)
            sectionOfCore.updateDictionary(dict: dictOfButtonToView)
        }
    }
    
    static func loadSectionHeader(sid: Int) -> SectionHeader_Core? {
        let fetchRequest: NSFetchRequest<SectionHeader_Core> = SectionHeader_Core.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "sid = %@", sid)
        
        do {
            let sectionHeaders = try CoreDataManager.shared.context.fetch(fetchRequest)
            guard let sectionHeader = sectionHeaders.first else {
                print("Error: not exist SectionHeader of \(sid)")
                return nil
            }
            return sectionHeader
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
}
