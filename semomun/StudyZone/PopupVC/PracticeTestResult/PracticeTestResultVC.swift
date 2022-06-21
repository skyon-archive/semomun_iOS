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
    /// 뷰가 나타나고 애니메이션을 실행시키기 위한 백업용 변수
    private var privateProgress: Float = 0
    private var publicProgress: Float = 0
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var correctProblemCountLabel: UILabel!
    @IBOutlet weak var totalProblemCountLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var privateProgressView: CircularProgressView!
    @IBOutlet weak var publicProgressView: CircularProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureProgressView()
        self.bindAll()
        self.viewModel?.fetchResult()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.animateProgressView()
    }
}

// MARK: 외부 설정용
extension PracticeTestResultVC {
    func configureViewModel(_ viewModel: PracticeTestResultVM) {
        self.viewModel = viewModel
    }
}

// MARK: Configure
extension PracticeTestResultVC {
    private func configureProgressView() {
        self.publicProgressView.progressColor = UIColor(.munBlue) ?? .blue
        self.publicProgressView.trackColor = UIColor(.munLightBlue) ?? .lightGray
        self.publicProgressView.progressWidth = 22
        
        self.privateProgressView.progressColor = UIColor(.mainColor) ?? .green
        self.privateProgressView.trackColor = UIColor(.lightMainColor) ?? .lightGray
        self.privateProgressView.progressWidth = 22
    }
}

// MARK: Animate
extension PracticeTestResultVC {
    private func animateProgressView() {
        self.privateProgressView.setProgressWithAnimation(duration: 0.5, value: Float(self.privateProgress), from: 0)
        self.publicProgressView.setProgressWithAnimation(duration: 0.5, value: Float(self.publicProgress), from: 0)
    }
}

// MARK: Binding
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
                guard let practiceTestResult = practiceTestResult else { return }
                
                self?.titleLabel.text = practiceTestResult.title
                self?.correctProblemCountLabel.text = "\(practiceTestResult.correctProblemCount)"
                self?.totalProblemCountLabel.text = "\(practiceTestResult.totalProblemCount)"
                self?.totalTimeLabel.text = "\(practiceTestResult.totalTimeFormattedString)"
                
                self?.privateProgress = Float(practiceTestResult.privateScoreResult.correctRatio)
                self?.publicProgress = Float(practiceTestResult.publicScoreResult.correctRatio)
                
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
