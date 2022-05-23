//
//  SubProblemCell.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/05/23.
//

import UIKit
import PencilKit

class SubProblemCell: FormCell, XibAwakable {
    static let identifier = "SubProblemCell"
    static let topViewHeight: CGFloat = 87
    
    override var internalTopViewHeight: CGFloat {
        return SubProblemCell.topViewHeight
    }
    
    @IBOutlet weak var bookmarkBT: UIButton!
    @IBOutlet weak var explanationBT: UIButton!
    @IBOutlet weak var answerBT: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var answerTF: UITextField!
    
    private var currentProblemIndex: Int = 0 {
        didSet {
            self.answerTF.text = solvings[currentProblemIndex]
        }
    }
    private var solvings: [String?] = []
    
    lazy var checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private lazy var answerView: AnswerView = {
        let answerView = AnswerView()
        answerView.alpha = 0
        return answerView
    }()
    private lazy var timerView = ProblemTimerView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.answerTF.delegate = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.topView.addAccessibleShadow()
        self.topView.clipAccessibleShadow(at: .exceptTop)
        self.answerTF.layer.addBorder([.bottom], color: UIColor(.mainColor) ?? .black, width: 1)
    }
    
    @IBAction func toggleBookmark(_ sender: Any) {
        self.bookmarkBT.isSelected.toggle()
        let status = self.bookmarkBT.isSelected
        
        self.problem?.setValue(status, forKey: "star")
        self.delegate?.reload()
    }
    
    @IBAction func showExplanation(_ sender: Any) {
        guard let imageData = self.problem?.explanationImage,
              let pid = self.problem?.pid else { return }
        self.delegate?.showExplanation(image: UIImage(data: imageData), pid: Int(pid))
    }
    
    @IBAction func showAnswer(_ sender: Any) {
        guard let answer = self.problem?.answer else { return }
        self.answerView.removeFromSuperview()
        
        self.answerView.configureAnswer(to: answer.circledAnswer)
        self.contentView.addSubview(self.answerView)
        self.answerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.answerView.widthAnchor.constraint(equalToConstant: 146),
            self.answerView.heightAnchor.constraint(equalToConstant: 61),
            self.answerView.centerXAnchor.constraint(equalTo: self.answerBT.centerXAnchor),
            self.answerView.topAnchor.constraint(equalTo: self.answerBT.bottomAnchor,constant: 5)
        ])
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.answerView.alpha = 1
        } completion: { [weak self] _ in
            UIView.animate(withDuration: 0.2, delay: 2) { [weak self] in
                self?.answerView.alpha = 0
            }
        }
    }
    
    override func configureReuse(_ contentImage: UIImage?, _ problem: Problem_Core?, _ toolPicker: PKToolPicker?) {
        super.configureReuse(contentImage, problem, toolPicker)
        
//        guard let subProblemCount = problem?.subProblemsCount else { return }
        let subProblemCount = 6
        
        self.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for i in 0..<subProblemCount {
            let button = SubProblemCheckButton(index: i, delegate: self)
            self.stackView.addArrangedSubview(button)
            if i == 0 { button.isSelected = true; button.select() }
        }
        
//        guard let solved = problem?.solved else { return }
        let solved = "일$$삼$사$$육"
        self.solvings = solved.components(separatedBy: "$")
        self.currentProblemIndex = 0
    }
}

extension SubProblemCell: SubProblemCheckObservable {
    func checkButton(index: Int) {
        guard let targetButton = self.stackView.arrangedSubviews[safe: index] as? SubProblemCheckButton else {
            assertionFailure()
            return
        }
        
        targetButton.isSelected.toggle()
        if targetButton.isSelected {
            // 눌림
            self.currentProblemIndex = index
            targetButton.select()
        }
        
        self.stackView.arrangedSubviews
            .filter { $0 != targetButton}
            .compactMap { $0 as? SubProblemCheckButton }
            .forEach { $0.isSelected = false; $0.deselect() }
    }
}

extension SubProblemCell: UITextFieldDelegate {
    
}
