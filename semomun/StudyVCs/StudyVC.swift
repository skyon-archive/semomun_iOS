//
//  StudyVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import PencilKit

protocol PageDelegate: AnyObject {
    func updateStar(btName: String, to: Bool)
    func updateCheck(btName: String)
    func updateWrong(btName: String, to: Bool)
    func nextPage()
    func beforePage()
}

class StudyVC: UIViewController {
    static let identifier = "StudyVC"
    static let storyboardName = "Study"
    
    @IBOutlet weak var sectionTitle: UILabel!
    @IBOutlet weak var sectionTime: UILabel!
    @IBOutlet weak var bottomFrame: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var solvingFrameView: UIView!
    @IBOutlet weak var showResultVC: UIButton!
    
    private var singleWith5Answer: SingleWith5AnswerVC!
    private var singleWithTextAnswer: SingleWithTextAnswerVC!
    private var multipleWith5Answer: MultipleWith5AnswerVC!
    private var singleWith4Answer: SingleWith4AnswerVC!
    private var multipleWithNoAnswer: MultipleWithNoAnswerVC!
    private var concept: ConceptVC!
    private var singleWithNoAnswer: SingleWithNoAnswerVC!
    
    private var currentVC: UIViewController!
    private var manager: SectionManager!
    var sectionHeaderCore: SectionHeader_Core?
    var sectionCore: Section_Core?
    var previewCore: Preview_Core?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureCollectionView()
        
        singleWith5Answer = UIStoryboard(name: SingleWith5AnswerVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: SingleWith5AnswerVC.identifier) as? SingleWith5AnswerVC
        singleWithTextAnswer = UIStoryboard(name: SingleWithTextAnswerVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: SingleWithTextAnswerVC.identifier) as? SingleWithTextAnswerVC
        multipleWith5Answer = UIStoryboard(name: MultipleWith5AnswerVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: MultipleWith5AnswerVC.identifier) as? MultipleWith5AnswerVC
        singleWith4Answer = UIStoryboard(name: SingleWith4AnswerVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: SingleWith4AnswerVC.identifier) as? SingleWith4AnswerVC
        multipleWithNoAnswer = UIStoryboard(name: MultipleWithNoAnswerVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: MultipleWithNoAnswerVC.identifier) as? MultipleWithNoAnswerVC
        concept = UIStoryboard(name: ConceptVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: ConceptVC.identifier) as? ConceptVC
        singleWithNoAnswer = UIStoryboard(name: SingleWithNoAnswerVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: SingleWithNoAnswerVC.identifier) as? SingleWithNoAnswerVC
        
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
        if self.manager.section.terminated {
            self.manager.terminateSection()
            return
        }
        self.showAlertWithCancelAndOK(title: "제출하시겠습니까?", text: "타이머가 정지되며 채점이 이루어집니다.") { [weak self] in
            self?.manager.terminateSection()
        }
    }
}

// MARK: - Configure
extension StudyVC {
    func configureUI() {
        bottomFrame.layer.cornerRadius = 30
        bottomFrame.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private func configureCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    func configureManager() {
        if let sectionCore = self.sectionCore {
            self.manager = SectionManager(delegate: self, section: sectionCore)
        } else {
            self.manager = SectionManager(delegate: self, section: Section_Core(context: CoreDataManager.shared.context), isTest: true)
        }
    }
}

extension StudyVC: UICollectionViewDelegate, UICollectionViewDataSource {
    // 문제수 반환
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.manager.count
    }
    
    // 문제버튼 생성
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProblemNameCell.identifier, for: indexPath) as? ProblemNameCell else { return UICollectionViewCell() }
        
        let num = self.manager.buttonTitle(at: indexPath.item)
        let isStar = self.manager.isStar(at: indexPath.item)
        let isTerminated = self.manager.section.terminated
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

extension StudyVC {
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

extension StudyVC: LayoutDelegate {
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
        case SingleWith5AnswerVC.identifier:
            self.currentVC = singleWith5Answer
            singleWith5Answer.viewModel = SingleWith5AnswerVM(delegate: self, pageData: pageData)
            singleWith5Answer.image = getImage(data: pageData.problems[0].contentImage)
            
        case SingleWithTextAnswerVC.identifier:
            self.currentVC = singleWithTextAnswer
            singleWithTextAnswer.viewModel = SingleWithTextAnswerVM(delegate: self, pageData: pageData)
            singleWithTextAnswer.image = getImage(data: pageData.problems[0].contentImage)
            
        case MultipleWith5AnswerVC.identifier:
            multipleWith5Answer = self.storyboard?.instantiateViewController(withIdentifier: MultipleWith5AnswerVC.identifier) as? MultipleWith5AnswerVC
            self.currentVC = multipleWith5Answer
            multipleWith5Answer.viewModel = MultipleWith5AnswerVM(delegate: self, pageData: pageData)
            multipleWith5Answer.mainImage = getImage(data: pageData.pageCore.materialImage)
            multipleWith5Answer.subImages = getImages(problems: pageData.problems)
            
        case SingleWith4AnswerVC.identifier:
            self.currentVC = singleWith4Answer
            singleWith4Answer.viewModel = SingleWith4AnswerVM(delegate: self, pageData: pageData)
            singleWith4Answer.image = getImage(data: pageData.problems[0].contentImage)
            
        case MultipleWithNoAnswerVC.identifier:
            self.currentVC = multipleWithNoAnswer
            multipleWithNoAnswer.viewModel = MultipleWithNoAnswerVM(delegate: self, pageData: pageData)
            multipleWithNoAnswer.mainImage = getImage(data: pageData.pageCore.materialImage)
            multipleWithNoAnswer.subImages = getImages(problems: pageData.problems)
            
        case ConceptVC.identifier:
            self.currentVC = concept
            concept.viewModel = ConceptVM(delegate: self, pageData: pageData)
            concept.image = getImage(data: pageData.problems[0].contentImage)
        
        case SingleWithNoAnswerVC.identifier:
            self.currentVC = singleWithNoAnswer
            singleWithNoAnswer.viewModel = SingleWithNoAnswerVM(delegate: self, pageData: pageData)
            singleWithNoAnswer.image = getImage(data: pageData.problems[0].contentImage)
        
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
        guard let sectionResultVC = UIStoryboard(name: SectionResultVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: SectionResultVC.identifier) as? SectionResultVC else { return }
        sectionResultVC.result = result
        self.present(sectionResultVC, animated: true, completion: nil)
    }
    
    func terminateSection(result: SectionResult, sid: Int, jsonString: String) {
        let isConnected = true
        let network = Network()
        let networkUseCase = NetworkUsecase(network: network)
        if isConnected && sid >= 0 {
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
                    self?.sectionHeaderCore?.setValue(true, forKey: "terminated")
                    CoreDataManager.saveCoreData()
                    self?.changeResultLabel()
                    self?.showResultViewController(result: result)
                }
            }
        } else { // Dummy는 put 안하도록
            self.previewCore?.setValue(true, forKey: "terminated")
            self.sectionHeaderCore?.setValue(true, forKey: "terminated")
            CoreDataManager.saveCoreData()
            self.changeResultLabel()
            self.showResultViewController(result: result)
        }
    }
    
    func changeResultLabel() {
        self.showResultVC.setTitle("결과보기", for: .normal)
    }
}

extension StudyVC: PageDelegate {
    func updateStar(btName: String, to: Bool) {
        self.manager.updateStar(title: btName, to: to)
    }
    
    func updateCheck(btName: String) {
        self.manager.updateCheck(title: btName)
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
