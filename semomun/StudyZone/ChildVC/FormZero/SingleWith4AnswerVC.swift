//
//  SingleWith4AnswerVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import PencilKit

final class SingleWith4AnswerVC: FormZero {
    static let identifier = "SingleWith4AnswerVC" // form == 0 && type == 4
    static let storyboardName = "Study"
    
    @IBOutlet weak var bookmarkBT: UIButton!
    @IBOutlet weak var explanationBT: UIButton!
    @IBOutlet weak var answerBT: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewTrailing: NSLayoutConstraint!
    @IBOutlet var checkButtons: [UIButton]!
    
    var viewModel: SingleWith4AnswerVM?
    
    private lazy var checkImageViews: [UIImageView] = (0..<self.checkButtons.count).map { _ in
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "check")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        
        return imageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTimerViewLayout()
        // 4다선지 관련 configure
        self.configureCheckButtonLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateCheckedButtons()
        self.updateBookmarkBT()
        self.updateAnswerBT()
        self.updateExplanationBT()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel?.startTimeRecord()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.checkImageViews.forEach { $0.isHidden = true }
        self.endTimeRecord()
    }
    
    @IBAction func selectAnswer(_ sender: UIButton) {
        guard self.viewModel?.problem?.terminated == false else { return }
        self.updateSelectedButton(tag: sender.tag)
    }
    
    @IBAction func toggleBookmark(_ sender: Any) {
        self.bookmarkBT.isSelected.toggle()
        self.viewModel?.updateStar(to: self.bookmarkBT.isSelected)
    }
    
    @IBAction func showExplanation(_ sender: Any) {
        if self.explanationShown {
            self.closeExplanation()
        } else {
            guard let imageData = self.viewModel?.problem?.explanationImage else { return }
            self.showExplanation(to: UIImage(data: imageData))
        }
    }
    
    @IBAction func showAnswer(_ sender: Any) {
        guard let answer = self.viewModel?.answerStringForUser() else { return }
        self.answerView.configureAnswer(to: answer)
        
        self.view.addSubview(self.answerView)
        NSLayoutConstraint.activate([
            self.answerView.topAnchor.constraint(equalTo: self.answerBT.bottomAnchor),
            self.answerView.leadingAnchor.constraint(equalTo: self.answerBT.centerXAnchor)
        ])
        self.answerView.showShortTime()
    }
    
    /* 상위 class를 위하여 override가 필요한 Property들 */
    override var problem: Problem_Core? {
        return self.viewModel?.problem
    }
    override var topViewHeight: CGFloat {
        return self.topView.frame.height
    }
    /* 상위 class를 위하여 override가 필요한 메소드들 */
    override func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let data = self.canvasView.drawing.dataRepresentation()
        self.viewModel?.updatePencilData(to: data, width: Double(self.canvasView.frame.width))
    }
}

// MARK: IBAction
extension SingleWith4AnswerVC {
    private func updateSelectedButton(tag: Int) {
        guard let vm = self.viewModel else { return }
        
        if vm.shouldChooseMultipleAnswer {
            self.checkButtons[tag-1].isSelected.toggle()
        } else {
            self.checkButtons.forEach { $0.isSelected = false }
            self.checkButtons[tag-1].isSelected = true
        }
        self.updateButtonUI()
        
        // Solved값 업데이트
        let selectedButtonTags = self.checkButtons.filter(\.isSelected).map(\.tag)
        vm.updateSolved(withSelectedAnswers: selectedButtonTags)
    }
}

// MARK: Configure
extension SingleWith4AnswerVC {
    private func configureTimerViewLayout() {
        self.view.addSubview(self.timerView)
        
        NSLayoutConstraint.activate([
            self.timerView.centerYAnchor.constraint(equalTo: self.explanationBT.centerYAnchor),
            self.timerView.leadingAnchor.constraint(equalTo: self.explanationBT.trailingAnchor, constant: 15)
        ])
    }
    
    private func configureCheckButtonLayout() {
        zip(self.checkButtons, self.checkImageViews).forEach { button, imageView in
            button.addSubview(imageView)
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 75),
                imageView.heightAnchor.constraint(equalToConstant: 75),
                imageView.centerXAnchor.constraint(equalTo: button.centerXAnchor, constant: 10),
                imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor, constant: -10)
            ])
        }
    }
}

// MARK: Update
extension SingleWith4AnswerVC {
    private func updateCheckedButtons() {
        self.checkButtons.forEach { $0.isSelected = false }
        self.viewModel?.savedSolved.forEach { self.checkButtons[$0-1].isSelected = true }
        self.updateButtonUI()
        self.updateUIIfTerminated()
    }
    
    private func updateButtonUI() {
        self.checkButtons.forEach { button in
            if button.isSelected {
                button.backgroundColor = UIColor(.blueRegular)
                button.setTitleColor(UIColor.white, for: .normal)
            } else {
                button.backgroundColor = UIColor.white
                button.setTitleColor(UIColor(.blueRegular), for: .normal)
            }
        }
    }
    
    /// 채점이 완료된 경우 && 틀린 경우 정답을 빨간색으로 표시
    private func updateUIIfTerminated() {
        guard let problem = self.viewModel?.problem else { return }
        
        if problem.terminated {
            self.answerBT.isHidden = true
            self.viewModel?.answer.forEach {
                self.checkImageViews[$0-1].isHidden = false
            }
            self.showResultImage(to: problem.correct)
        } else {
            self.answerBT.isHidden = false
        }
    }
    
    private func updateBookmarkBT() {
        self.bookmarkBT.isSelected = self.viewModel?.problem?.star ?? false
    }
    
    private func updateAnswerBT() {
        self.answerBT.isUserInteractionEnabled = true
        self.answerBT.setTitleColor(UIColor(.blueRegular), for: .normal)
        if self.viewModel?.problem?.answer == nil {
            self.answerBT.isUserInteractionEnabled = false
            self.answerBT.setTitleColor(UIColor.gray, for: .normal)
        }
    }
    
    private func updateExplanationBT() {
        self.explanationBT.isSelected = false
        self.explanationBT.isUserInteractionEnabled = true
        self.explanationBT.setTitleColor(UIColor(.blueRegular), for: .normal)
        if self.viewModel?.problem?.explanationImage == nil {
            self.explanationBT.isUserInteractionEnabled = false
            self.explanationBT.setTitleColor(UIColor.gray, for: .normal)
        }
    }
}

extension SingleWith4AnswerVC: TimeRecordControllable {
    func endTimeRecord() {
        self.viewModel?.endTimeRecord()
    }
}
