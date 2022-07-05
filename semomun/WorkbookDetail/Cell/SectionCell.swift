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
    
    private func resetCell() {
        self.titleLabel.text = ""
        self.sectionNumber.textColor = UIColor(.black)
        self.titleLabel.textColor = UIColor(.black)
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
        self.configureDeleteButton(isEditing, isSelected)
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
                self.controlButton.setTitle("채점완료", for: .normal)
            } else {
                self.controlButton.setTitle("문제풀기", for: .normal)
            }
        } else {
            self.configureWhite()
            self.controlButton.setTitle("다운로드", for: .normal)
        }
    }
    
    private func configureDeleteButton(_ editing: Bool, _ isSelected: Bool) {
        if editing {
            self.progressLabel.isHidden = true
            self.rightIcon.isHidden = true
            
            guard self.sectionHeader?.downloaded == true else {
                self.sectionNumber.textColor = UIColor(.lightGray)
                self.titleLabel.textColor = UIColor(.lightGray)
                return
            }
            
            if isSelected {
                self.controlButton.setImage(UIImage(.checkCircleSolid), for: .normal)
            } else {
                self.controlButton.setImage(UIImage(.warning), for: .normal)
            }
            self.controlButton.isHidden = false
        } else {
            
        }
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
