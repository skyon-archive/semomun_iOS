//
//  MajorDetailVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/21.
//

import UIKit

protocol MajorDetailSetable: AnyObject {
    func didSelectMajorDetail(to: String)
}

final class MajorDetailVC: UIViewController {
    enum Identifier {
        static let controller = "MajorDetailVC"
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
extension MajorDetailVC {
    private func configureManager() {
        self.manager = MajorDetailManager(delegate: self)
    }
    
    private func configureDelegate() {
        self.majorCollectionView.delegate = self
        self.majorCollectionView.dataSource = self
    }
    
    func updateMajors(with majors: [Major]) {
        self.manager?.updateItems(with: majors)
        self.majorCollectionView.reloadData()
    }
}

//MARK: - CollectionView
extension MajorDetailVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.manager?.selected(section: indexPath.section, to: indexPath.item, completion: { [weak self] major in
            self?.delegate?.didSelectMajorDetail(to: major)
            self?.majorCollectionView.reloadData()
        })
    }
}

extension MajorDetailVC: UICollectionViewDataSource {
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

extension MajorDetailVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalInset: CGFloat = 15
        let rowCount: Int = 5
        let cellWidth = (self.majorCollectionView.frame.width-(CGFloat(rowCount-1)*horizontalInset))/CGFloat(rowCount)
        let cellHeight: CGFloat = 55
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

extension MajorDetailVC: MajorDetailObserveable {
    func reload() {
        self.majorCollectionView.reloadData()
    }
}
