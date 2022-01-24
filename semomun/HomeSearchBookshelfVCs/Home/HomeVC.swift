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
    @IBOutlet weak var bannerAds: UICollectionView!
    @IBOutlet weak var bestSellers: UICollectionView!
    @IBOutlet weak var workbooksWithTags: UICollectionView!
    @IBOutlet weak var workbooksWithRecent: UICollectionView!
    @IBOutlet weak var workbooksWithNewest: UICollectionView!
    @IBOutlet weak var tagsStackView: UIStackView!
    private var viewModel: HomeVM?
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setShadow(with: navigationTitleView)
        self.configureViewModel()
        self.configureCollectionView()
        self.bindAll()
        self.viewModel?.fetchBestSellers()
        self.viewModel?.fetchTags()
    }
    
    @IBAction func appendTags(_ sender: Any) {
        
    }
}

// MARK: - Configure
extension HomeVC {
    private func configureViewModel() {
        let network = Network()
        let networkUsecase = NetworkUsecase(network: network)
        self.viewModel = HomeVM(networkUsecase: networkUsecase)
    }
    
    private func configureCollectionView() {
//        self.bestSellers.delegate = self
        self.bestSellers.dataSource = self
    }
    
    private func configureTags(with tags: [String]) {
        self.tagsStackView.translatesAutoresizingMaskIntoConstraints = false
        let superWidth = self.view.frame.width
        var widthSum: CGFloat = 0
        
        tags.forEach { tag in
            let tagView = UIView()
            tagView.layer.borderWidth = 1
            tagView.layer.cornerRadius = 15
            tagView.clipsToBounds = true
            tagView.layer.borderColor = UIColor(named: SemomunColor.mainColor)?.cgColor
            let tagLabel = UILabel()
            tagLabel.backgroundColor = .clear
            tagLabel.textColor = UIColor(named: SemomunColor.mainColor)
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
            
            let width = "#\(tag)".size(withAttributes: [.font: UIFont.systemFont(ofSize: 12, weight: .regular)]).width+20+8
            if superWidth - 200 > widthSum + width {
                self.tagsStackView.addArrangedSubview(tagView)
                widthSum += width+8
            }
        }
    }
}

// MARK: - Binding
extension HomeVC {
    private func bindAll() {
        self.bindBestSellers()
        self.bindTags()
    }
    
    private func bindBestSellers() {
        self.viewModel?.$bestSellers
            .receive(on: DispatchQueue.main)
//            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.bestSellers.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindTags() {
        self.viewModel?.$tags
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] tags in
                self?.configureTags(with: tags)
            })
            .store(in: &self.cancellables)
    }
}

// MARK: - CollectionView
extension HomeVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.bestSellers {
            return self.viewModel?.bestSellers.count ?? 0
        } else { return 0 }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.bannerAds {
            return UICollectionViewCell()
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeWorkbookCell.identifier, for: indexPath) as? HomeWorkbookCell else { return UICollectionViewCell() }
            guard let preview = self.viewModel?.bestSeller(index: indexPath.item) else { return cell }
            
            if collectionView == self.bestSellers {
                cell.configure(with: preview)
            }
            
            return cell
        }
    }
}
