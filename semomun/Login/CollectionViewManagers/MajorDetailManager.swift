//
//  MajorDetailManager.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/11.
//

import Foundation

protocol MajorDetailObserveable: AnyObject {
    func reload()
}

final class MajorDetailManager {
    weak var delegate: MajorDetailObserveable?
    private var items: [[String]] = [[]]
    private var currentSection: Int = 0
    private(set) var selectedSection: Int?
    private(set) var selectedIndex: Int?
    
    init(delegate: MajorDetailObserveable) {
        self.delegate = delegate
        NotificationCenter.default.addObserver(forName: SurveyViewController.NotificationName.selectMajor, object: nil, queue: .main) { [weak self] notification in
            guard let section = notification.userInfo?[SurveyViewController.NotificationUserInfo.sectionKey] as? Int else { return }
            self?.currentSection = section
            self?.selectedSection = nil
            self?.selectedIndex = nil
            self?.delegate?.reload()
        }
    }
    
    func updateItems(with majors: [[String: [String]]]) {
        self.items = majors.compactMap { Array($0.values).first}
    }
    
    var count: Int {
        return items[currentSection].count
    }
    
    func item(at: Int) -> String {
        return self.items[currentSection][at]
    }
    
    func selected(section: Int, to index: Int, completion: @escaping((String) -> Void)) {
        self.selectedSection = section
        self.selectedIndex = index
        completion(item(at: index))
    }
}
