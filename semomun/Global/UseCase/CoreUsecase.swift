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
    
    static func downloadSection(sid: Int, pages: [PageOfDB], loading: LoadingDelegate, completion: @escaping (Section_Core?) -> Void) {
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
    
    static func downloadPracticeSection(section: SectionOfDB, workbook: Preview_Core, loading: LoadingDelegate, completion: @escaping (PracticeTestSection_Core?) -> Void) {
        let context = CoreDataManager.shared.context
        let practiceTestSectionCore = PracticeTestSection_Core(context: context)
        var pageCores: [Page_Core] = []
        var problemCores: [Problem_Core] = []
        
        var pageUUIDs: [PageUUID] = []
        var problemUUIDs: [ProblemUUID] = []
        var problemIndex: Int = 0
        
        print("----------save start----------")
        
        section.pages.forEach { page in
            let pageData = CoreUsecase.createPage(context: context, page: page, type: page.problems.last?.type ?? 5)
            let pageCore = pageData.page
            pageCores.append(pageCore)
            pageUUIDs.append(pageData.result)
            
            page.problems.forEach { problem in
                let problemData = CoreUsecase.createProblem(context: context, problem: problem, practiceTestSection: practiceTestSectionCore, page: pageCore, index: problemIndex)
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
                        Self.terminateDownload(section: section, practiceTestSection: practiceTestSectionCore, workbook: workbook, completion: completion)
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
                        Self.terminateDownload(section: section, practiceTestSection: practiceTestSectionCore, workbook: workbook, completion: completion)
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
    
    static private func createProblem(context: NSManagedObjectContext, problem: ProblemOfDB, practiceTestSection: PracticeTestSection_Core, page: Page_Core, index: Int) -> (problem: Problem_Core, result: ProblemUUID) {
        let problemCore = Problem_Core(context: context)
        let problemResult = problemCore.setValues(prob: problem, index: index)
        problemCore.pageCore = page
        problemCore.practiceSectionCore = practiceTestSection
        return (problem: problemCore, result: problemResult)
    }
    
    static private func terminateDownload(section: Section_Core, header: SectionHeader_Core, completion: ((Section_Core?) -> Void)) {
        print("----------download end----------")
        section.setValues(header: header)
        CoreDataManager.saveCoreData()
        completion(section)
    }
    
    static private func terminateDownload(section: SectionOfDB, practiceTestSection: PracticeTestSection_Core, workbook: Preview_Core, completion: ((PracticeTestSection_Core?) -> Void)) {
        print("----------download end----------")
        practiceTestSection.setValues(section: section, workbook: workbook)
        workbook.setDownloadedSection()
        CoreDataManager.saveCoreData()
        completion(practiceTestSection)
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
    
    static func fetchWorkbookGroups() -> [WorkbookGroup_Core]? {
        let fetchRequest: NSFetchRequest<WorkbookGroup_Core> = WorkbookGroup_Core.fetchRequest()
        if let workbookGroups = try? CoreDataManager.shared.context.fetch(fetchRequest) {
            return workbookGroups
        } else {
            print("Error: fetch workbookGroups")
            return nil
        }
    }
    
    static func fetchWorkbookGroup(wgid: Int) -> WorkbookGroup_Core? {
        let fetchRequest: NSFetchRequest<WorkbookGroup_Core> = WorkbookGroup_Core.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "wgid = %@", "\(wgid)")
        if let workbookGroups = try? CoreDataManager.shared.context.fetch(fetchRequest) {
            return workbookGroups.last
        } else {
            print("Error: fetch workbookGroup")
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
    static func fetchPreviews(wgid: Int) -> [Preview_Core]? {
        let fetchRequest: NSFetchRequest<Preview_Core> = Preview_Core.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "wgid = %@", "\(wgid)")
        
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
    
    static func fetchPracticeSection(sid: Int) -> PracticeTestSection_Core? {
        let fetchRequest: NSFetchRequest<PracticeTestSection_Core> = PracticeTestSection_Core.fetchRequest()
        let filter = NSPredicate(format: "sid = %@", "\(sid)")
        fetchRequest.predicate = filter
        
        if let fetches = try? CoreDataManager.shared.context.fetch(fetchRequest) {
            return fetches.last
        } else {
            print("Error: fetch section")
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
    /// WorkbookGroupDetailVC 상에서 구매로직, 책장으로 넘어가지 않은 상태에서 저장로직이 필요
    static func downloadWorkbook(wid: Int, networkUsecase: (UserWorkbooksFetchable & WorkbookSearchable & S3ImageFetchable), completion: @escaping (Bool) -> Void) {
        // Preview_Core 존재하는 경우 Error
        if let _ = Self.fetchPreview(wid: wid) {
            print("duplicated workbook error")
            completion(false)
            return
        }
        // 구매내역 -> workbook 저장
        print("fetch workbook infos")
        networkUsecase.getUserBookshelfInfos { status, infos in
            // Network Error
            guard status == .SUCCESS else {
                completion(false)
                return
            }
            // Purchased Workbook not exist
            guard let targetInfo = infos.first(where: { $0.wid == wid }) else {
                print("Purchased Workbook not exist")
                completion(false)
                return
            }
            // Fetch Workbook Info, save Preview_Core
            // SectionHeader_Core 는 별도로 저장하지 않는다
            networkUsecase.getWorkbook(wid: wid) { workbook in
                guard let workbook = workbook else {
                    print("workbook info fetch error")
                    completion(false)
                    return
                }

                let preview_Core = Preview_Core(context: CoreDataManager.shared.context)
                preview_Core.setValues(workbook: workbook, info: BookshelfInfo(info: targetInfo))
                preview_Core.fetchBookcover(uuid: workbook.bookcover, networkUsecase: networkUsecase) {
                    CoreDataManager.saveCoreData()
                    print("save preview(\(wid)) complete")
                    completion(true)
                    return
                }
            }
        }
    }
    
    /// WorkbookGroupDetailVC 상에서 구매로직, 책장으로 넘어가지 않은 상태에서 저장로직이 필요
    static func downloadWorkbookGroup(wgid: Int, networkUsecase: (UserWorkbookGroupsFetchable & WorkbookGroupSearchable & S3ImageFetchable), completion: @escaping (WorkbookGroup_Core?) -> Void) {
        // WorkbookGroup_Core 존재하는 경우 Error
        if let _ = Self.fetchWorkbookGroup(wgid: wgid) {
            print("duplicated workbook error")
            completion(nil)
            return
        }
        // 구매내역 -> workbookGroup 저장
        print("fetch workbookGroup infos")
        networkUsecase.getUserWorkbookGroupInfos { status, infos in
            // network Error
            guard status == .SUCCESS else {
                completion(nil)
                return
            }
            // Purchased Workbook not exist
            guard let targetInfo = infos.first(where: { $0.wgid == wgid }) else {
                print("Purchased WorkbookGroup not exist")
                completion(nil)
                return
            }
            // Fetch WorkbookGroup Info, save WorkbookGroup_Core
            networkUsecase.searchWorkbookGroup(wgid: wgid) { status, workbookGroup in
                guard status == .SUCCESS, let workbookGroup = workbookGroup else {
                    print("workbookGroup info fetch error")
                    completion(nil)
                    return
                }
                
                let workbookGroup_Core = WorkbookGroup_Core(context: CoreDataManager.shared.context)
                workbookGroup_Core.setValues(workbookGroup: workbookGroup, purchasedInfo: targetInfo)
                workbookGroup_Core.fetchGroupcover(uuid: workbookGroup.groupCover, networkUsecase: networkUsecase) {
                    CoreDataManager.saveCoreData()
                    print("save workbookGroup(\(wgid)) complete")
                    completion(workbookGroup_Core)
                    return
                }
            }
        }
    }
}
