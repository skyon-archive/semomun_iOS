//
//  PracticeTestManager.swift
//  semomun
//
//  Created by Kang Minsang on 2022/06/27.
//

import Foundation
import Combine

final class PracticeTestManager {
    @Published private(set) var sectionTitle: String = "title"
    @Published private(set) var recentTime: Int64 = 0
    @Published private(set) var currentPage: PageData?
    private(set) var problems: [Problem_Core] = []
    private(set) var section: PracticeTestSection_Core
    private(set) var currentIndex: Int = 0
    private weak var delegate: LayoutDelegate?
    private let workbook: Preview_Core
    private var timer: Timer!
    private var isRunning: Bool = true
    private let networkUsecase: UserSubmissionSendable
    /// WorkbookGroupDetailVC 에서 VM 생성
    init(section: PracticeTestSection_Core, workbook: Preview_Core, networkUsecase: UserSubmissionSendable) {
        self.section = section
        self.workbook = workbook
        self.networkUsecase = networkUsecase
    }
    /// StudyVC 내에서 delegate 설정 및 configure 로직 수행
    func configureDelegate(to delegate: LayoutDelegate) {
        self.delegate = delegate
    }
}
