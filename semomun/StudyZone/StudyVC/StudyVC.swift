//
//  StudyVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import PencilKit
import Combine
import SwiftUI

protocol PageDelegate: AnyObject {
    func refreshPageButtons()
    func addScoring(pid: Int)
    func addUploadProblem(pid: Int)
    func addUploadPage(vid: Int)
}

final class StudyVC: UIViewController {
    /* public */
    static let identifier = "StudyVC"
    static let storyboardName = "Study"
    enum Mode {
        case `default`, practiceTest
    }
    /* private */
    @IBOutlet weak var headerFrameView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var clockIcon: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var scoringButton: UIButton!
    @IBOutlet weak var contentsSlideButton: UIButton!
    @IBOutlet weak var childFrameView: UIView!
    @IBOutlet weak var bottomProblemIndicatorView: UIView!
    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pageLabel: UILabel!
    
    private var mode: Mode? // default, practiceTest
    private var currentVC: UIViewController?
    private var sectionManager: SectionManager?
    private var practiceTestManager: PracticeTestManager?
    private var cancellables: Set<AnyCancellable> = []
    private lazy var singleWith5Answer: SingleWith5AnswerVC = {
        return UIStoryboard(name: SingleWith5AnswerVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: SingleWith5AnswerVC.identifier) as? SingleWith5AnswerVC ?? SingleWith5AnswerVC()
    }()
    private lazy var singleWithTextAnswer: SingleWithTextAnswerVC = {
        return UIStoryboard(name: SingleWithTextAnswerVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: SingleWithTextAnswerVC.identifier) as? SingleWithTextAnswerVC ?? SingleWithTextAnswerVC()
    }()
    private lazy var multipleWith5Answer = MultipleWith5AnswerVC()
    private lazy var singleWith4Answer: SingleWith4AnswerVC = {
        return UIStoryboard(name: SingleWith4AnswerVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: SingleWith4AnswerVC.identifier) as? SingleWith4AnswerVC ?? SingleWith4AnswerVC()
    }()
    private lazy var multipleWithNoAnswer = MultipleWithNoAnswerVC()
    private lazy var concept: ConceptVC = {
        return UIStoryboard(name: ConceptVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: ConceptVC.identifier) as? ConceptVC ?? ConceptVC()
    }()
    private lazy var singleWithNoAnswer: SingleWithNoAnswerVC = {
        return UIStoryboard(name: SingleWithNoAnswerVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: SingleWithNoAnswerVC.identifier) as? SingleWithNoAnswerVC ?? SingleWithNoAnswerVC()
    }()
    private var multipleWith5AnswerWide = MultipleWith5AnswerWideVC()
    private var multipleWithSubProblemsWide = MultipleWithSubProblemsWideVC()
    private var multipleWithConceptWide = MultipleWithConceptWideVC()
    private var multipleWithNoAnswerWide = MultipleWithNoAnswerWideVC()
    private lazy var singleWithSubProblems = {
        return UIStoryboard(name: SingleWithSubProblemsVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: SingleWithSubProblemsVC.identifier) as? SingleWithSubProblemsVC ?? SingleWithSubProblemsVC()
    }()
    private var didSlideViewShow: Bool = false
    private lazy var slideSectionContentsView: SlideSectionContentsView = {
        let view = SlideSectionContentsView()
        view.configureDelegate(self)
        return view
    }()
    private lazy var dimBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.getSemomunColor(.black).withAlphaComponent(0.3)
        view.alpha = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.closeSlideView))
        view.addGestureRecognizer(tap)
        return view
    }()
    private var slideViewTrailingConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureMenu()
        self.configureManager()
        self.bindAll()
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
    
    /* homebar 제거 로직 */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setNeedsUpdateOfHomeIndicatorAutoHidden()
        self.setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return UIRectEdge.bottom
    }
    
    override var childForHomeIndicatorAutoHidden: UIViewController? {
        return self.currentVC
    }
    
    @IBAction func back(_ sender: Any) {
        if let vc = self.currentVC as? TimeRecordControllable {
            vc.endTimeRecord()
        }
        guard let mode = self.mode else { return }
        
        switch mode {
        case .default:
            self.sectionManager?.pauseSection()
            self.sectionManager?.postProblemAndPageDatas(isDismiss: true) // 나가기 전에 submission
        case .practiceTest:
            self.practiceTestManager?.pauseSection()
            self.practiceTestManager?.postProblemAndPageDatas(isDismiss: true) // 나가기 전에 submission
        }
    }
    
    @IBAction func scoringSection(_ sender: Any) {
        if let vc = self.currentVC as? TimeRecordControllable {
            vc.endTimeRecord()
        }
        guard let mode = self.mode else { return }
    
        switch mode {
        case .default:
            guard let sectionNum = self.sectionManager?.sectionNum,
                  let workbookTitle = self.sectionManager?.workbooktitle,
                  let section = self.sectionManager?.section else { return }
            /// ternimate 상태와 상관 없이 항상 SelectProblemsVC 가 표시된다.
            self.showSelectProblemsVC(section: section, sectionNum: sectionNum, workbookTitle: workbookTitle)
        case .practiceTest:
            guard let practiceSection = self.practiceTestManager?.section else { return }
            if practiceSection.terminated {
                self.practiceTestManager?.postProblemAndPageDatas(isDismiss: false) // 결과보기 누를때 submission
                self.showPracticeTestResultVC()
            } else {
                self.showSolvedProblemsVC(practiceSection: practiceSection)
            }
        }
    }
    
    @IBAction func beforePage(_ sender: Any) {
        self.mode == .default ? self.sectionManager?.changePreviousPage() : self.practiceTestManager?.changePreviousPage()
    }
    
    @IBAction func nextPage(_ sender: Any) {
        self.mode == .default ? self.sectionManager?.changeNextPage() : self.practiceTestManager?.changeNextPage()
    }
    
    @IBAction func showContentsSlideVC(_ sender: Any) {
        self.showSlideSectionContetnsView()
    }
}

