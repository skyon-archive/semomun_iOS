//
//  SingleWithSubProblemsVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/05/17.
//

import UIKit
import PencilKit
import Kingfisher

final class SingleWithSubProblemsVC: FormZero {
    static let identifier = "SingleWithSubProblemsVC"
    static let storyboardName = "Study"
    
    // textField 의 width 값
    private let savedAnswerWidth: CGFloat = 250+10
    
    // 이거 어딘가에 이미 있지 않았나?
    private var subProblemCheckButtons: [SubProblemCheckButton] = []
    
    /// 현재 선택된 문제의 인덱스. Zero-based.
    private var currentProblemIndex: Int? = nil {
        didSet {
            guard let currentProblemIndex = self.currentProblemIndex else { return }
            // 선택된 문제에 맞게 textfield 내용 업데이트
            self.answerInputTextField.text = solvings[currentProblemIndex]
        }
    }
    
    /// 문제별로 유저가 입력한 답안.
    private var solvings: [String?] = [] {
        didSet {
            // 입력된 사용자 답안이 없는 경우 '내 답안' 라벨 숨김
            let notTerminated = self.viewModel?.problem?.terminated != true
            let zeroSolved = self.solvings.allSatisfy { $0 == nil }
            self.userAnswersLabel.isHidden = notTerminated && zeroSolved
            
            // 사용자가 쓴 답안에 맞게 textfield 내용 업데이트
            if let currentProblemIndex = self.currentProblemIndex {
                self.answerInputTextField.text = solvings[currentProblemIndex]
            }
            
            self.userAnswers.reloadData()
        }
    }
    
    /// 문제별 정답
    private var answer: [String] = [] {
        didSet { self.resultAnswers.reloadData() }
    }
    
    @IBOutlet weak var bookmarkBT: UIButton!
    @IBOutlet weak var explanationBT: UIButton!
    @IBOutlet weak var answerBT: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewTrailing: NSLayoutConstraint!
    // 문제입력에 대한 Views
    @IBOutlet weak var checkButtonsStackView: UIStackView!
    @IBOutlet weak var answerInputTextField: UITextField!
    @IBOutlet weak var returnButton: UIButton!
    // 좌측 사용자입력에 대한 Views
    @IBOutlet weak var userAnswers: UICollectionView!
    @IBOutlet weak var userAnswersLabel: UILabel!
    @IBOutlet weak var userAnswersTrailing: NSLayoutConstraint!
    // 좌측하단 채점이후 정답에 대한 Views
    @IBOutlet weak var resultFrameView: UIView!
    @IBOutlet weak var resultAnswers: UICollectionView!
    
    var viewModel: SingleWithSubProblemsVM?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTimerViewLayout()
        self.configureAnswerViewLayout()
        
        // SubProblem 관련 configure
        self.configureDataSources()
        self.configureDelegates()
        self.configureRegisteredCells()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let subProblemCount = self.viewModel?.problem?.subProblemsCount, subProblemCount > 0 else { return }
        guard let problem = self.viewModel?.problem else { return }
        
        self.updateCheckButtonsStackView(solved: problem.solved, subProblemCount: Int(subProblemCount))
        self.updateUserAnswer(saved: problem.solved, subProblemCount: Int(subProblemCount))
        
        if problem.terminated {
            self.updateUIForTerminated()
        } else {
            self.updateUIForNotTerminated()
        }
        
