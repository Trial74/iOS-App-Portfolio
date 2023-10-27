//
//  extreme_look_iosApp.swift
//  extreme-look-ios
//
//  Created by Влад Важенин on 18.11.2022.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import UIKit
import WebKit
import YandexMobileMetrica

public var token: String = ""

struct ExtremeLook {
    static var webView: WKWebView!
    static var openNotifi = false
    static var notifiURL = ""
    static var initWebView = true
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    var viewModel = ViewModel()
    let configYAmetrica = YMMYandexMetricaConfiguration.init(apiKey: "fdd1ade4-5bed-43f2-9ec3-7d62cf9b4da3")
    
    func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {

        YMMYandexMetrica.activate(with: configYAmetrica!)
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self

        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )

        application.registerForRemoteNotifications()
        
        if UIApplication.shared.applicationIconBadgeNumber > 0{ UIApplication.shared.applicationIconBadgeNumber = 0 }
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if UIApplication.shared.applicationIconBadgeNumber > 0{ UIApplication.shared.applicationIconBadgeNumber = 0 }
    }
    
    func application(_ application: UIApplication,
                       didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
    }
    func application(_ application: UIApplication,
                       didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async
        -> UIBackgroundFetchResult {
        return UIBackgroundFetchResult.newData
    }
    
    func application(_ application: UIApplication,
                       didFailToRegisterForRemoteNotificationsWithError error: Error) {
        //print("EX_Unable to register for remote notifications: \(error.localizedDescription)")
    }

    func application(_ application: UIApplication,
                       didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //print("EX_APNs token retrieved: \(deviceToken)")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification) async
    -> UNNotificationPresentationOptions {
        return [[.list, .badge, .banner, .sound]]
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        if UIApplication.shared.applicationIconBadgeNumber > 0{ UIApplication.shared.applicationIconBadgeNumber = 0 }
        if let temp = userInfo["url"],
        let notiURL = temp as? String {
            ExtremeLook.notifiURL = self.viewModel.host + notiURL + self.viewModel.param;
            switch UIApplication.shared.applicationState {
                case .background, .inactive:
                if(ExtremeLook.initWebView){
                    //Приложение открыто уведомлением
                    ExtremeLook.openNotifi = true
                }else{
                    //Приложение развернуто уведомлением
                    ExtremeLook.webView.load(URLRequest(url: URL(string: ExtremeLook.notifiURL)!));
                }
                break
                case .active:
                    ExtremeLook.webView.load(URLRequest(url: URL(string: ExtremeLook.notifiURL)!));
                break
                default:
                break
            }
        }
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        //print("EX_Firebase registration token: \(String(describing: fcmToken))")
        token = fcmToken ?? "";
    }
}

@main
struct extreme_look_iosApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
