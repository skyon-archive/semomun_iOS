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
        self.configureCellRegister(MultipleWith5Cell.self)
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

// MARK: Override 필수인 것들 
extension MultipleWith5AnswerVC {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.problems.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MultipleWith5Cell.identifier, for: indexPath) as? MultipleWith5Cell else { return UICollectionViewCell() }
        
        let contentImage = self.subImages?[indexPath.item] ?? nil
        let problem = self.viewModel?.problems[indexPath.item]
        
        cell.delegate = self
        cell.prepareForReuse(contentImage, problem, self.toolPicker, self.viewModel?.mode)
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
        self.viewModel?.updatePagePencilData(to: self.canvasViewDrawing, width: Double(self.canvasViewContentWidth))
    }
}

extension MultipleWith5AnswerVC: FormCellControllable {
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

extension MultipleWith5AnswerVC: TimerTerminateable {
    func endTimeRecord() {
        self.viewModel?.endTimeRecord()
    }
}

extension MultipleWith5AnswerVC: SolvedUpdateable {
    func updateSolved(answer: String, problem: Problem_Core) {
        self.viewModel?.updateSolved(withSelectedAnswer: answer, problem: problem)
    }
}
