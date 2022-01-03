//
//  ScreenProtector.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/03.
//

import UIKit

class ScreenProtector {
    private var warningWindow: UIWindow?

    private var window: UIWindow? {
        return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window
    }

    func startPreventingRecording() {
        NotificationCenter.default.addObserver(self, selector: #selector(alertPreventScreenCapture), name: UIScreen.capturedDidChangeNotification, object: nil)
    }
    
    func startPreventingScreenshot() {
        NotificationCenter.default.addObserver(self, selector: #selector(alertPreventScreenCapture), name: UIApplication.userDidTakeScreenshotNotification, object: nil)
    }
    
    @objc func alertPreventScreenCapture(notification:Notification) -> Void {
        let alert = UIAlertController(title: "주의", message: "캡쳐 혹은 녹화를 하면 안되요!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        hideScreen()
        self.window?.rootViewController!.present(alert, animated: true, completion: nil)
    }
    
    private func hideScreen() {
        if UIScreen.main.isCaptured {
            window?.alpha = 0.4
        } else {
            window?.alpha = 1
        }
    }
}
