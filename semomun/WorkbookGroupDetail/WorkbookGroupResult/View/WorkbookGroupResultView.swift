//
//  WorkbookGroupResultView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/21.
//

import UIKit

final class WorkbookGroupResultView: UIView {
    /* public */
    let graphView = AveragePercentileGraphView()
    /* private */
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
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
    private let subjectResultStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 16
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
    
    func configureContent(_ testResults: [PrivateTestResultOfDB]) {
        self.configureRankScrollViewContent(testResults)
        self.configureSubjectResultStackView(testResults)
        
    }
    
    private func configureRankScrollViewContent(_ content: [PrivateTestResultOfDB]) {
        content.forEach { privateTestResultOfDB in
            let view = TestSubjectRankView(title: privateTestResultOfDB.subject, rank: privateTestResultOfDB.rank)
            self.rankStackView.addArrangedSubview(view)
        }
    }
    
    private func configureSubjectResultStackView(_ testResults: [PrivateTestResultOfDB]) {
        var temp = Array(testResults.reversed())
        while temp.isEmpty == false {
            let horizontalStackView = UIStackView()
            horizontalStackView.spacing = 16
            horizontalStackView.distribution = .fillEqually
            for _ in 0..<2 {
                guard let testResult = temp.popLast() else {
                    let emptyView = UIView()
                    emptyView.layer.opacity = 0
                    horizontalStackView.addArrangedSubview(emptyView)
                    break
                }
                let resultView = TestSubjectResultView()
                resultView.configureContent(testResult)
                horizontalStackView.addArrangedSubview(resultView)
            }
            self.subjectResultStackView.addArrangedSubview(horizontalStackView)
        }
    }
}

extension WorkbookGroupResultView {
    private func configureLayout() {
        self.addSubview(self.scrollView)
        self.scrollView.addSubviews(self.graphView, self.rankScrollView, self.subjectResultStackView)
        self.rankScrollView.addSubview(self.rankStackView)
        NSLayoutConstraint.activate([
            self.scrollView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            self.scrollView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            self.scrollView.frameLayoutGuide.widthAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.widthAnchor),
            
            self.graphView.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor, constant: 10),
            self.graphView.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor, constant: 32),
            self.graphView.centerXAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.centerXAnchor),
            self.graphView.heightAnchor.constraint(equalToConstant: 418),
            
            self.rankScrollView.topAnchor.constraint(equalTo: self.graphView.bottomAnchor, constant: 24),
            self.rankScrollView.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor),
            self.rankScrollView.trailingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.trailingAnchor),
            self.rankScrollView.heightAnchor.constraint(equalToConstant: 83),
            self.rankScrollView.frameLayoutGuide.heightAnchor.constraint(equalToConstant: 83),
           
            self.rankStackView.topAnchor.constraint(equalTo: self.rankScrollView.contentLayoutGuide.topAnchor, constant: 12),
            self.rankStackView.leadingAnchor.constraint(equalTo: self.rankScrollView.contentLayoutGuide.leadingAnchor),
            self.rankStackView.bottomAnchor.constraint(equalTo: self.rankScrollView.contentLayoutGuide.bottomAnchor, constant: -12),
            self.rankStackView.trailingAnchor.constraint(equalTo: self.rankScrollView.contentLayoutGuide.trailingAnchor),
            self.rankStackView.heightAnchor.constraint(equalToConstant: 59),
            
            self.subjectResultStackView.topAnchor.constraint(equalTo: self.rankScrollView.bottomAnchor, constant: 24),
            self.subjectResultStackView.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor, constant: 32),
            self.subjectResultStackView.centerXAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.centerXAnchor),
            self.subjectResultStackView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor, constant: -24)
        ])
    }
}
