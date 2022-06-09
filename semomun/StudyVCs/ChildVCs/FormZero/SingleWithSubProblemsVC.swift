//
//  SingleWithSubProblemsVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/05/17.
//

import UIKit
import PencilKit
import Kingfisher
import Combine

final class SingleWithSubProblemsVC: FormZero {
    static let identifier = "SingleWithSubProblemsVC"
    static let storyboardName = "Study"
    
    /// textField 의 width 값
    private let savedAnswerWidth: CGFloat = 250+10
    
    /// checkButtons로 선택된 문제의 인덱스
    private var currentProblemIndex: Int? = nil {
        didSet {
            if let currentProblemIndex = currentProblemIndex {
                let userAnswer = self.viewModel?.userAnswers[currentProblemIndex]
                self.answerInputTextField.text = userAnswer
                
                let targetButton = self.checkButtons[currentProblemIndex]
                targetButton.isSelected = true
                self.deselectCheckButtons(except: targetButton)
            } else {
                self.deselectCheckButtons()
            }
        }
    }
    private var checkButtons: [SubProblemCheckButton] = []
    private var cancellables: Set<AnyCancellable> = []
    
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
    @IBOutlet weak var userAnswersView: UICollectionView!
    @IBOutlet weak var userAnswersLabel: UILabel!
    @IBOutlet weak var userAnswersTrailing: NSLayoutConstraint!
    // 좌측하단 채점이후 정답에 대한 Views
    @IBOutlet weak var resultFrameView: UIView!
    @IBOutlet weak var resultAnswersView: UICollectionView!
    
    var viewModel: SingleWithSubProblemsVM?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTimerViewLayout()
        self.configureAnswerViewLayout()
        
        // SubProblem 관련 configure
        self.configureDataSources()
        self.configureDelegates()
        self.configureCellRegister()
        self.bindAll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateCheckButtonsStackView()
        self.updateUIAboutTermination()
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
        self.endTimeRecord()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.answerInputTextField.addAccessibleShadow()
        let borderColor = UIColor(.deepMint) ?? .green
        self.answerInputTextField.layer.addBorder([.bottom], color: borderColor, width: 1)
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
        self.userAnswersView.dataSource = self
        self.resultAnswersView.dataSource = self
    }
    
    private func configureDelegates() {
        self.userAnswersView.delegate = self
        self.resultAnswersView.delegate = self
        self.answerInputTextField.delegate = self
    }
    
    private func configureCellRegister() {
        self.userAnswersView.register(SavedAnswerCell.self, forCellWithReuseIdentifier: SavedAnswerCell.identifier)
        self.resultAnswersView.register(SavedAnswerCell.self, forCellWithReuseIdentifier: SavedAnswerCell.identifier)
    }
}

// MARK: Update
extension SingleWithSubProblemsVC {
    /// 부분문제 개수에 맞게 선택 버튼 추가
    private func updateCheckButtonsStackView() {
        guard let vm = self.viewModel else { return }
        guard let subProblemCount = vm.problem?.subProblemsCount, subProblemCount > 0 else { return }
        
        self.checkButtons.forEach { $0.removeFromSuperview() }
        self.checkButtons = (0..<Int(subProblemCount)).map {
            SubProblemCheckButton(size: 32, fontSize: 16, index: $0, delegate: self)
        }
        self.checkButtons.forEach { self.checkButtonsStackView.addArrangedSubview($0) }
        
        // 아무 문제도 풀리지 않았을 경우 첫번째 버튼이 선택되어있음.
        if vm.noProblemSolved {
            self.currentProblemIndex = 0
        }
    }
    
    /// 문제 채점 유무와 관련된 UI 설정
    private func updateUIAboutTermination() {
        guard let terminated = self.problem?.terminated else { return }
        
        if terminated {
            self.currentProblemIndex = nil
            self.resultFrameView.isHidden = false
            self.hideTextField(animation: false)
            self.answerBT.isHidden = true
            
            self.updateCheckButtonTerminated()
        } else {
            self.currentProblemIndex = 0
            self.resultFrameView.isHidden = true
            self.showTextField(animation: false)
            self.answerBT.isHidden = false
        }
    }
    
