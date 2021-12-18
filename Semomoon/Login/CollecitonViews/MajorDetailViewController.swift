//
//  MajorDetailViewController.swift
//  Semomoon
//
//  Created by Kang Minsang on 2021/12/11.
//

import UIKit

protocol MajorDetailSetable: AnyObject {
    func didSelectMajorDetail(to: String)
}

final class MajorDetailViewController: UIViewController {
    enum Identifier {
        static let controller = "MajorDetailViewController"
        static let segue = "MajorDetailSegue"
    }
    weak var delegate: MajorDetailSetable?
    @IBOutlet weak var majorCollectionView: UICollectionView!
    
    var manager: MajorDetailManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureManager()
        self.configureDelegate()
    }
}

//MARK: - Configure
extension MajorDetailViewController {
    private func configureManager() {
        self.manager = MajorDetailManager(delegate: self)
        manager?.fetch { [weak self] in
            self?.majorCollectionView.reloadData()
        }
    }
    
    private func configureDelegate() {
        self.majorCollectionView.delegate = self
        self.majorCollectionView.dataSource = self
    }
}

//MARK: - CollectionView
extension MajorDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.manager?.selected(section: indexPath.section, to: indexPath.item, completion: { [weak self] major in
            self?.delegate?.didSelectMajorDetail(to: major)
            self?.majorCollectionView.reloadData()
        })
    }
}

extension MajorDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.manager?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MajorDetailCell.identifier, for: indexPath) as? MajorDetailCell else { return UICollectionViewCell() }
        guard let manager = self.manager else { return cell }
        let title = manager.item(at: indexPath.item)
        cell.configure(title: title)
        
        if let selectedSection = manager.selectedSection,
           let selected = manager.selectedIndex {
            if indexPath.section == selectedSection && indexPath.item == selected {
                cell.didSelected()
            }
        }
        
        return cell
    }
}

extension MajorDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalInset: CGFloat = 15
        let rowCount: Int = 5
        let cellWidth = (self.majorCollectionView.frame.width-(CGFloat(rowCount-1)*horizontalInset))/CGFloat(rowCount)
        let cellHeight: CGFloat = 55
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

extension MajorDetailViewController: MajorDetailObserveable {
    func reload() {
        self.majorCollectionView.reloadData()
    }
}
