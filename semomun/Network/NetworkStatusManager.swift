//
//  NetworkStatusManager.swift
//  semomun
//
//  Created by Kang Minsang on 2021/10/05.
//

import Foundation
import Alamofire

// MARK: - Network 연결상태 변화를 감지해야 하는 인스턴스가 채택하기 위한 protocol
protocol NetworkStatusDelegate {
    func didConnected()
    func disConnected()
}

class NetworkStatusManager {
    static let shared = NetworkStatusManager()
    private init() {}
    
    enum Notifications {
        static let didConnected = Notification.Name("didConnected")
        static let disConnected = Notification.Name("disConnected")
    }
    
    static private let manager = Alamofire.NetworkReachabilityManager()
    static var started: Bool = false
    
    static func isConnectedToInternet() -> Bool {
        return manager?.isReachable ?? false
    }
    
    static func state() {
        manager?.startListening { status in
            switch status {
            case .notReachable :
                NotificationCenter.default.post(name: Notifications.disConnected, object: self)
            case .reachable :
                NotificationCenter.default.post(name: Notifications.didConnected, object: self)
            default :
                print("unknown")
            }
        }
        started = true
    }
}
