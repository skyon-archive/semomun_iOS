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
    @IBOutlet weak var practiceTests: UICollectionView!
    // MARK: Cell Size
    private lazy var portraitColumnCount: CGFloat = {
        let screenWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        switch screenWidth {
        case 744: return 4 // 미니
        case 1024: return 6 // 12인치
        default: return 5 // 11인치
        }
    }()
    private lazy var landscapeColumCount: CGFloat = {
        return self.portraitColumnCount + 2 // 세로개수 + 2
    }()
    private var portraitCellSize: CGSize {
        let screenWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        let columCount = self.portraitColumnCount
        let horizontalInset: CGFloat = 28
        let horizontalTerm: CGFloat = 12
        let cellWidth: CGFloat = (screenWidth - (horizontalInset * 2) - (horizontalTerm * (columCount - 1))) / columCount
        let cellHeight = cellWidth*5/4 + 65

        return CGSize(cellWidth, cellHeight)
    }
    private var landscapeCellSize: CGSize {
        let screenWidth = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        let columCount = self.landscapeColumCount
        let horizontalInset: CGFloat = 28
        let horizontalTerm: CGFloat = 12
        let cellWidth: CGFloat = (screenWidth - (horizontalInset * 2) - (horizontalTerm * (columCount - 1))) / columCount
        let cellHeight = cellWidth*5/4 + 65

        return CGSize(cellWidth, cellHeight)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindAll()
        self.configurePracticeTests()
        self.configureWorkbookGroupResultButton()
        self.configureAddObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // MARK: reload 로직 필요 (workbook terminated 상태 최신화)
        self.practiceTests.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.practiceTests.collectionViewLayout.invalidateLayout()
        coordinator.animate { _ in
            self.practiceTests.reloadData()
        }
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
        self.practiceTests.dataSource = self
        self.practiceTests.delegate = self
    }
    
    private func configureWorkbookGroupResultButton() {
        let workbookGroupResultButton = WorkbookGroupResultButton()
        
        if self.viewModel?.hasTerminatedWorkbook == true {
            let action = UIAction { [weak self] _ in
                guard NetworkStatusManager.isConnectedToInternet() else {
                    self?.showAlertWithOK(title: "네트워크 에러", text: "네트워크 연결을 확인 후 다시 시도하세요")
                    return
                }
                self?.showWorkbookGroupResultVC()
            }
            workbookGroupResultButton.addAction(action, for: .touchUpInside)
        } else {
            workbookGroupResultButton.configureDisabledUI()
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: workbookGroupResultButton)
    }
    
    private func showWorkbookGroupResultVC() {
        let storyboard = UIStoryboard(controllerType: WorkbookGroupResultVC.self)
        guard let comprehensiveReportVC = storyboard.instantiateViewController(withIdentifier: WorkbookGroupResultVC.identifier) as? WorkbookGroupResultVC else { return }
        
        guard let info = self.viewModel?.info else { return }
        // MARK: info 를 넘기는 로직 필요
        
        let networkUsecase = NetworkUsecase(network: Network())
        let viewModel = WorkbookGroupResultVM(info: info, networkUsecase: networkUsecase)
        comprehensiveReportVC.configureViewModel(viewModel)
        self.navigationController?.pushViewController(comprehensiveReportVC, animated: true)
    }
    
    private func configureAddObserver() {
        NotificationCenter.default.addObserver(forName: .goToLogin, object: nil, queue: .main) { [weak self] _ in
            self?.showLoginVC()
        }
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
}

// MARK: CollectionView
extension WorkbookGroupDetailVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (self.viewModel?.hasPurchasedWorkbook ?? false) ? 2 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let hasPurchasedWorkbook = self.viewModel?.hasPurchasedWorkbook ?? false
        let purchasedCount = self.viewModel?.purchasedWorkbooks.count ?? 0
        let nonPurchasedCount = self.viewModel?.nonPurchasedWorkbooks.count ?? 0
        
        switch section {
        case 0:
            return hasPurchasedWorkbook ? purchasedCount : nonPurchasedCount
        case 1:
            return nonPurchasedCount
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TestSubjectCell.identifer, for: indexPath) as? TestSubjectCell else { return UICollectionViewCell() }
        let hasPurchasedWorkbook = self.viewModel?.hasPurchasedWorkbook ?? false
        cell.configureNetworkUsecase(to: self.networkUsecase)
        
        switch indexPath.section {
        case 0:
            if hasPurchasedWorkbook {
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
            let hasPurchasedWorkbook = self.viewModel?.hasPurchasedWorkbook ?? false
            
            switch indexPath.section {
            case 0:
                headerView.updateLabel(to: hasPurchasedWorkbook ? "나의 실전 모의고사" : "실전 모의고사")
            case 1:
                headerView.updateLabel(to: "실전 모의고사")
            default:
                assertionFailure("collectionView indexPath section error")
            }
            
            return headerView
        default:
            return UICollectionReusableView()
        }
    }
}

extension WorkbookGroupDetailVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return UIWindow.isLandscape ? self.landscapeCellSize : self.portraitCellSize
    }
}

extension WorkbookGroupDetailVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let hasPurchasedWorkbook = self.viewModel?.hasPurchasedWorkbook ?? false
        switch indexPath.section {
        case 0:
            if hasPurchasedWorkbook == false {
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
        let storyboard = UIStoryboard(name: ChangeUserInfoVC.storyboardName, bundle: nil)
        guard let changeUserinfoVC = storyboard.instantiateViewController(withIdentifier: ChangeUserInfoVC.identifier) as? ChangeUserInfoVC else { return }
        let viewModel = ChangeUserInfoVM(networkUseCase: NetworkUsecase(network: Network()))
        changeUserinfoVC.configureVM(viewModel)
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
