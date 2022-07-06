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
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    private weak var delegate: WorkbookCellController?
    private var sectionHeader: SectionHeader_Core?
    private var totalCount: Int = 0
    private var currentCount: Int = 0
    private var editingMode: Bool = false
    private var sectionSelected: Bool = false
    private var index: Int = 0
    private var downloading: Bool = false {
        didSet {
            if downloading {
                self.loader.startAnimating()
            } else {
                self.loader.stopAnimating()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.rightIcon.setSVGTintColor(to: UIColor.getSemomunColor(.lightGray))
        self.resetCell()
        self.configureDeleteButtonObserver()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetCell()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            guard self.sectionHeader?.downloaded == true,
                  self.downloading == false,
                  self.editingMode == false else { return }
            self.showSection()
        }
    }
    /// DTO 상태에서 표시되는 UI
    private func resetCell() {
        self.titleLabel.text = ""
        self.controlButton.isHidden = true
        self.setBlackLabels()
        self.hideProgressLabels()
        self.downloading = false
    }
    
    @IBAction func controlAction(_ sender: Any) {
        // download 를 위한 action
        if self.sectionHeader?.downloaded == false,
           self.editingMode == false,
           self.downloading == false {
            self.controlButton.isHidden = true
            self.downloading = true
            self.downloadSection()
            return
        }
        
        // 삭제 선택을 위한 action 필요
        if self.sectionHeader?.downloaded == true,
           self.editingMode == true,
           self.downloading == false {
            self.sectionSelected.toggle() // delegate 로 index 값, selected 전달 필요
            if self.sectionSelected {
                self.setControlButtonImage(to: UIImage(.checkCircleSolid), color: .blueRegular)
            } else {
                self.setControlButtonImage(to: UIImage(.circle), color: .lightGray)
            }
            return
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
    
    func configureCell(sectionHeader: SectionHeader_Core, isEditing: Bool = false, isSelected: Bool = false, index: Int) {
        self.sectionNumber.text = String(format: "%02d", Int(sectionHeader.sectionNum))
        self.titleLabel.text = sectionHeader.title
        
        self.sectionHeader = sectionHeader
        self.editingMode = isEditing
        self.sectionSelected = isSelected
        self.index = index
        self.configureButton()
        
        if isEditing {
            self.configureEditing()
        }
    }
    
    private func configureDeleteButtonObserver() {
        NotificationCenter.default.addObserver(forName: .showSectionDeleteButton, object: nil, queue: .main) { [weak self] _ in
            self?.configureEditing()
        }
        NotificationCenter.default.addObserver(forName: .hideSectionDeleteButton, object: nil, queue: .main) { [weak self] _ in
            self?.restoreEditing()
        }
    }
    /// reload 시점에서 DTO 상태 UI 기준 추가 UI 설정
    private func configureButton() {
        guard let sectionHeader = self.sectionHeader else { return }
        
        if sectionHeader.downloaded {
            self.updateProgress()
            self.showProgressLabels()
            
            if sectionHeader.terminated {
                self.setControlButtonImage(to: UIImage(.badgeCheckSolid), color: .orangeRegular)
            }
        } else {
            self.setControlButtonImage(to: UIImage(.cloudDownloadOutline), color: .blueRegular)
            self.setGrayLabels()
        }
    }
    
    private func showProgressLabels() {
        self.progressLabel.isHidden = false
        self.rightIcon.isHidden = false
    }
    
    private func hideProgressLabels() {
        self.progressLabel.isHidden = true
        self.rightIcon.isHidden = true
    }
    
    private func setBlackLabels() {
        self.sectionNumber.textColor = UIColor.getSemomunColor(.black)
        self.titleLabel.textColor = UIColor.getSemomunColor(.black)
    }
    
    private func setGrayLabels() {
        self.sectionNumber.textColor = UIColor.getSemomunColor(.lightGray)
        self.titleLabel.textColor = UIColor.getSemomunColor(.lightGray)
    }
    
    private func setControlButtonImage(to image: UIImage, color: SemomunColor) {
        self.controlButton.setImageWithSVGTintColor(image: image, color: color)
        self.controlButton.isHidden = false
    }
    
    private func updateProgress() {
        // MARK: 내부 로직 구현 필요
        self.progressLabel.text = "100% 채점"
    }
    
    private func configureEditing() {
        self.editingMode = true
        self.hideProgressLabels()
        
        guard self.sectionHeader?.downloaded == true else {
            self.controlButton.isHidden = true
            self.setGrayLabels()
            return
        }
        
        if self.sectionSelected {
            self.setControlButtonImage(to: UIImage(.checkCircleSolid), color: .blueRegular)
        } else {
            self.setControlButtonImage(to: UIImage(.circle), color: .lightGray)
        }
    }
    
    private func restoreEditing() {
        self.editingMode = false
        self.sectionSelected = false
        guard self.sectionHeader?.downloaded == true else {
            self.setControlButtonImage(to: UIImage(.cloudDownloadOutline), color: .blueRegular)
            self.setGrayLabels()
            self.hideProgressLabels()
            return
        }
        
        self.showProgressLabels()
        self.setBlackLabels()
        
        if self.sectionHeader?.terminated == true {
            self.setControlButtonImage(to: UIImage(.badgeCheckSolid), color: .orangeRegular)
        } else {
            self.controlButton.isHidden = true
        }
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
                return
            }

            CoreUsecase.downloadSection(sid: Int(sid), pages: section.pages, loading: self) { [weak self] sectionCore in
                self?.downloading = false
                if sectionCore == nil {
                    self?.delegate?.showAlertDownloadSectionFail()
                    return
                }
                self?.sectionHeader?.setValue(true, forKey: "downloaded")
                CoreDataManager.saveCoreData()
                self?.terminate()
            }
        }
    }
    
    private func showPercent() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // 소수점*100 -> 퍼센트 -> 반올림 -> Int형
            let percent = Int(round(Double(self.currentCount)/Double(self.totalCount)*100))
            // MARK: 다운로드 표시 로직 물어보기
            print("\(percent)%")
        }
    }
}

extension SectionCell: LoadingDelegate {
    func setCount(to count: Int) {
        self.totalCount = count
        self.currentCount = 0
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
        self.setBlackLabels()
        self.updateProgress()
        self.showPercent()
    }
}
