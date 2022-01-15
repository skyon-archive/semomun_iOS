//
//  SolvingViewController.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import UIKit
import PencilKit

protocol PageDelegate: AnyObject {
    func updateStar(btName: String, to: Bool)
    func updateWrong(btName: String, to: Bool)
    func nextPage()
    func beforePage()
}

class SolvingViewController: UIViewController {
    static let identifier = "SolvingViewController"
    
    @IBOutlet weak var sectionTitle: UILabel!
    @IBOutlet weak var sectionTime: UILabel!
    @IBOutlet weak var bottomFrame: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var solvingFrameView: UIView!
    @IBOutlet weak var showResultVC: UIButton!
    
    private var singleWith5Answer: SingleWith5Answer!
    private var singleWithTextAnswer: SingleWithTextAnswer!
    private var multipleWith5Answer: MultipleWith5Answer!
    private var singleWith4Answer: SingleWith4Answer!
    private var multipleWithNoAnswer: MultipleWithNoAnswer!
    private var concept: Concept!
    private var singleWithNoAnswer: SingleWithNoAnswer!
    
    private var currentVC: UIViewController!
    private var manager: SectionManager!
    var sectionCore: Section_Core?
    var previewCore: Preview_Core?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        
        singleWith5Answer = self.storyboard?.instantiateViewController(withIdentifier: SingleWith5Answer.identifier) as? SingleWith5Answer
        singleWithTextAnswer = self.storyboard?.instantiateViewController(withIdentifier: SingleWithTextAnswer.identifier) as? SingleWithTextAnswer
        multipleWith5Answer = self.storyboard?.instantiateViewController(withIdentifier: MultipleWith5Answer.identifier) as? MultipleWith5Answer
        singleWith4Answer = self.storyboard?.instantiateViewController(withIdentifier: SingleWith4Answer.identifier) as? SingleWith4Answer
        multipleWithNoAnswer = self.storyboard?.instantiateViewController(withIdentifier: MultipleWithNoAnswer.identifier) as? MultipleWithNoAnswer
        concept = self.storyboard?.instantiateViewController(withIdentifier: Concept.identifier) as? Concept
        singleWithNoAnswer = self.storyboard?.instantiateViewController(withIdentifier: SingleWithNoAnswer.identifier) as? SingleWithNoAnswer
        
        self.addChild(singleWith5Answer)
        self.addChild(singleWithTextAnswer)
        self.addChild(multipleWith5Answer)
        self.addChild(singleWith4Answer)
        self.addChild(multipleWithNoAnswer)
        self.addChild(concept)
        self.addChild(singleWithNoAnswer)
        
        self.configureManager()
        self.addCoreDataAlertObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("solving will disappear")
        super.viewWillDisappear(animated)
        self.view.subviews.forEach { $0.removeFromSuperview() }
        self.singleWith5Answer = nil
        self.singleWithTextAnswer = nil
        self.multipleWith5Answer = nil
        self.singleWith4Answer = nil
        self.multipleWithNoAnswer = nil
        self.concept = nil
        self.singleWithNoAnswer = nil
    }
    
    deinit {
        print("solving deinit")
    }
    
    @IBAction func back(_ sender: Any) {
        self.manager.stopSection()
    }
    
    @IBAction func finish(_ sender: Any) {
        if manager.isTerminated {
            self.manager.terminateSection()
            return
        }
        self.showAlertWithCancelAndOK(title: "제출하시겠습니까?", text: "타이머가 정지되며 채점이 이루어집니다.") { [weak self] in
            self?.manager.terminateSection()
        }
    }
}

// MARK: - Configure
extension SolvingViewController {
    func configureUI() {
        bottomFrame.layer.cornerRadius = 30
        bottomFrame.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func configureManager() {
        self.manager = SectionManager(delegate: self, section: self.sectionCore)
    }
}

extension SolvingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // 문제수 반환
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.manager.count
    }
    
    // 문제버튼 생성
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProblemNameCell.identifier, for: indexPath) as? ProblemNameCell else { return UICollectionViewCell() }
        
        let num = self.manager.buttonTitle(at: indexPath.item)
        let isStar = self.manager.isStar(at: indexPath.item)
        let isTerminated = self.manager.isTerminated
        let isWrong = self.manager.isWrong(at: indexPath.item)
        let isCheckd = self.manager.isCheckd(at: indexPath.item)
        let isSelect = indexPath.item == self.manager.currentIndex
        
        cell.configure(to: num, isStar: isStar, isTerminated: isTerminated, isWrong: isWrong, isCheckd: isCheckd)
        cell.configureSize(isSelect: isSelect)
        
        return cell
    }
    
    // 문제 버튼 클릭시
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.manager.changePage(at: indexPath.item)
    }
}

extension SolvingViewController {
    func showVC() {
        currentVC.view.frame = self.solvingFrameView.bounds
        self.solvingFrameView.addSubview(currentVC.view)
    }
    
    func getImage(data: Data?) -> UIImage {
        guard let data = data else { return UIImage() }
        return UIImage(data: data) ?? UIImage()
    }
    
