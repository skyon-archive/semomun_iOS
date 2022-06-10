//
//  MultipleWithNoAnswerVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import PencilKit

class MultipleWithNoAnswerVC: FormOne {
    static let identifier = "MultipleWithNoAnswerVC" // form == 1 && type == 0

    private var explanationId: Int? // Cell 에서 받은 explanation 의 pid 저장
    var subImages: [UIImage?]?
    var viewModel: MultipleWithNoAnswerVM?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cellIdentifier = MultipleWithNoCell.identifier
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
}

// MARK: Overide
extension MultipleWithNoAnswerVC {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.problems.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MultipleWithNoCell.identifier, for: indexPath) as? MultipleWithNoCell else { return UICollectionViewCell() }
        
        let contentImage = self.subImages?[indexPath.item] ?? nil
        let problem = self.viewModel?.problems[indexPath.item]
        let superWidth = self.collectionView.frame.width
        
        cell.delegate = self
        cell.configureReuse(contentImage, problem, superWidth, toolPicker)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = self.view.frame.width/2 - 10
        let solveInputFrameHeight: CGFloat = 6 + 45
        // imageView 높이값 가져오기
        guard var contentImage = subImages?[indexPath.row] else {
            return CGSize(width: width, height: 300) }
        if contentImage.size.width == 0 || contentImage.size.height == 0 {
            contentImage = UIImage(.warning)
        }
        let imgHeight: CGFloat = contentImage.size.height * (width/contentImage.size.width)
        
        let height: CGFloat = solveInputFrameHeight + imgHeight
        
        return CGSize(width: width, height: height)
    }
    
    override func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        self.viewModel?.updatePagePencilData(to: self.canvasViewDrawing, width: self.canvasViewContentWidth)
    }
}

// MARK: Protocol Conformance
extension MultipleWithNoAnswerVC: CollectionCellWithNoAnswerDelegate {
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

extension MultipleWithNoAnswerVC: TimeRecordControllable {
    func endTimeRecord() {
        self.viewModel?.endTimeRecord()
    }
}
