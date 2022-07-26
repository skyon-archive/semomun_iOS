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
        
        NotificationCenter.default.addObserver(forName: .showLoginStartVC, object: nil, queue: .main) { [weak self] _ in
            self?.showLoginVC()
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let mainViewController = storyboard.instantiateInitialViewController() else { return }
        self.window?.rootViewController = mainViewController
        self.configureNavigationBarColor()
        self.configureTabBarAppearance()
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
    private func showLoginVC() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        guard let loginVC = storyboard.instantiateViewController(withIdentifier: LoginSelectVC.identifier) as? LoginSelectVC else { return }
        let navigationVC = UINavigationController(rootViewController: loginVC)
        navigationVC.navigationBar.tintColor = UIColor.getSemomunColor(.orangeRegular)
        navigationVC.modalPresentationStyle = .fullScreen
        let rootVC = UIApplication.shared.windows.first!.rootViewController
        rootVC?.present(navigationVC, animated: true)
    }
    
    private func configureNavigationBarColor() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.getSemomunColor(.background)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont.heading4]
        
        UINavigationBar.appearance().tintColor = UIColor.getSemomunColor(.orangeRegular)
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    private func configureTabBarAppearance() {
        let tabBarItemAppearance = UITabBarItemAppearance()
        tabBarItemAppearance.normal.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: UIFont.boldFont, size: 14) ?? .systemFont(ofSize: 14, weight: .bold),
            .foregroundColor: UIColor.getSemomunColor(.black),
        ]
        tabBarItemAppearance.selected.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: UIFont.boldFont, size: 14) ?? .systemFont(ofSize: 14, weight: .bold),
            .foregroundColor: UIColor.getSemomunColor(.blueRegular),
        ]
        tabBarItemAppearance.normal.iconColor = .getSemomunColor(.black)
        tabBarItemAppearance.selected.iconColor = .getSemomunColor(.blueRegular)
        
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        tabBarAppearance.backgroundColor = .getSemomunColor(.background)
        tabBarAppearance.shadowColor = .clear
        
        tabBarAppearance.stackedLayoutAppearance = tabBarItemAppearance
        tabBarAppearance.inlineLayoutAppearance = tabBarItemAppearance
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
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
