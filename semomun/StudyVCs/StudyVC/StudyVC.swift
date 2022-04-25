//
//  StudyVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import PencilKit
import Combine

protocol PageDelegate: AnyObject {
    func reload()
    func nextPage()
    func beforePage()
    func addScoring(pid: Int)
    func addUploadProblem(pid: Int)
    func addUploadPage(vid: Int)
}

final class StudyVC: UIViewController {
    static let identifier = "StudyVC"
    static let storyboardName = "Study"
    
    @IBOutlet weak var headerFrameView: UIView!
    @IBOutlet weak var bottomFrameView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var childFrameView: UIView!
    @IBOutlet weak var resultBT: UIButton!
    @IBOutlet weak var beforeFrameView: UIView!
    @IBOutlet weak var nextFrameView: UIView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    var sectionHeaderCore: SectionHeader_Core?
    var sectionCore: Section_Core?
    var previewCore: Preview_Core?
    private var currentVC: UIViewController?
    private var manager: SectionManager?
    private var cancellables: Set<AnyCancellable> = []
    private lazy var singleWith5Answer: SingleWith5AnswerVC = {
        return UIStoryboard(name: SingleWith5AnswerVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: SingleWith5AnswerVC.identifier) as? SingleWith5AnswerVC ?? SingleWith5AnswerVC()
    }()
    private lazy var singleWithTextAnswer: SingleWithTextAnswerVC = {
        return UIStoryboard(name: SingleWithTextAnswerVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: SingleWithTextAnswerVC.identifier) as? SingleWithTextAnswerVC ?? SingleWithTextAnswerVC()
    }()
    private lazy var multipleWith5Answer: MultipleWith5AnswerVC = {
        return UIStoryboard(name: MultipleWith5AnswerVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: MultipleWith5AnswerVC.identifier) as? MultipleWith5AnswerVC ?? MultipleWith5AnswerVC()
    }()
    private lazy var singleWith4Answer: SingleWith4AnswerVC = {
        return UIStoryboard(name: SingleWith4AnswerVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: SingleWith4AnswerVC.identifier) as? SingleWith4AnswerVC ?? SingleWith4AnswerVC()
    }()
    private lazy var multipleWithNoAnswer: MultipleWithNoAnswerVC = {
        return UIStoryboard(name: MultipleWithNoAnswerVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: MultipleWithNoAnswerVC.identifier) as? MultipleWithNoAnswerVC ?? MultipleWithNoAnswerVC()
    }()
    private lazy var concept: ConceptVC = {
        return UIStoryboard(name: ConceptVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: ConceptVC.identifier) as? ConceptVC ?? ConceptVC()
    }()
    private lazy var singleWithNoAnswer: SingleWithNoAnswerVC = {
        return UIStoryboard(name: SingleWithNoAnswerVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: SingleWithNoAnswerVC.identifier) as? SingleWithNoAnswerVC ?? SingleWithNoAnswerVC()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureMenu()
        self.configureCollectionView()
        self.configureManager()
        self.bindAll()
        self.addCoreDataAlertObserver()
        self.configureShadow()
        self.configureObservation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.subviews.forEach { $0.removeFromSuperview() }
    }
    
    deinit {
        print("solving deinit")
    }
    
    @IBAction func back(_ sender: Any) {
        self.manager?.pauseSection()
        self.manager?.postProblemAndPageDatas(isDismiss: true) // 나가기 전에 submission
    }
    
    @IBAction func scoringSection(_ sender: Any) {
        guard let section = self.manager?.section else { return }
        
        if section.terminated {
            self.manager?.postProblemAndPageDatas(isDismiss: false) // 결과보기 누를때 submission
            self.showResultViewController(section: section)
        } else {
            self.showSelectProblemsVC(section: section)
        }
    }
    
    @IBAction func beforePage(_ sender: Any) {
        self.manager?.changeBeforePage()
    }
    
    @IBAction func nextPage(_ sender: Any) {
        self.manager?.changeNextPage()
    }
}

// MARK: - Configure
extension StudyVC {
    private func configureMenu() {
        let reportErrorAction = UIAction(title: "오류신고", image: nil) { [weak self] _ in
            self?.showReportView()
        }
        let showResultAction = UIAction(title: "결과보기", image: nil) { [weak self] _ in
            guard let section = self?.manager?.section else { return }
            self?.showResultViewController(section: section)
        }
        self.menuButton.menu = UIMenu(title: "", image: nil, children: [reportErrorAction, showResultAction])
        self.menuButton.showsMenuAsPrimaryAction = true
    }
    
