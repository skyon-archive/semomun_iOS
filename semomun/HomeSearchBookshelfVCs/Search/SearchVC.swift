//
//  SearchVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit

protocol SearchControlable: AnyObject {
    func hiddenRemoveTextBT()
    func hiddenSearchBT()
    func hiddenCancelSearchBT()
    func appendTag(name: String)
    func changeToSearchFavoriteTagsVC()
}

class SearchVC: UIViewController {
    static let identifier = "SearchVC"
    static let storyboardName = "HomeSearchBookshelf"
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchInnerView: UIView!
    @IBOutlet weak var removeTextBT: UIView!
    @IBOutlet weak var cancelSearchBT: UIView!
    @IBOutlet weak var searchTextField: UIView!
    @IBOutlet weak var searchBT: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tagList: UICollectionView!
    
    private var currentChildVC: UIViewController?
    private lazy var searchFavoriteTagsVC: UIViewController = {
        let storyboard = UIStoryboard(name: SearchFavoriteTagsVC.storyboardName, bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: SearchFavoriteTagsVC.identifier) as? SearchFavoriteTagsVC else { return UIViewController() }
        viewController.configureDelegate(delegate: self)
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setShadow(with: searchView)
        self.configureUI()
        self.configureCollectionView()
        self.changeToSearchFavoriteTagsVC()
    }
    
    @IBAction func removeText(_ sender: Any) {
        
    }
    
    @IBAction func search(_ sender: Any) {
        
    }
    
    @IBAction func cancelSearch(_ sender: Any) {
        
    }
}

// MARK: - Configure
extension SearchVC {
    private func configureUI() {
        self.configureSearchInnerView()
        self.hiddenRemoveTextBT()
        self.hiddenSearchBT()
        self.hiddenCancelSearchBT()
    }
    
    private func configureSearchInnerView() {
        self.searchInnerView.clipsToBounds = true
        self.searchInnerView.layer.borderWidth = 2
        self.searchInnerView.layer.cornerRadius = 10
        self.searchInnerView.layer.borderColor = UIColor(named: SemomunColor.mainColor)?.cgColor
    }
    
    private func configureCollectionView() {
//        self.tagList.delegate = self
//        self.tagList.dataSource = self
    }
}

// MARK: - CollectionView
//extension SearchVC: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//    }
//}
//
//extension SearchVC: UICollectionViewDelegate {
//
//}

// MARK: - Logic
extension SearchVC {
    private func removeChildVC() {
        self.currentChildVC?.willMove(toParent: nil)
        self.currentChildVC?.view.removeFromSuperview()
        self.currentChildVC?.removeFromParent()
    }
    
    private func changeChildVC(to targetVC: UIViewController) {
        targetVC.view.frame = self.containerView.bounds
        self.containerView.addSubview(targetVC.view)
        self.addChild(targetVC)
        targetVC.didMove(toParent: self)
    }
}

// MARK: - Delegate
extension SearchVC: SearchControlable {
    func hiddenRemoveTextBT() {
        self.removeTextBT.isHidden = true
    }
    
    func hiddenSearchBT() {
        self.searchBT.isHidden = true
    }
    
    func hiddenCancelSearchBT() {
        self.cancelSearchBT.isHidden = true
    }
    
    func appendTag(name: String) {
        print(name)
    }
    
    func changeToSearchFavoriteTagsVC() {
        self.removeChildVC()
        self.changeChildVC(to: self.searchFavoriteTagsVC)
    }
}
