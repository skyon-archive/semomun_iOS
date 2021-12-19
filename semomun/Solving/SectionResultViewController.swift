//
//  SectionResultViewController.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import UIKit

class SectionResultViewController: UIViewController {
    static let identifier = "SectionResultViewController"
    
    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var totalScoreLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var wrongProblemsLabel: UILabel!
    
    var result: SectionResult?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureUI()
        self.configureData()
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func configureUI() {
        self.frameView.clipsToBounds = true
        self.frameView.layer.cornerRadius = 25
    }
    
    func configureData() {
        guard let result = self.result else { return }
        self.titleLabel.text = result.title
        self.totalScoreLabel.text = "\(result.totalScore)"
        self.totalTimeLabel.text = result.totalTime.toTimeString()
        self.wrongProblemsLabel.text = self.wrongProblems(problems: result.wrongProblems)
    }
    
    func wrongProblems(problems: [String]) -> String {
        var result: String = ""
        for (idx, problem) in problems.enumerated() {
            result += problem
            if idx != problems.count-1 {
                result += ", "
            }
        }
        return result
    }
}
