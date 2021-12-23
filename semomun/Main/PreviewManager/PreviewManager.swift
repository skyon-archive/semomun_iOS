//
//  PreviewManager.swift
//  semomun
//
//  Created by Kang Minsang on 2021/10/16.
//

import Foundation
import CoreData

protocol PreviewDatasource: AnyObject {
    func reloadData()
    func deleteAlert(title: String, idx: Int)
}

class PreviewManager {
    weak var delegate: PreviewDatasource?
    
    private var subjects: [String] = ["전체"]
    private var currentFilter: String = "전체"
    private(set) var previews: [Preview_Core] = []
    private(set) var currentIndex: Int = 0
    
    init(delegate: PreviewDatasource) {
        self.delegate = delegate
    }
    
    func updateSubjects(with previews: [Preview_Core]) {
        self.subjects = ["전체"]
        for subject in previews.compactMap(\.subject) where !self.subjects.contains(subject) {
            self.subjects.append(subject)
        }
    }
    
    var subjectsCount: Int {
        return self.subjects.count
    }
    
    var previewsCount: Int {
        return self.previews.count
    }
    
    func subject(at: Int) -> String {
        return self.subjects[at]
    }
    
    func updateCategory(idx: Int) {
        self.currentIndex = idx
        self.currentFilter = subjects[idx]
        self.fetchPreviews()
    }
    
    func fetchPreviews() {
        self.previews.removeAll()
        
        guard let previews = CoreUsecase.fetchPreviews(subject: self.currentFilter) else {
            print("no previews")
            return
        }
        self.previews = previews
        self.updateSubjects(with: previews)
        
        DispatchQueue.main.async {
            self.delegate?.reloadData()
        }
    }
    
    func preview(at: Int) -> Preview_Core {
        return self.previews[at]
    }
    
    func deletePreview(at: Int) {
        guard let title = self.previews[at].title else { return }
        self.delegate?.deleteAlert(title: title, idx: at)
    }
    
    func delete(at: Int) {
        var targetCoreDatas: [NSManagedObject] = []
        let targetPreview = self.previews[at]
        targetCoreDatas.append(targetPreview)
        
        let targetSids = targetPreview.sids
        
        targetSids.compactMap({ CoreUsecase.fetchSection(sid: $0) }).forEach { targetSection in
            
            targetCoreDatas.append(targetSection)
            
            let targetVids = CoreUsecase.vidsFromDictionary(dict: targetSection.dictionaryOfProblem)
            
            targetVids.compactMap({ CoreUsecase.fetchPage(vid: $0) }).forEach { targetPage in
                
                targetCoreDatas.append(targetPage)
                
                let targetProblems = targetPage.problems
                targetCoreDatas += targetProblems.compactMap({CoreUsecase.fetchProblem(pid: $0)})
            }
        }
        
        targetCoreDatas.forEach { coreData in
            CoreDataManager.shared.context.delete(coreData)
        }
        CoreUsecase.saveCoreData()
        self.fetchPreviews()
    }
    
    func showSelectSectionView(index: Int) -> Bool {
        return self.preview(at: index).sids.count > 1
    }
}