    private func updateCheckButtonTerminated() {
        guard let vm = self.viewModel else { return }
        
        // 선택지 터치 불가하게
        self.checkButtons.forEach {
            $0.isUserInteractionEnabled = false
        }
        
        for idx in 0..<vm.userAnswers.count {
            guard let button = self.checkButtons[safe: idx],
                  let userAnswer = vm.userAnswers[safe: idx],
                  let resultAnswer = vm.resultAnswers[safe: idx] else {
                assertionFailure()
                return
            }
            if userAnswer == resultAnswer {
                button.isSelected = false
            } else {
                button.setWrongUI()
            }
        }
    }
    
    private func updateBookmarkBT() {
         self.bookmarkBT.isSelected = self.viewModel?.problem?.star ?? false
     }

     private func updateAnswerBT() {
         if self.viewModel?.problem?.answer == nil {
             self.answerBT.isUserInteractionEnabled = false
             self.answerBT.setTitleColor(UIColor.gray, for: .normal)
         } else {
             self.answerBT.isUserInteractionEnabled = true
             self.answerBT.setTitleColor(UIColor(.deepMint), for: .normal)
         }
     }

     private func updateExplanationBT() {
         if self.viewModel?.problem?.explanationImage == nil {
             self.explanationBT.isUserInteractionEnabled = false
             self.explanationBT.setTitleColor(UIColor.gray, for: .normal)
         } else {
             self.explanationBT.isUserInteractionEnabled = true
             self.explanationBT.setTitleColor(UIColor(.deepMint), for: .normal)
         }
     }
}

extension SingleWithSubProblemsVC: SubProblemCheckObservable {
    func checkButton(index: Int) {
        let targetButton = self.checkButtons[index]
        targetButton.isSelected.toggle()
        
        if targetButton.isSelected {
            self.currentProblemIndex = index
            self.showTextField(animation: true)
        } else {
            self.currentProblemIndex = nil
            self.hideTextField(animation: true)
            self.answerInputTextField.resignFirstResponder()
        }
        
        self.deselectCheckButtons(except: targetButton)
    }
}

extension SingleWithSubProblemsVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let vm = self.viewModel else { return 0 }
        
        if collectionView == self.userAnswersView {
            guard let problem = self.viewModel?.problem else { return 0 }
            if problem.terminated {
                return vm.resultAnswers.count
            } else {
                return vm.userAnswers.compactMap({$0}).count
            }
        } else if collectionView == self.resultAnswersView {
            return vm.resultAnswers.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SavedAnswerCell.identifier, for: indexPath) as? SavedAnswerCell else { return UICollectionViewCell() }
        
        let text = self.textForCollectionView(collectionView, itemIdx: indexPath.item)
        cell.configureText(to: text)
        
        // 채점 이후 userAnswer라면 틀린 것 UI 처리
        guard let vm = self.viewModel else { return cell }
        if collectionView == self.userAnswersView, vm.problem?.terminated == true {
            if vm.userAnswers[indexPath.item] != vm.resultAnswers[indexPath.item] {
                cell.makeWrong()
            } else {
                cell.makeCorrect()
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard self.viewModel?.problem?.terminated == false,
              collectionView == self.userAnswersView else { return }
        
        let subProblemIndex = self.getSolvingIndex(from: indexPath.item)
        self.currentProblemIndex = subProblemIndex
        self.showTextField(animation: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = self.textForCollectionView(collectionView, itemIdx: indexPath.item)
        let itemSize = text.size(withAttributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12, weight: .medium)
        ])
        return .init(itemSize.width+20, 30)
    }
}

// MARK: CollectionView에서 표시한 텍스트 관련
extension SingleWithSubProblemsVC {
    private func textForCollectionView(_ collectionView: UICollectionView, itemIdx: Int) -> String {
        if collectionView == self.userAnswersView {
            guard let problem = self.viewModel?.problem else { return "" }
            if problem.terminated {
                return self.getTermimatedUserAnswerCellTitle(at: itemIdx)
            } else {
                return self.getUserAnswerCellTitle(at: itemIdx)
            }
        } else if collectionView == self.resultAnswersView {
            return self.getResultCellTitle(at: itemIdx)
        } else {
            return ""
        }
    }
    
    private func getTermimatedUserAnswerCellTitle(at itemIdx: Int) -> String {
        guard let userAnswers = self.viewModel?.userAnswers else { return "" }
        let button = self.checkButtons[itemIdx]
        let buttonTitle = button.titleLabel?.text ?? ""
        let solved = userAnswers[itemIdx] ?? "미기입"
        return "\(buttonTitle): \(solved)"
    }
    
