//
//  WorkbookGroupResultView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/21.
//

import UIKit

final class WorkbookGroupResultView: UIView {
    private let graphView = NormalDistributionGraphView()
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .getSemomunColor(.background)
        self.configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension WorkbookGroupResultView {
    private func configureLayout() {
        self.addSubviews(self.graphView)
        NSLayoutConstraint.activate([
            self.graphView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 10),
            self.graphView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            self.graphView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.graphView.heightAnchor.constraint(equalToConstant: 418),
            
            
        ])
    }
}
