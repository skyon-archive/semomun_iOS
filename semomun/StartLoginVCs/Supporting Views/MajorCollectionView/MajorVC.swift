//
//  MajorVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/21.
//

import UIKit

protocol MajorSetable: AnyObject {
    func didSelectMajor(section: Int, to: String)
}

final class MajorVC: UIViewController {
    enum Identifier {
        static let controller = "MajorVC"
        static let segue = "MajorSegue"
    }
    weak var delegate: MajorSetable?
    @IBOutlet weak var majorCollectionView: UICollectionView!
    
    var manager: MajorManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureManager()
        self.configureDelegate()
    }
}

//MARK: - Configure
extension MajorVC {
    private func configureManager() {
        self.manager = MajorManager()
    }
    
    private func configureDelegate() {
        self.majorCollectionView.delegate = self
        self.majorCollectionView.dataSource = self
    }
    
    func updateMajors(with majors: [[String: [String]]]) {
        self.manager?.updateItems(with: majors)
        self.majorCollectionView.reloadData()
    }
}

//MARK: - CollectionView
extension MajorVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.manager?.selected(to: indexPath.item, completion: { [weak self] major in
            self?.delegate?.didSelectMajor(section: indexPath.item, to: major)
            self?.majorCollectionView.reloadData()
        })
    }
}

extension MajorVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.manager?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MajorCell.identifier, for: indexPath) as? MajorCell else { return UICollectionViewCell() }
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

extension MajorVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalInset: CGFloat = 15
        let rowCount: Int = 3
        let cellWidth = (self.majorCollectionView.frame.width-(CGFloat(rowCount-1)*horizontalInset))/CGFloat(rowCount)
        let cellHeight: CGFloat = 55
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
