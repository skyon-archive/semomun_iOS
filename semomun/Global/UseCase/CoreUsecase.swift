//
//  CoreUsecase.swift
//  semomun
//
//  Created by Kang Minsang on 2021/10/17.
//

import Foundation
import CoreData
import Kingfisher

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
    
    static func savePages(sid: Int, pages: [PageOfDB], loading: loadingDelegate, completion: @escaping(Section_Core?) -> Void) {
        let context = CoreDataManager.shared.context
        let sectionOfCore = Section_Core(context: context)
        
        if pages.isEmpty {
            completion(nil)
            return
        }
        guard let sectionHeader = loadSectionHeader(sid: sid) else {
            completion(nil)
            return
        }
        
        var problemNames: [String] = []
        var problemNameToPage: [String: Int] = [:]
        var pageCores: [Page_Core] = []
        var problemCores: [Problem_Core] = []
        var pageResults: [PageResult] = []
        var problemResults: [ProblemResult] = []
        var pageImageCount: Int = 0
        var problemImageCount: Int = 0
        
        print("----------save start----------")
        for page in pages {
            let pageOfCore = Page_Core(context: context)
            var problemIds: [Int] = []
            var pageLayoutType: Int = 5

            for problem in page.problems {
                let problemOfCore = Problem_Core(context: context)
                let problemResult = problemOfCore.setValues(prob: problem)
                // Section property
                problemNames.append(problem.icon_name)
                problemNameToPage[problem.icon_name] = page.vid
                // Page property
                problemIds.append(problem.pid)
                pageLayoutType = problem.type
                // append instance
                problemImageCount += problemResult.imageCount
                problemCores.append(problemOfCore)
                problemResults.append(problemResult)
            }
            let pageResult = pageOfCore.setValues(page: page, pids: problemIds, type: pageLayoutType)
            // append instance
            if pageResult.isImage { pageImageCount += 1 }
            pageCores.append(pageOfCore)
            pageResults.append(pageResult)
        }
        print("----------save end----------")
        let totalCount: Int = problemImageCount + pageResults.count
        let loadingCount: Int = problemImageCount + pageImageCount
        print(totalCount, loadingCount)
        var currentCount: Int = 0
        
        DispatchQueue.main.async {
            loading.setCount(count: loadingCount)
        }
        
        DispatchQueue.global().async {
            for (idx, problem) in problemCores.enumerated() {
                problem.fetchImages(problemResult: problemResults[idx]) {
                    DispatchQueue.main.async {
                        loading.updateProgress()
                        currentCount += 1
                        terminateDownload(currentCount: currentCount, totalCount: totalCount, section: sectionOfCore, header: sectionHeader, buttons: problemNames, dict: problemNameToPage, completion: completion)
                    }
                }
            }
            for (idx, page) in pageCores.enumerated() {
                page.setMaterial(pageResult: pageResults[idx]) {
                    DispatchQueue.main.async {
                        if pageResults[idx].isImage {
                            loading.updateProgress()
                        }
                        currentCount += 1
                        terminateDownload(currentCount: currentCount, totalCount: totalCount, section: sectionOfCore, header: sectionHeader, buttons: problemNames, dict: problemNameToPage, completion: completion)
                    }
                }
            }
        }
    }
    
    static func terminateDownload(currentCount: Int, totalCount: Int, section: Section_Core, header: SectionHeader_Core, buttons: [String], dict: [String: Int], completion: ((Section_Core?) -> Void)) {
        if currentCount == totalCount {
            print("----------download end----------")
            section.setValues(header: header, buttons: buttons, dict: dict)
            completion(section)
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
    
    static func createMockDataForMulty() {
        let context = CoreDataManager.shared.context
        
        //5Answer
        let problemOfCore1 = Problem_Core(context: context)
        problemOfCore1.setMocks(pid: -121, type: 5, btName: "1", imgName: "mock1", expName: "exp1", answer: "1")
        let pageOfCore1 = Page_Core(context: context)
        pageOfCore1.setMocks(vid: -12, form: 0, type: 5, pids: [-121], mateImgName: nil)
        
        let problemOfCore2 = Problem_Core(context: context)
        problemOfCore2.setMocks(pid: -232, type: 5, btName: "2", imgName: "mock2", expName: "exp2", answer: "3")
        let pageOfCore2 = Page_Core(context: context)
        pageOfCore2.setMocks(vid: -23, form: 0, type: 5, pids: [-232], mateImgName: nil)
        
        let problemOfCore3 = Problem_Core(context: context)
        problemOfCore3.setMocks(pid: -343, type: 5, btName: "3", imgName: "mock3", expName: "exp4", answer: "2")
        let pageOfCore3 = Page_Core(context: context)
        pageOfCore3.setMocks(vid: -34, form: 0, type: 5, pids: [-343], mateImgName: nil)
        
        let problemOfCore4 = Problem_Core(context: context)
        problemOfCore4.setMocks(pid: -454, type: 5, btName: "4", imgName: "mock4", answer: "5")
        let pageOfCore4 = Page_Core(context: context)
        pageOfCore4.setMocks(vid: -45, form: 0, type: 5, pids: [-454], mateImgName: nil)
        
        //Text
        let problemOfCore5 = Problem_Core(context: context)
        problemOfCore5.setMocks(pid: -565, type: 1, btName: "5", imgName: "mock5", expName: "exp3", answer: "123")
        let pageOfCore5 = Page_Core(context: context)
        pageOfCore5.setMocks(vid: -56, form: 0, type: 1, pids: [-565], mateImgName: nil)
        
        //Multi 5
        let problemOfCore6 = Problem_Core(context: context)
        problemOfCore6.setMocks(pid: -131, type: 5, btName: "6", imgName: "mockImg11", expName: "exp1", answer: "1")
        let problemOfCore7 = Problem_Core(context: context)
        problemOfCore7.setMocks(pid: -242, type: 5, btName: "7", imgName: "mockImg12", expName: "exp2", answer: "5")
        let problemOfCore8 = Problem_Core(context: context)
        problemOfCore8.setMocks(pid: -353, type: 5, btName: "8", imgName: "mockImg13", answer: "3")
        let problemOfCore9 = Problem_Core(context: context)
        problemOfCore9.setMocks(pid: -464, type: 5, btName: "9", imgName: "mockImg14", answer: "4")
        
        let pageOfCore6 = Page_Core(context: context)
        pageOfCore6.setMocks(vid: -13, form: 1, type: 5, pids: [-131, -242, -353, -464], mateImgName: "material1")
        
        let problemOfCore10 = Problem_Core(context: context)
        problemOfCore10.setMocks(pid: -575, type: 5, btName: "10", imgName: "mockImg21", expName: "exp3", answer: "5")
        let problemOfCore11 = Problem_Core(context: context)
        problemOfCore11.setMocks(pid: -686, type: 5, btName: "11", imgName: "mockImg22", expName: "exp4", answer: "2")
        let problemOfCore12 = Problem_Core(context: context)
        problemOfCore12.setMocks(pid: -797, type: 5, btName: "12", imgName: "mockImg23", answer: "2")
        let problemOfCore13 = Problem_Core(context: context)
        problemOfCore13.setMocks(pid: -898, type: 5, btName: "13", imgName: "mockImg24", answer: "1")
        
        let pageOfCore7 = Page_Core(context: context)
        pageOfCore7.setMocks(vid: -24, form: 1, type: 5, pids: [-575, -686, -797, -898], mateImgName: "material2")
        
        //4Answer
        let problemOfCore14 = Problem_Core(context: context)
        problemOfCore14.setMocks(pid: -141, type: 4, btName: "14", imgName: "mock1", expName: "exp1", answer: "1")
        let pageOfCore8 = Page_Core(context: context)
        pageOfCore8.setMocks(vid: -14, form: 0, type: 4, pids: [-141], mateImgName: nil)
        
        let problemOfCore15 = Problem_Core(context: context)
        problemOfCore15.setMocks(pid: -252, type: 4, btName: "15", imgName: "mock2", expName: "exp2", answer: "3")
        let pageOfCore9 = Page_Core(context: context)
        pageOfCore9.setMocks(vid: -25, form: 0, type: 4, pids: [-252], mateImgName: nil)
        
        //Multi No
        let problemOfCore16 = Problem_Core(context: context)
        problemOfCore16.setMocks(pid: -151, type: 0, btName: "16", imgName: "mockImg11")
        let problemOfCore17 = Problem_Core(context: context)
        problemOfCore17.setMocks(pid: -262, type: 0, btName: "17", imgName: "mockImg12")
        
        let pageOfCore10 = Page_Core(context: context)
        pageOfCore10.setMocks(vid: -15, form: 1, type: 0, pids: [-151, -262], mateImgName: "material1")
        
        //Section
        let sectionCore = Section_Core(context: context)
        let buttons = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17"]
        let dict = ["1": -12, "2": -23, "3": -34, "4": -45, "5": -56,
                    "6": -13, "7": -13, "8": -13, "9": -13,
                    "10": -24, "11": -24, "12": -24, "13": -24,
                    "14": -14, "15": -25,
                    "16": -15, "17": -15]
        sectionCore.setMocks(sid: -3, buttons: buttons, dict: dict)
        
        do { try context.save() } catch let error { print(error.localizedDescription) }
        print("MOCK SAVE COMPLETE")
    }
    
    static func fetchPreviews(subject: String) -> [Preview_Core]? {
        let fetchRequest: NSFetchRequest<Preview_Core> = Preview_Core.fetchRequest()
        if subject != "전체" {
            let filter = NSPredicate(format: "subject = %@", subject)
            fetchRequest.predicate = filter
        }
        
        if let previews = try? CoreDataManager.shared.context.fetch(fetchRequest) {
            return previews
        } else {
            return nil
        }
    }
    
    static func fetchPreview(wid: Int) -> Preview_Core? {
        let fetchRequest: NSFetchRequest<Preview_Core> = Preview_Core.fetchRequest()
        let filter = NSPredicate(format: "wid = %@", "\(wid)")
        fetchRequest.predicate = filter
        
        if let fetches = try? CoreDataManager.shared.context.fetch(fetchRequest) {
            guard let section = fetches.first else { return nil }
            return section
        } else {
            return nil
        }
    }
    
    static func fetchSection(sid: Int) -> Section_Core? {
        let fetchRequest: NSFetchRequest<Section_Core> = Section_Core.fetchRequest()
        let filter = NSPredicate(format: "sid = %@", "\(sid)")
        fetchRequest.predicate = filter
        
        if let fetches = try? CoreDataManager.shared.context.fetch(fetchRequest) {
            guard let section = fetches.first else { return nil }
            return section
        } else {
            return nil
        }
    }
    
    static func fetchPage(vid: Int) -> Page_Core? {
        let fetchRequest: NSFetchRequest<Page_Core> = Page_Core.fetchRequest()
        let filter = NSPredicate(format: "vid = %@", "\(vid)")
        fetchRequest.predicate = filter
        
        if let fetches = try? CoreDataManager.shared.context.fetch(fetchRequest) {
            guard let section = fetches.first else { return nil }
            return section
        } else {
            return nil
        }
    }
    
    static func fetchProblem(pid: Int) -> Problem_Core? {
        let fetchRequest: NSFetchRequest<Problem_Core> = Problem_Core.fetchRequest()
        let filter = NSPredicate(format: "pid = %@", "\(pid)")
        fetchRequest.predicate = filter
        
        if let fetches = try? CoreDataManager.shared.context.fetch(fetchRequest) {
            guard let section = fetches.first else { return nil }
            return section
        } else {
            return nil
        }
    }
    
    static func fetchUserInfo() -> UserCoreData? {
        let fetchRequest: NSFetchRequest<UserCoreData> = UserCoreData.fetchRequest()
        
        if let datas = try? CoreDataManager.shared.context.fetch(fetchRequest) {
            guard let userInfo = datas.first else { return nil }
            return userInfo
        } else {
            return nil
        }
    }
    
    static func vidsFromDictionary(dict: [String: Int]) -> [Int] {
        let dumlicatedVids = dict.values.map() { $0 }
        return Array(Set(dumlicatedVids)).sorted(by: < )
    }
    
    static func deleteSection(sid: Int) {
        var targetCoreDatas: [NSManagedObject] = []
        var targetVids: [Int] = []
        var targetPids: [Int] = []
        
        if let targetSection = CoreUsecase.fetchSection(sid: sid) {
            targetVids += CoreUsecase.vidsFromDictionary(dict: targetSection.dictionaryOfProblem)
            targetCoreDatas.append(targetSection)
        }
        
        targetVids.forEach { vid in
            if let targetPage = CoreUsecase.fetchPage(vid: vid) {
                targetPids += targetPage.problems
                targetCoreDatas.append(targetPage)
            }
        }
        
        targetPids.forEach { pid in
            if let targetProblem = CoreUsecase.fetchProblem(pid: pid) {
                targetCoreDatas.append(targetProblem)
            }
        }
        
        targetCoreDatas.forEach { coreData in
            CoreDataManager.shared.context.delete(coreData)
        }
        CoreDataManager.saveCoreData()
    }
                         
    static func createUserCoreData(userInfo: UserInfo?) {
        guard let userInfo = userInfo else { return }
        let context = CoreDataManager.shared.context
        let userCore = UserCoreData(context: context)
        userCore.setValues(userInfo: userInfo)
        do { try context.save() } catch let error { print(error.localizedDescription) }
    }
}
