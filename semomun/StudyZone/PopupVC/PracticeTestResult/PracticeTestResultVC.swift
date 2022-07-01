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
    private var viewModel: PracticeTestResultVM?
    private var cancellables: Set<AnyCancellable> = []
    // MARK: 뷰가 나타나면 애니메이션을 실행시키기 위한 저장용 변수들
    /// viewDidAppear 이전에 값이 반드시 존재하므로 optional 아님
    private var privateProgress: Float = 0
    /// viewDidAppear 이전에 값이 존재하지 않을 수 있으므로(네트워크 연결 필요) optional
    private var publicProgress: Float?
    private var initialAnimationEnded = false
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var correctProblemCountLabel: UILabel!
    @IBOutlet weak var totalProblemCountLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var privateProgressView: CircularProgressView!
    @IBOutlet weak var publicProgressView: CircularProgressView!
    @IBOutlet weak var privateScoreResultView: ScoreResultView!
    @IBOutlet weak var publicScoreResultView: ScoreResultView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureProgressView()
        self.bindAll()
        self.viewModel?.fetchResult()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.initialAnimationEnded == false {
            self.animateProgessView()
        }
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true)
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

// MARK: Binding
extension PracticeTestResultVC {
    private func bindAll() {
        self.bindPracticeTestResult()
        self.bindPublicScoreResult()
        self.bindNotConnectedToInternet()
    }
    
    private func bindPracticeTestResult() {
        self.viewModel?.$practiceTestResult
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] practiceTestResult in
                guard let practiceTestResult = practiceTestResult else { return }
                
                self?.privateProgress = Float(practiceTestResult.privateScoreResult.correctRatio)
                self?.configureLabels(practiceTestResult: practiceTestResult)
                self?.configureScoreResultView(practiceTestResult: practiceTestResult)
            })
            .store(in: &self.cancellables)
    }
    
    private func bindPublicScoreResult() {
        self.viewModel?.$publicScoreResult
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] publicScoreResult in
                guard let publicScoreResult = publicScoreResult else { return }
                
                self?.publicScoreResultView.updateContent(
                    title: "세모문 사용자 예상 등급",
                    scoreResult: publicScoreResult,
                    rankContainerBackgroundColor: UIColor(.munBlue) ?? .blue
                )
                
                guard let initialAnimationEnded = self?.initialAnimationEnded else { return }
                
                self?.publicProgress = Float(publicScoreResult.correctRatio)
                
                // 네트워크에서 정보를 받아오기 전에 첫번째 viewDidAppear가 끝났거나, 인터넷이 재연결되어 publicScoreResult가 다시 할당된 경우
                // 이 때는 뷰가 보여져있는 상태이므로 이곳에서 애니메이션을 수행해도 좋다.
                if initialAnimationEnded {
                    self?.publicProgressView.setProgressWithAnimation(duration: 0.5, value: Float(publicScoreResult.correctRatio), from: 0)
                }
            })
            .store(in: &self.cancellables)
    }
    
    private func bindNotConnectedToInternet() {
        self.viewModel?.$notConnectedToInternet
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] notConnectedToInternet in
                if notConnectedToInternet == true {
                    self?.publicScoreResultView.updateForNoInternet()
                    
                    guard let publicProgess = self?.publicProgress else { return }
                    self?.publicProgressView.setProgressWithAnimation(duration: 0.5, value: 0, from: publicProgess)
                }
            })
            .store(in: &self.cancellables)
    }
}

extension PracticeTestResultVC {
    private func configureLabels(practiceTestResult: PracticeTestResult) {
        self.titleLabel.text = practiceTestResult.title
        self.correctProblemCountLabel.text = "\(practiceTestResult.correctProblemCount)"
        self.totalProblemCountLabel.text = "\(practiceTestResult.totalProblemCount)"
        self.totalTimeLabel.text = "\(practiceTestResult.totalTimeFormattedString)"
    }
    
    private func configureScoreResultView(practiceTestResult: PracticeTestResult) {
        self.privateScoreResultView.updateContent(
            title: "나의 예상 등급",
            scoreResult: practiceTestResult.privateScoreResult,
            rankContainerBackgroundColor: UIColor(.mainColor) ?? .green
        )
    }
}

// MARK: Animation
extension PracticeTestResultVC {
    /// 뷰가 맨 처음 보일 때의 progress 애니메이션을 수행
    private func animateProgessView() {
        self.privateProgressView.setProgressWithAnimation(duration: 0.5, value: privateProgress, from: 0)
        if let publicProgress = self.publicProgress {
            self.publicProgressView.setProgressWithAnimation(duration: 0.5, value: publicProgress, from: 0)
        }
        self.initialAnimationEnded = true
    }
}
