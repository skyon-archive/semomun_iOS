//
//  _HomeVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/07.
//

import UIKit

struct HomeVCSectionInfo {
    let title: String
    let workbookTapAction: ((Int) -> Void)?
    let workbookGroupTapAction: ((WorkbookGroupPreviewOfDB) -> Void)?
    let isWorkbookGroup: Bool
    
    let getWorkbookPreviewOfDB: (() -> [WorkbookPreviewOfDB])?
    let getBookshelfInfo: (() -> [BookshelfInfo])?
    let getWorkbookGroupPreviewOfDB: (() -> [WorkbookGroupPreviewOfDB])?
}

class _HomeVC: UIViewController {
    enum SectionDataType {
        case workbook, workbookGroup, bookshelf
    }
    enum SectionType: Int, CaseIterable {
        case bestseller
        case recent
        case tag
        case workbookGroup
        //        case popularTag1
        //        case popularTag2
    }
    private var viewModel: HomeVM?
    private var sectionCollectionViews: [UICollectionView] = []
    private lazy var sectionInfo: [SectionType: HomeVCSectionInfo] = {
        return [
            .bestseller: .init(
                title: "베스트셀러",
                workbookTapAction: { self.searchWorkbook(wid: $0) },
                workbookGroupTapAction: nil,
                isWorkbookGroup: false,
                getWorkbookPreviewOfDB: { self.viewModel?.bestSellers ?? [] },
                getBookshelfInfo: nil,
                getWorkbookGroupPreviewOfDB: nil
            ),
            .recent: .init(
                title: "최근에 푼 문제집",
                workbookTapAction: { self.searchWorkbook(wid: $0) },
                workbookGroupTapAction: nil,
                isWorkbookGroup: false,
                getWorkbookPreviewOfDB: nil,
                getBookshelfInfo: { self.viewModel?.recentPurchased ?? [] },
                getWorkbookGroupPreviewOfDB: nil
            ),
            .tag: .init(
                title: "나의 태그",
                workbookTapAction: { self.searchWorkbook(wid: $0) },
                workbookGroupTapAction: nil,
                isWorkbookGroup: false,
                getWorkbookPreviewOfDB: { self.viewModel?.workbooksWithTags ?? [] },
                getBookshelfInfo: nil,
                getWorkbookGroupPreviewOfDB: nil
            ),
            .workbookGroup: .init(
                title: "실전 모의고사",
                workbookTapAction: nil,
                workbookGroupTapAction: { self.searchWorkbookGroup(info: $0) },
                isWorkbookGroup: true,
                getWorkbookPreviewOfDB: nil,
                getBookshelfInfo: nil,
                getWorkbookGroupPreviewOfDB: { self.viewModel?.workbookGroups ?? [] }
            )
        ]
    }()
    
    private let headerView: HomeHeaderView = {
        let view = HomeHeaderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()
    private let roundedBackground: UIView = {
        let roundedBackground = UIView()
        roundedBackground.translatesAutoresizingMaskIntoConstraints = false
        roundedBackground.configureTopCorner(radius: .cornerRadius24)
        roundedBackground.backgroundColor = UIColor.getSemomunColor(.white)
        
        return roundedBackground
    }()
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 40
        
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.getSemomunColor(.background)
        self.configureHomeHeaderView()
        
        self.configureScrollViewLayout()
        self.configureScrollViewBackground()
        self.configureStackViewLayout()
        
        self.configureStackViewContent()
    }
}

extension _HomeVC {
    private func configureHomeHeaderView() {
        self.view.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            headerView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            headerView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
        ])
    }
    
    private func configureScrollViewLayout() {
        self.view.addSubview(scrollView)
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.scrollView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func configureScrollViewBackground() {
        // 위쪽 모서리가 둥근 흰색 배경 추가
        self.scrollView.addSubview(self.roundedBackground)
        
        NSLayoutConstraint.activate([
            self.roundedBackground.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor),
            self.roundedBackground.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor),
            self.roundedBackground.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor),
            self.roundedBackground.trailingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.trailingAnchor),
            self.scrollView.frameLayoutGuide.widthAnchor.constraint(equalTo: self.roundedBackground.widthAnchor),
        ])
    }
    
    private func configureStackViewLayout() {
        self.roundedBackground.addSubview(self.stackView)
        
        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: self.roundedBackground.topAnchor, constant: 32),
            self.stackView.trailingAnchor.constraint(equalTo: self.roundedBackground.trailingAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: self.roundedBackground.bottomAnchor),
            self.stackView.leadingAnchor.constraint(equalTo: self.roundedBackground.leadingAnchor, constant: 32),
        ])
    }
    
    private func configureStackViewContent() {
        SectionType.allCases.forEach { sectionOrder in
            let sectionView = HomeVCSectionView()
            sectionView.widthAnchor.constraint(equalTo: self.stackView.widthAnchor).isActive = true
            guard let sectionInfo = self.sectionInfo[sectionOrder] else { return }
            sectionView.configureContent(title: sectionInfo.title, collectionViewTag: sectionOrder.rawValue, delegate: self, seeAllAction: { })
            self.stackView.addArrangedSubview(sectionView)
        }
    }
    
    private func searchWorkbook(wid: Int) {
        if UserDefaultsManager.isLogined, let book = CoreUsecase.fetchPreview(wid: wid) {
            self.showWorkbookDetailVC(book: book)
        } else {
            self.viewModel?.fetchWorkbook(wid: wid)
        }
    }
    
    private func searchWorkbookGroup(info: WorkbookGroupPreviewOfDB) {
        if UserDefaultsManager.isLogined, let coreInfo = CoreUsecase.fetchWorkbookGroup(wgid: info.wgid) {
            self.showWorkbookGroupDetailVC(coreInfo: coreInfo)
        } else {
            self.showWorkbookGroupDetailVC(dtoInfo: info)
        }
    }
}

