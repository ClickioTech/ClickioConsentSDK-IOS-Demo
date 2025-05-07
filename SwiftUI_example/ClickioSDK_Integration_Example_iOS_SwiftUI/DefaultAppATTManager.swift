//
//  DefaultAppATTManager.swift
//  ClickioSDK_Integration_Example_iOS_SwiftUI
//

import AppTrackingTransparency

// MARK: - DefaultAppATTManager
final class DefaultAppATTManager {
    // MARK: Singleton
    public static let shared = DefaultAppATTManager()
    
    // MARK: Initialization
    private init() {}
    
    // MARK: Typealias
    typealias ATTPermissionCallback = (_ isGrantedAccess: Bool) -> Void
    
    // MARK: Methods
    func requestPermission(completion: @escaping ATTPermissionCallback) {
        if #available(iOS 14, *) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    if Thread.isMainThread {
                        completion(status == .authorized)
                    } else {
                        DispatchQueue.main.async {
                            completion(status == .authorized)
                        }
                    }
                }
            }
        } else {
            // For iOS versions under 14
            completion(true)
        }
    }
}
