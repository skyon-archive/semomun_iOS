//
//  BookshelfOrderController.swift
//  semomun
//
//  Created by Kang Minsang on 2022/06/29.
//

import Foundation

protocol BookshelfOrderController: AnyObject {
    func reloadWorkbookGroups(order: BookshelfSortOrder)
    func syncBookshelf()
    func reloadWorkbooks(order: BookshelfSortOrder)
    func showWarning(title: String, text: String)
}
