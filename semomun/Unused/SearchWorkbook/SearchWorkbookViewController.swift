//
//  SearchWorkbookViewController.swift
//  semomun
//
//  Created by Kang Minsang on 2021/09/12.
//

import UIKit
import Kingfisher

class SearchWorkbookViewController: UIViewController {
    static let identifier = "SearchWorkbookViewController"
    
    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var previews: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    private var queryButtons: [UIButton] = []
    private var queryDtos: [QueryListButton] = []
    private var networkUseCase: NetworkUsecase?
    
    var manager: SearchWorkbookManager?
    
    lazy var loaderForPreview = self.makeLoaderWithoutPercentage()
    lazy var loaderForButton = self.makeLoaderWithoutPercentage()
    let buttonIcon: UIImage? = {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .regular, scale: .large)
        return UIImage(systemName: "chevron.down", withConfiguration: largeConfig)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNetwork()
        self.fetchQueryButtons()
        self.configureDelegate()
        self.configureUI()
        self.configureLoader()
        self.configureObserve()
        self.addCoreDataAlertObserver()
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Configure
extension SearchWorkbookViewController {
    private func configureNetwork() {
        let network = Network()
        self.networkUseCase = NetworkUsecase(network: network)
    }
    
    func fetchQueryButtons() {
        guard let manager = self.manager else { return }
        self.networkUseCase?.getQueryButtons(category: manager.category) { [weak self] queryListButtons in
            guard let queryListButtons = queryListButtons else {
                self?.showAlertWithOK(title: "네트워크 에러", text: "다시 시도하시기 바랍니다.")
                return
            }
            queryListButtons.forEach { $0.queryParamValues.insert("전체", at: 0)}
            self?.queryDtos = queryListButtons
            DispatchQueue.main.async {
                for (idx, button) in queryListButtons.enumerated() {
                    self?.createQueryButton(with: button, idx: idx)
                }
                self?.createStackView()
            }
        }
    }
    
    func createQueryButton(with buttonDto: QueryListButton, idx: Int) {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle(buttonDto.title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.tintColor = .lightGray
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.setImage(self.buttonIcon, for: .normal)
        button.contentHorizontalAlignment = .left
        button.semanticContentAttribute = .forceLeftToRight
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 76, bottom: 0, right: -76)
        button.tag = idx
        button.addTarget(self, action: #selector(selectQeuryButton(_:)), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 104),
            button.heightAnchor.constraint(equalToConstant: 41)
        ])
        
        self.queryButtons.append(button)
    }
    
    @objc func selectQeuryButton(_ sender: UIButton) {
        let idx = sender.tag
        print(self.queryDtos[idx].title)
        self.showAlertController(title: self.queryDtos[idx].title, index: idx, data: self.queryDtos[idx].queryParamValues)
    }
    
    func createStackView() {
        let stackView = UIStackView(arrangedSubviews: self.queryButtons)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 30
        
        self.view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 25),
            stackView.centerXAnchor.constraint(equalTo: self.titleLabel.centerXAnchor)
        ])
    }
    
    func configureDelegate() {
        previews.delegate = self
        previews.dataSource = self
    }
    
    func configureUI() {
        self.setRadiusOfFrame()
    }
    
    func configureLoader() {
        self.view.addSubview(self.loaderForPreview)
        self.loaderForPreview.translatesAutoresizingMaskIntoConstraints = false
        self.loaderForPreview.layer.zPosition = CGFloat.greatestFiniteMagnitude
        NSLayoutConstraint.activate([
            self.loaderForPreview.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.loaderForPreview.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
    
    private func configureObserve() {
        NotificationCenter.default.addObserver(forName: .logined, object: nil, queue: .main) { [weak self] _ in
//            self?.showAlertToAddPreview(index: self?.manager?.selectedIndex ?? 0)
            self?.fetchSearchWorkbook(index: self?.manager?.selectedIndex ?? 0)
        }
    }
    
    func setRadiusOfFrame() {
        frameView.layer.cornerRadius = 30
    }
}

extension SearchWorkbookViewController {
    func startPreviewLoader() {
        self.loaderForPreview.isHidden = false
        self.loaderForPreview.startAnimating()
        self.view.isUserInteractionEnabled = false
        
        let backgroundView = UIView()
        backgroundView.tag = 123
        backgroundView.backgroundColor = .gray.withAlphaComponent(0.8)
        backgroundView.frame = self.frameView.frame
        backgroundView.layer.cornerRadius = 30
        print(backgroundView)
        self.view.addSubview(backgroundView)
    }
    
    func stopPreviewLoader() {
        self.loaderForPreview.isHidden = true
        self.loaderForPreview.stopAnimating()
        self.view.isUserInteractionEnabled = true
        if let backgroundView = self.view.viewWithTag(123) {
            backgroundView.removeFromSuperview()
        }
    }
    
    func startButtonLoader() {
        self.loaderForButton.isHidden = false
        self.loaderForButton.startAnimating()
    }
    
    func stopButtonLoader() {
        self.loaderForButton.isHidden = true
        self.loaderForButton.stopAnimating()
    }
}

extension SearchWorkbookViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // 문제수 반환
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return manager?.count ?? 0
    }
    
    // 문제버튼 생성
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchedPreviewCell.identifier, for: indexPath) as? SearchedPreviewCell else { return UICollectionViewCell() }
        // 문제번호 설정
        guard let manager = self.manager else { return cell }
        let imageUrlString = manager.imageURL(at: indexPath.item)
        cell.showImage(url: imageUrlString)
        cell.title.text = manager.title(at: indexPath.item)
        
        return cell
    }
    
    // 문제 버튼 클릭시
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let isLogined = UserDefaultsManager.get(forKey: .logined) as? Bool ?? false
        if isLogined == false {
            self.manager?.select(to: indexPath.item) // 로그인 절차 이후 문제집 다운로드가 이어지기 위한 문제집 index 저장
            self.showLoginAlert()
        } else {
            self.fetchSearchWorkbook(index: indexPath.item)
        }
    }
}

