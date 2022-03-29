//
//  StartVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit

final class StartVC: UIViewController, StoryboardController {
    static let identifier = "StartVC"
    static let storyboardNames: [UIUserInterfaceIdiom: String] = [.pad: "StartLogin", .phone: "StartLogin_phone"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.configureObservation()
    }
    
    @IBAction func start(_ sender: Any) {
        self.goStartSettingVC()
    }
}

extension StartVC {
    private func configureObservation() {
        NotificationCenter.default.addObserver(forName: .networkError, object: nil, queue: .main) { [weak self] _ in
            self?.showAlertWithOK(title: "네트워크 에러", text: "네트워크를 확인 후 다시 시도해주시기 바랍니다.", completion: {
                UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    exit(0)
                }
            })
        }
    }
    private func goStartSettingVC() {
        let nextVC = UIStoryboard(controllerType: StartSettingVC.self).instantiateViewController(withIdentifier: StartSettingVC.identifier)
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}
