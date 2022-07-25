//
//  SingleWith5AnswerVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import PencilKit

final class SingleWith5AnswerVC: FormZero {
    /* public */
    static let identifier = "SingleWith5AnswerVC" // form == 0 && type == 5
    static let storyboardName = "Study"
    var viewModel: SingleWith5AnswerVM?
    /* private */
//    @IBOutlet var checkButtons: [UIButton]!
    
//    private lazy var checkImageViews: [UIImageView] = (0..<self.checkButtons.count).map { _ in
//        let imageView = UIImageView()
//        imageView.backgroundColor = UIColor.clear
//        imageView.contentMode = .scaleAspectFit
//        imageView.image = UIImage(named: "check")
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.isHidden = true
//
//        return imageView
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 5다선지 관련 configure
        self.configureCheckButtonLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateCheckedButtons()
        self.updateUIIfTerminated()
        if let viewModel = viewModel{
            self.toolbarView.updateUI(mode: viewModel.mode, problem: viewModel.problem, answer: viewModel.answerStringForUser())
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel?.startTimeRecord()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.checkImageViews.forEach { $0.isHidden = true }
        self.endTimeRecord()
    }
    
    @IBAction func selectAnswer(_ sender: UIButton) {
        guard self.viewModel?.problem?.terminated == false else { return }
        self.updateSelectedButton(tag: sender.tag)
    }
    
    /* 상위 class를 위하여 override가 필요한 Property들 */
    override var problem: Problem_Core? {
        return self.viewModel?.problem
    }
    override var topViewHeight: CGFloat {
//        return self.topView.frame.height
        return 72
    }
    /* 상위 class를 위하여 override가 필요한 메소드들 */
    override func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let data = self.canvasView.drawing.dataRepresentation()
        self.viewModel?.updatePencilData(to: data, width: Double(self.canvasView.frame.width))
    }
}

// MARK: IBAction
extension SingleWith5AnswerVC {
    private func updateSelectedButton(tag: Int) {
//        guard let vm = self.viewModel else { return }
//
//        if vm.shouldChooseMultipleAnswer {
//            self.checkButtons[tag-1].isSelected.toggle()
//        } else {
//            self.checkButtons.forEach { $0.isSelected = false }
//            self.checkButtons[tag-1].isSelected = true
//        }
//        self.updateButtonUI()
//
//        // Solved값 업데이트
//        let selectedButtonTags = self.checkButtons.filter(\.isSelected).map(\.tag)
//        vm.updateSolved(withSelectedAnswers: selectedButtonTags)
    }
}

// MARK: Configure
extension SingleWith5AnswerVC {
    private func configureCheckButtonLayout() {
//        zip(self.checkButtons, self.checkImageViews).forEach { button, imageView in
//            button.addSubview(imageView)
//            NSLayoutConstraint.activate([
//                imageView.widthAnchor.constraint(equalToConstant: 75),
//                imageView.heightAnchor.constraint(equalToConstant: 75),
//                imageView.centerXAnchor.constraint(equalTo: button.centerXAnchor, constant: 10),
//                imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor, constant: -10)
//            ])
//        }
    }
}

// MARK: Update
extension SingleWith5AnswerVC {
    private func updateCheckedButtons() {
//        self.checkButtons.forEach { $0.isSelected = false }
//        self.viewModel?.savedSolved.forEach { self.checkButtons[$0-1].isSelected = true }
//        self.updateButtonUI()
    }
    
    private func updateButtonUI() {
//        self.checkButtons.forEach { button in
//            if button.isSelected {
//                button.backgroundColor = UIColor(.blueRegular)
//                button.setTitleColor(UIColor.white, for: .normal)
//            } else {
//                button.backgroundColor = UIColor.white
//                button.setTitleColor(UIColor(.blueRegular), for: .normal)
//            }
//        }
    }
    
    /// 채점이 완료된 경우 && 틀린 경우 정답을 빨간색으로 표시
    private func updateUIIfTerminated() {
//        guard let problem = self.viewModel?.problem else { return }
//
//        if problem.terminated {
//            self.viewModel?.answer.forEach {
//                self.checkImageViews[$0-1].isHidden = false
//            }
//
//            if problem.answer != nil {
//                self.showResultImage(to: problem.correct)
//            }
//        }
    }
}

extension SingleWith5AnswerVC: TimeRecordControllable {
    func endTimeRecord() {
        self.viewModel?.endTimeRecord()
    }
}

extension SingleWith5AnswerVC: StudyToolbarViewDelegate {
    func toggleBookmark() {
        self.viewModel?.updateStar(to: self.toolbarView.bookmarkSelected)
    }
    
    func toggleExplanation() {
        if self.explanationShown {
            self.closeExplanation()
        } else {
            guard let imageData = self.viewModel?.problem?.explanationImage else { return }
            self.showExplanation(to: UIImage(data: imageData))
        }
    }
}
