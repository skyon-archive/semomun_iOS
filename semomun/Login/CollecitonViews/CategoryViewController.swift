//
//  CategoryViewController.swift
//  semomun
//
//  Created by Kang Minsang on 2021/11/28.
//

import UIKit

protocol CategorySetable: AnyObject {
    func didSelectCategory(to: String)
}

final class CategoryViewController: UIViewController {
    enum Identifier {
        static let controller = "CategoryViewController"
        static let segue = "CategorySegue"
    }
    weak var delegate: CategorySetable?
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    var manager: CategoryManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureManager()
        self.configureDelegate()
    }
}

//MARK: - Configure
extension CategoryViewController {
    private func configureManager() {
        self.manager = CategoryManager()
        manager?.fetch { [weak self] in
            self?.categoryCollectionView.reloadData()
        }
    }
    
    private func configureDelegate() {
        self.categoryCollectionView.delegate = self
        self.categoryCollectionView.dataSource = self
    }
}

//MARK: - CollectionView
extension CategoryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.manager?.selected(to: indexPath.item, completion: { [weak self] category in
            self?.delegate?.didSelectCategory(to: category)
            self?.categoryCollectionView.reloadData()
        })
    }
}

extension CategoryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.manager?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoriteCategoryCell.identifier, for: indexPath) as? FavoriteCategoryCell else { return UICollectionViewCell() }
        guard let manager = self.manager else { return cell }
        let title = manager.item(at: indexPath.item)
        cell.configure(title: title)
        
        if let selected = manager.selectedIndex {
            if indexPath.item == selected {
                cell.didSelected()
            }
        }
        
        return cell
    }
}

extension CategoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalInset: CGFloat = 15
        let rowCount: Int = 3
        let cellWidth = (self.categoryCollectionView.frame.width-(CGFloat(rowCount-1)*horizontalInset))/CGFloat(rowCount)
        let cellHeight: CGFloat = 55
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
