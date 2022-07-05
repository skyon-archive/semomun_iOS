//
//  SingleWithNoAnswerVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import PencilKit

final class SingleWithNoAnswerVC: FormZero {
    static let identifier = "SingleWithNoAnswerVC" // form == 0 && type == 0
    static let storyboardName = "Study"
    
    @IBOutlet weak var bookmarkBT: UIButton!
    @IBOutlet weak var explanationBT: UIButton!
    @IBOutlet weak var topView: UIView!
    
    var viewModel: SingleWithNoAnswerVM?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTimerViewLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateBookmarkBT()
        self.updateExplanationBT()
        self.addScoring()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel?.startTimeRecord()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.endTimeRecord()
    }
    
    @IBAction func toggleBookmark(_ sender: Any) {
        self.bookmarkBT.isSelected.toggle()
        self.viewModel?.updateStar(to: self.bookmarkBT.isSelected)
    }
    
    @IBAction func showExplanation(_ sender: Any) {
        if self.explanationShown {
            self.closeExplanation()
        } else {
            guard let imageData = self.viewModel?.problem?.explanationImage else { return }
            self.showExplanation(to: UIImage(data: imageData))
        }
    }
    
    /* 상위 class 를 위하여 override가 필요한 Property들 */
    override var problem: Problem_Core? {
        return self.viewModel?.problem
    }
    override var topViewHeight: CGFloat {
        return self.topView.frame.height
    }
    override var topViewTrailingConstraint: NSLayoutConstraint? {
        return nil
    }
    /* 상위 class를 위하여 override가 필요한 메소드들 */
    override func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let data = self.canvasView.drawing.dataRepresentation()
        self.viewModel?.updatePencilData(to: data, width: Double(self.canvasView.frame.width))
    }
}

// MARK: Configure
extension SingleWithNoAnswerVC {
    private func configureTimerViewLayout() {
        self.view.addSubview(self.timerView)
        
        NSLayoutConstraint.activate([
            self.timerView.centerYAnchor.constraint(equalTo: self.bookmarkBT.centerYAnchor),
            self.timerView.leadingAnchor.constraint(equalTo: self.bookmarkBT.trailingAnchor, constant: 15)
        ])
    }
}

// MARK: Update
extension SingleWithNoAnswerVC {
    private func updateBookmarkBT() {
        self.bookmarkBT.isSelected = self.viewModel?.problem?.star ?? false
    }
    
    private func updateExplanationBT() {
        self.explanationBT.isSelected = false
        self.explanationBT.isUserInteractionEnabled = true
        self.explanationBT.setTitleColor(UIColor(.blueRegular), for: .normal)
        if self.viewModel?.problem?.explanationImage == nil {
            self.explanationBT.isUserInteractionEnabled = false
            self.explanationBT.setTitleColor(UIColor.gray, for: .normal)
        }
    }
    
    private func addScoring() {
        guard let problem = self.viewModel?.problem,
              problem.terminated == false else { return }
        self.viewModel?.delegate?.addScoring(pid: Int(problem.pid))
    }
}

extension SingleWithNoAnswerVC: TimeRecordControllable {
    func endTimeRecord() {
        self.viewModel?.endTimeRecord()
    }
}
