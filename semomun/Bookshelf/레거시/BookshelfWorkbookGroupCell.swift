//
//  BookshelfWorkbookGroupCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/06/29.
//

import UIKit

final class BookshelfWorkbookGroupCell: UICollectionViewCell {
    static let identifier = "BookshelfWorkbookGroupCell"
    @IBOutlet weak var bookcoverFrameView: UIView!
    @IBOutlet weak var bookcover: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressPercentLabel: UILabel!
    @IBOutlet weak var bookcoverHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.progressView.setProgress(0, animated: false)
    }
    
    func configure(with workbookGroup: WorkbookGroup_Core, imageSize: CGSize) {
        print("wgid: \(workbookGroup.wgid)")
        self.title.text = workbookGroup.title
        if let imageData = workbookGroup.image {
            self.bookcover.image = UIImage(data: imageData)
        }
        
        let percent: Float = workbookGroup.wids.isEmpty ? 0 : Float(workbookGroup.progressCount)/Float(workbookGroup.wids.count)
        self.progressView.setProgress(percent, animated: false)
        self.progressPercentLabel.text = "\(Int(percent*100))%"
        
        self.bookcoverHeight.constant = imageSize.height
        self.layoutIfNeeded()
        // TODO: 0.2 없애기
        let shadowBound = CGRect(-0.2, -0.2, self.bookcover.frame.width, self.bookcover.frame.height)
        self.bookcoverFrameView.addAccessibleShadow(direction: .custom(1.5, 3.5), opacity: 0.4, shadowRadius: 3, bounds: shadowBound)
    }
}
