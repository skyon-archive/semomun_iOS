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
    
    @IBOutlet weak var tags: UICollectionView!
    
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
        self.tags.delegate = self
        self.tags.dataSource = self
        self.tags.collectionViewLayout = TagsLayout()
    }
}

// MARK: - Binding
extension StartSettingVC {
    private func bindAll() {
        self.bindTags()
        self.bindError()
        self.bindWarning()
        self.bindSelectedTags()
    }
    
    private func bindTags() {
        self.viewModel?.$tags
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.tags.reloadData()
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
    
    private func bindWarning() {
        self.viewModel?.$warning
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] warning in
                guard let warning = warning else { return }
                self?.showAlertWithOK(title: warning, text: "")
            })
            .store(in: &self.cancellables)
    }
    
    private func bindSelectedTags() {
        self.viewModel?.$selectedTags
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.tags.reloadData()
            })
            .store(in: &self.cancellables)
    }
}

// MARK: - Logic
extension StartSettingVC {
    private func goMainVC() {
        NotificationCenter.default.post(name: .goToMain, object: nil)
    }
}

//MARK: - CollectionView
extension StartSettingVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel?.select(to: indexPath.item)
    }
}

extension StartSettingVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.tags.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StartTagCell.identifier, for: indexPath) as? StartTagCell else { return UICollectionViewCell() }
        guard let viewModel = self.viewModel else { return cell }
        
        cell.configure(title: viewModel.tag(index: indexPath.item))
        if viewModel.selectedIndexes.contains(indexPath.item) {
            cell.didSelect()
        }
        
        return cell
    }
}
