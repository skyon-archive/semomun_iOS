//
//  WorkbookGroupResultVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/21.
//

import UIKit

final class WorkbookGroupResultVC: UIViewController {
    /* private */
    private let viewModel: WorkbookGroupResultVM
    private let workbookGroupResultView = WorkbookGroupResultView()
    
    init(viewModel: WorkbookGroupResultVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = viewModel.title
        
        let averagePercentile = Double(viewModel.sortedTestResults.map(\.percentile).reduce(0, +)) / Double(viewModel.sortedTestResults.count)
        self.workbookGroupResultView.graphView.configurePercentile(to: averagePercentile/100)
        
        self.workbookGroupResultView.configureContent(viewModel.sortedTestResults)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func loadView() {
        self.view = self.workbookGroupResultView
    }
}