extension SearchWorkbookViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (previews.frame.width)/5
        let height = previews.frame.height/3
        
        return CGSize(width: width, height: height)
    }
}


extension SearchWorkbookViewController {
    func showAlertController(title: String, index: Int, data: [String]) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        for (idx, title) in data.enumerated() {
            let button = UIAlertAction(title: title, style: .default) { _ in
                let queryKey = self.queryDtos[index].queryParamKey
                let queryValue = self.queryDtos[index].queryParamValues[idx]
                
                if queryValue == "전체" {
                    self.manager?.queryDic.updateValue(nil, forKey: queryKey)
                    
                } else {
                    self.manager?.queryDic.updateValue(queryValue, forKey: queryKey)
                }
                
                DispatchQueue.global().async {
                    self.loadPreviewFromDB()
                }
                self.queryButtons[index].setTitle(title, for: .normal)
            }
            button.setValue(UIColor.label, forKey: "titleTextColor")
            alertController.addAction(button)
        }
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.queryButtons[index]
            popoverController.sourceRect = CGRect(x: self.queryButtons[index].bounds.midX, y: self.queryButtons[index].bounds.maxY, width: 0, height: 0)
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func fetchSearchWorkbook(index: Int) {
        guard let wid = self.manager?.preview(at: index).wid else { return }
        self.networkUseCase?.downloadWorkbook(wid: wid, handler: { [weak self] searchWorkbook in
            self?.showWorkbookDetailVC(searchWorkbook: searchWorkbook)
        })
    }
    
    private func showWorkbookDetailVC(searchWorkbook: SearchWorkbook) {
//        guard let workbookVC = UIStoryboard(name: WorkbookDetailVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: WorkbookDetailVC.identifier) as? WorkbookDetailVC else { return }
//        let viewModel = WorkbookViewModel(workbookDTO: searchWorkbook)
//        workbookVC.configureViewModel(to: viewModel)
//        workbookVC.configureIsCoreData(to: false)
//
//        self.present(workbookVC, animated: true, completion: nil)
    }
    
    func loadPreviewFromDB() {
        self.manager?.loadPreviews {
            DispatchQueue.main.async {
                self.previews.reloadData()
            }
        }
    }
    
    func showAlertToAddPreview(index: Int) {
        guard let manager = self.manager else { return }
        let alert = UIAlertController(title: manager.title(at: index),
            message: "해당 시험을 추가하시겠습니까?",
            preferredStyle: UIAlertController.Style.alert)
        
        let cancle = UIAlertAction(title: "취소", style: .destructive, handler: nil)
        let ok = UIAlertAction(title: "추가", style: .default) { _ in
            self.startPreviewLoader()
            self.loadSidsFromDB(index: index)
        }
        
        alert.addAction(cancle)
        alert.addAction(ok)
        present(alert,animated: true,completion: nil)
    }
    
    func savePreview(index: Int, workbook: WorkbookOfDB, sids: [Int]) {
        guard let manager = self.manager else { return }
        let preview_core = Preview_Core(context: CoreDataManager.shared.context)
        let preview = manager.preview(at: index)
        let baseURL = NetworkURL.bookcoverImageDirectory(manager.imageScale)
        
        preview_core.setValues(preview: preview, workbook: workbook, sids: sids, baseURL: baseURL, category: manager.category)
    }
    
    func saveSectionHeader(sections: [SectionOfDB], subject: String, wid: Int) {
        guard let manager = self.manager else { return }
        let sectionHeader_core = SectionHeader_Core(context: CoreDataManager.shared.context)
        
//        sections.forEach {
//            sectionHeader_core.setValues(section: $0, baseURL: NetworkURL.sectioncoverImageDirectory(manager.imageScale), wid: wid)
//        }
        CoreDataManager.saveCoreData()
        print("save complete")
        NotificationCenter.default.post(name: .downloadPreview, object: self, userInfo: ["subject" : subject])
        DispatchQueue.main.async {
            self.stopPreviewLoader()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func loadSidsFromDB(index: Int) {
        guard let manager = self.manager else { return }
        self.networkUseCase?.downloadWorkbook(wid: manager.preview(at: index).wid) { searchWorkbook in
            let workbook = searchWorkbook.workbook
            let sections = searchWorkbook.sections
            let sids: [Int] = sections.map(\.sid)
            
            DispatchQueue.global().async {
                self.savePreview(index: index, workbook: workbook, sids: sids)
//                self.saveSectionHeader(sections: sections, subject: workbook.subject, wid: workbook.wid)
            }
        }
    }
}

