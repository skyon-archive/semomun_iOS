//
//  HomeCategoryHeaderView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/28.
//

import UIKit

final class HomeCategoryHeaderView: UIView {
    static let identifier = "HomeCategoryHeaderView"
    /* private */
    private let tagScrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsHorizontalScrollIndicator = false
        view.contentInset = .init(top: 0, left: UICollectionView.gridPadding, bottom: 0, right: UICollectionView.gridPadding)
        return view
    }()
    private let tagStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = 12
        view.distribution = .equalSpacing
        return view
    }()
    
    convenience init() {
        self.init(frame: .zero)
        
        self.translatesAutoresizingMaskIntoConstraints = false

        self.addSubviews(self.tagScrollView)
        self.tagScrollView.addSubview(self.tagStackView)
        
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 52),
            
            self.tagScrollView.topAnchor.constraint(equalTo: self.topAnchor),
            self.tagScrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.tagScrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.tagScrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.tagScrollView.contentLayoutGuide.heightAnchor.constraint(equalTo: self.tagScrollView.frameLayoutGuide.heightAnchor),
            
            self.tagStackView.topAnchor.constraint(equalTo: self.tagScrollView.contentLayoutGuide.topAnchor, constant: 10),
            self.tagStackView.bottomAnchor.constraint(equalTo: self.tagScrollView.contentLayoutGuide.bottomAnchor, constant: -10),
            self.tagStackView.leadingAnchor.constraint(equalTo: self.tagScrollView.contentLayoutGuide.leadingAnchor),
            self.tagStackView.trailingAnchor.constraint(equalTo: self.tagScrollView.contentLayoutGuide.trailingAnchor),
        ])
    }
    
    func configureTagList(tagOfDBs: [TagOfDB], action: @escaping (TagOfDB) -> Void) {
        tagOfDBs.forEach { tagOfDB in
            let view = TagView(tagName: tagOfDB.name)
            view.addAction(UIAction { _ in action(tagOfDB) }, for: .touchUpInside)
            self.tagStackView.addArrangedSubview(view)
        }
    }
}
