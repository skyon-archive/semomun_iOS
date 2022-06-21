//
//  PracticeTestResultVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/06/21.
//

import UIKit
import Combine

final class PracticeTestResultVC: UIViewController, StoryboardController {
    /* public */
    static let identifier: String = "PracticeTestResultVC"
    static let storyboardNames: [UIUserInterfaceIdiom : String] = [
        .pad: "Study"
    ]
    /* private */
    private var viewModel: PracticeTestResultVM? = nil
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindAll()
        self.viewModel?.fetchResult()
    }
}

extension PracticeTestResultVC {
    func configureViewModel(_ viewModel: PracticeTestResultVM) {
        self.viewModel = viewModel
    }
}

extension PracticeTestResultVC {
    private func bindAll() {
        self.bindPracticeTestResult()
        self.bindAlert()
        self.bindNotConnectedToInternet()
    }
    
    private func bindPracticeTestResult() {
        self.viewModel?.$practiceTestResult
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] practiceTestResult in
                print(practiceTestResult)
            })
            .store(in: &self.cancellables)
    }
    
    private func bindAlert() {
        self.viewModel?.$alert
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] alertContent in
                guard let alertContent = alertContent else { return }
                self?.showAlertWithOK(title: alertContent.title, text: alertContent.message)
            })
            .store(in: &self.cancellables)
    }
    
    private func bindNotConnectedToInternet() {
        self.viewModel?.$notConnectedToInternet
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] notConnectedToInternet in
                print(notConnectedToInternet)
            })
            .store(in: &self.cancellables)
    }
}
