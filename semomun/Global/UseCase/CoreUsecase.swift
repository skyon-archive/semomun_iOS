//
//  CoreUsecase.swift
//  semomun
//
//  Created by Kang Minsang on 2021/10/17.
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
    
    static func savePages(sid: Int, pages: [PageOfDB], loading: LoadingDelegate, completion: @escaping (Section_Core?) -> Void) {
        guard let sectionHeader = Self.fetchSectionHeader(sid: sid), pages.isEmpty == false else {
            completion(nil)
            return
        }
        
        let context = CoreDataManager.shared.context
        let sectionCore = Section_Core(context: context)
        var pageCores: [Page_Core] = []
        var problemCores: [Problem_Core] = []
        
        var pageUUIDs: [PageUUID] = []
        var problemUUIDs: [ProblemUUID] = []
        var problemIndex: Int = 0
        
        print("----------save start----------")
        
        pages.forEach { page in
            let pageData = CoreUsecase.createPage(context: context, page: page, type: page.problems.last?.type ?? 5)
            let pageCore = pageData.page
            pageCores.append(pageCore)
            pageUUIDs.append(pageData.result)
            
            page.problems.forEach { problem in
                let problemData = CoreUsecase.createProblem(context: context, problem: problem, section: sectionCore, page: pageCore, index: problemIndex)
                let problemCore = problemData.problem
                problemCores.append(problemCore)
                problemUUIDs.append(problemData.result)
                problemIndex += 1
            }
        }
        
        print("----------save end----------")
        
        let pageImageCount = pageUUIDs.filter({ $0.material != nil }).count // 지문이미지 수
        let problemImageCount = problemUUIDs.reduce(0) { $0 + $1.imageCount } // 문제+해설 이미지 수
        let loadingCount: Int = pageImageCount + problemImageCount
        var currentCount: Int = 0
        loading.setCount(to: loadingCount)
        
        let networkUsecase = NetworkUsecase(network: Network())
        DispatchQueue.global().async {
            for idx in 0..<problemCores.count {
                let problemCore = problemCores[idx]
                let problemUUID = problemUUIDs[idx]
                
                problemCore.fetchImages(uuids: problemUUID, networkUsecase: networkUsecase) {
                    loading.oneProgressDone()
                    currentCount += 1
                    print("\(currentCount)/\(loadingCount)")
                    
                    if currentCount == loadingCount {
                        Self.terminateDownload(section: sectionCore, header: sectionHeader, completion: completion)
                    }
                }
            }
            
            for idx in 0..<pageCores.count {
                let pageCore = pageCores[idx]
                let pageUUID = pageUUIDs[idx]
                pageCore.setMaterial(uuid: pageUUID, networkUsecase: networkUsecase) {
                    loading.oneProgressDone()
                    currentCount += 1
                    print("\(currentCount)/\(loadingCount)")
                    
                    if currentCount == loadingCount {
                        Self.terminateDownload(section: sectionCore, header: sectionHeader, completion: completion)
                    }
                }
            }
        }
    }
    
    static private func createPage(context: NSManagedObjectContext, page: PageOfDB, type: Int) -> (page: Page_Core, result: PageUUID) {
        let pageCore = Page_Core(context: context)
        let pageResult = pageCore.setValues(page: page, type: type)
        return (page: pageCore, result: pageResult)
    }
    
    static private func createProblem(context: NSManagedObjectContext, problem: ProblemOfDB, section: Section_Core, page: Page_Core, index: Int) -> (problem: Problem_Core, result: ProblemUUID) {
        let problemCore = Problem_Core(context: context)
        let problemResult = problemCore.setValues(prob: problem, index: index)
        problemCore.pageCore = page
        problemCore.sectionCore = section
        return (problem: problemCore, result: problemResult)
    }
    
    static private func terminateDownload(section: Section_Core, header: SectionHeader_Core, completion: ((Section_Core?) -> Void)) {
        print("----------download end----------")
        section.setValues(header: header)
        CoreDataManager.saveCoreData()
        completion(section)
    }
    
    static func fetchSectionHeader(sid: Int) -> SectionHeader_Core? {
        let fetchRequest: NSFetchRequest<SectionHeader_Core> = SectionHeader_Core.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "sid = %@", "\(sid)")
        if let sectionHeaders = try? CoreDataManager.shared.context.fetch(fetchRequest) {
            return sectionHeaders.first
        } else {
            print("Error: fetch sectionHeader")
            return nil
        }
    }
    
    static func fetchSectionHeaders(wid: Int) -> [SectionHeader_Core]? {
        let fetchRequest: NSFetchRequest<SectionHeader_Core> = SectionHeader_Core.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "wid = %@", "\(wid)")
        
        if let sectionHeaders = try? CoreDataManager.shared.context.fetch(fetchRequest) {
            return sectionHeaders
        } else {
            print("Error: fetch sectionHeaders")
            return nil
        }
    }
    
    static func fetchPreviews(subject: String, category: String) -> [Preview_Core]? {
        let fetchRequest: NSFetchRequest<Preview_Core> = Preview_Core.fetchRequest()
        var filters: [NSPredicate] = []
        filters.append(NSPredicate(format: "category = %@", category))
        if subject != "전체" {
            filters.append(NSPredicate(format: "subject = %@", subject))
        }
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: filters)
        
        if let previews = try? CoreDataManager.shared.context.fetch(fetchRequest) {
            return previews
        } else {
            print("Error: fetch previews")
            return nil
        }
    }
    
    static func fetchPreviews() -> [Preview_Core]? {
        let fetchRequest: NSFetchRequest<Preview_Core> = Preview_Core.fetchRequest()
        if let previews = try? CoreDataManager.shared.context.fetch(fetchRequest) {
            return previews
        } else {
            print("Error: fetch previews")
            return nil
        }
    }
    
    static func fetchPreview(wid: Int) -> Preview_Core? {
        let fetchRequest: NSFetchRequest<Preview_Core> = Preview_Core.fetchRequest()
        let filter = NSPredicate(format: "wid = %@", "\(wid)")
        fetchRequest.predicate = filter
        
        if let fetches = try? CoreDataManager.shared.context.fetch(fetchRequest) {
            return fetches.first
        } else {
            print("Error: fetch preview")
            return nil
        }
    }
    
    static func fetchSection(sid: Int) -> Section_Core? {
        let fetchRequest: NSFetchRequest<Section_Core> = Section_Core.fetchRequest()
        let filter = NSPredicate(format: "sid = %@", "\(sid)")
        fetchRequest.predicate = filter
        
        if let fetches = try? CoreDataManager.shared.context.fetch(fetchRequest) {
            return fetches.first
        } else {
            print("Error: fetch section")
            return nil
        }
    }
    
    static func fetchSections() -> [Section_Core]? {
        let fetchRequest: NSFetchRequest<Section_Core> = Section_Core.fetchRequest()
        if let sections = try? CoreDataManager.shared.context.fetch(fetchRequest) {
            return sections
        } else {
            print("Error: fetch all sections")
            return nil
        }
    }
    
    static func fetchPage(vid: Int) -> Page_Core? {
        let fetchRequest: NSFetchRequest<Page_Core> = Page_Core.fetchRequest()
        let filter = NSPredicate(format: "vid = %@", "\(vid)")
        fetchRequest.predicate = filter
        
        if let fetches = try? CoreDataManager.shared.context.fetch(fetchRequest) {
            return fetches.first
        } else {
            print("Error: fetch page")
            return nil
        }
    }
    
    static func fetchProblem(pid: Int) -> Problem_Core? {
        let fetchRequest: NSFetchRequest<Problem_Core> = Problem_Core.fetchRequest()
        let filter = NSPredicate(format: "pid = %@", "\(pid)")
        fetchRequest.predicate = filter
        
        if let fetches = try? CoreDataManager.shared.context.fetch(fetchRequest) {
            return fetches.first
        } else {
            print("Error: fetch problem")
            return nil
        }
    }
    
    static func fetchUserInfo() -> UserCoreData? {
        let fetchRequest: NSFetchRequest<UserCoreData> = UserCoreData.fetchRequest()
        
        if let fetches = try? CoreDataManager.shared.context.fetch(fetchRequest) {
            return fetches.first
        } else {
            print("Error: fetch userInfo")
            return nil
        }
    }
    
    static func vidsFromDictionary(dict: [String: Int]) -> [Int] {
        let dumlicatedVids = dict.values.map() { $0 }
        return Array(Set(dumlicatedVids)).sorted(by: < )
    }
    
    static func deleteAllCoreData() {
        guard let allPreviews = CoreUsecase.fetchPreviews() else {
            print("Error: fetch all preview")
            return
        }
        
        allPreviews.forEach { preview in
            CoreUsecase.deletePreview(wid: Int(preview.wid))
        }
        guard let userInfo = CoreUsecase.fetchUserInfo() else {
            print("Error: fetch userinfo")
            return
        }
        CoreDataManager.shared.context.delete(userInfo)
        CoreDataManager.saveCoreData()
        print("CoreData delete complete")
    }
    
    static func deletePreview(wid: Int) {
        guard let targetPreview = CoreUsecase.fetchPreview(wid: wid) else {
            print("Error: fetch preview")
            return
        }
        var targetCoreDatas: [NSManagedObject] = []
        targetCoreDatas.append(targetPreview)
        let targetSids = targetPreview.sids
        
        targetCoreDatas += targetSids.compactMap({ CoreUsecase.fetchSectionHeader(sid: $0) })
        targetSids.forEach { sid in
            CoreUsecase.deleteSection(sid: sid)
        }
        
        targetCoreDatas.forEach { coreData in
            CoreDataManager.shared.context.delete(coreData)
        }
        CoreDataManager.saveCoreData()
        print("sectionHeader delete complete")
        print("preview delete complete")
    }
    
    static func deleteSection(sid: Int) {
        guard let targetSection = CoreUsecase.fetchSection(sid: sid) else {
            print("fetch section error")
            return
        }
        var targetCoreDatas: [NSManagedObject] = []
        targetCoreDatas.append(targetSection)
        let targetVids = CoreUsecase.vidsFromDictionary(dict: targetSection.dictionaryOfProblem)
        
        targetVids.compactMap({ CoreUsecase.fetchPage(vid: $0) }).forEach { targetPage in
            targetCoreDatas.append(targetPage)
            let targetProblems = targetPage.problems
            targetCoreDatas += targetProblems.compactMap({ CoreUsecase.fetchProblem(pid: $0)} )
        }
        
        targetCoreDatas.forEach { coreData in
            CoreDataManager.shared.context.delete(coreData)
        }
        CoreDataManager.saveCoreData()
        print("section delete complete")
    }
                         
    static func createUserCoreData(userInfo: UserInfo) {
        let context = CoreDataManager.shared.context
        let userCore = UserCoreData(context: context)
        userCore.setValues(userInfo: userInfo)
        CoreDataManager.saveCoreData()
    }
}


