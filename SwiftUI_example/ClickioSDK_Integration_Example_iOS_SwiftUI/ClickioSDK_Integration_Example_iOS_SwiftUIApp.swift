//
//  ClickioSDK_Integration_Example_iOS_SwiftUIApp.swift
//  ClickioSDK_Integration_Example_iOS_SwiftUI
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
}

@main
struct ClickioSDK_Integration_Example_iOS_SwiftUIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ConsentView()
        }
    }
}
