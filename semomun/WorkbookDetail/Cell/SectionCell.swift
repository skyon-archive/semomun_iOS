//
//  SectionCell.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/14.
//

import UIKit

final class SectionCell: UITableViewCell {
    /* public */
    static let identifier = "SectionCell"
    /* private */
    @IBOutlet weak var controlButton: UIButton!
    @IBOutlet weak var sectionNumber: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var rightIcon: UIImageView!
    
    private weak var delegate: WorkbookCellController?
    private var sectionHeader: SectionHeader_Core?
    private var totalCount: Int = 0
    private var currentCount: Int = 0
    private var downloading: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.resetCell()
        self.configureDeleteButtonObserver()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetCell()
    }
    /// DTO 상태에서 표시되는 UI
    private func resetCell() {
        self.titleLabel.text = ""
        self.sectionNumber.textColor = UIColor.getSemomunColor(.black)
        self.titleLabel.textColor = UIColor.getSemomunColor(.black)
        self.controlButton.isHidden = true
        self.progressLabel.isHidden = true
        self.rightIcon.isHidden = true
        self.downloading = false
    }
    
    @IBAction func controlAction(_ sender: Any) {
        // MARK: download, select, deSelect, terminated 상태 표시
        guard let downloaded = self.sectionHeader?.downloaded else { return }
        if downloaded {
            self.showSection()
        } else if downloading == false {
            self.downloading = true
            self.downloadSection()
        }
    }
}

extension SectionCell {
    // MARK: - Configure from Search
    func configureCell(sectionDTO: SectionHeaderOfDB) {
        self.sectionNumber.text = String(format: "%02d", Int(sectionDTO.sectionNum))
        self.titleLabel.text = sectionDTO.title
    }
    // MARK: - Configure from CoreData
    func configureDelegate(to delegate: WorkbookCellController) {
        self.delegate = delegate
    }
    
    func configureCell(sectionHeader: SectionHeader_Core, isEditing: Bool = false, isSelected: Bool = false) {
        self.sectionNumber.text = String(format: "%02d", Int(sectionHeader.sectionNum))
        self.titleLabel.text = sectionHeader.title
        
        self.sectionHeader = sectionHeader
        self.configureButton()
        
        if isEditing {
            self.configureEditing(isSelected)
        }
    }
    
    private func configureDeleteButtonObserver() {
        NotificationCenter.default.addObserver(forName: .showSectionDeleteButton, object: nil, queue: .main) { [weak self] _ in
            self?.configureEditing(false)
        }
        NotificationCenter.default.addObserver(forName: .hideSectionDeleteButton, object: nil, queue: .main) { [weak self] _ in
            self?.restoreEditing()
        }
    }
    /// reload 시점에서 DTO 상태 UI 기준 추가 UI 설정
    private func configureButton() {
        guard let sectionHeader = self.sectionHeader else { return }
        
        if sectionHeader.downloaded {
            // MARK: 진행률 로직 필요
            self.configureDownloadedUI()
            
            if sectionHeader.terminated {
                self.controlButton.setImage(UIImage(.badgeCheckSolid), for: .normal)
                self.controlButton.setSVGTintColor(to: UIColor.getSemomunColor(.orangeRegular))
            }
        } else {
            self.configureNonDownloadedUI()
        }
    }
    /// DTO 상태 UI 기준 download 상태 UI 설정
    private func configureDownloadedUI() {
        self.progressLabel.isHidden = false
        self.rightIcon.isHidden = false
    }
    /// DTO 상태 UI 기준 not download 상태 UI 설정
    private func configureNonDownloadedUI() {
        self.controlButton.setImage(UIImage(.cloudDownloadOutline), for: .normal)
        self.controlButton.setSVGTintColor(to: UIColor.getSemomunColor(.blueRegular))
        self.controlButton.isHidden = false
        self.sectionNumber.textColor = UIColor.getSemomunColor(.lightGray)
        self.titleLabel.textColor = UIColor.getSemomunColor(.lightGray)
    }
    /// downloaded 여부에 따른 UI 기준 editing 활성화 상태 UI 설정
    private func configureEditing(_ isSelected: Bool) {
        self.progressLabel.isHidden = true
        self.rightIcon.isHidden = true
        
        guard self.sectionHeader?.downloaded == true else {
            self.controlButton.isHidden = true
            self.sectionNumber.textColor = UIColor.getSemomunColor(.lightGray)
            self.titleLabel.textColor = UIColor.getSemomunColor(.lightGray)
            return
        }
        
        if isSelected {
            self.controlButton.setImage(UIImage(.checkCircleSolid), for: .normal)
            self.controlButton.setSVGTintColor(to: UIColor.getSemomunColor(.blueRegular))
        } else {
            self.controlButton.setImage(UIImage(.warning), for: .normal)
            self.controlButton.setSVGTintColor(to: UIColor.getSemomunColor(.lightGray))
        }
        
        self.controlButton.isHidden = false
        
        
//        guard editing else {
//            self.deleteButton.isHidden = true
//            return
//        }
//        self.deleteButton.isHidden = false
//        if self.sectionHeader?.downloaded ?? false {
//            self.deleteEnable()
//        } else {
//            self.deleteUnable()
//        }
    }
    
