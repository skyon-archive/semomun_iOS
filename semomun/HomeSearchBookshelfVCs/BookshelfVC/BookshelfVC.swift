//
//  BookshelfVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import Combine

class BookshelfVC: UIViewController {
    static let identifier = "BookshelfVC"
    static let storyboardName = "HomeSearchBookshelf"
    enum SortOrder: String {
        case purchase = "최근 구매일 순"
        case recent = "최근 읽은 순"
        case alphabet = "제목 가나다 순"
    }
    
    @IBOutlet weak var navigationTitleView: UIView!
    @IBOutlet weak var bookCountLabel: UILabel!
    @IBOutlet weak var refreshBT: UIButton!
    @IBOutlet weak var sortSelector: UIButton!
    @IBOutlet weak var books: UICollectionView!
    
    private var viewModel: BookshelfVM?
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setShadow(with: navigationTitleView)
        self.configureUI()
        self.configureViewModel()
        self.configureCollectionView()
        self.bindAll()
        self.viewModel?.fetchBooks()
    }
    
    @IBAction func refresh(_ sender: Any) {
        self.spinAnimation()
        self.viewModel?.fetchBooks()
    }
}

extension BookshelfVC {
    private func configureUI() {
        self.sortSelector.layer.borderWidth = 1
        self.sortSelector.layer.borderColor = UIColor.lightGray.cgColor
        self.sortSelector.clipsToBounds = true
        self.sortSelector.layer.cornerRadius = 3
        self.configureMenu()
    }
    
    private func configureMenu() {
        let purchaseAction = UIAction(title: SortOrder.purchase.rawValue, image: nil) { [weak self] _ in
            self?.sort(to: .purchase)
        }
        let recentAction = UIAction(title: SortOrder.recent.rawValue, image: nil) { [weak self] _ in
            self?.sort(to: .recent)
        }
        let alphabetAction = UIAction(title: SortOrder.alphabet.rawValue, image: nil) { [weak self] _ in
            self?.sort(to: .alphabet)
        }
        self.sortSelector.menu = UIMenu(title: "정렬 순서", image: nil, children: [purchaseAction, recentAction, alphabetAction])
        self.sortSelector.showsMenuAsPrimaryAction = true
    }
    
    private func sort(to order: SortOrder) {
        self.sortSelector.setTitle(order.rawValue, for: .normal)
    }
    
    private func spinAnimation() {
        UIView.animate(withDuration: 1) {
            self.refreshBT.transform = CGAffineTransform(rotationAngle: ((180.0 * .pi) / 180.0) * -1)
            self.refreshBT.transform = CGAffineTransform(rotationAngle: ((0.0 * .pi) / 360.0) * -1)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.refreshBT.transform = CGAffineTransform.identity
        }
    }
    
    private func configureViewModel() {
        let network = Network()
        let networkUsecase = NetworkUsecase(network: network)
        self.viewModel = BookshelfVM(networkUsecse: networkUsecase)
    }
    
    private func configureCollectionView() {
        self.books.dataSource = self
        self.books.delegate = self
    }
}

extension BookshelfVC {
    private func bindAll() {
        self.bindTestBooks()
        self.bindWarning()
    }
    
    private func bindTestBooks() {
        self.viewModel?.$testBooks
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] books in
                self?.bookCountLabel.text = "\(books.count)권"
                self?.books.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindWarning() {
        self.viewModel?.$warning
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] warning in
                guard let warning = warning else { return }
                self?.showAlertWithOK(title: warning.0, text: warning.1)
            })
            .store(in: &self.cancellables)
    }
}

extension BookshelfVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.testBooks.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookshelfCell.identifier, for: indexPath) as? BookshelfCell else { return UICollectionViewCell() }
        guard let book = self.viewModel?.testBooks[indexPath.item] else { return cell }
        cell.configureTest(with: book)
        
        return cell
    }
}

extension BookshelfVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let book = self.viewModel?.testBooks[indexPath.item] else { return }
        print(book)
    }
}

extension BookshelfVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.books.frame.width)/2
        let height: CGFloat = 182
        return CGSize(width: width, height: height)
    }
}