// MARK: Public
extension StudyVC {
    /// 일반 section 의 관리자
    func configureManager(_ manager: SectionManager) {
        self.sectionManager = manager
        self.mode = .default
    }
    /// 실전 모의고사 section 의 관리자
    func configureManager(_ manager: PracticeTestManager) {
        self.practiceTestManager = manager
        self.mode = .practiceTest
    }
}

// MARK: - Configure
extension StudyVC {
    private func configureUI() {
        self.backButton.setImageWithSVGTintColor(image: UIImage(.chevronLeftOutline), color: .black)
        self.clockIcon.setSVGTintColor(to: .lightGray)
        self.menuButton.setImageWithSVGTintColor(image: UIImage(.dotsCircleHorizontalOutline), color: .black)
        self.scoringButton.setImageWithSVGTintColor(image: UIImage(.clipboardCheckOutline), color: .black)
        self.contentsSlideButton.setImageWithSVGTintColor(image: UIImage(.menuAlt3Outline), color: .black)
        self.previewButton.setImageWithSVGTintColor(image: UIImage(.chevronLeftOutline), color: .black)
        self.nextButton.setImageWithSVGTintColor(image: UIImage(.chevronRightOutline), color: .black)
    }
    
    private func configureMenu() {
        let reportErrorAction = UIAction(title: "오류신고", image: nil) { [weak self] _ in
            self?.showReportView()
        }
        self.menuButton.menu = UIMenu(title: "", image: nil, children: [reportErrorAction])
        self.menuButton.showsMenuAsPrimaryAction = true
    }
    
    private func configureManager() {
        guard let mode = self.mode else { return }
        switch mode {
        case .default: self.sectionManager?.configureDelegate(to: self)
        case .practiceTest: self.practiceTestManager?.configureDelegate(to: self)
        }
    }
    
    private func configureShadow() {
        self.view.layoutIfNeeded()
        self.headerFrameView.addShadow()
        self.bottomProblemIndicatorView.addShadow()
    }
    
