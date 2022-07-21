//
//  _WorkbookGroupResultVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/21.
//

import UIKit

final class _WorkbookGroupResultVC: UIViewController {
    /* private */
    private let viewModel: WorkbookGroupResultVM
    private let workbookGroupResultView = WorkbookGroupResultView()
    
    init(viewModel: WorkbookGroupResultVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = viewModel.title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = self.workbookGroupResultView
    }
}
