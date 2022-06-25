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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindAll()
        self.configurePracticeTests()
        self.configureComprehensiveReportButton()
        self.configureAddObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
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
    
    private func configureComprehensiveReportButton() {
        let comprehensiveReportButton = WorkbookGroupResultButton()
        let action = UIAction { [weak self] _ in self?.showWorkbookGroupResultVC() }
        comprehensiveReportButton.addAction(action, for: .touchUpInside)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: comprehensiveReportButton)
    }
    
    private func showWorkbookGroupResultVC() {
        let storyboard = UIStoryboard(controllerType: WorkbookGroupResultVC.self)
        guard let comprehensiveReportVC = storyboard.instantiateViewController(withIdentifier: WorkbookGroupResultVC.identifier) as? WorkbookGroupResultVC else { return }
        
        // wgid 받아오는 임시 로직
        let wgid = 1
        
        let networkUsecase = NetworkUsecase(network: Network())
        let viewModel = WorkbookGroupResultVM(wgid: wgid, networkUsecase: networkUsecase)
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
}

// MARK: CollectionView
extension WorkbookGroupDetailVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.viewModel?.isPurchased ?? false ? 2 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let isPurchased = self.viewModel?.isPurchased ?? false
        let purchasedCount = self.viewModel?.purchasedWorkbooks.count ?? 0
        let nonPurchasedCount = self.viewModel?.nonPurchasedWorkbooks.count ?? 0
        
        switch section {
        case 0:
            return isPurchased ? purchasedCount : nonPurchasedCount
        case 1:
            return nonPurchasedCount
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TestSubjectCell.identifer, for: indexPath) as? TestSubjectCell else { return UICollectionViewCell() }
        let isPurchased = self.viewModel?.isPurchased ?? false
        
        switch indexPath.section {
        case 0:
            if isPurchased {
                guard let coreInfo = self.viewModel?.purchasedWorkbooks[safe: indexPath.item] else { return cell
                }
                cell.configure(coreInfo: coreInfo)
            } else {
                guard let dtoInfo = self.viewModel?.nonPurchasedWorkbooks[safe: indexPath.item] else { return cell }
                cell.configureNetworkUsecase(to: self.networkUsecase)
                cell.configure(dtoInfo: dtoInfo)
            }
        case 1:
            guard let dtoInfo = self.viewModel?.nonPurchasedWorkbooks[safe: indexPath.item] else { return cell }
            cell.configureNetworkUsecase(to: self.networkUsecase)
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
            let isPurchased = self.viewModel?.isPurchased ?? false
            
            switch indexPath.section {
            case 0:
                headerView.updateLabel(to: isPurchased ? "나의 실전 모의고사" : "실전 모의고사")
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
        // 가로모드, 기기별, 그림자 처리 등 추후 수정 예정
        return TestSubjectCell.cellSize
    }
}

extension WorkbookGroupDetailVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let isPurchased = self.viewModel?.isPurchased ?? false
        switch indexPath.section {
        case 0:
            if isPurchased == false {
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
        self.present(popupVC, animated: true, completion: nil)
    }
    
    private func showPurchasePopupVC(workbook: WorkbookOfDB) {
        print("hello")
        let storyboard = UIStoryboard(name: PurchasePopupVC.storyboardName, bundle: nil)
        guard let popupVC = storyboard.instantiateViewController(withIdentifier: PurchasePopupVC.identifier) as? PurchasePopupVC else { return }
        guard let credit = self.viewModel?.credit else { return }
        popupVC.configureInfo(info: workbook)
        popupVC.configureCurrentMoney(money: credit)
        self.present(popupVC, animated: true, completion: nil)
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
    
    func showTestPracticeSection(workbook: Preview_Core) {
        // studyVC 표시로직 필요
    }
}