    /// 채점 이후 결과창 표시를 위한 observer
    private func configureObservation() {
        NotificationCenter.default.addObserver(forName: .showSectionResult, object: nil, queue: .current) { [weak self] _ in
            // MARK: Mode 에 따른 분기처리가 필요, 또는 다른 Noti를 사용하는 식으로
            guard let workbookTitle = self?.sectionManager?.workbooktitle,
                  let sectionNum = self?.sectionManager?.sectionNum,
                  let section = self?.sectionManager?.section,
                  let pageData = self?.sectionManager?.currentPage else { return }
            
            self?.changeVC(pageData: pageData)
            self?.sectionManager?.postProblemAndPageDatas(isDismiss: false) // 채점 이후 post
            self?.showResultViewController(section: section, sectionNum: sectionNum, workbookTitle: workbookTitle)
        }
        NotificationCenter.default.addObserver(forName: .showPracticeTestResult, object: nil, queue: .main) { [weak self] _ in
            guard let pageData = self?.practiceTestManager?.currentPage else { return }
            
            self?.changeVC(pageData: pageData)
            self?.practiceTestManager?.postProblemAndPageDatas(isDismiss: false)
            self?.showPracticeTestResultVC()
        }
        NotificationCenter.default.addObserver(forName: .previousPage, object: nil, queue: .main) { [weak self] _ in
            self?.previousPage()
        }
        NotificationCenter.default.addObserver(forName: .nextPage, object: nil, queue: .main) { [weak self] _ in
            self?.nextPage()
        }
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
        switch self.mode {
        case .default:
            guard let pageData = self.sectionManager?.currentPage else { return }
            guard let title = self.sectionManager?.sectionTitle else { return }
            let reportVC = ReportProblemErrorVC(pageData: pageData, title: title)
            
            self.present(reportVC, animated: true, completion: nil)
        case .practiceTest:
            guard let pageData = self.practiceTestManager?.currentPage else { return }
            guard let title = self.practiceTestManager?.sectionTitle else { return }
            let reportVC = ReportProblemErrorVC(pageData: pageData, title: title)
            
            self.present(reportVC, animated: true, completion: nil)
        default:
            return
        }
    }
    
    private func showSelectProblemsVC(section: Section_Core, sectionNum: Int, workbookTitle: String) {
        let storyboard = UIStoryboard(name: SelectProblemsVC.storyboardName, bundle: nil)
        guard let selectProblemsVC = storyboard.instantiateViewController(withIdentifier: SelectProblemsVC.identifier) as? SelectProblemsVC else { return }
        let viewModel = SelectProblemsVM(section: section, sectionNum: sectionNum, workbookTitle: workbookTitle)
        selectProblemsVC.configureViewModel(viewModel: viewModel)
        
        self.present(selectProblemsVC, animated: true, completion: nil)
    }
    
    private func showSolvedProblemsVC(practiceSection: PracticeTestSection_Core) {
        let storyboard = UIStoryboard(name: ShowSolvedProblemsVC.storyboardName, bundle: nil)
        guard let showSolvedProblemsVC = storyboard.instantiateViewController(withIdentifier: ShowSolvedProblemsVC.identifier) as? ShowSolvedProblemsVC else { return }
        let viewModel = ShowSolvedProblemsVM(practiceSection: practiceSection)
        showSolvedProblemsVC.configureViewModel(viewModel: viewModel)
        
        self.present(showSolvedProblemsVC, animated: true, completion: nil)
    }
    
    private func showTestInfoView(testInfo: TestInfo) {
        let hostingVC = UIHostingController(rootView: TestInfoView(info: testInfo, delegate: self))
        hostingVC.modalPresentationStyle = .overFullScreen
        self.present(hostingVC, animated: true, completion: nil)
    }
    
