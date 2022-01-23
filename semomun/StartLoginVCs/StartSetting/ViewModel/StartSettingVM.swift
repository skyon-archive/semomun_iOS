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
    @Published private(set) var mediumTags: [String] = []
    @Published private(set) var smallTags: [[String]] = [[]]
    @Published private(set) var currentMediumIndex: Int = 0
    @Published private(set) var currentSmallIndex: Int?
    @Published private(set) var error: String?
    private(set) var selectedMediumTag: String?
    private(set) var selectedSmallTag: String?
    
    init(networkUsecase: NetworkUsecase) {
        self.networkUsecase = networkUsecase
    }
    
    func fetchTags() {
        // TODO: Network 에서 받아오는 로직 필요
        self.mediumTags = ["수험서/자격증","대학교재","외국어","고등","중등","초등"]
        let small1 = ["국가 기술 자격", "국가 전문 자격", "귀화시험", "민간자격", "국가직 7급 공무원", "국가직 9급 공무원", "경찰공무원", "소방공무원", "기타공무원 시험", "교원임용", "한국사능력검정시험", "공사 공단 수험서", "기업 적성 검사", "공인중개사/주택관리사", "법학적성시험", "MEET/DEET/PEET", "공인회계사", "검정고시", "변호사 시험", "취업/상식", "PSAT", "컴퓨터 활용 능력", "운전면허"]
        let small2 = ["대학1", "대학2", "대학3"]
        let small3 = ["영어", "중국어", "프랑스어"]
        let small4 = ["고등1", "고등2", "고등3"]
        let small5 = ["중등1", "중등2", "중등3"]
        let small6 = ["초등1", "초등2", "초등3"]
        self.smallTags = [small1, small2, small3, small4, small5, small6]
    }
    
    func selectMedium(to index: Int) {
        self.selectedMediumTag = self.mediumTag(index: index)
        self.currentSmallIndex = nil
        self.selectedSmallTag = nil
        self.currentMediumIndex = index
    }
    
    func selectSmall(to index: Int) {
        self.currentSmallIndex = index
        self.selectedSmallTag = self.smallTag(index: index)
    }
    
    func mediumTag(index: Int) -> String {
        return self.mediumTags[index]
    }
    
    func smallTag(index: Int) -> String {
        return self.smallTags[currentMediumIndex][index]
    }
    
    func saveUserDefaults() {
        // TODO: 중분류, 소분류를 저장해야 하는지 의논 후 구조 생성할 예정
    }
    
    var smallTagsCount: Int {
        if self.smallTags.isEmpty {
            return 0
        } else {
            return self.smallTags[self.currentMediumIndex].count
        }
    }
    
    var isSelectFinished: Bool {
        return self.selectedMediumTag != nil && self.selectedSmallTag != nil
    }
}
