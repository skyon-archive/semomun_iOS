//
//  BookshelfVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import Combine

final class BookshelfVC: UIViewController {
    enum Tab: Int {
        case home = 0
        case workbook = 1
        case practiceTest = 2
    }
    /* public */
    static let identifier = "BookshelfVC"
    static let storyboardName = "HomeSearchBookshelf"
    
    @IBOutlet var bookshelfTabButtons: [UIButton]!
    @IBOutlet var bookshelfTabUnderlines: [UIView]!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var viewModel: BookshelfVM?
    private var cancellables: Set<AnyCancellable> = []
    private lazy var loadingView = LoadingView()
    private var currentTab: Tab = .home {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
        self.configureViewModel()
        self.bindAll()
        self.checkSyncBookshelf()
        self.configureObservation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard UserDefaultsManager.isLogined else { return }
        self.reloadCollectionView()
    }
    
    @IBAction func changeTab(_ sender: UIButton) {
        let index = sender.tag
        self.changeTabUI(index: index)
        self.currentTab = Tab(rawValue: index) ?? .home
    }
}

extension BookshelfVC {
    private func configureCollectionView() {
        let flowLayout = ScrollingBackgroundFlowLayout(sectionHeaderExist: true)
        self.collectionView.collectionViewLayout = flowLayout
        self.collectionView.configureDefaultDesign()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        let homeHeaderNib = UINib(nibName: BookshelfHeaderView.identifier, bundle: nil)
        let detailHeaderNib = UINib(nibName: BookshelfDetailHeaderView.identifier, bundle: nil)
        self.collectionView.register(homeHeaderNib, forCellWithReuseIdentifier: BookshelfHeaderView.identifier)
        self.collectionView.register(detailHeaderNib, forCellWithReuseIdentifier: BookshelfDetailHeaderView.identifier)
    }
}

extension BookshelfVC: UICollectionViewDelegate {
    
}

extension BookshelfVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        <#code#>
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }
}

extension BookshelfVC {
    private func changeTabUI(index: Int) {
        for (idx, button) in self.bookshelfTabButtons.enumerated() {
            if button.tag == index {
                button.setTitleColor(UIColor.getSemomunColor(.blueRegular), for: .normal)
                self.bookshelfTabUnderlines[idx].alpha = 1
            } else {
                button.setTitleColor(UIColor.getSemomunColor(.black), for: .normal)
                self.bookshelfTabUnderlines[idx].alpha = 0
            }
        }
    }
}

