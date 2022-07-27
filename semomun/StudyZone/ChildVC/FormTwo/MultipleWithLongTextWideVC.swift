//
//  MultipleWithLongTextWideVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/27.
//

import UIKit
import PencilKit

final class MultipleWithLongTextWideVC: FormTwo {
    static let identifier = "MultipleWithLongTextWideVC"
    /* public */
    var viewModel: MultipleWithLongTextAnswerVM?
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
extension MultipleWithLongTextWideVC {
    private func configureCellRegister() {
        self.configureCellRegisters([LongTextCell.self])
    }
}

// MARK: Override 필수인 것들
extension MultipleWithLongTextWideVC {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.problems.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LongTextCell.identifier, for: indexPath) as? LongTextCell else { return UICollectionViewCell() }
        
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
        let problem = self.viewModel?.problems[indexPath.item]
        
        let width: CGFloat = collectionView.bounds.width - 10
        let topViewHeight: CGFloat = LongTextCell.topViewHeight(with: problem)
        let imageHeight = imageSize.height * (width/imageSize.width)
        let height = topViewHeight + imageHeight
        
        return CGSize(width: width, height: height)
    }
    
    override func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        self.viewModel?.updatePagePencilData(to: self.canvasViewDrawing, width: Double(self.canvasViewWidth))
    }
}

extension MultipleWithLongTextWideVC: FormCellControllable {
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

extension MultipleWithLongTextWideVC: TimerTerminateable {
    func endTimeRecord() {
        self.viewModel?.endTimeRecord()
    }
}

extension MultipleWithLongTextWideVC: SolvedUpdateable {
    func updateSolved(answer: String, problem: Problem_Core) {
        self.viewModel?.updateSolved(withSelectedAnswer: answer, problem: problem)
    }
}
