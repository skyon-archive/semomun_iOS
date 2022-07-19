//
//  WorkbookGroupDetailVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/05/06.
//

import UIKit
import Combine

final class WorkbookGroupDetailVC: UIViewController {
    /* public */
    static let identifier = "WorkbookGroupDetailVC"
    static let storyboardName = "HomeSearchBookshelf"
    var viewModel: WorkbookGroupDetailVM?
    /* private */
    private var cancellables: Set<AnyCancellable> = []
    private var networkUsecase = NetworkUsecase(network: Network())
    private lazy var loadingView = LoadingView()
    private let workbookGroupResultButton = WorkbookGroupResultButton()
    @IBOutlet weak var practiceTests: UICollectionView!
    private var hasPurchasedWorkbook: Bool {
        return self.viewModel?.purchasedWorkbooks.isEmpty == false
    }
    private var noMorePurchaseable: Bool {
        return self.viewModel?.nonPurchasedWorkbooks.isEmpty == true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindAll()
        self.configurePracticeTests()
        self.configureWorkbookGroupResultButton()
        self.configureAddObserver()
        self.navigationItem.backButtonTitle = "뒤로"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel?.fetchTestResults()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.practiceTests.reloadData()        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(
            alongsideTransition: { [weak self] _ in
                self?.practiceTests.collectionViewLayout.invalidateLayout()
            }
        )
    }
}

// MARK: Public
extension WorkbookGroupDetailVC {
    func configureViewModel(to viewModel: WorkbookGroupDetailVM) {
        self.viewModel = viewModel
    }
}

// MARK: Configure
extension WorkbookGroupDetailVC {
    private func configurePracticeTests() {
        let flowLayout = ScrollingBackgroundFlowLayout(sectionHeaderExist: true)
        self.practiceTests.collectionViewLayout = flowLayout
        self.practiceTests.configureDefaultDesign()
        
        self.practiceTests.register(TestSubjectCell.self, forCellWithReuseIdentifier: TestSubjectCell.identifer)
        self.practiceTests.dataSource = self
        self.practiceTests.delegate = self
    }
    
    private func configureWorkbookGroupResultButton() {
        let action = UIAction { [weak self] _ in
            self?.showWorkbookGroupResultVC()
        }
        
        self.workbookGroupResultButton.addAction(action, for: .touchUpInside)
        self.workbookGroupResultButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: workbookGroupResultButton)
    }
    
    private func showWorkbookGroupResultVC() {
        let storyboard = UIStoryboard(controllerType: WorkbookGroupResultVC.self)
        guard let comprehensiveReportVC = storyboard.instantiateViewController(withIdentifier: WorkbookGroupResultVC.identifier) as? WorkbookGroupResultVC else { return }
        
        guard let viewModel = self.viewModel else { return }
        
        let workbookGroupVM = WorkbookGroupResultVM(workbookGroupInfo: viewModel.info, testResults: viewModel.testResults)
        comprehensiveReportVC.configureViewModel(workbookGroupVM)
        
        self.navigationController?.pushViewController(comprehensiveReportVC, animated: true)
    }
    
    private func configureAddObserver() {
        NotificationCenter.default.addObserver(forName: .goToUpdateUserinfo, object: nil, queue: .main) { [weak self] _ in
            self?.showChangeUserinfoVC()
        }
        NotificationCenter.default.addObserver(forName: .goToCharge, object: nil, queue: .main) { [weak self] _ in
            self?.showChargeVC()
        }
        NotificationCenter.default.addObserver(forName: .purchaseComplete, object: nil, queue: .main) { [weak self] _ in
            self?.viewModel?.purchaseComplete()
        }
    }
}

// MARK: Binding
extension WorkbookGroupDetailVC {
    private func bindAll() {
        self.bindWorkbookGroupInfo()
        self.bindPurchasedWorkbooks()
        self.bindNonPurchasedWorkbooks()
        self.bindLoader()
        self.bindPopupType()
        self.bindPurchaseWorkbook()
        self.bindWarning()
        self.bindPopVC()
        self.bindTestResults()
    }
    
