//
//  HomeCategoryDetailView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/28.
//

import UIKit

final class HomeCategoryDetailView: UIView {
    /* public */
    typealias OpenTagVC = (TagOfDB) -> Void
    let headerView = HomeCategoryHeaderView()
    /* private */
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 32
        stackView.clipsToBounds = false
        
        return stackView
    }()
    private let roundedBackground: UIView = {
        let roundedBackground = UIView()
        roundedBackground.translatesAutoresizingMaskIntoConstraints = false
        roundedBackground.configureTopCorner(radius: .cornerRadius24)
        roundedBackground.backgroundColor = UIColor.getSemomunColor(.white)
        
        return roundedBackground
    }()
    private var sections: [Section] = []
    
    convenience init() {
        self.init(frame: .zero)
        self.backgroundColor = .getSemomunColor(.background)
        self.configureLayout()
        
        self.stackView.addArrangedSubview(self.headerView)
    }
}

// MARK: Configure
extension HomeCategoryDetailView {
    func configureCollectionViews(tagOfDBs: [TagOfDB], delegate: (UICollectionViewDelegate&UICollectionViewDataSource), action: @escaping OpenTagVC) {
        self.sections = tagOfDBs.enumerated().map { index, tagOfDB in
            let section = Section(tagOfDB: tagOfDB, action: { action(tagOfDB) })
            section.collectionView.tag = index
            section.collectionView.delegate = delegate
            section.collectionView.dataSource = delegate
            return section
        }
        self.sections.forEach {
            self.stackView.addArrangedSubview($0)
        }
    }
}

// MARK: Update
extension HomeCategoryDetailView {
    func reloadCollectionView(at index: Int) {
        self.sections[index].collectionView.reloadData()
    }
    
    func invalidateCollectionViewLayout() {
        self.sections.forEach { $0.collectionView.collectionViewLayout.invalidateLayout() }
    }
}

extension HomeCategoryDetailView {
    private func configureLayout() {
        self.addSubview(self.roundedBackground)
        self.roundedBackground.addSubview(self.scrollView)
        self.scrollView.addSubviews(self.stackView)
        
        NSLayoutConstraint.activate([
            self.roundedBackground.topAnchor.constraint(equalTo: self.topAnchor),
            // 아래방향 스크롤 overflow가 일어나도 흰색 배경이 보이도록 여백 설정
            self.roundedBackground.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 500),
            self.roundedBackground.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.roundedBackground.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            self.scrollView.frameLayoutGuide.widthAnchor.constraint(equalTo: self.roundedBackground.widthAnchor),
            self.scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.widthAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.roundedBackground.topAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.roundedBackground.trailingAnchor),
            self.scrollView.leadingAnchor.constraint(equalTo: self.roundedBackground.leadingAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.roundedBackground.bottomAnchor),
            
            self.stackView.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor, constant: 24),
            self.stackView.trailingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.trailingAnchor),
            // 위에서 설정한 여백 값만큼 아래 여백을 설정
            self.stackView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor, constant: -524),
            self.stackView.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor),
        ])
    }
}

fileprivate final class Section: UIView {
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = UICollectionView.gutterWidth
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        // 셀 그림자 잘림 방지
        view.clipsToBounds = false
        view.register(HomeBookcoverCell.self, forCellWithReuseIdentifier: HomeBookcoverCell.identifier)
        view.showsHorizontalScrollIndicator = false
        view.contentInset = .init(top: 0, left: UICollectionView.gridPadding, bottom: 0, right: UICollectionView.gridPadding)
        
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .heading3
        label.textColor = .getSemomunColor(.black)
        return label
    }()
    private let seeAllButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("모두 보기", for: .normal)
        button.titleLabel?.font = .heading5
        button.setTitleColor(.getSemomunColor(.orangeRegular), for: .normal)
        return button
    }()
    
    convenience init(tagOfDB: TagOfDB, action: @escaping () -> Void) {
        self.init(frame: .zero)
        self.clipsToBounds = false
        self.addSubviews(self.titleLabel, self.seeAllButton, self.collectionView)
        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32),
            
            self.seeAllButton.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor),
            self.seeAllButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -32),
            
            self.collectionView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 16),
            self.collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.collectionView.heightAnchor.constraint(equalToConstant: UICollectionView.bookcoverCellSize.height)
        ])
        
        self.titleLabel.text = tagOfDB.name
        self.seeAllButton.addAction(UIAction { _ in action() }, for: .touchUpInside)
    }
}
