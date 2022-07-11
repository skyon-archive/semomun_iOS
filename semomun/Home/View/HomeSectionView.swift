//
//  HomeSectionView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/08.
//

import UIKit

final class HomeSectionView: UIView {
    /* public */
    lazy private(set) var tagList: UserTagListView = {
        let view = UserTagListView()
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        // 셀 그림자 잘림 방지
        view.clipsToBounds = false
        view.register(HomeBookcoverCell.self, forCellWithReuseIdentifier: HomeBookcoverCell.identifier)
        view.showsHorizontalScrollIndicator = false
        view.contentInset = .init(top: 0, left: UICollectionView.gridPadding, bottom: 0, right: 0)
        
        return view
    }()
    /* private */
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
    
    init(hasTagList: Bool) {
        super.init(frame: .zero)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.configureLayout()
        if hasTagList {
            self.configureTagListLayout()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// title은 인기 태그 섹션의 경우 configure 시점에 알 수 없기 때문에 nil
    func configureContent(collectionViewTag: Int, delegate: (UICollectionViewDelegate & UICollectionViewDataSource), seeAllAction: @escaping () -> Void, title: String? = nil) {
        self.titleLabel.text = title
        self.collectionView.tag = collectionViewTag
        self.collectionView.dataSource = delegate
        self.collectionView.delegate = delegate
        self.seeAllButton.addAction(UIAction { _ in seeAllAction() }, for: .touchUpInside)
    }
    
    func configureTitle(to title: String) {
        self.titleLabel.text = title
    }
}

// MARK: Private
extension HomeSectionView {
    private func configureLayout() {
        self.addSubviews(self.titleLabel, self.seeAllButton, self.collectionView)
        let titleLabelHeight: CGFloat = 29
        let verticalMargin: CGFloat = 16
        
        NSLayoutConstraint.activate([
            // 29는 섹션 타이틀 높이, 16은 타이틀에서 UICollectionView까지의 거리
            self.heightAnchor.constraint(equalToConstant: titleLabelHeight+verticalMargin+UICollectionView.bookcoverCellSize.height),
            
            self.titleLabel.heightAnchor.constraint(equalToConstant: titleLabelHeight),
            self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: UICollectionView.gridPadding),
            
            self.seeAllButton.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor),
            self.seeAllButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -UICollectionView.gridPadding),
            
            self.collectionView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: verticalMargin),
            self.collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        ])
    }
    
    private func configureTagListLayout() {
        self.addSubview(self.tagList)
        
        NSLayoutConstraint.activate([
            self.tagList.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor),
            self.tagList.trailingAnchor.constraint(equalTo: self.seeAllButton.leadingAnchor, constant: -12),
            self.tagList.leadingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor, constant: 12),
            self.tagList.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
}
