//
//  WorkbookGroupResultView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/21.
//

import UIKit

final class WorkbookGroupResultView: UIView {
    private let graphView = NormalDistributionGraphView()
    private let rankScrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .getSemomunColor(.white)
        view.contentInset = .init(top: 0, left: 32, bottom: 0, right: 32)
        return view
    }()
    private let rankStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 1
        view.axis = .horizontal
        view.backgroundColor = .getSemomunColor(.border)
        return view
    }()

    init() {
        super.init(frame: .zero)
        self.backgroundColor = .getSemomunColor(.background)
        self.configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureRankScrollViewContent(_ content: [PrivateTestResultOfDB]) {
        content.forEach { privateTestResultOfDB in
            let view = TestSubjectRankView(title: privateTestResultOfDB.subject, rank: privateTestResultOfDB.rank)
            self.rankStackView.addArrangedSubview(view)
        }
    }
}

extension WorkbookGroupResultView {
    private func configureLayout() {
        self.addSubviews(self.graphView, self.rankScrollView)
        self.rankScrollView.addSubview(self.rankStackView)
        NSLayoutConstraint.activate([
            self.graphView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 10),
            self.graphView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            self.graphView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.graphView.heightAnchor.constraint(equalToConstant: 418),
            
            self.rankScrollView.topAnchor.constraint(equalTo: self.graphView.bottomAnchor, constant: 24),
            self.rankScrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.rankScrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.rankScrollView.heightAnchor.constraint(equalToConstant: 83),
            self.rankScrollView.frameLayoutGuide.heightAnchor.constraint(equalToConstant: 83),
           
            self.rankStackView.topAnchor.constraint(equalTo: self.rankScrollView.contentLayoutGuide.topAnchor, constant: 12),
            self.rankStackView.leadingAnchor.constraint(equalTo: self.rankScrollView.contentLayoutGuide.leadingAnchor),
            self.rankStackView.bottomAnchor.constraint(equalTo: self.rankScrollView.contentLayoutGuide.bottomAnchor, constant: -12),
            self.rankStackView.trailingAnchor.constraint(equalTo: self.rankScrollView.contentLayoutGuide.trailingAnchor),
            self.rankStackView.heightAnchor.constraint(equalToConstant: 59)
        ])
    }
}
