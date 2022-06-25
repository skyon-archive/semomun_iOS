//
//  TestSubjectCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/05/08.
//

import UIKit

typealias TestSubjectNetworkUsecase = (S3ImageFetchable & SectionDownloadable)
protocol TestSubjectCellObserber: AnyObject {
    func showAlertDownloadSectionFail()
    func showTestPracticeSection(workbook: Preview_Core)
}

final class TestSubjectCell: UICollectionViewCell {
    /* public */
    static let identifer = "TestSubjectCell"
    /* private */
    private var networkUsecase: TestSubjectNetworkUsecase?
    private var requestedUUID: UUID?
    private var coreInfo: Preview_Core? // section download 시 필요한 정보를 지니기 위함
    private var downloading: Bool = false
    private weak var delegate: TestSubjectCellObserber?
    @IBOutlet weak var bookcoverFrameView: UIView!
    @IBOutlet weak var bookcover: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    // 회색 view 추가
    // progress 추가
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.bookcover.image = UIImage(.loadingBookcover)
        self.requestedUUID = nil
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
    func configureNetworkUsecase(to usecase: TestSubjectNetworkUsecase?) {
        self.networkUsecase = usecase
    }
    
    func configureDelegate(to delegate: TestSubjectCellObserber) {
        self.delegate = delegate
    }
    
    func configure(coreInfo info: Preview_Core) {
        self.coreInfo = info
        self.titleLabel.text = "\(info.subject ?? "")(\(info.area ?? ""))"
        self.priceLabel.text = ""
        self.configureImage(data: info.image)
        self.configureShadow()
        
        if info.downloaded == false {
            self.notDownloadedUI()
        }
    }
    
    func configure(dtoInfo info: WorkbookOfDB) {
        self.titleLabel.text = "\(info.subject)(\(info.area))"
        self.priceLabel.text = "\(info.price.withComma)원"
        self.configureImage(uuid: info.bookcover)
        self.configureShadow()
    }
}

// MARK: Private
extension TestSubjectCell {
    private func configureImage(uuid: UUID) {
        if let cachedImage = ImageCacheManager.shared.getImage(uuid: uuid) {
            self.bookcover.image = cachedImage
        } else {
            self.requestedUUID = uuid
            self.networkUsecase?.getImageFromS3(uuid: uuid, type: .bookcover, completion: { [weak self] status, imageData in
                switch status {
                case .SUCCESS:
                    guard let imageData = imageData,
                          let image = UIImage(data: imageData) else { return }
                    DispatchQueue.main.async { [weak self] in
                        ImageCacheManager.shared.saveImage(uuid: uuid, image: image)
                        guard self?.requestedUUID == uuid else { return }
                        self?.bookcover.image = image
                    }
                default:
                    print("HomeWorkbookCell: GET image fail")
                }
            })
        }
    }
    
    private func configureImage(data: Data?) {
        if let imageData = data {
            self.bookcover.image = UIImage(data: imageData)
        } else {
            self.bookcover.image = UIImage(.dummy_bookcover)
        }
    }
    
    private func configureShadow() {
        let shadowBound = CGRect(0, -0.2, self.bookcover.frame.width-12, self.bookcover.frame.height)
        self.bookcoverFrameView.addAccessibleShadow(direction: .custom(0, 4.5), opacity: 0.15, shadowRadius: 6, bounds: shadowBound)
    }
    
    private func notDownloadedUI() {
        // 회색 표시
    }
    
    private func downloadedUI() {
        // 회색 제거
    }
    
    private func touchAction() {
        guard let workbook = self.coreInfo,
              self.downloading == false else { return }
        if workbook.downloaded {
            self.delegate?.showTestPracticeSection(workbook: workbook)
        } else {
            guard workbook.sids.count == 1, let targetSid = workbook.sids.first else { return }
            // download section
            self.startProgress()
            self.downloadSection(workbook: workbook, sid: targetSid)
        }
    }
    
    private func startProgress() {
        self.downloading = true
        // progress 표시
    }
    
    private func downloadSection(workbook: Preview_Core, sid: Int) {
        self.networkUsecase?.downloadSection(sid: sid) { section in
            CoreUsecase.downloadPracticeSection(section: section, workbook: workbook, loading: self) { [weak self] sectionCore in
                self?.downloading = false
                // save section Error
                if sectionCore == nil {
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
    func setCount(to: Int) {
        //
    }
    
    func oneProgressDone() {
        //
    }
    
    func terminate() {
        self.downloading = false
        // progress 제거
        self.downloadedUI()
    }
}
