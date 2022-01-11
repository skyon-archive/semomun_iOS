//
//  SelectFavoriteViewController.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/11.
//

import UIKit

class SelectFavoriteViewController: UIViewController {
    static let identifier = "SelectFavoriteViewController"

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    private var manager: CategoryManager?
    private var checked: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureManager()
        self.configureDelegate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "세모문"
    }
    
    @IBAction func goMain(_ sender: Any) {
        if self.checked {
            self.saveUserDefaults()
            self.goMainVC()
        } else {
            self.showAlertWithOK(title: "한가지를 선택해주세요", text: "")
        }
    }
}

// MARK: - Configure
extension SelectFavoriteViewController {
    private func configureUI() {
        self.startButton.clipsToBounds = true
        self.startButton.cornerRadius = 10
    }
    
    private func configureManager() {
        self.manager = CategoryManager()
        self.manager?.fetch { [weak self] in
            self?.categoryCollectionView.reloadData()
        }
    }
    
    private func configureDelegate() {
        self.categoryCollectionView.delegate = self
        self.categoryCollectionView.dataSource = self
    }
}

extension SelectFavoriteViewController {
    private func saveUserDefaults() {
        UserDefaultsManager.set(to: false, forKey: UserDefaultsManager.Keys.isInitial)
    }
    
    private func goMainVC() {
        guard let mainViewController = self.storyboard?.instantiateViewController(identifier: MainViewController.identifier) else { return }
        let navigationController = UINavigationController(rootViewController: mainViewController)
        navigationController.navigationBar.tintColor = UIColor(named: SemomunColor.mainColor)
        
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
}

//MARK: - CollectionView
extension SelectFavoriteViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.manager?.selected(to: indexPath.item, completion: { [weak self] category in
            UserDefaultsManager.set(to: category, forKey: UserDefaultsManager.Keys.currentCategory)
            self?.checked = true
            self?.categoryCollectionView.reloadData()
        })
    }
}

extension SelectFavoriteViewController: UICollectionViewDataSource {
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

extension SelectFavoriteViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalInset: CGFloat = 24
        let rowCount: Int = 3
        let cellWidth = (self.categoryCollectionView.frame.width-(CGFloat(rowCount-1)*horizontalInset))/CGFloat(rowCount)
        let cellHeight: CGFloat = 60
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