        self.answerBT.isHidden = problem.terminated
        self.updateStar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel?.startTimeRecord()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.endTimeRecord()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.answerInputTextField.addAccessibleShadow()
        self.answerInputTextField.layer.addBorder([.bottom], color: UIColor(.deepMint) ?? .black, width: 1)
        self.answerInputTextField.clipAccessibleShadow(at: .exceptLeft)
    }
    
    @IBAction func toggleBookmark(_ sender: Any) {
        self.bookmarkBT.isSelected.toggle()
        let status = self.bookmarkBT.isSelected
        self.viewModel?.updateStar(to: status)
    }
    
    @IBAction func showExplanation(_ sender: Any) {
        guard let imageData = self.viewModel?.problem?.explanationImage,
            let image = UIImage(data: imageData) else { return }
        self.explanationBT.isSelected.toggle()
        if self.explanationBT.isSelected {
            self.showExplanation(to: image)
        } else {
            self.closeExplanation()
        }
    }
    
    @IBAction func showAnswer(_ sender: Any) {
        guard let answer = self.viewModel?.answerStringForUser() else { return }
        self.answerView.removeFromSuperview()
        
        self.answerView.configureAnswer(to: answer)
        self.view.addSubview(self.answerView)
        self.answerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.answerView.topAnchor.constraint(equalTo: self.answerBT.bottomAnchor),
            self.answerView.leadingAnchor.constraint(equalTo: self.answerBT.centerXAnchor),
        ])
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.answerView.alpha = 1
        } completion: { [weak self] _ in
            UIView.animate(withDuration: 0.2, delay: 2) { [weak self] in
                self?.answerView.alpha = 0
            }
        }
    }
    
    @IBAction func returnButtonAction(_ sender: Any) {
        self.returnAction()
    }
    
    /* 상위 class를 위하여 override가 필요한 Property들 */
    override var problem: Problem_Core? {
        return self.viewModel?.problem
    }
    override var topViewHeight: CGFloat {
        return self.topView.frame.height
    }
    override var topViewTrailingConstraint: NSLayoutConstraint? {
        return self.topViewTrailing
    }
}

// MARK: Configure
extension SingleWithSubProblemsVC {
    private func configureTimerViewLayout() {
        self.view.addSubview(self.timerView)
        
        NSLayoutConstraint.activate([
            self.timerView.centerYAnchor.constraint(equalTo: self.explanationBT.centerYAnchor),
            self.timerView.leadingAnchor.constraint(equalTo: self.explanationBT.trailingAnchor, constant: 15)
        ])
    }
    
    private func configureAnswerViewLayout() {
        self.view.addSubview(self.answerView)
        
        NSLayoutConstraint.activate([
            self.answerView.topAnchor.constraint(equalTo: self.answerBT.bottomAnchor),
            self.answerView.leadingAnchor.constraint(equalTo: self.answerBT.centerXAnchor)
        ])
    }
    
    private func configureDataSources() {
        self.userAnswers.dataSource = self
        self.resultAnswers.dataSource = self
    }
    
    private func configureDelegates() {
        self.userAnswers.delegate = self
        self.resultAnswers.delegate = self
        self.answerInputTextField.delegate = self
    }
    
    private func configureRegisteredCells() {
        self.userAnswers.register(SavedAnswerCell.self, forCellWithReuseIdentifier: SavedAnswerCell.identifier)
        self.resultAnswers.register(SavedAnswerCell.self, forCellWithReuseIdentifier: SavedAnswerCell.identifier)
    }
}

// MARK: Update
extension SingleWithSubProblemsVC {
    /// 부분문제 개수에 맞게 선택 버튼 추가
    private func updateCheckButtonsStackView(solved: String?, subProblemCount: Int) {
        self.subProblemCheckButtons.forEach { $0.removeFromSuperview() }
        
        self.subProblemCheckButtons = (0..<subProblemCount).map {
            SubProblemCheckButton(size: 32, fontSize: 16, index: $0, delegate: self)
        }
        self.subProblemCheckButtons.forEach { self.checkButtonsStackView.addArrangedSubview($0) }
        
        // 아무 문제도 풀리지 않았을 경우 첫번째 버튼이 선택되어있음.
        if solved == nil, let firstButton = self.subProblemCheckButtons.first {
            firstButton.isSelected = true
        }
    }
    
    /// 사용자 답안을 불러와서 적용
    private func updateUserAnswer(saved: String?, subProblemCount: Int) {
        self.solvings = .init(repeating: nil, count: Int(subProblemCount))
        guard let saved = saved else { return }

        let savedSolved = saved.components(separatedBy: "$").map { $0 == "" ? nil : $0 }
        guard self.solvings.count == savedSolved.count else {
            assertionFailure()
            return
        }
        
        for (n, x) in savedSolved.enumerated() {
            self.solvings[n] = x
        }
        self.hideTextField() // viewWillDisappear로 이동?
    }
    
