//
//  SearchResultCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/27.
//

import UIKit

final class SearchResultCell: BookcoverCell {
    static let identifier = "SearchResultCell"
    // 로그인 상태와 상관 없는 configure
    func configure(with preview: WorkbookPreviewOfDB, networkUsecase: S3ImageFetchable) {
        self.configureReuse(bookTitle: preview.title, publishCompany: preview.publishCompany)
        self.configureImage(uuid: preview.bookcover, networkUsecase: networkUsecase)
    }

    // 로그인 상태에 구매내역을 통한 configure
    func configure(with info: BookshelfInfo, networkUsecase: (WorkbookSearchable & S3ImageFetchable)) {
        networkUsecase.getWorkbook(wid: info.wid) { workbookOfDB in
            guard let workbookOfDB = workbookOfDB else { return }
            
            self.configureReuse(bookTitle: workbookOfDB.title, publishCompany: workbookOfDB.publishCompany)
            self.configureImage(uuid: workbookOfDB.bookcover, networkUsecase: networkUsecase)
        }
    }
}