    private func configureManager() {
        guard let section = self.sectionCore,
              let sectionHeader = self.sectionHeaderCore,
              let preview = self.previewCore else { return }
        
        let networkUsecase = NetworkUsecase(network: Network())
        self.manager = SectionManager(delegate: self, section: section, sectionHeader: sectionHeader, preview: preview, networkUsecase: networkUsecase)
    }
    
    private func configureCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    private func configureShadow() {
        self.view.layoutIfNeeded()
        self.setShadow(with: self.childFrameView)
        self.beforeFrameView.addShadow(direction: .right)
        self.nextFrameView.addShadow(direction: .left)
    }
    
    private func configureObservation() {
        NotificationCenter.default.addObserver(forName: .showSectionResult, object: nil, queue: .current) { [weak self] _ in
            guard let section = self?.manager?.section,
                  let pageData = self?.manager?.currentPage else { return }
            
            self?.changeVC(pageData: pageData)
            self?.reloadButtons()
            self?.manager?.postProblemAndPageDatas(isDismiss: false) // 채점 이후 post
            self?.showResultViewController(section: section)
        }
    }
}

extension StudyVC: UICollectionViewDelegate, UICollectionViewDataSource {
    // 문제수 반환
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.manager?.problems.count ?? 0
    }
    
    // 문제버튼 생성
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProblemNameCell.identifier, for: indexPath) as? ProblemNameCell else { return UICollectionViewCell() }
        guard let manager = self.manager else { return cell }
        
        let num = manager.title(at: indexPath.item)
        let isStar = manager.isStar(at: indexPath.item)
        let isTerminated = manager.isTerminated(at: indexPath.item)
        let isWrong = manager.isWrong(at: indexPath.item)
        let isCurrent = indexPath.item == manager.currentIndex
        
        cell.configure(to: num, isStar: isStar, isTerminated: isTerminated, isWrong: isWrong, isCurrent: isCurrent)
        
        return cell
    }
    
    // 문제 버튼 클릭시
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.manager?.changePage(at: indexPath.item)
    }
}

extension StudyVC {
    private func showVC(to targetVC: UIViewController?) {
        guard let targetVC = targetVC else { return }

        targetVC.view.frame = self.childFrameView.bounds
        self.childFrameView.addSubview(targetVC.view)
        self.addChild(targetVC)
        targetVC.didMove(toParent: self)
        
        targetVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            targetVC.view.leadingAnchor.constraint(equalTo: self.childFrameView.leadingAnchor),
            targetVC.view.topAnchor.constraint(equalTo: self.childFrameView.topAnchor),
            targetVC.view.trailingAnchor.constraint(equalTo: self.childFrameView.trailingAnchor),
            targetVC.view.bottomAnchor.constraint(equalTo: self.childFrameView.bottomAnchor)
        ])
    }
    
    private func removeCurrentVC() {
        self.currentVC?.willMove(toParent: nil)
        self.currentVC?.view.removeFromSuperview()
        self.currentVC?.removeFromParent()
        for child in self.childFrameView.subviews { child.removeFromSuperview() }
    }
    
    private func getImage(data: Data?) -> UIImage {
        if let data = data, let image = UIImage(data: data) {
            return image
        } else {
            return UIImage(.warning)
        }
    }
    
    private func getImages(problems: [Problem_Core]) -> [UIImage] {
        return problems.map { getImage(data: $0.contentImage) }
    }
    
    private func showReportView() {
        guard let pageData = self.manager?.currentPage else { return }
        guard let title = self.manager?.sectionTitle else { return }
        let reportVC = ReportProblemErrorVC(pageData: pageData, title: title)
        
        self.present(reportVC, animated: true, completion: nil)
    }
    
    private func showSelectProblemsVC(section: Section_Core) {
        let storyboard = UIStoryboard(name: SelectProblemsVC.storyboardName, bundle: nil)
        guard let selectProblemsVC = storyboard.instantiateViewController(withIdentifier: SelectProblemsVC.identifier) as? SelectProblemsVC else { return }
        let viewModel = SelectProblemsVM(section: section)
        selectProblemsVC.configureViewModel(viewModel: viewModel)
        
        self.present(selectProblemsVC, animated: true, completion: nil)
    }
}

