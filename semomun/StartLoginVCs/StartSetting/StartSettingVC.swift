//
//  StartSettingVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import Combine

final class StartSettingVC: UIViewController {
    static let identifier = "StartSettingVC"
    static let storyboardName = "StartLogin"
    
    @IBOutlet weak var mediumTags: UICollectionView!
    @IBOutlet weak var smallTags: UICollectionView!
    
    private var viewModel: StartSettingVM?
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViewModel()
        self.configureCollectionView()
        self.bindAll()
        self.viewModel?.fetchTags()
    }
    
    @IBAction func goMain(_ sender: Any) {
        let finished = self.viewModel?.isSelectFinished ?? false
        if finished {
            self.viewModel?.saveUserDefaults()
            self.goMainVC()
        } else {
            self.showAlertWithOK(title: "관심이 있는 문제 유형을 선택해 주세요", text: "")
        }
    }
}

// MARK: - Configure
extension StartSettingVC {
    private func configureViewModel() {
        let network = Network()
        let networkUsecase = NetworkUsecase(network: network)
        self.viewModel = StartSettingVM(networkUsecase: networkUsecase)
    }
    
    private func configureCollectionView() {
        self.mediumTags.delegate = self
        self.mediumTags.dataSource = self
        self.smallTags.delegate = self
        self.smallTags.dataSource = self
    }
}

// MARK: - Binding
extension StartSettingVC {
    private func bindAll() {
        self.bindMediumTags()
        self.bindSmallTags()
        self.bindCurrentMediumIndex()
        self.bindCurrentSmallIndex()
        self.bindError()
    }
    
    private func bindMediumTags() {
        self.viewModel?.$mediumTags
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.mediumTags.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindSmallTags() {
        self.viewModel?.$smallTags
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.smallTags.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindCurrentMediumIndex() {
        self.viewModel?.$currentMediumIndex
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.mediumTags.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindCurrentSmallIndex() {
        self.viewModel?.$currentSmallIndex
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.smallTags.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindError() {
        self.viewModel?.$error
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] error in
                guard let error = error else { return }
                self?.showAlertWithOK(title: "네트워크 에러", text: error)
            })
            .store(in: &self.cancellables)
    }
}

// MARK: - Logic
extension StartSettingVC {
    private func goMainVC() {
        guard let mainViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() else {
            return 
        }
        let navigationController = UINavigationController(rootViewController: mainViewController)
        navigationController.navigationBar.tintColor = UIColor(named: SemomunColor.mainColor)
        
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
}

//MARK: - CollectionView
extension StartSettingVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.mediumTags {
            self.viewModel?.selectMedium(to: indexPath.item)
        } else {
            self.viewModel?.selectSmall(to: indexPath.item)
        }
    }
}

extension StartSettingVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.mediumTags {
            return self.viewModel?.mediumTags.count ?? 0
        } else {
            return self.viewModel?.smallTagsCount ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StartTagCell.identifier, for: indexPath) as? StartTagCell else { return UICollectionViewCell() }
        guard let viewModel = self.viewModel else { return cell }
        
        if collectionView == self.mediumTags {
            cell.configure(title: viewModel.mediumTag(index: indexPath.item))
            if viewModel.selectedMediumTag != nil && indexPath.item == viewModel.currentMediumIndex {
                cell.didSelect()
            }
        } else {
            cell.configure(title: viewModel.smallTag(index: indexPath.item))
            if let currentSmallIndex = viewModel.currentSmallIndex,
               indexPath.item == currentSmallIndex {
                cell.didSelect()
            }
        }
        
        return cell
    }
}

//extension StartSettingVC: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        let horizontalInset: CGFloat = 24
//        let rowCount: Int = 3
//        let cellWidth = (self.mediumTags.frame.width-(CGFloat(rowCount-1)*horizontalInset))/CGFloat(rowCount)
//        let cellHeight: CGFloat = 60
//
//        return CGSize(width: cellWidth, height: cellHeight)
//    }
//}
