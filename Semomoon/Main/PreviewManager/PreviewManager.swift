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
            self.previews = try CoreDataManager.shared.context.fetch(fetchRequest)
        } catch let error {
            print(error.localizedDescription)
        }
        delegate.reloadData()
    }
    
    func preview(at: Int) -> Preview_Core {
        return self.previews[at]
    }
    
    func deletePreview(at: Int) {
        guard let title = self.previews[at].title else { return }
        delegate.deleteAlert(title: title, idx: at)
    }
    
    func delete(at: Int) {
        let object = self.previews[at]
        CoreDataManager.shared.context.delete(object)
        do {
            CoreDataManager.shared.appDelegate.saveContext()
            self.fetchPreviews()
        } catch let error {
            print(error.localizedDescription)
            CoreDataManager.shared.context.rollback()
        }
    }
    
    func showSelectSectionView(index: Int) -> Bool {
        return self.previews[index].sids.count > 1
    }
    
    func sectionOfCoreData(sid: Int) -> Section_Core? {
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
}
