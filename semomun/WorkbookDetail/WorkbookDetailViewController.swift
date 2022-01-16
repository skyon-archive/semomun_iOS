//
//  WorkBookDetailViewController.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/14.
//

import Foundation
import Kingfisher
import Combine
import UIKit

final class WorkbookDetailViewController: UIViewController {
    static let identifier = "WorkbookDetailViewController"
    
    @IBOutlet weak var workbookInfoView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var publisherLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var bookCoverImageView: UIImageView!
    @IBOutlet weak var addWorkbookButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var sectionNumberLabel: UILabel!
    @IBOutlet weak var sectionListTableView: UITableView!
    
    private var isCoreData: Bool = false
    private var viewModel: WorkbookViewModel?
    private var cancellables: Set<AnyCancellable> = []
    private lazy var loader = self.makeLoaderWithoutPercentage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureTableViewDelegate()
        self.bindAll()
        self.configureAddObserver()
        self.fetchWorkbook()
    }
    
    @IBAction func addWorkbook(_ sender: Any) {
        guard let workbookInfo = self.viewModel?.workbookInfo else { return }
        self.showAlertWithCancelAndOK(title: workbookInfo.title, text: "해당 시험을 추가하시겠습니까?") { [weak self] in
            self?.viewModel?.saveWorkbook()
        }
    }
    
    @IBAction func close(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension WorkbookDetailViewController {
    func configureViewModel(to viewModel: WorkbookViewModel) {
        self.viewModel = viewModel
    }
    
    func configureIsCoreData(to: Bool) {
        self.isCoreData = to
    }
    
    private func configureUI() {
        self.configureShadow()
        self.configureLoader()
        
        if self.isCoreData {
            self.addWorkbookButton.isHidden = true
            self.closeButton.isHidden = true
        }
    }
    
    private func configureShadow() {
        self.workbookInfoView.layer.shadowOpacity = 0.35
        self.workbookInfoView.layer.shadowColor = UIColor.lightGray.cgColor
        self.workbookInfoView.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.workbookInfoView.layer.shadowRadius = 7
    }
    
    private func configureLoader() {
        self.view.addSubview(self.loader)
        self.loader.translatesAutoresizingMaskIntoConstraints = false
        self.loader.layer.zPosition = CGFloat.greatestFiniteMagnitude
        NSLayoutConstraint.activate([
            self.loader.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.loader.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
    
    private func configureTableViewDelegate() {
        self.sectionListTableView.delegate = self
        self.sectionListTableView.dataSource = self
    }
    
    private func configureAddObserver() {
        NotificationCenter.default.addObserver(forName: .showSection, object: nil, queue: .main) { [weak self] notification in
            guard let sid = notification.userInfo?["sid"] as? Int else { return }
            guard let preview = self?.viewModel?.previewCore else { return }
            if let section = CoreUsecase.sectionOfCoreData(sid: sid) {
                self?.showSolvingVC(section: section, preview: preview)
                return
            }
        }
        NotificationCenter.default.addObserver(forName: .downloadSectionFail, object: nil, queue: .main) { [weak self] notification in
            self?.showAlertWithOK(title: "다운로드에 실패하였습니다", text: "네트워크 확인 후 다시 시도해주세요", completion: nil)
        }
    }
    
    private func fetchWorkbook() {
        if self.isCoreData {
            self.viewModel?.configureWorkbookInfo(isCoreData: true)
            self.viewModel?.fetchSectionHeaders()
        } else {
            self.viewModel?.configureWorkbookInfo(isCoreData: false)
            self.viewModel?.fetchSectionDTOs()
        }
    }
    
    private func configureBookInfo(workbookInfo: WorkbookInfo) {
        self.titleLabel.text = workbookInfo.title
        self.authorLabel.text = workbookInfo.author
        self.publisherLabel.text = workbookInfo.publisher
        self.releaseDateLabel.text = workbookInfo.releaseDate
        if self.isCoreData {
            if let imageData = workbookInfo.image {
                self.bookCoverImageView.image = UIImage(data: imageData)
            } else {
                self.bookCoverImageView.image = UIImage(named: SemomunImage.warning)
            }
        } else {
            guard let bookcoverURL = workbookInfo.imageURL,
                  let url = URL(string: NetworkURL.bookcovoerImageDirectory(.large) + bookcoverURL) else { return }
            self.bookCoverImageView.kf.setImage(with: url)
        }
    }
    
    private func configureSectionNumber() {
        guard let sectionCount = self.viewModel?.count(isCoreData: self.isCoreData) else { return }
        self.sectionNumberLabel.text = "총 \(sectionCount)단원"
    }
    
    private func showSolvingVC(section: Section_Core, preview: Preview_Core) {
        guard let solvingVC = self.storyboard?.instantiateViewController(withIdentifier: SolvingViewController.identifier) as? SolvingViewController else { return }
        solvingVC.modalPresentationStyle = .fullScreen
        solvingVC.sectionCore = section
        solvingVC.previewCore = preview
        self.present(solvingVC, animated: true, completion: nil)
    }
    
    private func startLoader() {
        self.loader.isHidden = false
        self.loader.startAnimating()
        self.view.isUserInteractionEnabled = false
        
        let backgroundView = UIView()
        backgroundView.tag = 123
        backgroundView.backgroundColor = .gray.withAlphaComponent(0.8)
        backgroundView.frame = self.view.frame
        self.view.addSubview(backgroundView)
    }
    
    private func stopLoader() {
        self.loader.isHidden = true
        self.loader.stopAnimating()
        self.view.isUserInteractionEnabled = true
        if let backgroundView = self.view.viewWithTag(123) {
            backgroundView.removeFromSuperview()
        }
    }
}

// MARK: - Binding
extension WorkbookDetailViewController {
    private func bindAll() {
        self.bindWarning()
        self.bindWorkbookInfo()
        self.bindSectionHeaders()
        self.bindSectionDTOs()
        self.bindLoader()
    }
    
    private func bindWarning() {
        self.viewModel?.$warning
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] warning in
                guard let warning = warning else { return }
                self?.showAlertWithOK(title: warning, text: "", completion: nil)
            })
            .store(in: &self.cancellables)
    }
    
    private func bindWorkbookInfo() {
        self.viewModel?.$workbookInfo
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] workbookInfo in
                guard let workbookInfo = workbookInfo else { return }
                self?.configureBookInfo(workbookInfo: workbookInfo)
            })
            .store(in: &self.cancellables)
    }
    
    private func bindSectionHeaders() {
        self.viewModel?.$sectionHeaders
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.configureSectionNumber()
                self?.sectionListTableView.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindSectionDTOs() {
        self.viewModel?.$sectionDTOs
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.configureSectionNumber()
                self?.sectionListTableView.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindLoader() {
        self.viewModel?.$showLoader
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] showLoader in
                if showLoader {
                    self?.startLoader()
                } else {
                    self?.stopLoader()
                    self?.presentingViewController?.dismiss(animated: true, completion: nil)
                }
            })
            .store(in: &self.cancellables)
    }
}

// MARK: - TableView
extension WorkbookDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel?.count(isCoreData: self.isCoreData) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SectionCell.identifier, for: indexPath) as? SectionCell else {
            return UITableViewCell() }
        
        if self.isCoreData {
            guard let sectionHeader = self.viewModel?.sectionHeader(idx: indexPath.row) else { return cell }
            cell.configureCell(sectionHeader: sectionHeader)
        } else {
            guard let sectionDTO = self.viewModel?.sectionDTO(idx: indexPath.row) else { return cell }
            cell.configureCell(sectionDTO: sectionDTO)
        }
        
        return cell
    }
}
