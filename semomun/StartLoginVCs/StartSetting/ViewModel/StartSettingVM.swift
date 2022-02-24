//
//  StartSettingVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/23.
//

import Foundation
import Combine

final class StartSettingVM {
    private let networkUsecase: NetworkUsecase
    @Published private(set) var tags: [String] = []
    @Published private(set) var error: String?
    @Published private(set) var warning: String?
    @Published private(set) var selectedTags: [String] = []
    private(set) var selectedIndexes: [Int] = []
    
    init(networkUsecase: NetworkUsecase) {
        self.networkUsecase = networkUsecase
    }
    
    func fetchTags() {
        // TODO: Network 에서 받아오는 로직 필요
        self.tags = ["수험서/자격증","대학교재","외국어","고등","중등","초등", "국가 기술 자격", "국가 전문 자격", "귀화시험", "민간자격", "국가직 7급 공무원", "국가직 9급 공무원", "경찰공무원", "소방공무원", "기타공무원 시험", "교원임용", "한국사능력검정시험", "공사 공단 수험서", "기업 적성 검사", "공인중개사/주택관리사", "법학적성시험", "MEET/DEET/PEET", "공인회계사", "검정고시", "변호사 시험", "취업/상식", "PSAT", "컴퓨터 활용 능력", "운전면허"]
    }
    
    func select(to index: Int) {
        // 제거
        if self.selectedIndexes.contains(index) {
            self.selectedIndexes = self.selectedIndexes.filter { $0 != index }
            self.selectedTags = self.selectedTags.filter { $0 != self.tags[index] }
        }
        // 추가
        else {
            if selectedTags.count >= 5 {
                self.warning = "5개 이하만 선택해주세요"
                return
            }
            self.selectedIndexes.append(index)
            self.selectedTags.append(self.tags[index])
        }
    }
    
    func tag(index: Int) -> String {
        return self.tags[index]
    }
    
    func saveUserDefaults() {
        UserDefaultsManager.set(to: self.selectedTags, forKey: .favoriteTags)
        UserDefaultsManager.set(to: false, forKey: .isInitial)
    }
    
    var isSelectFinished: Bool {
        return self.selectedTags.count > 0 && self.selectedTags.count <= 5
    }
}
