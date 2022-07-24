//
//  PracticeTestResultVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/22.
//

import UIKit
import Combine

final class PracticeTestResultVC: UIViewController {
    /* private */
    private let customView = PracticeTestResultView()
    private let viewModel: PracticeTestResultVM
    private var cancellables: Set<AnyCancellable> = []
    
    init(viewModel: PracticeTestResultVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.customView.closeButton.addAction(UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        }, for: .touchUpInside)
        self.bindAll()
        self.viewModel.fetchResult()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = self.customView
    }
}

extension PracticeTestResultVC {
    private func bindAll() {
        self.bindPracticeTestResult()
        self.bindPublicScoreResult()
    }
    
    private func bindPracticeTestResult() {
        self.viewModel.$practiceTestResult
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] practiceTestResult in
                guard let practiceTestResult = practiceTestResult else { return }
                self?.customView.configureLocalContent(practiceTestResult: practiceTestResult)
            })
            .store(in: &self.cancellables)
    }
    
    private func bindPublicScoreResult() {
        self.viewModel.$publicScoreResult
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] publicScoreResult in
                guard let publicScoreResult = publicScoreResult else { return }
                guard let perfectScore = self?.viewModel.perfectScore else { return }
                self?.customView.configureServerContent(publicTestResult: publicScoreResult, perfectScore: Int(perfectScore))
            })
            .store(in: &self.cancellables)
    }
}
