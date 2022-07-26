//
//  MultipleWithNoAnswerWideVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/05/24.
//

import Foundation
import PencilKit

final class MultipleWithNoAnswerWideVC: FormTwo {
    static let identifier = "MultipleWithNoAnswerWideVC"
    /* public */
    var viewModel: MultipleWithNoAnswerVM?
    var subImages: [UIImage?]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCellRegister()
        self.configurePagePencilData(data: self.viewModel?.pagePencilData, width: self.viewModel?.pagePencilDataWidth)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel?.startTimeRecord()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.endTimeRecord()
    }
}

// MARK: Configure
extension MultipleWithNoAnswerWideVC {
    private func configureCellRegister() {
        self.configureCellRegisters([MultipleWithNoAnswerCell.self])
    }
}

// MARK: Override 필수인 것들
extension MultipleWithNoAnswerWideVC {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.problems.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MultipleWithNoAnswerCell.identifier, for: indexPath) as? MultipleWithNoAnswerCell else { return UICollectionViewCell() }
        
        let contentImage = self.subImages?[indexPath.item]
        let problem = self.viewModel?.problems[indexPath.item]
        
        cell.delegate = self
        cell.prepareForReuse(contentImage, problem, toolPicker)
        cell.showTopShadow = indexPath.item != 0
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var imageSize = self.subImages?[indexPath.row]?.size ?? UIImage(.warning).size
        if imageSize.hasValidSize == false { imageSize = UIImage(.warning).size }
        
        let width: CGFloat = collectionView.bounds.width - 10
        let topViewHeight: CGFloat = MultipleWith5Cell.topViewHeight(with: nil)
        let imageHeight = imageSize.height * (width/imageSize.width)
        let height = topViewHeight + imageHeight
        
        return CGSize(width: width, height: height)
    }
    
    override func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        self.viewModel?.updatePagePencilData(to: self.canvasViewDrawing, width: Double(self.canvasViewWidth))
    }
}

extension MultipleWithNoAnswerWideVC: FormCellControllable {
    func refreshPageButtons() {
        self.viewModel?.delegate?.refreshPageButtons()
    }
    
    func addScoring(pid: Int) {
        self.viewModel?.delegate?.addScoring(pid: pid)
    }
    
    func addUpload(pid: Int) {
        self.viewModel?.delegate?.addUploadProblem(pid: pid)
    }
}

extension MultipleWithNoAnswerWideVC: TimeRecordControllable {
    func endTimeRecord() {
        self.viewModel?.endTimeRecord()
    }
}
