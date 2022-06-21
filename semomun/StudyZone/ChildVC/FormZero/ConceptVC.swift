//
//  ConceptVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import PencilKit

final class ConceptVC: FormZero {
    static let identifier = "ConceptVC" // form == 0 && type == -1
    static let storyboardName = "Study"
    
    @IBOutlet weak var bookmarkBT: UIButton!
    @IBOutlet weak var topView: UIView!
    
    var viewModel: ConceptVM?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTimerViewLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateBookmarkBT()
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
}

// MARK: Configure
extension ConceptVC {
    private func configureTimerViewLayout() {
        self.view.addSubview(self.timerView)
        
        NSLayoutConstraint.activate([
            self.timerView.centerYAnchor.constraint(equalTo: self.bookmarkBT.centerYAnchor),
            self.timerView.leadingAnchor.constraint(equalTo: self.bookmarkBT.trailingAnchor, constant: 15)
        ])
    }
}

// MARK: Update
extension ConceptVC {
    private func updateBookmarkBT() {
        self.bookmarkBT.isSelected = self.viewModel?.problem?.star ?? false
    }
    
    private func addScoring() {
        guard let problem = self.viewModel?.problem,
              problem.terminated == false else { return }
        self.viewModel?.delegate?.addScoring(pid: Int(problem.pid))
    }
}

extension ConceptVC: TimeRecordControllable {
    func endTimeRecord() {
        self.viewModel?.endTimeRecord()
    }
}
