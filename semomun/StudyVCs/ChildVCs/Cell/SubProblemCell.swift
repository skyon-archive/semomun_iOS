//
//  SubProblemCell.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/05/23.
//

import UIKit
import PencilKit

class SavedAnswerCell: UICollectionViewCell {
    static let identifier = "SavedAnswerCell"
    private let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderColor = UIColor(.deepMint)?.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 3
        
        self.contentView.addSubview(self.label)
        self.label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.label.widthAnchor.constraint(equalTo: self.contentView.widthAnchor),
            self.label.heightAnchor.constraint(equalTo: self.contentView.heightAnchor),
            self.label.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.label.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
        ])
        
        self.label.font = .systemFont(ofSize: 12, weight: .medium)
        self.label.textColor = UIColor(.deepMint) ?? .black
        self.label.textAlignment = .center
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError()
    }
    
    func configureText(to text: String) {
        self.label.text = text
    }
}

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
    @IBOutlet weak var savedAnswerView: UICollectionView!
    
    private var currentProblemIndex: Int = 0 {
        didSet {
            self.answerTF.text = solvings[currentProblemIndex]
        }
    }
    
    private var solvings: [String?] = [] {
        didSet {
            self.savedAnswerView.reloadData()
            self.answerTF.text = solvings[currentProblemIndex]
            
            let solvingConverted = self.solvings
                .map { $0 ?? "" }
                .joined(separator: "$")
            self.updateSolved(input: solvingConverted)
        }
    }
    
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
        self.savedAnswerView.delegate = self
        self.savedAnswerView.dataSource = self
        
        self.savedAnswerView.register(SavedAnswerCell.self, forCellWithReuseIdentifier: SavedAnswerCell.identifier)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        self.topView.addAccessibleShadow()
        self.topView.clipAccessibleShadow(at: .exceptTop)
        self.answerTF.layer.addBorder([.bottom], color: UIColor(.deepMint) ?? .black, width: 1)
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
        
        if let solved = problem?.solved {
            self.solvings = solved.components(separatedBy: "$").map {
                $0 == "" ? nil : $0
            }
            self.solvings += .init(repeating: nil, count: subProblemCount - self.solvings.count)
        } else {
            self.solvings = .init(repeating: nil, count: subProblemCount)
        }
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

extension SubProblemCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private func getSolvingIndex(from itemIdx: Int) -> Int {
        var subProblemIdx = 0
        var cnt = 0
        for (n, x) in self.solvings.enumerated() {
            if x != nil { cnt += 1 }
            if cnt == itemIdx+1 {
                subProblemIdx = n
                break
            }
        }
        return subProblemIdx
    }
    
    private func getSubproblemName(from itemIdx: Int) -> String {
        let subProblemIdx = self.getSolvingIndex(from: itemIdx)
        guard let subproblemCheckButton = self.stackView.arrangedSubviews[safe: subProblemIdx] as? SubProblemCheckButton,
              let subproblemName = subproblemCheckButton.titleLabel?.text else {
            return ""
        }
        return subproblemName
    }
    
    private func getCellTitle(at itemIdx: Int) -> String {
        let subproblemName = self.getSubproblemName(from: itemIdx)
        
        guard let solved = self.solvings.compactMap({$0})[safe: itemIdx] else { return "" }
        
        return "\(subproblemName): \(solved)"
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.solvings.compactMap({$0}).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SavedAnswerCell.identifier, for: indexPath) as? SavedAnswerCell else { return UICollectionViewCell() }
        
        let text = self.getCellTitle(at: indexPath.item)
        cell.configureText(to: text)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let subProblemIdx = self.getSolvingIndex(from: indexPath.item)
        self.solvings[subProblemIdx] = nil
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 사용자 풀이 내용
        let text = self.getCellTitle(at: indexPath.item)
        print(text)
        let itemSize = text.size(withAttributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12, weight: .medium)
        ])
        
        return .init(itemSize.width+20, 30)
    }
}

extension SubProblemCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.solvings[self.currentProblemIndex] = textField.text
        return true
    }
}