    private func showResultViewController(section: Section_Core, sectionNum: Int, workbookTitle: String) {
        let storyboard = UIStoryboard(name: SectionResultVC.storyboardName, bundle: nil)
        guard let sectionResultVC = storyboard.instantiateViewController(withIdentifier: SectionResultVC.identifier) as? SectionResultVC else { return }
        let viewModel = SectionResultVM(section: section, sectionNum: sectionNum, workbookTitle: workbookTitle)
        sectionResultVC.configureViewModel(viewModel: viewModel)
        
        self.present(sectionResultVC, animated: true, completion: nil)
    }
    
    private func showPracticeTestResultVC() {
        guard let wgid = self.practiceTestManager?.wgid else { return }
        guard let section = self.practiceTestManager?.section else { return }
        
        let networkUsecase = NetworkUsecase(network: Network())
        let viewModel = PracticeTestResultVM(
            wgid: wgid,
            practiceTestSection: section,
            networkUsecase: networkUsecase
        )
        let vc = PracticeTestResultVC(viewModel: viewModel)
        self.present(vc, animated: true)
    }
}

extension StudyVC: LayoutDelegate {
    func changeVC(pageData: PageData) {
        self.removeCurrentVC()

        switch pageData.layoutType {
        case SingleWith5AnswerVC.identifier:
            self.currentVC = self.singleWith5Answer
            self.singleWith5Answer.viewModel = SingleWith5AnswerVM(delegate: self, pageData: pageData, mode: self.mode)
            self.singleWith5Answer.image = self.getImage(data: pageData.problems[0].contentImage)
            
        case SingleWithTextAnswerVC.identifier:
            self.currentVC = self.singleWithTextAnswer
            self.singleWithTextAnswer.viewModel = SingleWithTextAnswerVM(delegate: self, pageData: pageData, mode: self.mode)
            self.singleWithTextAnswer.image = self.getImage(data: pageData.problems[0].contentImage)
            
        case MultipleWith5AnswerVC.identifier:
            // Page 필기 겹치는 문제 때문에 Multiple계열 VC들은 모두 새로 객체를 생성. 
            self.multipleWith5Answer = .init()
            self.currentVC = self.multipleWith5Answer
            self.multipleWith5Answer.viewModel = MultipleWith5AnswerVM(delegate: self, pageData: pageData, mode: self.mode)
            self.multipleWith5Answer.mainImage = self.getImage(data: pageData.pageCore.materialImage)
            self.multipleWith5Answer.subImages = self.getImages(problems: pageData.problems)
            
        case SingleWith4AnswerVC.identifier:
            self.currentVC = self.singleWith4Answer
            self.singleWith4Answer.viewModel = SingleWith4AnswerVM(delegate: self, pageData: pageData, mode: self.mode)
            self.singleWith4Answer.image = self.getImage(data: pageData.problems[0].contentImage)
            
        case MultipleWithNoAnswerVC.identifier:
            self.multipleWithNoAnswer = .init()
            self.currentVC = self.multipleWithNoAnswer
            self.multipleWithNoAnswer.viewModel = MultipleWithNoAnswerVM(delegate: self, pageData: pageData, mode: self.mode)
            self.multipleWithNoAnswer.mainImage = self.getImage(data: pageData.pageCore.materialImage)
            self.multipleWithNoAnswer.subImages = self.getImages(problems: pageData.problems)
            
        case ConceptVC.identifier:
            self.currentVC = self.concept
            self.concept.viewModel = ConceptVM(delegate: self, pageData: pageData, mode: self.mode)
            self.concept.image = self.getImage(data: pageData.problems[0].contentImage)
        
        case SingleWithNoAnswerVC.identifier:
            self.currentVC = self.singleWithNoAnswer
            self.singleWithNoAnswer.viewModel = SingleWithNoAnswerVM(delegate: self, pageData: pageData, mode: self.mode)
            self.singleWithNoAnswer.image = self.getImage(data: pageData.problems[0].contentImage)
        
        case MultipleWith5AnswerWideVC.identifier:
            self.multipleWith5AnswerWide = .init()
            self.currentVC = self.multipleWith5AnswerWide
            self.multipleWith5AnswerWide.viewModel = MultipleWith5AnswerVM(delegate: self, pageData: pageData, mode: self.mode)
            self.multipleWith5AnswerWide.mainImage = self.getImage(data: pageData.pageCore.materialImage)
            self.multipleWith5AnswerWide.subImages = self.getImages(problems: pageData.problems)
            
        case MultipleWithSubProblemsWideVC.identifier:
            self.multipleWithSubProblemsWide = .init()
            self.currentVC = self.multipleWithSubProblemsWide
            self.multipleWithSubProblemsWide.viewModel = MultipleWithSubProblemsVM(delegate: self, pageData: pageData, mode: self.mode)
            self.multipleWithSubProblemsWide.mainImage = self.getImage(data: pageData.pageCore.materialImage)
            self.multipleWithSubProblemsWide.subImages = self.getImages(problems: pageData.problems)
            
        case MultipleWithConceptWideVC.identifier:
            self.multipleWithConceptWide = .init()
            self.currentVC = self.multipleWithConceptWide
            self.multipleWithConceptWide.viewModel = MultipleWithConceptWideVM(delegate: self, pageData: pageData, mode: self.mode)
            self.multipleWithConceptWide.mainImage = self.getImage(data: pageData.pageCore.materialImage)
            self.multipleWithConceptWide.subImages = self.getImages(problems: pageData.problems)
            
        case MultipleWithNoAnswerWideVC.identifier:
            self.multipleWithNoAnswerWide = .init()
            self.currentVC = self.multipleWithNoAnswerWide
            self.multipleWithNoAnswerWide.viewModel = MultipleWithNoAnswerVM(delegate: self, pageData: pageData, mode: self.mode)
            self.multipleWithNoAnswerWide.mainImage = self.getImage(data: pageData.pageCore.materialImage)
            self.multipleWithNoAnswerWide.subImages = self.getImages(problems: pageData.problems)
            
        case SingleWithSubProblemsVC.identifier:
            self.currentVC = self.singleWithSubProblems
            self.singleWithSubProblems.configureViewModel(delegate: self, pageData: pageData, mode: self.mode)
            self.singleWithSubProblems.image = self.getImage(data: pageData.problems[0].contentImage)
        
        default:
            break
        }
        self.showVC(to: self.currentVC)
    }
    
