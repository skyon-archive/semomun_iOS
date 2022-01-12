//
//  LoadingIndicator.swift
//  semomun
//
//  Created by Kang Minsang on 2021/11/06.
//

import UIKit

protocol LoadingDelegate: AnyObject {
    func setCount(to: Int)
    func oneProgressDone()
    func terminate()
}

final class LoadingIndicator: UIViewController {
    static let identifier = "LoadingIndicator"
    static let update = Notification.Name("update")
    static let terminate = Notification.Name("terminate")

    @IBOutlet weak var loadingProgress: CircularProgressView!
    @IBOutlet weak var statusLabel: UILabel!
    
    var totalPageCount: Int = 0
    var currentCount: Int = 0
    var currentPersent: Float = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.setProgress()
    }
    
    private func configureUI() {
        self.isModalInPresentation = true
    }
    
    private func setProgress() {
        self.loadingProgress.progressWidth = 15.0
        self.loadingProgress.trackColor = UIColor.darkGray
        self.loadingProgress.progressColor = UIColor(named: SemomunColor.mainColor)!
        self.statusLabel.text = "\(self.currentCount)/\(self.totalPageCount)"
        self.loadingProgress.setProgressWithAnimation(duration: 0.2, value: 0.0, from: 0)
    }
    
    func configureObserve() {
        NotificationCenter.default.addObserver(forName: Self.update, object: nil, queue: .main) { _ in
            self.oneProgressDone()
        }
        NotificationCenter.default.addObserver(forName: Self.terminate, object: nil, queue: .main) { _ in
            self.terminate()
        }
    }
}

extension LoadingIndicator: LoadingDelegate {
    func setCount(to: Int) {
        self.totalPageCount = to
        self.setProgress()
    }
    
    func oneProgressDone() {
        self.currentCount += 1
        let newPersent = Float(currentCount)/Float(totalPageCount)
        self.statusLabel.text = "\(self.currentCount)/\(self.totalPageCount)"
        self.loadingProgress.setProgressWithAnimation(duration: 0.2, value: newPersent, from: currentPersent)
        self.currentPersent = newPersent
        
        if self.currentCount >= self.totalPageCount {
            self.terminate()
        }
    }
    
    func terminate() {
        self.dismiss(animated: true, completion: nil)
    }
}