    func getImages(problems: [Problem_Core]) -> [UIImage] {
        return problems.map { getImage(data: $0.contentImage) }
    }
}

extension SolvingViewController: LayoutDelegate {
    func showTitle(title: String) {
        self.sectionTitle.text = title
    }
    
    func showTime(time: Int64) {
        self.sectionTime.text = time.toTimeString()
    }
    
    func changeVC(pageData: PageData) {
        if let _ = currentVC {
            for child in self.solvingFrameView.subviews { child.removeFromSuperview() }
            currentVC.willMove(toParent: nil) // 제거되기 직전에 호출
            currentVC.removeFromParent() // parentVC로 부터 관계 삭제
            currentVC.view.removeFromSuperview() // parentVC.view.addsubView()와 반대 기능
        }

        switch pageData.layoutType {
        case SingleWith5Answer.identifier:
            self.currentVC = singleWith5Answer
            singleWith5Answer.viewModel = SingleWith5AnswerViewModel(delegate: self, pageData: pageData)
            singleWith5Answer.image = getImage(data: pageData.problems[0].contentImage)
            
        case SingleWithTextAnswer.identifier:
            self.currentVC = singleWithTextAnswer
            singleWithTextAnswer.viewModel = SingleWithTextAnswerViewModel(delegate: self, pageData: pageData)
            singleWithTextAnswer.image = getImage(data: pageData.problems[0].contentImage)
            
        case MultipleWith5Answer.identifier:
            multipleWith5Answer = self.storyboard?.instantiateViewController(withIdentifier: MultipleWith5Answer.identifier) as? MultipleWith5Answer
            self.currentVC = multipleWith5Answer
            multipleWith5Answer.viewModel = MultipleWith5AnswerViewModel(delegate: self, pageData: pageData)
            multipleWith5Answer.mainImage = getImage(data: pageData.pageCore.materialImage)
            multipleWith5Answer.subImages = getImages(problems: pageData.problems)
            
        case SingleWith4Answer.identifier:
            self.currentVC = singleWith4Answer
            singleWith4Answer.viewModel = SingleWith4AnswerViewModel(delegate: self, pageData: pageData)
            singleWith4Answer.image = getImage(data: pageData.problems[0].contentImage)
            
        case MultipleWithNoAnswer.identifier:
            self.currentVC = multipleWithNoAnswer
            multipleWithNoAnswer.viewModel = MultipleWithNoAnswerViewModel(delegate: self, pageData: pageData)
            multipleWithNoAnswer.mainImage = getImage(data: pageData.pageCore.materialImage)
            multipleWithNoAnswer.subImages = getImages(problems: pageData.problems)
            
        case Concept.identifier:
            self.currentVC = concept
            concept.image = getImage(data: pageData.problems[0].contentImage)
            concept.viewModel = ConceptViewModel(delegate: self, pageData: pageData)
        
        case SingleWithNoAnswer.identifier:
            self.currentVC = singleWithNoAnswer
            singleWithNoAnswer.image = getImage(data: pageData.problems[0].contentImage)
            singleWithNoAnswer.viewModel = SingleWithNoAnswerViewModel(delegate: self, pageData: pageData)
        
        default:
            break
        }
        self.showVC()
    }
    
    func reloadButtons() {
        self.collectionView.reloadData()
    }
    
    func showAlert(text: String) {
        self.showAlertWithOK(title: text, text: "")
    }
    
    func saveComplete() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func showResultViewController(result: SectionResult) {
        guard let sectionResultVC = self.storyboard?.instantiateViewController(withIdentifier: SectionResultViewController.identifier) as? SectionResultViewController else { return }
        sectionResultVC.result = result
        self.present(sectionResultVC, animated: true, completion: nil)
    }
    
    func terminateSection(result: SectionResult, sid: Int, jsonString: String) {
        let isConnected = true
        let network = Network()
        let networkUseCase = NetworkUsecase(network: network)
        if isConnected {
            networkUseCase.putSectionResult(sid: sid, submissions: jsonString) { [weak self] status in
                DispatchQueue.main.async {
                    switch status {
                    case .SUCCESS:
                        print("post sections success")
                    default:
                        // TODO: 쥐도 새도 모르게 반영한다 하여 따로 UI로 보이는 로직은 없는 상태
                        print("Error: update submissions fail")
                    }
                    self?.previewCore?.setValue(true, forKey: "terminated")
                    CoreDataManager.saveCoreData()
                    self?.changeResultLabel()
                    self?.showResultViewController(result: result)
                }
            }
        }
    }
    
    func changeResultLabel() {
        self.showResultVC.setTitle("결과보기", for: .normal)
    }
}

extension SolvingViewController: PageDelegate {
    func updateStar(btName: String, to: Bool) {
        self.manager.updateStar(title: btName, to: to)
    }
    
    func updateWrong(btName: String, to: Bool) {
        self.manager.updateWrong(title: btName, to: to)
    }
    
    func nextPage() {
        self.manager.changeNextPage()
    }
    
    func beforePage() {
        self.manager.changeBeforePage()
    }
}
