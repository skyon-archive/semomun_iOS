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
    private var sectionHeader: SectionHeader_Core?
    private var totalCount: Int = 0
    private var currentCount: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.downloadButton.borderWidth = 1
        self.downloadButton.borderColor = UIColor(named: SemomunColor.mainColor)
        self.terminatedImageView.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.nameLabel.text = ""
        self.terminatedImageView.isHidden = true
        self.configureWhite()
        self.numberLeading.constant = 114
        self.downloadButton.isHidden = false
        self.downloadButton.setTitle("다운로드", for: .normal)
    }
    
    @IBAction func download(_ sender: Any) {
        guard let downloaded = self.sectionHeader?.downloaded else { return }
        if downloaded {
            self.showSection()
        } else {
            self.downloadSection()
        }
    }
}

extension SectionCell {
    // MARK: - Configure from Search
    func configureCell(sectionDTO: SectionOfDB, idx: Int) {
        self.sectionNumber.text = String(format: "%02d", idx)
        self.downloadButton.isHidden = true
        self.numberLeading.constant = 0
        self.nameLabel.text = sectionDTO.title
    }
    // MARK: - Configure from CoreData
    func configureCell(sectionHeader: SectionHeader_Core, idx: Int) {
        self.sectionNumber.text = String(format: "%02d", idx)
        self.sectionHeader = sectionHeader
        self.nameLabel.text = sectionHeader.title
        self.configureButton()
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
    
    private func configureWhite() {
        self.downloadButton.backgroundColor = .white
        self.downloadButton.setTitleColor(.black, for: .normal)
    }
    
    private func configureNoneWhite() {
        self.downloadButton.backgroundColor = UIColor(named: SemomunColor.mainColor)
        self.downloadButton.setTitleColor(.white, for: .normal)
    }
}

extension SectionCell {
    private func showSection() {
        print("show Section")
        guard let sid = self.sectionHeader?.sid else { return }
        NotificationCenter.default.post(name: .showSection, object: nil, userInfo: ["sid" : Int(sid)])
    }
    
    private func downloadSection() {
        guard let sid = self.sectionHeader?.sid else { return }
        let networkUsecase = NetworkUsecase(network: Network())
        
        networkUsecase.getPages(sid: Int(sid)) { pages in
            CoreUsecase.savePages(sid: Int(sid), pages: pages, loading: self) { [weak self] sectionCore in
                if sectionCore == nil {
                    NotificationCenter.default.post(name: .downloadSectionFail, object: nil)
                    self?.downloadButton.setTitle("다운실패", for: .normal)
                    return
                }
                self?.sectionHeader?.setValue(true, forKey: "downloaded")
                CoreDataManager.saveCoreData()
                self?.terminate()
            }
        }
    }
    
    private func showPersent() {
        // 소수점*100 -> 퍼센트 -> 반올림 -> Int형
        let percent = Int(round(Double(self.currentCount)/Double(self.totalCount)*100))
        self.downloadButton.setTitle("\(percent)%", for: .normal)
    }
}

extension SectionCell: LoadingDelegate {
    func setCount(to count: Int) {
        self.totalCount = count
        self.currentCount = 0
        self.configureWhite()
        self.showPersent()
    }
    
    func oneProgressDone() {
        self.currentCount += 1
        self.showPersent()
        if self.currentCount >= self.totalCount {
            self.terminate()
        }
    }
    
    func terminate() {
        self.downloadButton.setTitle("문제풀기", for: .normal)
        self.configureNoneWhite()
    }
}
