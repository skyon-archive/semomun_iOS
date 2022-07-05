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
    func showPracticeTestSection(workbook: Preview_Core)
}

final class TestSubjectCell: UICollectionViewCell {
    /* public */
    static let identifer = "TestSubjectCell"
    /* private */
    private weak var delegate: TestSubjectCellObserber?
    private var networkUsecase: TestSubjectNetworkUsecase?
    private var coreInfo: Preview_Core? // section download 시 필요한 정보를 지니기 위함
    private var requestedUUID: UUID?
    private var downloading: Bool = false
    private var totalCount: Int = 0
    private var currentCount: Int = 0
    @IBOutlet weak var bookcoverFrameView: UIView!
    @IBOutlet weak var bookcover: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var downloadIndicator: CircularProgressView!
    private lazy var grayCoverView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.3
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bookcoverFrameView.cornerRadius = CGFloat.cornerRadius12
        self.bookcoverFrameView.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.coreInfo = nil
        self.requestedUUID = nil
        self.downloading = false
        self.bookcover.image = UIImage(.loadingBookcover)
        self.downloadedUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        self.bookcoverFrameView.addAccessibleShadow()
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
            self.bookcover.image = UIImage(.loadingBookcover)
        }
    }
    
    private func configureShadow() {
        let shadowBound = CGRect(0, -0.2, self.bookcover.frame.width-12, self.bookcover.frame.height)
        self.bookcoverFrameView.addAccessibleShadow(direction: .custom(0, 4.5), opacity: 0.15, shadowRadius: 6, bounds: shadowBound)
    }
    
    private func notDownloadedUI() {
        self.bookcover.addSubview(self.grayCoverView)
        self.grayCoverView.frame = self.bookcover.frame
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