    private func bindWorkbookGroupInfo() {
        self.viewModel?.$info
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] info in
                self?.title = info.title
            })
            .store(in: &self.cancellables)
    }
    
    private func bindPurchasedWorkbooks() {
        self.viewModel?.$purchasedWorkbooks
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] purchases in
                guard purchases.isEmpty == false else { return }
                self?.practiceTests.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindNonPurchasedWorkbooks() {
        self.viewModel?.$nonPurchasedWorkbooks
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] workbooks in
                guard workbooks.isEmpty == false else { return }
                self?.practiceTests.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindLoader() {
        self.viewModel?.$showLoader
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] showLoader in
                if showLoader {
                    self?.startLoader()
                } else {
                    self?.stopLoader()
                }
            })
            .store(in: &self.cancellables)
    }
    
    private func bindPopupType() {
        self.viewModel?.$popupType
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] type in
                guard let type = type else { return }
                self?.showPopupVC(type: type)
            })
            .store(in: &self.cancellables)
    }
    
    private func bindPurchaseWorkbook() {
        self.viewModel?.$purchaseWorkbook
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] workbook in
                guard let workbook = workbook else { return }
                self?.showPurchasePopupVC(workbook: workbook)
            })
            .store(in: &self.cancellables)
    }
    
    private func bindWarning() {
        self.viewModel?.$warning
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] error in
                guard let error = error else { return }
                self?.showAlertWithOK(title: error.title, text: error.text)
            })
            .store(in: &self.cancellables)
    }
    
    private func bindPopVC() {
        self.viewModel?.$popVC
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] popVC in
                guard let popVC = popVC else { return }
                self?.showAlertWithOK(title: popVC.title, text: popVC.text, completion: {
                    self?.navigationController?.popViewController(animated: true)
                })
            })
            .store(in: &self.cancellables)
    }
    
    private func bindTestResults() {
        self.viewModel?.$testResults
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] testResults in

                self?.workbookGroupResultButton.isEnabled = (testResults.isEmpty == false)
            })
            .store(in: &self.cancellables)
    }
}

// MARK: CollectionView
extension WorkbookGroupDetailVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (self.hasPurchasedWorkbook && self.noMorePurchaseable == false) ? 2 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let purchasedCount = self.viewModel?.purchasedWorkbooks.count ?? 0
        let nonPurchasedCount = self.viewModel?.nonPurchasedWorkbooks.count ?? 0
        
        switch section {
        case 0:
            return self.hasPurchasedWorkbook ? purchasedCount : nonPurchasedCount
        case 1:
            return nonPurchasedCount
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TestSubjectCell.identifer, for: indexPath) as? TestSubjectCell else { return UICollectionViewCell() }
        cell.configureNetworkUsecase(to: self.networkUsecase)
        
        switch indexPath.section {
        case 0:
            if self.hasPurchasedWorkbook {
                guard let coreInfo = self.viewModel?.purchasedWorkbooks[safe: indexPath.item] else { return cell }
                cell.configure(coreInfo: coreInfo)
                cell.configureDelegate(to: self)
            } else {
                guard let dtoInfo = self.viewModel?.nonPurchasedWorkbooks[safe: indexPath.item] else { return cell }
                cell.configure(dtoInfo: dtoInfo)
            }
        case 1:
            guard let dtoInfo = self.viewModel?.nonPurchasedWorkbooks[safe: indexPath.item] else { return cell }
            cell.configure(dtoInfo: dtoInfo)
        default:
            assertionFailure("collectionView indexPath section error")
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: WorkbookGroupDetailHeaderView.identifier, for: indexPath) as? WorkbookGroupDetailHeaderView else { return UICollectionReusableView() }
            
            switch indexPath.section {
            case 0:
                headerView.updateLabel(to: self.hasPurchasedWorkbook ? "구매한 과목" : "구매하지 않은 과목")
            case 1:
                headerView.updateLabel(to: "구매한 과목")
            default:
                assertionFailure("collectionView indexPath section error")
            }
            
            return headerView
        default:
            return UICollectionReusableView()
        }
    }
}

