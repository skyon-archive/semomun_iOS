//
//  MultipleWith5AnswerWideVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/05/17.
//

import UIKit
import PencilKit

final class MultipleWith5AnswerWideVC: FormTwo {
    static let identifier = "MultipleWith5AnswerWideVC"
    /* 외부에서 주입가능한 property들 */
    var viewModel: MultipleWith5AnswerVM?
    var subImages: [UIImage?]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCellRegister()
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
    
    override var pagePencilDataWidth: CGFloat {
        if let width = self.viewModel?.pagePencilDataWidth {
            return CGFloat(width)
        } else {
            return super.pagePencilDataWidth
        }
    }
    
    override func updatePagePencilData(data: Data, width: CGFloat) {
        self.viewModel?.updatePagePencilData(to: data, width: Double(width))
    }
    
    override func previousPage() {
        NotificationCenter.default.post(name: .previousPage, object: nil)
    }
    
    override func nextPage() {
        NotificationCenter.default.post(name: .nextPage, object: nil)
    }
}

// MARK: Configure
extension MultipleWith5AnswerWideVC {
    private func configureCellRegister() {
        let cellIdentifiers: [String] = [MultipleWith5Cell.identifier]
        self.configureCellRegisters(identifiers: cellIdentifiers)
    }
}

// MARK: Override 필요한 functions
extension MultipleWith5AnswerWideVC {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.problems.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MultipleWith5Cell.identifier, for: indexPath) as? MultipleWith5Cell else { return UICollectionViewCell() }
        
        let contentImage = self.subImages?[indexPath.item]
        let problem = self.viewModel?.problems[indexPath.item]
        
        cell.delegate = self
        cell.prepareForReuse(contentImage, problem, toolPicker)
        cell.showTopShadow = indexPath.item != 0
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let image = self.subImages?[indexPath.row] ?? UIImage(.warning)
        
        let width: CGFloat = self.collectionView.bounds.width
        let topViewHeight: CGFloat = MultipleWith5Cell.topViewHeight(with: nil)
        let imageHeight = image.size.height * (width/image.size.width)
        let height = topViewHeight + imageHeight
        
        return CGSize(width: width, height: height)
    }
}

extension MultipleWith5AnswerWideVC: FormCellControllable {
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

extension MultipleWith5AnswerWideVC: TimeRecordControllable {
    func endTimeRecord() {
        self.viewModel?.endTimeRecord()
    }
}