    func showAlert(text: String) {
        self.showAlertWithOK(title: text, text: "")
    }
    
    func dismissSection() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension StudyVC: PageDelegate {
    func refreshPageButtons() {
        CoreDataManager.saveCoreData()
    }
    
    func nextPage() {
        self.mode == .default ? self.sectionManager?.changeNextPage() : self.practiceTestManager?.changeNextPage()
    }
    
    func previousPage() {
        self.mode == .default ? self.sectionManager?.changePreviousPage() : self.practiceTestManager?.changePreviousPage()
    }
    
    func addScoring(pid: Int) {
        switch self.mode {
        case .default:
            self.sectionManager?.addScoring(pid: pid)
        case .practiceTest:
            self.practiceTestManager?.addScoring(pid: pid)
        default:
            return
        }
    }
    
    func addUploadProblem(pid: Int) {
        switch self.mode {
        case .default:
            self.sectionManager?.addUploadProblem(pid: pid)
        case .practiceTest:
            self.practiceTestManager?.addUploadProblem(pid: pid)
        default:
            return
        }
    }
    
    func addUploadPage(vid: Int) {
        switch self.mode {
        case .default:
            self.sectionManager?.addUploadPage(vid: vid)
        case .practiceTest:
            self.practiceTestManager?.addUploadPage(vid: vid)
        default:
            return
        }
    }
}

// MARK: Binding
extension StudyVC {
    private func bindAll() {
        self.bindTime()
        self.bindPage()
        self.bindTestInfo()
        self.bindWarning()
        self.bindTernimate()
        self.bindPageCount()
        self.bindCurrentPageIndex()
    }
    
