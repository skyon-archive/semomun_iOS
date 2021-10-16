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
    func deleteAlert(title: String?)
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
    
    func delegePreview(at: Int) {
        guard let title = self.previews[at].title else { return }
        delegate.deleteAlert(title: self.previews[at].title)
    }
}
