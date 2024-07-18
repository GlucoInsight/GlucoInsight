//
//  NotificationManager.swift
//  GlucoInsight
//
//  Created by Rong Han & Sichao He on 2024/7/18.
//

import Foundation
import UserNotifications

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("请求通知权限时出错: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func checkGlucoseLevelAndNotify(glucoseLevel: Double) {
        let content = UNMutableNotificationContent()
        content.sound = .default
        
        if glucoseLevel > 140 {
            content.title = "血糖水平偏高"
            content.body = "您的血糖水平偏高 (\(glucoseLevel) mg/dL)。请注意监测您的饮食和运动。"
        } else if glucoseLevel < 70 {
            content.title = "血糖水平偏低"
            content.body = "您的血糖水平偏低 (\(glucoseLevel) mg/dL)。请及时补充一些糖分。"
        } else {
            print("血糖水平正常，不发送通知")
            return
        }
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("发送通知失败: \(error.localizedDescription)")
            } else {
                print("通知已成功发送")
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // 允许在应用前台时显示通知
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("用户点击了通知: \(response.notification.request.content.title)")
        completionHandler()
    }
}
