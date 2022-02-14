//
//  SceneDelegate.swift
//  semomun
//
//  Created by Kang Minsang on 2021/08/17.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)

        let isInitial = UserDefaultsManager.get(forKey: UserDefaultsManager.Keys.isInitial) as? Bool ?? true // 앱 최초로딩 여부
        let tags = UserDefaultsManager.get(forKey: UserDefaultsManager.Keys.favoriteTags) as? [String] ?? [] // 2.0 기반 생긴 데이터
        if isInitial || tags.isEmpty {
            let storyboard = UIStoryboard(name: StartVC.storyboardName, bundle: nil)
            let startViewController = storyboard.instantiateViewController(withIdentifier: StartVC.identifier)
            let navigationController = UINavigationController(rootViewController: startViewController)
            self.window?.rootViewController = navigationController
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let mainViewController = storyboard.instantiateInitialViewController() else { return }
            let navigationController = UINavigationController(rootViewController: mainViewController)
            navigationController.navigationBar.tintColor = UIColor(.mainColor)
            navigationController.isNavigationBarHidden = true
            self.window?.rootViewController = navigationController
        }
        
        NotificationCenter.default.addObserver(forName: .goToMain, object: nil, queue: .main) { [weak self] _ in
            self?.changeRootViewController()
        }
        NotificationCenter.default.addObserver(forName: .logout, object: nil, queue: .main) { [weak self] _ in
            self?.showStartVC()
        }

        self.window?.makeKeyAndVisible()
    }
    
    private func changeRootViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let mainViewController = storyboard.instantiateInitialViewController() else { return }
        let navigationController = UINavigationController(rootViewController: mainViewController)
        navigationController.navigationBar.tintColor = UIColor(.mainColor)
        navigationController.isNavigationBarHidden = true
        
        let snapshot:UIView = (self.window?.snapshotView(afterScreenUpdates: true))!
        navigationController.view.addSubview(snapshot)
        
        self.window?.rootViewController = navigationController
        
        UIView.animate(withDuration: 0.3, animations: {() in
            snapshot.layer.opacity = 0;
            snapshot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
        }, completion: {
            (value: Bool) in
            snapshot.removeFromSuperview()
        })
    }
    
    private func showStartVC() {
        let storyboard = UIStoryboard(name: StartVC.storyboardName, bundle: nil)
        let startViewController = storyboard.instantiateViewController(withIdentifier: StartVC.identifier)
        let navigationController = UINavigationController(rootViewController: startViewController)
        navigationController.navigationBar.tintColor = UIColor(.mainColor)
        navigationController.isNavigationBarHidden = true
        
        let snapshot:UIView = (self.window?.snapshotView(afterScreenUpdates: true))!
        navigationController.view.addSubview(snapshot)
        
        self.window?.rootViewController = navigationController
        
        UIView.animate(withDuration: 0.3, animations: {() in
            snapshot.layer.opacity = 0;
            snapshot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
        }, completion: {
            (value: Bool) in
            snapshot.removeFromSuperview()
        })
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