    private func restoreEditing() {
        guard self.sectionHeader?.downloaded == true else {
            self.controlButton.setImage(UIImage(.cloudDownloadOutline), for: .normal)
            self.controlButton.setSVGTintColor(to: UIColor.getSemomunColor(.blueRegular))
            self.controlButton.isHidden = false
            self.progressLabel.isHidden = true
            self.rightIcon.isHidden = true
            self.sectionNumber.textColor = UIColor.getSemomunColor(.lightGray)
            self.titleLabel.textColor = UIColor.getSemomunColor(.lightGray)
            return
        }
        
        self.controlButton.isHidden = true
        self.sectionNumber.textColor = UIColor.getSemomunColor(.black)
        
        self.progressLabel.isHidden = false
        self.rightIcon.isHidden = false
    }
    
    private func deleteEnable() {
        self.deleteButton.isUserInteractionEnabled = true
        self.deleteButton.backgroundColor = UIColor(.orangeRegular)
        self.deleteButton.layer.borderColor = UIColor(.orangeRegular)?.cgColor
        self.deleteButton.setTitleColor(.white, for: .normal)
    }
    
    private func deleteUnable() {
        self.deleteButton.isUserInteractionEnabled = false
        self.deleteButton.backgroundColor = .white
        self.deleteButton.layer.borderColor = UIColor(.lightGray)?.cgColor
        self.deleteButton.setTitleColor(UIColor(.lightGray), for: .normal)
    }
    
    private func configureWhite() {
        self.controlButton.backgroundColor = .white
        self.controlButton.setTitleColor(.black, for: .normal)
    }
    
    private func configureNoneWhite() {
        self.controlButton.backgroundColor = UIColor(.blueRegular)
        self.controlButton.setTitleColor(.white, for: .normal)
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
                self.controlButton.setTitle("다운실패", for: .normal)
                return
            }

            CoreUsecase.downloadSection(sid: Int(sid), pages: section.pages, loading: self) { [weak self] sectionCore in
                self?.downloading = false
                if sectionCore == nil {
                    self?.delegate?.showAlertDownloadSectionFail()
                    self?.controlButton.setTitle("다운실패", for: .normal)
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
            self.controlButton.setTitle("다운로드", for: .normal)
            self.deleteUnable()
            CoreDataManager.saveCoreData()
        }
    }
    
    private func showPercent() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // 소수점*100 -> 퍼센트 -> 반올림 -> Int형
            let percent = Int(round(Double(self.currentCount)/Double(self.totalCount)*100))
            self.controlButton.setTitle("\(percent)%", for: .normal)
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
            self?.controlButton.setTitle("문제풀기", for: .normal)
            self?.configureNoneWhite()
        }
    }
}
