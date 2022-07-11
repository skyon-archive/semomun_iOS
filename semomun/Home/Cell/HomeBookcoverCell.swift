//
//  HomeBookcoverCell.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/08.
//

import UIKit

final class HomeBookcoverCell: BookcoverCell {
    static let identifier = "HomeBookcoverCell"
    
    func configure(_ configurable: HomeBookcoverConfigurable, networkUsecase: S3ImageFetchable) {
        self.configureReuse(bookTitle: configurable.title, publishCompany: configurable.publishCompany)
        configurable.fetchBookcoverUUID { [weak self] uuid in
            self?.configureImage(uuid: uuid, networkUsecase: networkUsecase)
        }
    }
    
    // 로그인 상태와 상관 없는 configure
    func configure(with preview: WorkbookPreviewOfDB, networkUsecase: S3ImageFetchable) {
        self.configureReuse(bookTitle: preview.title, publishCompany: preview.publishCompany)
        self.configureImage(uuid: preview.bookcover, networkUsecase: networkUsecase)
    }
    
    func configure(with groupInfo: WorkbookGroupPreviewOfDB, networkUsecase: S3ImageFetchable) {
        self.configureReuse(bookTitle: groupInfo.title, publishCompany: "실전 모의고사")
        self.configureImage(uuid: groupInfo.groupCover, networkUsecase: networkUsecase)
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