extension StudyVC: LayoutDelegate {
    func changeVC(pageData: PageData) {
        self.removeCurrentVC()

        switch pageData.layoutType {
        case SingleWith5AnswerVC.identifier:
            self.currentVC = self.singleWith5Answer
            self.singleWith5Answer.viewModel = SingleWith5AnswerVM(delegate: self, pageData: pageData)
            self.singleWith5Answer.image = self.getImage(data: pageData.problems[0].contentImage)
            
        case SingleWithTextAnswerVC.identifier:
            self.currentVC = self.singleWithTextAnswer
            self.singleWithTextAnswer.viewModel = SingleWithTextAnswerVM(delegate: self, pageData: pageData)
            self.singleWithTextAnswer.image = self.getImage(data: pageData.problems[0].contentImage)
            
        case MultipleWith5AnswerVC.identifier:
            self.multipleWith5Answer = UIStoryboard(name: MultipleWith5AnswerVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: MultipleWith5AnswerVC.identifier) as? MultipleWith5AnswerVC ?? MultipleWith5AnswerVC()
            self.currentVC = self.multipleWith5Answer
            self.multipleWith5Answer.viewModel = MultipleWith5AnswerVM(delegate: self, pageData: pageData)
            self.multipleWith5Answer.mainImage = self.getImage(data: pageData.pageCore.materialImage)
            self.multipleWith5Answer.subImages = self.getImages(problems: pageData.problems)
            
        case SingleWith4AnswerVC.identifier:
            self.currentVC = self.singleWith4Answer
            self.singleWith4Answer.viewModel = SingleWith4AnswerVM(delegate: self, pageData: pageData)
            self.singleWith4Answer.image = self.getImage(data: pageData.problems[0].contentImage)
            
        case MultipleWithNoAnswerVC.identifier:
            self.multipleWithNoAnswer = UIStoryboard(name: MultipleWithNoAnswerVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: MultipleWithNoAnswerVC.identifier) as? MultipleWithNoAnswerVC ?? MultipleWithNoAnswerVC()
            self.currentVC = self.multipleWithNoAnswer
            self.multipleWithNoAnswer.viewModel = MultipleWithNoAnswerVM(delegate: self, pageData: pageData)
            self.multipleWithNoAnswer.mainImage = self.getImage(data: pageData.pageCore.materialImage)
            self.multipleWithNoAnswer.subImages = self.getImages(problems: pageData.problems)
            
        case ConceptVC.identifier:
            self.currentVC = self.concept
            self.concept.viewModel = ConceptVM(delegate: self, pageData: pageData)
            self.concept.image = self.getImage(data: pageData.problems[0].contentImage)
        
        case SingleWithNoAnswerVC.identifier:
            self.currentVC = self.singleWithNoAnswer
            self.singleWithNoAnswer.viewModel = SingleWithNoAnswerVM(delegate: self, pageData: pageData)
            self.singleWithNoAnswer.image = self.getImage(data: pageData.problems[0].contentImage)
        
        default:
            break
        }
        self.showVC(to: self.currentVC)
    }
    
    func reloadButtons() {
        self.collectionView.reloadData()
    }
    
    func showAlert(text: String) {
        self.showAlertWithOK(title: text, text: "")
    }
    
    func dismissSection() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func showResultViewController(section: Section_Core) {
        let storyboard = UIStoryboard(name: SectionResultVC.storyboardName, bundle: nil)
        guard let sectionResultVC = storyboard.instantiateViewController(withIdentifier: SectionResultVC.identifier) as? SectionResultVC else { return }
        let viewModel = SectionResultVM(section: section)
        sectionResultVC.configureViewModel(viewModel: viewModel)
        
        self.present(sectionResultVC, animated: true, completion: nil)
    }
    
    func changeResultLabel() {
        self.resultBT.setTitle("결과보기", for: .normal)
    }
}

extension StudyVC: PageDelegate {
    func reload() {
        CoreDataManager.saveCoreData()
        self.reloadButtons()
    }
    
    func nextPage() {
        self.manager?.changeNextPage()
    }
    
    func beforePage() {
        self.manager?.changeBeforePage()
    }
    
    func addScoring(pid: Int) {
        self.manager?.addScoring(pid: pid)
        self.reloadButtons()
    }
    
    func addUploadProblem(pid: Int) {
        self.manager?.addUploadProblem(pid: pid)
    }
    
    func addUploadPage(vid: Int) {
        self.manager?.addUploadPage(vid: vid)
    }
}

extension StudyVC {
    private func bindAll() {
        self.bindTitle()
        self.bindTime()
        self.bindPage()
    }
    
    private func bindTitle() {
        self.manager?.$sectionTitle
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] title in
                self?.titleLabel.text = title
            })
            .store(in: &self.cancellables)
    }
    
    private func bindTime() {
        self.manager?.$currentTime
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] time in
                self?.backButton.setTitle(time.toTimeString, for: .normal)
            })
            .store(in: &self.cancellables)
    }
    
    private func bindPage() {
        self.manager?.$currentPage
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] pageData in
                guard let pageData = pageData else { return }
                self?.changeVC(pageData: pageData)
                self?.reloadButtons()
            })
            .store(in: &self.cancellables)
    }
}