    private func updateUIForTerminated() {
        self.currentProblemIndex = nil
        self.resultFrameView.isHidden = false
        
        // 선택지 터치 불가하게
        self.subProblemCheckButtons.forEach {
            $0.isUserInteractionEnabled = false
        }
        self.updateCheckButtonTerminated()
        
        self.correctImageView.isHidden = false
        self.hideTextField(animation: true)
    }
    
    private func updateCheckButtonTerminated() {
        guard let answer = self.viewModel?.problem?.answer else { return }
        
        let answerConverted = answer.split(separator: "$").map { String($0) }
        self.answer = answerConverted
        
        for (idx, zipped) in zip(self.solvings, answerConverted).enumerated() {
            let button = self.subProblemCheckButtons[idx]
            
            guard let solving = zipped.0 else {
                button.setWrongUI()
                continue
            }
            
            if solving != zipped.1 {
                button.setWrongUI()
            } else {
                button.isSelected = false
            }
        }
    }
    
    private func updateUIForNotTerminated() {
        self.currentProblemIndex = 0
        self.resultFrameView.isHidden = true
        
        self.showTextField(animation: false)
    }
    
    private func updateStar() {
        self.bookmarkBT.isSelected = self.viewModel?.problem?.star ?? false
    }
}

extension SingleWithSubProblemsVC: SubProblemCheckObservable {
    func checkButton(index: Int) {
        let targetButton = self.subProblemCheckButtons[index]
        targetButton.isSelected.toggle()
        
        if targetButton.isSelected {
            self.currentProblemIndex = index
            self.showTextField(animation: true)
        } else {
            self.currentProblemIndex = nil
            self.hideTextField(animation: true)
        }
        
        self.deselectCheckButtons(except: targetButton)
    }
}

extension SingleWithSubProblemsVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private func textForCollectionView(_ collectionView: UICollectionView, itemIdx: Int) -> String {
        if collectionView == self.userAnswers {
            guard let problem = self.viewModel?.problem else { return "" }
            if problem.terminated {
                return self.getTermimatedUserAnswerCellTitle(at: itemIdx)
            } else {
                return self.getUserAnswerCellTitle(at: itemIdx)
            }
        } else {
            return self.getResultCellTitle(at: itemIdx)
        }
    }
    
    private func getTermimatedUserAnswerCellTitle(at itemIdx: Int) -> String {
        let button = self.subProblemCheckButtons[itemIdx]
        let buttonTitle = button.titleLabel?.text ?? ""
        let solved = self.solvings[itemIdx] ?? "미기입"
        return "\(buttonTitle): \(solved)"
    }
    
    private func getUserAnswerCellTitle(at itemIdx: Int) -> String {
        /// 인덱스 변환 과정이 필요
        let subproblemName = self.getSubproblemName(from: itemIdx)
        guard let solved = self.solvings.compactMap({$0})[safe: itemIdx] else { return "" }
        
        return "\(subproblemName): \(solved)"
    }
    
    private func getResultCellTitle(at itemIdx: Int) -> String {
        let button = self.subProblemCheckButtons[itemIdx]
        guard let buttonTitle = button.titleLabel?.text else {
            return ""
        }
        return "\(buttonTitle): \(self.answer[itemIdx])"
    }
    
    /// subProblemCheckButtons의 특정 인덱스의 버튼이 가지는 title값을 반환
    private func getSubproblemName(from itemIdx: Int) -> String {
        let subProblemIdx = self.getSolvingIndex(from: itemIdx)
        return self.subProblemCheckButtons[subProblemIdx].titleLabel?.text ?? ""
    }
    
    /// userAnswers의 인덱스에서 실제 문제 인덱스로 변환
    private func getSolvingIndex(from itemIdx: Int) -> Int {
        var cnt = 0
        for (n, x) in self.solvings.enumerated() where x != nil {
            cnt += 1
            if cnt == itemIdx+1 { return n }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.userAnswers {
            guard let problem = self.viewModel?.problem else { return 0 }
            return problem.terminated ? self.answer.count : self.solvings.compactMap({$0}).count
        } else {
            return self.answer.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SavedAnswerCell.identifier, for: indexPath) as? SavedAnswerCell else { return UICollectionViewCell() }
        
        let text = self.textForCollectionView(collectionView, itemIdx: indexPath.item)
        cell.configureText(to: text)
        
        // 채점 이후 userAnswer 중 틀린 것 처리
        if collectionView == self.userAnswers,
           self.viewModel?.problem?.terminated == true {
            if self.solvings[indexPath.item] != self.answer[indexPath.item] {
                cell.makeWrong()
            } else {
                cell.makeCorrect()
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard self.viewModel?.problem?.terminated == false,
              collectionView == self.userAnswers else { return }
        
        self.showTextField(animation: true)
        
        let subProblemIndex = self.getSolvingIndex(from: indexPath.item)
        self.currentProblemIndex = subProblemIndex
        
        let targetButton = self.subProblemCheckButtons[subProblemIndex]
        targetButton.isSelected = true
        self.deselectCheckButtons(except: targetButton)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = self.textForCollectionView(collectionView, itemIdx: indexPath.item)
        let itemSize = text.size(withAttributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12, weight: .medium)
        ])
        return .init(itemSize.width+20, 30)
    }
}