    private func bindTime() {
        self.sectionManager?.$currentTime
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] time in
                self?.timeLabel.text = time.toTimeString
            })
            .store(in: &self.cancellables)
        self.practiceTestManager?.$recentTime
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] time in
                self?.timeLabel.text = time.toTimeString
            })
            .store(in: &self.cancellables)
    }
    
    private func bindPage() {
        self.sectionManager?.$currentPage
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] pageData in
                guard let pageData = pageData else { return }
                self?.changeVC(pageData: pageData)
            })
            .store(in: &self.cancellables)
        self.practiceTestManager?.$currentPage
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] pageData in
                guard let pageData = pageData else { return }
                self?.changeVC(pageData: pageData)
            })
            .store(in: &self.cancellables)
    }
    
    private func bindTestInfo() {
        self.practiceTestManager?.$showTestInfo
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] testInfo in
                guard let testInfo = testInfo else { return }
                self?.showTestInfoView(testInfo: testInfo)
            })
            .store(in: &self.cancellables)
    }
    
    private func bindWarning() {
        self.practiceTestManager?.$warning
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] warning in
                guard let warning = warning else { return }
                self?.showAlertWithOK(title: warning.title, text: warning.text)
            })
            .store(in: &self.cancellables)
    }
    
    private func bindTernimate() {
        self.practiceTestManager?.$practiceTestTernimate
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] ternimnate in
                guard ternimnate else { return }
                guard let pageData = self?.practiceTestManager?.currentPage else { return }
                
                self?.changeVC(pageData: pageData)
                self?.showPracticeTestResultVC()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindPageCount() {
        self.sectionManager?.$totalPageCount
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] count in
                let currentPageIndex = self?.sectionManager?.currentPageIndex ?? 0
                self?.pageLabel.text = "\(currentPageIndex+1)/\(count)"
            })
            .store(in: &self.cancellables)
        self.practiceTestManager?.$totalPageCount
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] count in
                let currentPageIndex = self?.practiceTestManager?.currentPageIndex ?? 0
                self?.pageLabel.text = "\(currentPageIndex+1)/\(count)"
            })
            .store(in: &self.cancellables)
    }
    
    private func bindCurrentPageIndex() {
        self.sectionManager?.$currentPageIndex
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] index in
                let totalPageCount = self?.sectionManager?.totalPageCount ?? 0
                self?.pageLabel.text = "\(index+1)/\(totalPageCount)"
            })
            .store(in: &self.cancellables)
        self.practiceTestManager?.$currentPageIndex
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] index in
                let totalPageCount = self?.practiceTestManager?.totalPageCount ?? 0
                self?.pageLabel.text = "\(index+1)/\(totalPageCount)"
            })
            .store(in: &self.cancellables)
    }
}

extension StudyVC: TestStartable {
    func startTest() {
        self.practiceTestManager?.startTest()
    }
    func dismiss() {
        self.dismiss(animated: true)
    }
}

