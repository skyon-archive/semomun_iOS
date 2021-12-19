//
//  MajorDetailManager.swift
//  Semomoon
//
//  Created by Kang Minsang on 2021/12/11.
//

import Foundation

protocol MajorDetailObserveable: AnyObject {
    func reload()
}

final class MajorDetailManager {
    weak var delegate: MajorDetailObserveable?
    private var items1: [String] = []
    private var items2: [String] = []
    private var items3: [String] = []
    private var items: [[String]] = []
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
    
    func fetch(completion: @escaping(() -> Void)) {
        // TODO: 추후 DB 에서 수신하는 것으로 수정 예정
        self.items1 = ["인문", "상경", "사회", "교육", "기타"]
        self.items2 = ["공학", "자연", "의약", "생활과학", "기타"]
        self.items3 = ["미술", "음악", "체육", "기타"]
        self.items = [items1, items2, items3]
        completion()
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
