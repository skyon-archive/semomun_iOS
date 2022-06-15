//
//  MultipleWith5AnswerVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import PencilKit

class MultipleWith5AnswerVC: FormOne  {
    static let identifier = "MultipleWith5AnswerVC" // form == 1 && type == 5
    
    var subImages: [UIImage?]?
    var viewModel: MultipleWith5AnswerVM?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cellIdentifier = MultipleWith5Cell.identifier
        self.configureCellRegister(nibName: cellIdentifier, reuseIdentifier: cellIdentifier)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel?.startTimeRecord()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.endTimeRecord()
    }
    
    override var pagePencilData: Data? {
        return self.viewModel?.pagePencilData
    }
    
    override var pagePencilDataWidth: Double? {
        return self.viewModel?.pagePencilDataWidth
    }
}

// MARK: Override
extension MultipleWith5AnswerVC {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.problems.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MultipleWith5Cell.identifier, for: indexPath) as? MultipleWith5Cell else { return UICollectionViewCell() }
        
        let contentImage = self.subImages?[indexPath.item] ?? nil
        let problem = self.viewModel?.problems[indexPath.item]
        
        cell.delegate = self
        cell.prepareForReuse(contentImage, problem, self.toolPicker)
        cell.showTopShadow = indexPath.item != 0
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = self.view.frame.width/2 - 10
        let solveInputFrameHeight: CGFloat = 6 + 45
        // imageView 높이값 가져오기
        guard var contentImage = subImages?[indexPath.item] else {
            return CGSize(width: width, height: 300)
        }
        if contentImage.size.hasValidSize == false {
            contentImage = UIImage(.warning)
        }
        
        let imgHeight: CGFloat = contentImage.size.height * (width/contentImage.size.width)
        let height: CGFloat = solveInputFrameHeight + imgHeight
        return CGSize(width: width, height: height)
    }
    
    override func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        self.viewModel?.updatePagePencilData(to: self.canvasViewDrawing, width: Double(self.canvasViewContentWidth))
    }
}

extension MultipleWith5AnswerVC: FormCellControllable {
    func reload() {
        self.viewModel?.delegate?.reload()
    }
    
    func addScoring(pid: Int) {
        self.viewModel?.delegate?.addScoring(pid: pid)
    }
    
    func addUpload(pid: Int) {
        self.viewModel?.delegate?.addUploadProblem(pid: pid)
    }
}

extension MultipleWith5AnswerVC: TimeRecordControllable {
    func endTimeRecord() {
        self.viewModel?.endTimeRecord()
    }
}