// MARK: 새로운 VC 이동 관련
extension _HomeVC {
    private func showWorkbookDetailVC(workbook: WorkbookOfDB) {
        let storyboard = UIStoryboard(name: WorkbookDetailVC.storyboardName, bundle: nil)
        guard let workbookDetailVC = storyboard.instantiateViewController(withIdentifier: WorkbookDetailVC.identifier) as? WorkbookDetailVC else { return }
        guard let networkUsecase = self.viewModel?.networkUsecase else { return }
        let viewModel = WorkbookDetailVM(workbookDTO: workbook, networkUsecase: networkUsecase)
        workbookDetailVC.configureViewModel(to: viewModel)
        workbookDetailVC.configureIsCoreData(to: false)
        self.navigationController?.pushViewController(workbookDetailVC, animated: true)
    }
    
    private func showWorkbookDetailVC(book: Preview_Core) {
        let storyboard = UIStoryboard(name: WorkbookDetailVC.storyboardName, bundle: nil)
        guard let workbookDetailVC = storyboard.instantiateViewController(withIdentifier: WorkbookDetailVC.identifier) as? WorkbookDetailVC else { return }
        guard let networkUsecase = self.viewModel?.networkUsecase else { return }
        let viewModel = WorkbookDetailVM(previewCore: book, networkUsecase: networkUsecase)
        workbookDetailVC.configureViewModel(to: viewModel)
        workbookDetailVC.configureIsCoreData(to: true)
        self.navigationController?.pushViewController(workbookDetailVC, animated: true)
    }
    
    private func showSearchTagVC() {
        let storyboard = UIStoryboard(name: SearchTagVC.storyboardName, bundle: nil)
        guard let searchTagVC = storyboard.instantiateViewController(withIdentifier: SearchTagVC.identifier) as? SearchTagVC else { return }
        
        self.present(searchTagVC, animated: true, completion: nil)
    }
    
    private func showWorkbookGroupDetailVC(dtoInfo: WorkbookGroupPreviewOfDB) {
        let storyboard = UIStoryboard(name: WorkbookGroupDetailVC.storyboardName, bundle: nil)
        guard let workbookGroupDetailVC = storyboard.instantiateViewController(withIdentifier: WorkbookGroupDetailVC.identifier) as? WorkbookGroupDetailVC else { return }
        let viewModel = WorkbookGroupDetailVM(dtoInfo: dtoInfo, networkUsecase: NetworkUsecase(network: Network()))
        workbookGroupDetailVC.configureViewModel(to: viewModel)
        self.navigationController?.pushViewController(workbookGroupDetailVC, animated: true)
    }
    
    private func showWorkbookGroupDetailVC(coreInfo: WorkbookGroup_Core) {
        let storyboard = UIStoryboard(name: WorkbookGroupDetailVC.storyboardName, bundle: nil)
        guard let workbookGroupDetailVC = storyboard.instantiateViewController(withIdentifier: WorkbookGroupDetailVC.identifier) as? WorkbookGroupDetailVC else { return }
        let viewModel = WorkbookGroupDetailVM(coreInfo: coreInfo, networkUsecase: NetworkUsecase(network: Network()))
        workbookGroupDetailVC.configureViewModel(to: viewModel)
        self.navigationController?.pushViewController(workbookGroupDetailVC, animated: true)
    }
}

extension _HomeVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = SectionType(rawValue: collectionView.tag) else { return 0 }
        
        let sectionInfo = self.sectionInfo[sectionType]
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return .init()
    }
}

extension _HomeVC: UICollectionViewDelegate {
    
}


class HomeHeaderView: UIView {
    private let logoImageView: UIImageView = {
        let view = UIImageView()
        // 임시 코드
        view.image = UIImage(.cloudDownloadOutline)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 48),
            view.heightAnchor.constraint(equalToConstant: 38.99),
        ])
        
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .heading2
        label.text = "세모문"
        label.textColor = UIColor.getSemomunColor(.blueRegular)
        
        return label
    }()
    
    private let greetingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .heading5
        label.text = "반가워요:)\n오늘도 함께 공부해봐요"
        label.numberOfLines = 2
        label.textAlignment = .right
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        self.addSubviews(self.logoImageView, self.titleLabel, self.greetingLabel)
        
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 66),
            
            self.logoImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.logoImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32),
            
            self.titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.logoImageView.trailingAnchor, constant: 12),
            
            self.greetingLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.greetingLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -32)
        ])
    }
}

class HomeVCSectionView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .heading2
        label.textColor = UIColor.getSemomunColor(.black)
        
        return label
    }()
    private let seeAllButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .heading5
        button.setTitleColor(UIColor.getSemomunColor(.orangeRegular), for: .normal)
        button.setTitle("모두 보기", for: .normal)
        
        return button
    }()
    private let collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(BookcoverCell.self, forCellWithReuseIdentifier: BookcoverCell.identifier)
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureContent(title: String, collectionViewTag: Int, delegate: (UICollectionViewDelegate & UICollectionViewDataSource), seeAllAction: @escaping () -> Void) {
        self.titleLabel.text = title
        self.collectionView.tag = collectionViewTag
        self.collectionView.dataSource = delegate
        self.collectionView.delegate = delegate
        self.seeAllButton.addAction(UIAction { _ in seeAllAction() }, for: .touchUpInside)
    }
    
    private func configureLayout() {
        self.addSubviews(self.titleLabel, self.seeAllButton, self.collectionView)
        
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 270.75),
            
            self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            
            self.seeAllButton.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor),
            self.seeAllButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -32),
            
            self.collectionView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 16),
            self.collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        ])
    }
}
