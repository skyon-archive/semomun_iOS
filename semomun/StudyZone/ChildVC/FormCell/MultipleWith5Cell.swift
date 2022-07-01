//
//  MultipleWith5Cell.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import UIKit
import PencilKit

final class MultipleWith5Cell: FormCell, CellLayoutable {
    /* public */
    static let identifier = "MultipleWith5Cell"
    static func topViewHeight(with problem: Problem_Core?) -> CGFloat {
        return 51
    }
    override var internalTopViewHeight: CGFloat {
        return 51
    }
    /* private */
    private lazy var checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    @IBOutlet weak var bookmarkBT: UIButton!
    @IBOutlet weak var explanationBT: UIButton!
    @IBOutlet weak var answerBT: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet var checkButtons: [UIButton]!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.hideCheckImage()
    }

    @IBAction func selectAnswer(_ sender: UIButton) {
        guard let problem = self.problem,
        problem.terminated == false else { return }
        
        let selectedAnswer: Int = sender.tag
        self.updateSolved(input: "\(selectedAnswer)")
        
        self.updateCheckedButtons()
    }
    
    @IBAction func toggleBookmark(_ sender: Any) {
        self.bookmarkBT.isSelected.toggle()
        let status = self.bookmarkBT.isSelected
        
        self.problem?.setValue(status, forKey: "star")
        self.delegate?.refreshPageButtons()
    }
    
    @IBAction func showExplanation(_ sender: Any) {
        guard let imageData = self.problem?.explanationImage,
              let pid = self.problem?.pid else { return }
        self.delegate?.selectExplanation(image: UIImage(data: imageData), pid: Int(pid))
    }
    
    @IBAction func showAnswer(_ sender: Any) {
        guard let answer = self.problem?.answer else { return }
        let answerConverted = answer.split(separator: "$").joined(separator: ", ")
        self.answerView.configureAnswer(to: answerConverted)
        
        self.contentView.addSubview(self.answerView)
        NSLayoutConstraint.activate([
            self.answerView.topAnchor.constraint(equalTo: self.answerBT.bottomAnchor),
            self.answerView.leadingAnchor.constraint(equalTo: self.answerBT.centerXAnchor),
        ])
        self.answerView.showShortTime()
    }
    
    override func prepareForReuse(_ contentImage: UIImage?, _ problem: Problem_Core?, _ toolPicker: PKToolPicker?, _ mode: StudyVC.Mode?) {
        super.prepareForReuse(contentImage, problem, toolPicker, mode)
        self.updateCheckedButtons()
        self.updateBookmarkBT()
        self.updateAnswerBT()
        self.updateExplanationBT()
        self.updateUIIfTerminated()
        self.updateModeUI()
    }
    
    // MARK: override 구현
    override func configureTimerLayout() {
        self.contentView.addSubview(self.timerView)
        
        NSLayoutConstraint.activate([
            self.timerView.centerYAnchor.constraint(equalTo: self.explanationBT.centerYAnchor),
            self.timerView.leadingAnchor.constraint(equalTo: self.explanationBT.trailingAnchor, constant: 9)
        ])
    }
    
    override func addTopShadow() {
        self.topView.addAccessibleShadow()
        self.topView.clipAccessibleShadow(at: .exceptTop)
    }
    
    override func removeTopShadow() {
        self.topView.removeAccessibleShadow()
    }
}

// MARK: Update
extension MultipleWith5Cell {
    private func updateCheckedButtons() {
        self.checkButtons.forEach { $0.isSelected = false }
        if let solved = self.problem?.solved, let solvedIndex = Int(solved) {
            self.checkButtons[solvedIndex-1].isSelected = true
        }
        self.updateButtonUI()
    }
    
    private func updateButtonUI() {
        self.checkButtons.forEach { button in
            if button.isSelected {
                button.backgroundColor = UIColor(.deepMint)
                button.setTitleColor(UIColor.white, for: .normal)
            } else {
                button.backgroundColor = UIColor.white
                button.setTitleColor(UIColor(.deepMint), for: .normal)
            }
        }
    }
    
    private func updateUIIfTerminated() {
        guard let problem = self.problem else { return }
        
        if problem.terminated {
            self.answerBT.isHidden = true
            if let solved = self.problem?.solved, let solvedIndex = Int(solved) {
                self.showCheckImage(to: solvedIndex-1)
            }
            
            if problem.answer != nil {
                self.showCorrectImage(isCorrect: problem.correct)
            }
        } else {
            self.answerBT.isHidden = false
        }
    }
    
    private func updateBookmarkBT() {
        self.bookmarkBT.isSelected = self.problem?.star ?? false
    }
    
    private func updateAnswerBT() {
        self.answerBT.isHidden = false
        if self.problem?.answer == nil {
            self.answerBT.isUserInteractionEnabled = false
            self.answerBT.setTitleColor(UIColor.gray, for: .normal)
        } else {
            self.answerBT.isUserInteractionEnabled = true
            self.answerBT.setTitleColor(UIColor(.deepMint), for: .normal)
        }
    }
    
    private func updateExplanationBT() {
        self.explanationBT.isHidden = false
        self.explanationBT.isSelected = false
        if self.problem?.explanationImage == nil {
            self.explanationBT.isUserInteractionEnabled = false
            self.explanationBT.setTitleColor(UIColor.gray, for: .normal)
        } else {
            self.explanationBT.isUserInteractionEnabled = true
            self.explanationBT.setTitleColor(UIColor(.deepMint), for: .normal)
        }
    }
    
    private func updateModeUI() {
        guard let terminated = self.problem?.terminated, terminated == false else { return }
        
        switch self.mode {
        case .default:
            return
        case.practiceTest:
            self.explanationBT.isHidden = true
            self.answerBT.isHidden = true
        }
    }
}

extension MultipleWith5Cell {
    private func showCheckImage(to index: Int) {
        self.checkImageView.image = UIImage(named: "check")
        self.checkButtons[index].addSubview(self.checkImageView)
        
        NSLayoutConstraint.activate([
            self.checkImageView.widthAnchor.constraint(equalToConstant: 70),
            self.checkImageView.heightAnchor.constraint(equalToConstant: 70),
            self.checkImageView.centerXAnchor.constraint(equalTo: self.checkButtons[index].centerXAnchor, constant: 9),
            self.checkImageView.centerYAnchor.constraint(equalTo: self.checkButtons[index].centerYAnchor, constant: -9)
        ])
    }
    private func hideCheckImage() {
        self.checkImageView.removeFromSuperview()
    }
}