extension StudyVC {
    private func showSlideSectionContetnsView() {
        guard self.didSlideViewShow == false else { return }
        if self.mode == .default {
            guard let workbookTitle = self.sectionManager?.workbooktitle,
                  let sectionNum = self.sectionManager?.sectionNum,
                  let sectionTitle = self.sectionManager?.sectionTitle else { return }
            
            self.slideSectionContentsView.configure(workbookTitle: workbookTitle,
                                                  sectionNum: sectionNum,
                                                  sectionTitle: sectionTitle,
                                                  delegate: self)
        } else {
            guard let workbookTitle = self.practiceTestManager?.workbooktitle,
                  let sectionNum = self.practiceTestManager?.sectionNum,
                  let sectionTitle = self.practiceTestManager?.sectionTitle else { return }
            self.slideSectionContentsView.configure(workbookTitle: workbookTitle,
                                                    sectionNum: sectionNum,
                                                    sectionTitle: sectionTitle,
                                                    delegate: self)
        }
        
        self.slideSectionContentsView.reload()
        /// dim 추가
        self.view.addSubview(self.dimBackgroundView)
        NSLayoutConstraint.activate([
            self.dimBackgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.dimBackgroundView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.dimBackgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.dimBackgroundView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        /// slideView 추가
        self.view.addSubview(self.slideSectionContentsView)
        NSLayoutConstraint.activate([
            self.slideSectionContentsView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.slideSectionContentsView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        /// constraint 설정
        self.slideViewTrailingConstraint = self.slideSectionContentsView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: SlideSectionContentsView.width)
        self.slideViewTrailingConstraint?.isActive = true
        self.view.layoutIfNeeded()
        /// animation 설정
        self.slideViewTrailingConstraint?.constant = 0
        UIView.animate(withDuration: 0.25) {
            self.dimBackgroundView.alpha = 1
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.didSlideViewShow = true
        }
    }
}

extension StudyVC: StudyContentsSlideDelegate {
    @objc func closeSlideView() {
        guard self.didSlideViewShow == true else { return }
        self.slideViewTrailingConstraint?.constant = SlideSectionContentsView.width
        UIView.animate(withDuration: 0.25) {
            self.dimBackgroundView.alpha = 0
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.dimBackgroundView.removeFromSuperview()
            self.slideSectionContentsView.removeFromSuperview()
            self.didSlideViewShow = false
        }
    }
}

extension StudyVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch self.slideSectionContentsView.mode {
        case .contents:
            if self.mode == .default {
                guard let selectedProblem = self.sectionManager?.problems[safe: indexPath.item] else { return }
                self.sectionManager?.selecteProblem(to: selectedProblem)
            } else {
                guard let selectedProblem = self.practiceTestManager?.problems[safe: indexPath.item] else { return }
                self.practiceTestManager?.selecteProblem(to: selectedProblem)
            }
        case .bookmark:
            if self.mode == .default {
                guard let selectedProblem = self.sectionManager?.bookmarkedProblems[safe: indexPath.item] else { return }
                self.sectionManager?.selecteProblem(to: selectedProblem)
            } else {
                guard let selectedProblem = self.practiceTestManager?.bookmarkedProblems[safe: indexPath.item] else { return }
                self.practiceTestManager?.selecteProblem(to: selectedProblem)
            }
        }
        self.closeSlideView()
    }
}

extension StudyVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.slideSectionContentsView.mode {
        case .contents:
            if self.mode == .default {
                return self.sectionManager?.problems.count ?? 0
            } else {
                return self.practiceTestManager?.problems.count ?? 0
            }
        case .bookmark:
            if self.mode == .default {
                return self.sectionManager?.bookmarkedProblems.count ?? 0
            } else {
                return self.practiceTestManager?.bookmarkedProblems.count ?? 0
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProblemCell.identifier, for: indexPath) as? ProblemCell else { return .init() }
        switch self.slideSectionContentsView.mode {
        case .contents:
            if self.mode == .default {
                let dataSource = self.sectionManager?.problems ?? []
                guard let problem = dataSource[safe: indexPath.item] else { return cell }
                cell.configure(problem: problem, isSelected: self.sectionManager?.currentIndex == indexPath.item)
            } else {
                let dataSource = self.practiceTestManager?.problems ?? []
                guard let problem = dataSource[safe: indexPath.item] else { return cell }
                cell.configure(problem: problem, isSelected: self.practiceTestManager?.currentIndex == indexPath.item)
            }
        case.bookmark:
            if self.mode == .default {
                let dataSource = self.sectionManager?.bookmarkedProblems ?? []
                guard let problem = dataSource[safe: indexPath.item] else { return cell }
                cell.configure(problem: problem, isSelected: false)
            } else {
                let dataSource = self.practiceTestManager?.bookmarkedProblems ?? []
                guard let problem = dataSource[safe: indexPath.item] else { return cell }
                cell.configure(problem: problem, isSelected: false)
            }
        }
        return cell
    }
}

extension StudyVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(40, 40)
    }
}
