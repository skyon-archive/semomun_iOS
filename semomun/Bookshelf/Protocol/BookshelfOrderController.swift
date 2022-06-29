//
//  BookshelfOrderController.swift
//  semomun
//
//  Created by Kang Minsang on 2022/06/29.
//

import Foundation

protocol BookshelfOrderController: AnyObject {
    func reloadWorkbookGroups(order: BookshelfSortOrder)
    func syncWorkbookGroups()
    func reloadWorkbooks(order: BookshelfSortOrder)
    func syncWorkbooks()
    func showWarning(title: String, text: String)
}
