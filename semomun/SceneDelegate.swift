//
//  SceneDelegate.swift
//  semomun
//
//  Created by Kang Minsang on 2021/08/17.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var networkUsecase: SyncFetchable? = NetworkUsecase(network: Network())
    private lazy var syncUsecase: SyncUsecase? = {
        guard let networkUsecase = self.networkUsecase else {
            assertionFailure()
            return nil
        }
        
        return SyncUsecase(networkUsecase: networkUsecase)
    }()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)

        let isInitial = UserDefaultsManager.isInitial // 앱 최초로딩 여부
        let tagsData = UserDefaultsManager.favoriteTags // 나의 태그값 유무
        
        if isInitial == true || tagsData == nil {
            let storyboard = UIStoryboard(controllerType: StartVC.self)
            let startVC = storyboard.instantiateInitialViewController()
            self.window?.rootViewController = startVC
        } else {
            let storyboard = UIDevice.current.userInterfaceIdiom == .phone ? UIStoryboard(name: "Main_phone", bundle: nil) : UIStoryboard(name: "Main", bundle: nil)
            guard let mainViewController = storyboard.instantiateInitialViewController() else { return }
            self.window?.rootViewController = mainViewController
        }
        
        NotificationCenter.default.addObserver(forName: .goToMain, object: nil, queue: .main) { [weak self] _ in
            self?.changeRootViewController()
        }
        NotificationCenter.default.addObserver(forName: .logout, object: nil, queue: .main) { [weak self] _ in
            self?.showStartVC()
        }
        
        self.configureNavigationBarColor()

        self.window?.makeKeyAndVisible()
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
        NotificationCenter.default.post(name: .saveCoreData, object: nil)
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        
        // 앱의 background 상태에서 사용자 정보에 변화(e.g. 탈퇴 등)가 있을 경우 이를 반영
        // - TODO: 앱 사용 중 발생한 변화에도 대응하기.
        let coreVersion = UserDefaultsManager.coreVersion
        guard UserDefaultsManager.isLogined
                && coreVersion.compare(String.latestCoreVersion, options: .numeric) != .orderedAscending else { return }
        print("sync in sceneDelegate")
        self.syncUsecase?.syncUserDataFromDB { result in
            if case .failure = result {
                print("sceneWillEnterForeground: 유저 정보 동기화 실패")
            }
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

// MARK: Private
extension SceneDelegate {
    private func changeRootViewController() {
        let storyboard = UIDevice.current.userInterfaceIdiom == .phone ? UIStoryboard(name: "Main_phone", bundle: nil) : UIStoryboard(name: "Main", bundle: nil)
        guard let mainViewController = storyboard.instantiateInitialViewController() else { return }
        
        let snapshot:UIView = (self.window?.snapshotView(afterScreenUpdates: true))!
        mainViewController.view.addSubview(snapshot)
        
        self.window?.rootViewController = mainViewController
        
        UIView.animate(withDuration: 0.3, animations: {() in
            snapshot.layer.opacity = 0;
            snapshot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
        }, completion: {
            (value: Bool) in
            snapshot.removeFromSuperview()
        })
    }
    
    private func showStartVC() {
        let storyboard = UIStoryboard(controllerType: StartVC.self)
        guard let startVC = storyboard.instantiateInitialViewController() else { return }
        
        let snapshot: UIView = (self.window?.snapshotView(afterScreenUpdates: true))!
        startVC.view.addSubview(snapshot)
        
        self.window?.rootViewController = startVC
        
        UIView.animate(withDuration: 0.3, animations: {() in
            snapshot.layer.opacity = 0;
            snapshot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
        }, completion: {
            (value: Bool) in
            snapshot.removeFromSuperview()
        })
    }
    
    private func configureNavigationBarColor() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(.background)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont.heading4]
        
        UINavigationBar.appearance().tintColor = UIColor(.orangeRegular)
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

}

/// UIDevice.current.orientation 값이 부정확하므로 Window 의 UI의 값을 통한 가로모드인지 여부 값
extension UIWindow {
    static var isLandscape: Bool {
        return UIApplication.shared.windows
            .first?
            .windowScene?
            .interfaceOrientation
            .isLandscape ?? false
    }
}
