//
//  AppDelegate.swift
//  KleagueApp
//
//  Created by 최영건 on 5/28/25.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseMessaging
import KakaoSDKAuth
import KakaoSDKCommon
import NMapsMap
import NMapsGeometry
import CoreData
import CoreLocation
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Firebase 초기화
        FirebaseApp.configure()
        
        // Kakao SDK 초기화
        if let appKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String {
            KakaoSDK.initSDK(appKey: appKey)
        } else {
            fatalError("카카오 네이티브 앱 키가 설정되지 않았습니다.")
        }
        
        // FCM 푸시 알림 설정
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        requestNotificationAuthorization(application)
        
        return true
    }
    
    // MARK: - APNs 등록
    private func requestNotificationAuthorization(_ application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            } else {
                print("❌ 알림 권한 거부됨")
            }
        }
    }
    
    // MARK: - FCM 토큰 처리
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        print("✅ FCM 등록 토큰: \(fcmToken)")
        
        // Firestore에 토큰 저장 (로그인된 사용자 기준)
        if let uid = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(uid).setData(["fcmToken": fcmToken], merge: true)
        }
    }
    
    // MARK: - 푸시 알림 수신 시 처리 (포그라운드)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    // MARK: - 카카오 로그인 처리
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        if AuthApi.isKakaoTalkLoginUrl(url) {
            return AuthController.handleOpenUrl(url: url)
        }
        return false
    }
    
    // MARK: - Core Data
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "KleagueApp")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

// MARK: - Firebase Auth 세션 만료 확장
extension User {
    func isSessionExpired(thresholdDays: Int = 30) -> Bool {
        guard let lastSignIn = self.metadata.lastSignInDate else { return false }
        let interval = Date().timeIntervalSince(lastSignIn)
        return interval > Double(thresholdDays * 86400)
    }
}