    private func getUserAnswerCellTitle(at itemIdx: Int) -> String {
        guard let userAnswers = self.viewModel?.userAnswers else { return "" }
        
        let subproblemName = self.getSubproblemName(from: itemIdx)
        guard let solved = userAnswers.compactMap({$0})[safe: itemIdx] else { return "" }
        
        return "\(subproblemName): \(solved)"
    }
    
    private func getResultCellTitle(at itemIdx: Int) -> String {
        guard let resultAnswers = self.viewModel?.resultAnswers else { return "" }
        let button = self.checkButtons[itemIdx]
        guard let buttonTitle = button.titleLabel?.text else {
            return ""
        }
        return "\(buttonTitle): \(resultAnswers[itemIdx])"
    }
    
    /// checkButtons의 특정 인덱스의 버튼이 가지는 title값을 반환
    private func getSubproblemName(from itemIdx: Int) -> String {
        let subProblemIdx = self.getSolvingIndex(from: itemIdx)
        return self.checkButtons[subProblemIdx].titleLabel?.text ?? ""
    }
    
    /// userAnswers의 인덱스에서 실제 문제 인덱스로 변환
    private func getSolvingIndex(from itemIdx: Int) -> Int {
        guard let userAnswers = self.viewModel?.userAnswers else { return 0 }
        var cnt = 0
        for (n, x) in userAnswers.enumerated() where x != nil {
            cnt += 1
            if cnt == itemIdx+1 { return n }
        }
        return 0
    }
}

extension SingleWithSubProblemsVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.returnAction()
        return true
    }
    
    private func returnAction() {
        guard let currentProblemIndex = self.currentProblemIndex else { return }
        
        let text = self.answerInputTextField.text
        self.viewModel?.changeUserAnswer(at: currentProblemIndex, to: text)
        
        // 현재문제 deselect
        let currentButton = self.checkButtons[currentProblemIndex]
        currentButton.isSelected = false
        
        // 마지막 문제인 경우 keyboard 내림
        if currentProblemIndex == self.checkButtons.indices.last! {
            self.currentProblemIndex = nil
            self.hideTextField(animation: true)
            self.answerInputTextField.resignFirstResponder()
        }
        // 다음문제 있는 경우 다음문제 select
        else {
            self.currentProblemIndex = currentProblemIndex + 1
        }
    }
}

extension SingleWithSubProblemsVC {
    private func showTextField(animation: Bool) {
        UIView.animate(withDuration: animation ? 0.15 : 0) {
            self.userAnswersTrailing.constant = self.savedAnswerWidth
            self.answerInputTextField.alpha = 1
            self.returnButton.alpha = 1
        }
    }
    
    private func hideTextField(animation: Bool) {
        UIView.animate(withDuration: animation ? 0.15 : 0) {
            self.userAnswersTrailing.constant = 0
            self.answerInputTextField.alpha = 0
            self.returnButton.alpha = 0
        }
    }
    
    private func deselectCheckButtons(except button: SubProblemCheckButton? = nil) {
        self.checkButtons
            .filter { $0 != button }
            .forEach { $0.isSelected = false }
    }
}

extension SingleWithSubProblemsVC {
    private func bindAll() {
        self.bindUserAnswers()
        self.bindResultAnswers()
    }
    
    private func bindUserAnswers() {
        self.viewModel?.$userAnswers
         .receive(on: DispatchQueue.main)
         .sink(receiveValue: { [weak self] userAnswers in
             // 문제 풀이 중 사용자 답안이 없는 경우 '내 답안' 라벨 숨김
             let notTerminated = self?.viewModel?.problem?.terminated != true
             let zeroSolved = userAnswers.allSatisfy { $0 == nil }
             self?.userAnswersLabel.isHidden = notTerminated && zeroSolved
             
             // 사용자가 쓴 답안에 맞게 textfield 내용 업데이트
             if let currentProblemIndex = self?.currentProblemIndex {
                 self?.answerInputTextField.text = userAnswers[currentProblemIndex]
             }
 
             self?.userAnswersView.reloadData()
         })
         .store(in: &self.cancellables)
    }
    
    private func bindResultAnswers() {
        self.viewModel?.$resultAnswers
         .receive(on: DispatchQueue.main)
         .sink(receiveValue: { [weak self] userAnswers in
             self?.resultAnswersView.reloadData()
         })
         .store(in: &self.cancellables)
    }
}

extension SingleWithSubProblemsVC: TimeRecordControllable {
    func endTimeRecord() {
        self.viewModel?.endTimeRecord()
    }
}