extension WorkbookGroupDetailVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if self.hasPurchasedWorkbook == false {
                self.viewModel?.selectWorkbook(to: indexPath.item)
            }
        case 1:
            self.viewModel?.selectWorkbook(to: indexPath.item)
        default:
            assertionFailure("collectionView indexPath section error")
        }
    }
}

// MARK: PopupVC
extension WorkbookGroupDetailVC {
    private func showPopupVC(type: WorkbookGroupDetailVM.PopupType) {
        let storyboard = UIStoryboard(name: PurchaseWarningPopupVC.storyboardName, bundle: nil)
        guard let popupVC = storyboard.instantiateViewController(withIdentifier: PurchaseWarningPopupVC.identifier) as? PurchaseWarningPopupVC else { return }
        popupVC.configureWarning(type: type == .login ? .login : .updateUserinfo)
        self.present(popupVC, animated: true)
    }
    
    private func showPurchasePopupVC(workbook: WorkbookOfDB) {
        let storyboard = UIStoryboard(name: PurchasePopupVC.storyboardName, bundle: nil)
        guard let popupVC = storyboard.instantiateViewController(withIdentifier: PurchasePopupVC.identifier) as? PurchasePopupVC else { return }
        guard let credit = self.viewModel?.credit else { return }
        popupVC.configureInfo(info: workbook)
        popupVC.configureCurrentMoney(money: credit)
        self.present(popupVC, animated: true)
    }
}

// MARK: ChangeVC
extension WorkbookGroupDetailVC {
    private func showChangeUserinfoVC() {
        let storyboard = UIStoryboard(name: ChangeUserinfoVC.storyboardName, bundle: nil)
        guard let changeUserinfoVC = storyboard.instantiateViewController(withIdentifier: ChangeUserinfoVC.identifier) as? ChangeUserinfoVC else { return }
        self.navigationController?.pushViewController(changeUserinfoVC, animated: true)
    }
    
    private func showChargeVC() {
        let storyboard = UIStoryboard(name: WaitingChargeVC.storyboardName, bundle: nil)
        let waitingChargeVC = storyboard.instantiateViewController(withIdentifier: WaitingChargeVC.identifier)
        self.navigationController?.pushViewController(waitingChargeVC, animated: true)
    }
    
    private func showStudyVC(section: PracticeTestSection_Core, workbook: Preview_Core) {
        guard let studyVC = UIStoryboard(name: StudyVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: StudyVC.identifier) as? StudyVC else { return }
        guard let workbookGroup = self.viewModel?.workbookGroupCore else { return }
        
        let networkUsecase = NetworkUsecase(network: Network())
        let manager = PracticeTestManager(section: section, workbookGroup: workbookGroup, workbook: workbook, networkUsecase: networkUsecase)
        
        studyVC.modalPresentationStyle = .fullScreen
        studyVC.configureManager(manager)
        
        self.present(studyVC, animated: true, completion: nil)
    }
}

// MARK: Loader
extension WorkbookGroupDetailVC {
    private func startLoader() {
        self.view.addSubview(self.loadingView)
        self.loadingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.loadingView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.loadingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.loadingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.loadingView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        self.loadingView.start()
    }
    
    private func stopLoader() {
        self.loadingView.stop()
        self.loadingView.removeFromSuperview()
    }
}

extension WorkbookGroupDetailVC: TestSubjectCellObserber {
    func showAlertDownloadSectionFail() {
        self.showAlertWithOK(title: "다운로드 실패", text: "네트워크 연결을 확인 후 다시 시도하세요")
    }
    
    func showPracticeTestSection(workbook: Preview_Core) {
        guard workbook.sids.count == 1,
              let sid = workbook.sids.first,
              let practiceSection = CoreUsecase.fetchPracticeSection(sid: sid) else {
            self.showAlertWithOK(title: "문제집 정보 에러", text: "")
            return
        }
        self.viewModel?.updateRecentDate(workbook: workbook)
        self.showStudyVC(section: practiceSection, workbook: workbook)
    }
}
