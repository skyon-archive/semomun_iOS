//
//  HomeCategoryCell.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/28.
//

import UIKit

final class TagDetailVC<T: HomeBookcoverCellInfo>: HomeDetailVC<T> {
    private let tagOfDB: TagOfDB
    
    init(viewModel: HomeDetailVM<T>, tagOfDB: TagOfDB) {
        self.tagOfDB = tagOfDB
        super.init(viewModel: viewModel, title: "")
        self.configureNavigationTitleView(tagOfDB: tagOfDB)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TagDetailVC {
    private func configureNavigationTitleView(tagOfDB: TagOfDB) {
        let button = UIButton(type: .custom)
        let title = NSMutableAttributedString()
        if let categoryName = tagOfDB.category?.name {
            title.append(NSMutableAttributedString(string: "\(categoryName) / ", attributes:[
                NSAttributedString.Key.foregroundColor: UIColor.getSemomunColor(.lightGray),
                NSAttributedString.Key.font: UIFont.heading4
            ]))
        }
        title.append(NSMutableAttributedString(string: tagOfDB.name, attributes:[
            NSAttributedString.Key.font: UIFont.heading4
        ]))
        button.setAttributedTitle(title, for: .normal)
        button.addAction(UIAction { [weak self] _ in self?.showCategoryView()  }, for: .touchUpInside)
        
        self.navigationItem.titleView = button
    }
    private func showCategoryView() {
        print(self.tagOfDB)
    }
}
