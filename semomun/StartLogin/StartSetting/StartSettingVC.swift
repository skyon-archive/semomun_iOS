//
//  StartSettingVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import Combine

final class StartSettingVC: UIViewController, StoryboardController {
    static let identifier = "StartSettingVC"
    static var storyboardNames: [UIUserInterfaceIdiom : String] = [.pad: "StartLogin", .phone: "StartLogin_phone"]
    
    @IBOutlet weak var topFrameView: UIView! // phone 용
    @IBOutlet weak var startBT: UIButton!
    @IBOutlet weak var tags: UICollectionView!
    
    private var viewModel: StartSettingVM?
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureDeviceUI()
        self.configureViewModel()
        self.configureCollectionView()
        self.bindAll()
        self.viewModel?.fetchTags()
    }
    
    @IBAction func goMain(_ sender: Any) {
        let finished = self.viewModel?.isSelectFinished ?? false
        guard finished else {
            self.showAlertWithOK(title: "관심이 있는 문제 유형을 선택해 주세요", text: "")
            return
        }
        
        let logined = UserDefaultsManager.isLogined
        guard !logined || SyncUsecase.isPastUserGetTokenCompleted else {
            print("네트워크 느림")
            return
        }
        
        self.viewModel?.saveUserDefaults()
        self.goMainVC()
    }
}

// MARK: - Configure
extension StartSettingVC {
    private func configureDeviceUI() {
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.topFrameView.addShadow()
        }
    }
    private func configureViewModel() {
        let network = Network()
        let networkUsecase = NetworkUsecase(network: network)
        self.viewModel = StartSettingVM(networkUsecase: networkUsecase)
    }
    
    private func configureCollectionView() {
        self.tags.delegate = self
        self.tags.dataSource = self
        let layout = TagsLayout()
        layout.minimumLineSpacing = 18
        self.tags.collectionViewLayout = layout
    }
}

// MARK: - Binding
extension StartSettingVC {
    private func bindAll() {
        self.bindTags()
        self.bindWarning()
        self.bindSelectedTags()
        self.bindNetworkWarning()
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
            .sink(receiveValue: { [weak self] tags in
                if tags.count == 0 {
                    self?.startBT.backgroundColor = UIColor(.semoLightGray)
                } else {
                    self?.startBT.backgroundColor = UIColor(.blueRegular)
                }
                self?.tags.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindNetworkWarning() {
        self.viewModel?.$networkWarning
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] warning in
                if warning {
                    self?.showAlertWithOK(title: "네트워크 오류", text: "네트워크 연결을 확인해주세요.")
                }
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
        
        cell.configure(title: viewModel.tags[indexPath.item].name)
        if viewModel.selectedIndexes.contains(indexPath.item) {
            cell.didSelect()
        }
        
        return cell
    }
}
