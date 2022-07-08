//
//  HomeVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import Combine

final class HomeVC: UIViewController {
    @IBOutlet weak var navigationTitleView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var bannerAds: UICollectionView!
    @IBOutlet weak var bestSellers: UICollectionView!
    @IBOutlet weak var workbooksWithTags: UICollectionView!
    @IBOutlet weak var workbookGroups: UICollectionView!
    @IBOutlet weak var recentEntered: UICollectionView!
    @IBOutlet weak var recentPurchased: UICollectionView!
    
    @IBOutlet weak var tagsStackView: UIStackView!
    
    @IBOutlet weak var recentEnteredHeight: NSLayoutConstraint!
    @IBOutlet weak var recentPurchasedHeight: NSLayoutConstraint!
    
    private var viewModel: HomeVM?
    private var cancellables: Set<AnyCancellable> = []
    
    private var bannerAdsAutoScrollTimer: Timer?
    private let bannerAdsAutoScrollInterval: TimeInterval = 3
    
    private lazy var noLoginedLabel1 = NoneWorkbookLabel()
    private lazy var noLoginedLabel2 = NoneWorkbookLabel()
    private lazy var warningOfflineView = WarningOfflineStatusView()
    
    private lazy var loadingView = LoadingView()
}

// MARK: - Configure
extension HomeVC {
    
    private func configureTags(with tags: [String]) {
        self.tagsStackView.subviews.forEach { $0.removeFromSuperview() }
        self.tagsStackView.translatesAutoresizingMaskIntoConstraints = false
        var superWidth = self.view.frame.width
        if UIDevice.current.userInterfaceIdiom == .pad {
            superWidth -= 200
        } else {
            superWidth -= 137
        }
        var widthSum: CGFloat = 0
        
        tags.forEach { tag in
            let tagView = UIView()
            tagView.layer.borderWidth = 1
            tagView.layer.cornerRadius = 15
            tagView.clipsToBounds = true
            tagView.layer.borderColor = UIColor(.blueRegular)?.cgColor
            let tagLabel = UILabel()
            tagLabel.backgroundColor = .clear
            tagLabel.textColor = UIColor(.blueRegular)
            tagLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            tagLabel.text = "#\(tag)"
            
            tagView.translatesAutoresizingMaskIntoConstraints = false
            tagLabel.translatesAutoresizingMaskIntoConstraints = false
            tagView.addSubview(tagLabel)
            NSLayoutConstraint.activate([
                tagView.heightAnchor.constraint(equalToConstant: 30),
                tagLabel.centerXAnchor.constraint(equalTo: tagView.centerXAnchor),
                tagLabel.centerYAnchor.constraint(equalTo: tagView.centerYAnchor),
                tagLabel.leadingAnchor.constraint(equalTo: tagView.leadingAnchor, constant: 10)
            ])
            
            let width = "#\(tag)".size(withAttributes: [.font: UIFont.systemFont(ofSize: 12, weight: .regular)]).width+20
            if superWidth > widthSum + width {
                self.tagsStackView.addArrangedSubview(tagView)
                widthSum += width+8
            }
        }
    }
    
    private func configureLoginTextView() {
        self.recentEnteredHeight.constant = 72
        self.recentPurchasedHeight.constant = 72
        
        self.noLoginedLabel1.text = "아직 푼 문제집이 없습니다!\n문제집을 검색하여 추가하고, 문제집을 풀어보세요"
        self.recentEntered.addSubview(self.noLoginedLabel1)
        NSLayoutConstraint.activate([
            self.noLoginedLabel1.centerYAnchor.constraint(equalTo: self.recentEntered.centerYAnchor),
            self.noLoginedLabel1.leadingAnchor.constraint(equalTo: self.recentEntered.leadingAnchor, constant: 50)
        ])
        
        self.noLoginedLabel2.text = "아직 구매한 문제집이 없습니다!\n문제집을 검색하여 추가하고, 문제집을 풀어보세요"
        self.recentPurchased.addSubview(self.noLoginedLabel2)
        NSLayoutConstraint.activate([
            self.noLoginedLabel2.centerYAnchor.constraint(equalTo: self.recentPurchased.centerYAnchor),
            self.noLoginedLabel2.leadingAnchor.constraint(equalTo: self.recentPurchased.leadingAnchor, constant: 50)
        ])
    }
    
    private func showOfflineAlert() {
        self.view.addSubview(self.warningOfflineView)
        NSLayoutConstraint.activate([
            self.warningOfflineView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.warningOfflineView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.warningOfflineView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.warningOfflineView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}


// MARK: Loader
extension HomeVC {
    private func showLoader() {
        self.view.addSubview(self.loadingView)
        self.loadingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.loadingView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.loadingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.loadingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.loadingView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        self.loadingView.start()
    }
    
    private func removeLoader() {
        self.loadingView.stop()
        self.loadingView.removeFromSuperview()
    }
}