extension CoreUsecase {
    static func createMockDataForMulty() {
        let context = CoreDataManager.shared.context
        
        //5Answer
        let problemOfCore1 = Problem_Core(context: context)
        problemOfCore1.setMocks(pid: -200, type: 5, btName: "1", imgName: "mock1", expName: "exp1", answer: "1")
        let pageOfCore1 = Page_Core(context: context)
        pageOfCore1.setMocks(vid: -50, form: 0, type: 5, pids: [-200], mateImgName: nil)
        
        let problemOfCore2 = Problem_Core(context: context)
        problemOfCore2.setMocks(pid: -199, type: 5, btName: "2", imgName: "mock2", expName: "exp2", answer: "3")
        let pageOfCore2 = Page_Core(context: context)
        pageOfCore2.setMocks(vid: -49, form: 0, type: 5, pids: [-199], mateImgName: nil)
        
        let problemOfCore3 = Problem_Core(context: context)
        problemOfCore3.setMocks(pid: -198, type: 5, btName: "3", imgName: "mock3", expName: "exp4", answer: "2")
        let pageOfCore3 = Page_Core(context: context)
        pageOfCore3.setMocks(vid: -48, form: 0, type: 5, pids: [-198], mateImgName: nil)
        
        let problemOfCore4 = Problem_Core(context: context)
        problemOfCore4.setMocks(pid: -197, type: 5, btName: "4", imgName: "mock4", answer: "5")
        let pageOfCore4 = Page_Core(context: context)
        pageOfCore4.setMocks(vid: -47, form: 0, type: 5, pids: [-197], mateImgName: nil)
        
        //Text
        let problemOfCore5 = Problem_Core(context: context)
        problemOfCore5.setMocks(pid: -196, type: 1, btName: "5", imgName: "mock5", expName: "exp3", answer: "123")
        let pageOfCore5 = Page_Core(context: context)
        pageOfCore5.setMocks(vid: -46, form: 0, type: 1, pids: [-196], mateImgName: nil)
        
        //Multi 5
        let problemOfCore6 = Problem_Core(context: context)
        problemOfCore6.setMocks(pid: -195, type: 5, btName: "6", imgName: "mockImg11", expName: "exp1", answer: "1")
        let problemOfCore7 = Problem_Core(context: context)
        problemOfCore7.setMocks(pid: -194, type: 5, btName: "7", imgName: "mockImg12", expName: "exp2", answer: "5")
        let problemOfCore8 = Problem_Core(context: context)
        problemOfCore8.setMocks(pid: -193, type: 5, btName: "8", imgName: "mockImg13", answer: "3")
        let problemOfCore9 = Problem_Core(context: context)
        problemOfCore9.setMocks(pid: -192, type: 5, btName: "9", imgName: "mockImg14", answer: "4")
        
        let pageOfCore6 = Page_Core(context: context)
        pageOfCore6.setMocks(vid: -45, form: 1, type: 5, pids: [-195, -194, -193, -192], mateImgName: "material1")
        
        let problemOfCore10 = Problem_Core(context: context)
        problemOfCore10.setMocks(pid: -191, type: 5, btName: "10", imgName: "mockImg21", expName: "exp3", answer: "5")
        let problemOfCore11 = Problem_Core(context: context)
        problemOfCore11.setMocks(pid: -190, type: 5, btName: "11", imgName: "mockImg22", expName: "exp4", answer: "2")
        let problemOfCore12 = Problem_Core(context: context)
        problemOfCore12.setMocks(pid: -189, type: 5, btName: "12", imgName: "mockImg23", answer: "2")
        let problemOfCore13 = Problem_Core(context: context)
        problemOfCore13.setMocks(pid: -188, type: 5, btName: "13", imgName: "mockImg24", answer: "1")
        
        let pageOfCore7 = Page_Core(context: context)
        pageOfCore7.setMocks(vid: -44, form: 1, type: 5, pids: [-191, -190, -189, -188], mateImgName: "material2")
        
        //4Answer
        let problemOfCore14 = Problem_Core(context: context)
        problemOfCore14.setMocks(pid: -187, type: 4, btName: "14", imgName: "mock1", expName: "exp1", answer: "1")
        let pageOfCore8 = Page_Core(context: context)
        pageOfCore8.setMocks(vid: -43, form: 0, type: 4, pids: [-187], mateImgName: nil)
        
        let problemOfCore15 = Problem_Core(context: context)
        problemOfCore15.setMocks(pid: -186, type: 4, btName: "15", imgName: "mock2", expName: "exp2", answer: "3")
        let pageOfCore9 = Page_Core(context: context)
        pageOfCore9.setMocks(vid: -42, form: 0, type: 4, pids: [-186], mateImgName: nil)
        
        //Multi No
        let problemOfCore16 = Problem_Core(context: context)
        problemOfCore16.setMocks(pid: -185, type: 0, btName: "16", imgName: "mock1")
        let problemOfCore17 = Problem_Core(context: context)
        problemOfCore17.setMocks(pid: -184, type: 0, btName: "17", imgName: "mock2")
        
        let pageOfCore10 = Page_Core(context: context)
        pageOfCore10.setMocks(vid: -41, form: 1, type: 0, pids: [-185, -184], mateImgName: "material1")
        
        // Concept
        let problemOfCore18 = Problem_Core(context: context)
        problemOfCore18.setMocks(pid: -183, type: -1, btName: "개념", imgName: "mock3")
        let pageOfCore11 = Page_Core(context: context)
        pageOfCore11.setMocks(vid: -40, form: 0, type: -1, pids: [-183], mateImgName: nil)
        
        // Single No Answer
        let problemOfCore19 = Problem_Core(context: context)
        problemOfCore19.setMocks(pid: -182, type: 0, btName: "기본", imgName: "mock4", expName: "exp1")
        let pageOfCore12 = Page_Core(context: context)
        pageOfCore12.setMocks(vid: -39, form: 0, type: 0, pids: [-182], mateImgName: nil)
        
        
        //Section
        let sectionCore = Section_Core(context: context)
        let buttons = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "개념", "기본"]
        let dict = ["1": -50, "2": -49, "3": -48, "4": -47, "5": -46,
                    "6": -45, "7": -45, "8": -45, "9": -45,
                    "10": -44, "11": -44, "12": -44, "13": -44,
                    "14": -43, "15": -42,
                    "16": -41, "17": -41,
                    "개념": -40, "기본": -39]
        sectionCore.setMocks(sid: -1, buttons: buttons, dict: dict)
        
        do { try context.save() } catch let error { print(error.localizedDescription) }
        print("MOCK SAVE COMPLETE")
    }
}
