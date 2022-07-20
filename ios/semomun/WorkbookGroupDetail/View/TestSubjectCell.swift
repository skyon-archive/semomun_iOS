//
//  TestSubjectCell.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/05.
//

import UIKit

typealias TestSubjectNetworkUsecase = (S3ImageFetchable & SectionDownloadable)
protocol TestSubjectCellObserber: AnyObject {
    func showAlertDownloadSectionFail()
    func showPracticeTestSection(workbook: Preview_Core)
}

final class TestSubjectCell: BookcoverCell {
    /* public */
    static let identifer = "TestSubjectCell"
    /* private */
    private weak var delegate: TestSubjectCellObserber?
    private var networkUsecase: TestSubjectNetworkUsecase?
    private var coreInfo: Preview_Core? // section download 시 필요한 정보를 지니기 위함
    private var downloading: Bool = false
    private var totalCount: Int = 0
    private var currentCount: Int = 0
    private lazy var downloadIndicator: CircularProgressView = {
        let view = CircularProgressView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    private lazy var grayCoverView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.3
        return view
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.coreInfo = nil
        self.downloading = false
        self.downloadedUI()
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.touchAction()
            }
        }
    }
}

// MARK: Public
extension TestSubjectCell {
    func configureNetworkUsecase(to networkUsecase: TestSubjectNetworkUsecase?) {
        self.networkUsecase = networkUsecase
    }
    
    func configureDelegate(to delegate: TestSubjectCellObserber) {
        self.delegate = delegate
    }
    
    func configure(coreInfo info: Preview_Core) {
        self.coreInfo = info
        let bookTitle = "\(info.subject ?? "")(\(info.area ?? ""))"
        self.configureReuse(bookTitle: bookTitle, publishCompany: info.publisher ?? "")
        self.configureImage(data: info.image)
        
        if info.downloaded == false {
            self.notDownloadedUI()
        }
    }
    
    func configure(dtoInfo info: WorkbookOfDB) {
        guard let networkUsecase = self.networkUsecase else { return }
        
        let bookTitle = "\(info.subject)(\(info.area))"
        self.configureReuse(bookTitle: bookTitle, publishCompany: info.publishCompany)
        self.configureImage(uuid: info.bookcover, networkUsecase: networkUsecase)
    }
}

// MARK: Private
extension TestSubjectCell {
    private func notDownloadedUI() {
        self.bookcoverImageView.addSubview(self.grayCoverView)
        self.grayCoverView.frame = self.bookcoverImageView.frame
    }
    
    private func downloadedUI() {
        self.downloadIndicator.isHidden = true
        self.grayCoverView.removeFromSuperview()
    }
    
    private func touchAction() {
        guard let workbook = self.coreInfo,
              self.downloading == false else { return }
        
        if workbook.downloaded {
            self.delegate?.showPracticeTestSection(workbook: workbook)
        } else {
            guard workbook.sids.count == 1, let targetSid = workbook.sids.first else { return }
            // download section
            self.startProgress()
            self.downloadSection(workbook: workbook, sid: targetSid)
        }
    }
    
    private func startProgress() {
        self.downloading = true
        self.downloadIndicator.isHidden = false
        self.downloadIndicator.progressColor = .white
        self.downloadIndicator.trackColor = .clear
        self.downloadIndicator.progressWidth = 2
        self.downloadIndicator.setProgressWithAnimation(duration: 0, value: 0, from: 0)
    }
    
    private func downloadSection(workbook: Preview_Core, sid: Int) {
        self.networkUsecase?.downloadSection(sid: sid) { [weak self] section in
            guard let self = self else { return }
            guard let section = section else {
                self.delegate?.showAlertDownloadSectionFail()
                return
            }

            CoreUsecase.downloadPracticeSection(section: section, workbook: workbook, loading: self) { [weak self] sectionCore in
                self?.downloading = false
                // save section Error
                guard sectionCore != nil else {
                    self?.delegate?.showAlertDownloadSectionFail()
                    return
                }
                // save section success
                self?.terminate()
            }
        }
    }
}

extension TestSubjectCell: LoadingDelegate {
    func setCount(to count: Int) {
        self.totalCount = count
        self.currentCount = 0
    }
    
    func oneProgressDone() {
        self.currentCount += 1
        let beforePer = Float(self.currentCount-1)/Float(self.totalCount)
        let newPer = Float(self.currentCount)/Float(self.totalCount)
        self.downloadIndicator.setProgressWithAnimation(duration: 0.2, value: newPer, from: beforePer)
        
        if self.currentCount >= self.totalCount {
            self.terminate()
        }
    }
    
    func terminate() {
        self.downloading = false
        self.downloadedUI()
    }
}
