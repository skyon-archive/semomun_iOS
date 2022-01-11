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
    private var currentSubject: String = "전체"
    private(set) var currentCategory: String = "수능 및 모의고사"
    private(set) var previews: [Preview_Core] = []
    private(set) var currentIndex: Int = 0
    
    init(delegate: PreviewDatasource) {
        self.delegate = delegate
        self.configureCategory()
    }
    
    private func configureCategory() {
        guard let category = UserDefaultsManager.get(forKey: UserDefaultsManager.Keys.currentCategory) as? String else { return }
        self.currentCategory = category
    }
    
    func updateCategory(to category: String) {
        self.currentCategory = category
        self.selectSubject(idx: 0)
        self.fetchPreviews()
        self.fetchSubjects()
        self.delegate?.reloadData()
    }
    
    func fetchSubjects() {
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
    
    func selectSubject(idx: Int) {
        self.currentIndex = idx
        self.currentSubject = subjects[idx]
    }
    
    func fetchPreviews() {
        self.previews.removeAll()
        
        guard let previews = CoreUsecase.fetchPreviews(subject: self.currentSubject, category: self.currentCategory) else {
            print("no previews")
            return
        }
        self.previews = previews
    }
    
    func preview(at: Int) -> Preview_Core {
        return self.previews[at]
    }
    
    func showDeleteAlert(at: Int) {
        guard let title = self.previews[at].title else { return }
        self.delegate?.deleteAlert(title: title, idx: at)
    }
    
    func delete(at: Int) {
        if self.previews.count == 1 && self.currentSubject != "전체" {
            self.subjects = self.subjects.filter { $0 != self.currentSubject }
            self.selectSubject(idx: 0)
        }
        
        CoreUsecase.deletePreview(wid: Int(self.previews[at].wid))
        self.fetchPreviews()
        
        if self.currentSubject == "전체" {
            self.fetchSubjects()
        }
        self.delegate?.reloadData()
    }
    
    func showSelectSectionView(index: Int) -> Bool {
        return self.preview(at: index).sids.count > 1
    }
    
    func checkSubject(with category: String) {
        if self.subjects.contains(category) { return }
        self.subjects.append(category)
    }
}
