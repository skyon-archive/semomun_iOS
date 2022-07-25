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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    override func prepareForReuse(_ contentImage: UIImage?, _ problem: Problem_Core?, _ toolPicker: PKToolPicker?, _ mode: StudyVC.Mode?) {
        super.prepareForReuse(contentImage, problem, toolPicker, mode)
        self.updateCheckedButtons()
        self.updateUIIfTerminated()
        
        let answer = self.problem?.answer?.split(separator: "$").joined(separator: ", ")
        self.toolbarView.updateUI(mode: self.mode, problem: problem, answer: answer)
    }
    
    // MARK: override 구현
    override func configureTimerLayout() {
//        self.contentView.addSubview(self.timerView)
//
//        NSLayoutConstraint.activate([
//            self.timerView.centerYAnchor.constraint(equalTo: self.explanationBT.centerYAnchor),
//            self.timerView.leadingAnchor.constraint(equalTo: self.explanationBT.trailingAnchor, constant: 9)
//        ])
    }
    
    override func addTopShadow() {
    }
    
    override func removeTopShadow() {
    }
}

// MARK: Update
extension MultipleWith5Cell {
    private func updateCheckedButtons() {
//        self.checkButtons.forEach { $0.isSelected = false }
//        if let solved = self.problem?.solved, let solvedIndex = Int(solved) {
//            self.checkButtons[solvedIndex-1].isSelected = true
//        }
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
    
    private func updateUIIfTerminated() {
        guard let problem = self.problem else { return }
        
        if problem.terminated {
            if let solved = self.problem?.solved, let solvedIndex = Int(solved) {
                self.showCheckImage(to: solvedIndex-1)
            }
            
            if problem.answer != nil {
                self.showCorrectImage(isCorrect: problem.correct)
            }
        }
    }
}

extension MultipleWith5Cell {
    private func showCheckImage(to index: Int) {
//        self.checkImageView.image = UIImage(named: "check")
//        self.checkButtons[index].addSubview(self.checkImageView)
//
//        NSLayoutConstraint.activate([
//            self.checkImageView.widthAnchor.constraint(equalToConstant: 70),
//            self.checkImageView.heightAnchor.constraint(equalToConstant: 70),
//            self.checkImageView.centerXAnchor.constraint(equalTo: self.checkButtons[index].centerXAnchor, constant: 9),
//            self.checkImageView.centerYAnchor.constraint(equalTo: self.checkButtons[index].centerYAnchor, constant: -9)
//        ])
    }
    private func hideCheckImage() {
//        self.checkImageView.removeFromSuperview()
    }
}
