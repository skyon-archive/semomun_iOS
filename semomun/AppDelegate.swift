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
    
    private let signInConfig = GIDConfiguration.init(clientID: "688270638151-kgmitk0qq9k734nq7nh9jl6adhd00b57.apps.googleusercontent.com")
    private let screenProtecter = ScreenProtector()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        self.screenProtecter.startPreventingRecording()
//        self.screenProtecter.startPreventingScreenshot()
        FirebaseApp.configure()
//        if let userInfo = CoreUsecase.fetchUserInfo(),
//           let uid = userInfo.uid {
//            Analytics.logEvent("launch", parameters: [
//                AnalyticsParameterItemID: "\(uid)",
//            ])
//        } else {
//            Analytics.logEvent("launch", parameters: [
//                AnalyticsParameterItemID: "not logined",
//            ])
//        }
        
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
              // Show the app's signed-out state.
            } else {
              // Show the app's signed-in state.
            }
          }
        
        let isInitial = UserDefaultsManager.get(forKey: .isInitial) as? Bool ?? true // 앱 최초로딩 여부
        let isLogined = UserDefaultsManager.get(forKey: .logined) as? Bool ?? false
        let coreVersion = UserDefaultsManager.get(forKey: .coreVersion) as? String ?? String.pastVersion
        
        if isInitial {
            KeychainItem.deleteAllItems()
        }
        
        if isLogined {
            if coreVersion.compare("2.0.0", options: .numeric) == .orderedAscending {
                SyncUsecase.getTokensForPastVersionUser(networkUsecase: NetworkUsecase(network: Network())) { result in
                    if result == false {
                        // TODO: 처리해야됨
                    } else {
                        self.syncUserData()
                    }
                }
            } else {
                self.syncUserData()
            }
        }
        return true
    }
    
    private func syncUserData() {
        SyncUsecase.syncUserDataFromDB { status in
            switch status {
            case .success(_):
                print("AppDelegate: 유저 정보 동기화 성공")
            case .failure(let error):
                print("AppDelegate: 유저 정보 동기화 실패: \(error)")
            }
        }
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

