//
//  PreviewManager.swift
//  Semomoon
//
//  Created by qwer on 2021/10/16.
//

import Foundation
import CoreData

protocol PreviewDatasource: AnyObject {
    func reloadData()
    func deleteAlert(title: String, idx: Int)
}

class PreviewManager {
    static let identifier = "PreviewManager"
    
    weak var delegate: PreviewDatasource!
    
    // TODO: categoryButtons : 사용자의 다운로드 된 category들로 수정 : UserDefaults 에서 가져오는 식으로 변경
    let categoryButtons: [String] = ["전체", "국어", "수학"]
    var categoryIndex: Int = 0
    var queryDictionary: [String:NSPredicate] = [:]
    var currentFilter: String = "전체"
    
    var previews: [Preview_Core] = []
    
    init(delegate: PreviewDatasource) {
        self.delegate = delegate
        self.configureQueryDict()
    }
    
    func configureQueryDict() {
        // TODO: categoryButtons 값에 따라 결정되는 식으로 로직 변경
        self.queryDictionary["국어"] = NSPredicate(format: "subject = %@", "국어")
        self.queryDictionary["수학"] = NSPredicate(format: "subject = %@", "수학")
        self.queryDictionary["영어"] = NSPredicate(format: "subject = %@", "영어")
    }
    
    var categoryCount: Int {
        return self.categoryButtons.count
    }
    
    var previewCount: Int {
        return self.previews.count
    }
    
    func category(at: Int) -> String {
        return self.categoryButtons[at]
    }
    
    func updateCategory(idx: Int) {
        self.categoryIndex = idx
        self.currentFilter = categoryButtons[idx]
        self.fetchPreviews()
    }
    
    func fetchPreviews() {
        previews.removeAll()
        let fetchRequest: NSFetchRequest<Preview_Core> = Preview_Core.fetchRequest()
        if currentFilter != "전체" {
            let filter = queryDictionary[currentFilter]
            fetchRequest.predicate = filter
        }
        
        do {
            let loaded = try CoreDataManager.shared.context.fetch(fetchRequest)
            self.previews = try loaded
            
        } catch let error {
            print(error.localizedDescription)
        }
        DispatchQueue.main.async {
            self.delegate.reloadData()
        }
    }
    
    func preview(at: Int) -> Preview_Core {
        return self.previews[at]
    }
    
    func deletePreview(at: Int) {
        guard let title = self.previews[at].title else { return }
        delegate.deleteAlert(title: title, idx: at)
    }
    
    func delete(at: Int) {
        // TODO: 삭제 로직 수정
        var targetCoreDatas: [NSManagedObject] = []
        let targetPreview = self.previews[at]
        targetCoreDatas.append(targetPreview)
        
        let targetSids = targetPreview.sids
        var targetVids: [Int] = []
        var targetPids: [Int] = []
        
        targetSids.forEach { sid in
            if let targetSection = CoreUsecase.fetchSections(sid: sid) {
                targetVids += CoreUsecase.vidsFromDictionary(dict: targetSection.dictionaryOfProblem)
                targetCoreDatas.append(targetSection)
            }
        }
        
        targetVids.forEach { vid in
            if let targetPage = CoreUsecase.fetchPages(vid: vid) {
                targetPids += targetPage.problems
                targetCoreDatas.append(targetPage)
            }
        }
        
        targetPids.forEach { pid in
            if let targetProblem = CoreUsecase.fetchProblems(pid: pid) {
                targetCoreDatas.append(targetProblem)
            }
        }
        
        targetCoreDatas.forEach { coreData in
            CoreDataManager.shared.context.delete(coreData)
        }
        CoreUsecase.saveCoreData()
    }
    
    func showSelectSectionView(index: Int) -> Bool {
        return self.previews[index].sids.count > 1
    }
}
