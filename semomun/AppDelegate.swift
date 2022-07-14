//
//  AppDelegate.swift
//  semomun
//
//  Created by Kang Minsang on 2021/08/17.
//

import UIKit
import CoreData
import GoogleSignIn
import Firebase

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    private let screenProtecter = ScreenProtector()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //        self.screenProtecter.startPreventingRecording()
        //        self.screenProtecter.startPreventingScreenshot()
        FirebaseApp.configure()
        if let userInfo = CoreUsecase.fetchUserInfo(),
           let nickName = userInfo.nickName {
            Analytics.logEvent("launch", parameters: [
                AnalyticsParameterItemID: "\(nickName)",
            ])
        } else {
            Analytics.logEvent("launch", parameters: [
                AnalyticsParameterItemID: "not logined",
            ])
        }
        
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
                // Show the app's signed-out state.
            } else {
                // Show the app's signed-in state.
            }
        }
        
        let isLogined = UserDefaultsManager.isLogined
        let coreVersion = UserDefaultsManager.coreVersion
        
        if isLogined == false {
            KeychainItem.deleteAllItems()
        }
        
        if isLogined {
            if coreVersion.compare(String.latestCoreVersion, options: .numeric) == .orderedAscending {
                guard NetworkStatusManager.isConnectedToInternet() == true else {
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                        NotificationCenter.default.post(name: .networkError, object: nil)
                    }
                    return true
                }
                let syncUsecase = SyncUsecase(networkUsecase: NetworkUsecase(network: Network()))
                syncUsecase.getTokensForPastVersionUser { result in
                    if result == true {
                        print("1.0 사용자 authToken 발급 성공")
                        syncUsecase.syncUserDataFromDB { status in
                            switch status {
                            case .success(_):
                                print("1.0 사용자 정보 sync 성공")
                            case .failure(let error):
                                print("1.0 사용자 정보 sync 실패 \(error)")
                            }
                        }
                    } else {
                        print("1.0 사용자 authToken 발급 실패")
                        // TODO
                    }
                }
            }
        }
        
        UNUserNotificationCenter.current().delegate = self
        self.requestNotiAuth() // noti 권한 popup 표시
        
        return true
    }
    
    func application(
        _ app: UIApplication,
        open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        var handled: Bool
        
        handled = GIDSignIn.sharedInstance.handle(url)
        if handled {
            return true
        }
        
        // Handle other custom URL types.
        
        // If not handled by this app, return false.
        return false
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "semomun")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }
}

/// local Notification 설정 부분
extension AppDelegate: UNUserNotificationCenterDelegate {
    func requestNotiAuth() {
        let authOptions = UNAuthorizationOptions(arrayLiteral: .alert, .badge, .sound)
        
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: authOptions) { isSuccess, error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}
