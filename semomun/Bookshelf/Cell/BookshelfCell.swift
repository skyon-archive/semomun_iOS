//
//  BookshelfCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/28.
//

import UIKit

protocol BookshelfCellDelegate: AnyObject {
    func showWorkbookDetailVC(wid: Int)
}

final class BookshelfCell: BookcoverCell {
    enum InfoType {
        case workbook
        case workbookGroup
    }
    /* public */
    static let identifier = "BookshelfCell"
    /* private */
    private weak var delegate: BookshelfCellDelegate?
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
    
    func configure(with workbookInfo: WorkbookCellInfo, delegate: BookshelfCellDelegate) {
        self.delegate = delegate
        self.infoType = .workbook
        self.workbookInfo = workbookInfo
        self.configureReuse(bookTitle: workbookInfo.title, publishCompany: workbookInfo.publisher)
        self.configureImage(data: workbookInfo.imageData)
    }
    
    func configure(with workbookGroupInfo: WorkbookGroupCellInfo, delegate: BookshelfCellDelegate) {
        self.delegate = delegate
        self.infoType = .workbookGroup
        self.workbookGroupInfo = workbookGroupInfo
        self.configureReuse(bookTitle: workbookGroupInfo.title, publishCompany: workbookGroupInfo.publisher)
        self.configureImage(data: workbookGroupInfo.imageData)
    }
    
    private func touchAction() {
            guard let wid = self.workbookInfo?.wid else { return }
            self.delegate?.showWorkbookDetailVC(wid: wid)
    }
}
