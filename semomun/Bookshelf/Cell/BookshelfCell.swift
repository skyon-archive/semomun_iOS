//
//  BookshelfCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/28.
//

import UIKit

protocol BookshelfCellController: AnyObject {
    func showWorkbookDetailVC(wid: Int)
    func showWorkbookGroupDetailVC(wgid: Int)
}

final class BookshelfCell: BookcoverCell {
    enum InfoType {
        case workbook
        case workbookGroup
    }
    /* public */
    static let identifier = "BookshelfCell"
    /* private */
    private weak var delegate: BookshelfCellController?
    private var infoType: InfoType = .workbook
    private var workbookInfo: WorkbookCellInfo?
    private var workbookGroupInfo: WorkbookGroupCellInfo?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
        self.workbookInfo = nil
        self.workbookGroupInfo = nil
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.touchAction()
            }
        }
    }
    
    func configure(with workbookInfo: WorkbookCellInfo) {
        self.infoType = .workbook
        self.workbookInfo = workbookInfo
        self.configureReuse(bookTitle: workbookInfo.title, publishCompany: workbookInfo.publisher)
        self.configureImage(data: workbookInfo.imageData)
    }
    
    func configure(with workbookGroupInfo: WorkbookGroupCellInfo) {
        self.infoType = .workbookGroup
        self.workbookGroupInfo = workbookGroupInfo
        self.configureReuse(bookTitle: workbookGroupInfo.title, publishCompany: workbookGroupInfo.publisher)
        self.configureImage(data: workbookGroupInfo.imageData)
    }
    
    private func touchAction() {
        switch self.infoType {
        case .workbook:
            guard let wid = self.workbookInfo?.wid else { return }
            self.delegate?.showWorkbookDetailVC(wid: wid)
        case .workbookGroup:
            guard let wgid = self.workbookGroupInfo?.wgid else { return }
            self.delegate?.showWorkbookGroupDetailVC(wgid: wgid)
        }
    }
}
