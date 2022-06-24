//
//  SectionCell.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/14.
//

import UIKit

final class SectionCell: UITableViewCell {
    static let identifier = "SectionCell"
    
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var sectionNumber: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberLeading: NSLayoutConstraint!
    @IBOutlet weak var terminatedImageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    private var sectionHeader: SectionHeader_Core?
    private var totalCount: Int = 0
    private var currentCount: Int = 0
    private var downloading: Bool = false
    private var editingMode: Bool = false
    private weak var delegate: WorkbookCellController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.resetCell()
        self.configureDeleteButtonObserver()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetCell()
    }
    
    private func resetCell() {
        self.nameLabel.text = ""
        self.terminatedImageView.isHidden = true
        self.deleteButton.isHidden = true
        self.downloadButton.isHidden = false
        self.numberLeading.constant = 94
        self.downloadButton.setTitle("다운로드", for: .normal)
        self.downloading = false
        self.editingMode = false
    }
    
    @IBAction func download(_ sender: Any) {
        guard let downloaded = self.sectionHeader?.downloaded else { return }
        if downloaded {
            self.showSection()
        } else if downloading == false {
            self.downloading = true
            self.downloadSection()
        }
    }
    
    @IBAction func deleteSection(_ sender: Any) {
        let sectionTitle = self.sectionHeader?.title
        self.delegate?.showAlertDeletePopup(sectionTitle: sectionTitle, completion: { [weak self] in
            self?.deleteSection()
        })
    }
}

extension SectionCell {
    // MARK: - Configure from Search
    func configureCell(sectionDTO: SectionHeaderOfDB) {
        self.sectionNumber.text = String(format: "%02d", Int(sectionDTO.sectionNum))
        self.downloadButton.isHidden = true
        self.numberLeading.constant = 0
        self.nameLabel.text = sectionDTO.title
    }
    // MARK: - Configure from CoreData
    func configureDelegate(to delegate: WorkbookCellController) {
        self.delegate = delegate
    }
    
    func configureCell(sectionHeader: SectionHeader_Core, isEditing: Bool = false) {
        self.sectionNumber.text = String(format: "%02d", Int(sectionHeader.sectionNum))
        self.sectionHeader = sectionHeader
        self.nameLabel.text = sectionHeader.title
        self.configureButton()
        self.configureDeleteButton(isEditing)
    }
    
    private func configureDeleteButtonObserver() {
        NotificationCenter.default.addObserver(forName: .showSectionDeleteButton, object: nil, queue: .main) { [weak self] _ in
            self?.configureDeleteButton(true)
        }
        NotificationCenter.default.addObserver(forName: .hideSectionDeleteButton, object: nil, queue: .main) { [weak self] _ in
            self?.configureDeleteButton(false)
        }
    }
    
    private func configureButton() {
        guard let sectionHeader = self.sectionHeader else { return }
        if sectionHeader.downloaded {
            self.configureNoneWhite()
            if sectionHeader.terminated {
                self.terminatedImageView.isHidden = false
                self.downloadButton.setTitle("채점완료", for: .normal)
            } else {
                self.downloadButton.setTitle("문제풀기", for: .normal)
            }
        } else {
            self.configureWhite()
            self.downloadButton.setTitle("다운로드", for: .normal)
        }
    }
    
    private func configureDeleteButton(_ editing: Bool) {
        self.editingMode = editing
        guard editing else {
            self.deleteButton.isHidden = true
            return
        }
        self.deleteButton.isHidden = false
        if self.sectionHeader?.downloaded ?? false {
            self.deleteEnable()
        } else {
            self.deleteUnable()
        }
    }
    
    private func deleteEnable() {
        self.deleteButton.isUserInteractionEnabled = true
        self.deleteButton.backgroundColor = UIColor(.munRedColor)
        self.deleteButton.layer.borderColor = UIColor(.munRedColor)?.cgColor
        self.deleteButton.setTitleColor(.white, for: .normal)
    }
    
    private func deleteUnable() {
        self.deleteButton.isUserInteractionEnabled = false
        self.deleteButton.backgroundColor = .white
        self.deleteButton.layer.borderColor = UIColor(.semoLightGray)?.cgColor
        self.deleteButton.setTitleColor(UIColor(.semoLightGray), for: .normal)
    }
    
    private func configureWhite() {
        self.downloadButton.backgroundColor = .white
        self.downloadButton.setTitleColor(.black, for: .normal)
    }
    
    private func configureNoneWhite() {
        self.downloadButton.backgroundColor = UIColor(.mainColor)
        self.downloadButton.setTitleColor(.white, for: .normal)
    }
}

extension SectionCell {
    private func showSection() {
        guard let sid = self.sectionHeader?.sid else { return }
        self.delegate?.showSection(sid: Int(sid))
    }
    
    private func downloadSection() {
        guard let sid = self.sectionHeader?.sid else { return }
        let networkUsecase = NetworkUsecase(network: Network())
        
        networkUsecase.downloadSection(sid: Int(sid)) { [weak self] section in
            guard let self = self else { return }
            guard let section = section else {
                self.delegate?.showAlertDownloadSectionFail()
                self.downloadButton.setTitle("다운실패", for: .normal)
                return
            }

            CoreUsecase.downloadSection(sid: Int(sid), pages: section.pages, loading: self) { [weak self] sectionCore in
                self?.downloading = false
                if sectionCore == nil {
                    self?.delegate?.showAlertDownloadSectionFail()
                    self?.downloadButton.setTitle("다운실패", for: .normal)
                    return
                }
                self?.sectionHeader?.setValue(true, forKey: "downloaded")
                CoreDataManager.saveCoreData()
                self?.terminate()
                self?.configureDeleteButton(self?.editingMode ?? false)
            }
        }
    }
    
    private func deleteSection() {
        guard let sid = self.sectionHeader?.sid else { return }
        CoreUsecase.deleteSection(sid: Int(sid))
        if CoreUsecase.fetchSection(sid: Int(sid)) == nil {
            self.sectionHeader?.setValue(false, forKey: "downloaded")
            self.configureWhite()
            self.downloadButton.setTitle("다운로드", for: .normal)
            self.deleteUnable()
            CoreDataManager.saveCoreData()
        }
    }
    
    private func showPercent() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // 소수점*100 -> 퍼센트 -> 반올림 -> Int형
            let percent = Int(round(Double(self.currentCount)/Double(self.totalCount)*100))
            self.downloadButton.setTitle("\(percent)%", for: .normal)
        }
    }
}

extension SectionCell: LoadingDelegate {
    func setCount(to count: Int) {
        self.totalCount = count
        self.currentCount = 0
        self.configureWhite()
        self.showPercent()
    }
    
    func oneProgressDone() {
        self.currentCount += 1
        self.showPercent()
        if self.currentCount >= self.totalCount {
            self.terminate()
        }
    }
    
    func terminate() {
        DispatchQueue.main.async { [weak self] in
            self?.downloadButton.setTitle("문제풀기", for: .normal)
            self?.configureNoneWhite()
        }
    }
}