extension SingleWithSubProblemsVC: UITextFieldDelegate {
    // TODO: 빈 문자열 입력시 입력된 답안 제거?
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.returnAction()
        return true
    }
    
    private func returnAction() {
        guard let currentProblemIndex = self.currentProblemIndex else { return }
        self.solvings[currentProblemIndex] = (self.answerInputTextField.text == "" ? nil : self.answerInputTextField.text)
        
        // 답안 저장. 엔터를 눌렀을 경우에만 updateSolved해야함.
        self.viewModel?.updateSolved(withSelectedAnswer: self.solvings)
        self.updateCorrectPoints()
        // 현재문제 deselect
        guard let subCount = self.viewModel?.problem?.subProblemsCount,
              let currentButton = self.subProblemCheckButtons[safe: currentProblemIndex] else { return }
        currentButton.isSelected = false
        // 다음문제 있는 경우 다음문제 select
        if currentProblemIndex+1 < Int(subCount),
           let nextButton = self.subProblemCheckButtons[safe: currentProblemIndex] {
            self.currentProblemIndex = currentProblemIndex+1
            nextButton.isSelected = true
            self.deselectCheckButtons(except: nextButton)
        }
        // 마지막 문제인 경우 keyboard 내림
        else if currentProblemIndex+1 == Int(subCount) {
            self.currentProblemIndex = nil
            self.hideTextField(animation: true)
            self.view.endEditing(true)
        }
    }
}

extension SingleWithSubProblemsVC {
    private func updateCorrectPoints() {
        guard let answer = self.viewModel?.problem?.answer else {
            self.viewModel?.problem?.setValue(0, forKey: Problem_Core.Attribute.correctPoints.rawValue)
            return
        }
        let answers = answer.split(separator: "$").map { String($0) }
        let points = zip(self.solvings, answers)
            .filter { $0 == $1 }
            .count
        self.viewModel?.problem?.setValue(Int64(points), forKey: Problem_Core.Attribute.correctPoints.rawValue)
    }
    
    private func showTextField(animation: Bool = false) {
        UIView.animate(withDuration: animation ? 0.15 : 0) {
            self.userAnswersTrailing.constant = self.savedAnswerWidth
            self.answerInputTextField.alpha = 1
            self.returnButton.alpha = 1
        }
    }
    
    private func hideTextField(animation: Bool = false) {
        UIView.animate(withDuration: animation ? 0.15 : 0) {
            self.userAnswersTrailing.constant = 0
            self.answerInputTextField.alpha = 0
            self.returnButton.alpha = 0
        }
    }
    
    private func deselectCheckButtons(except button: SubProblemCheckButton) {
        self.subProblemCheckButtons
            .filter { $0 != button }
            .forEach { $0.isSelected = false }
    }
}

extension SingleWithSubProblemsVC: TimeRecordControllable {
    func endTimeRecord() {
        self.viewModel?.endTimeRecord()
    }
}
