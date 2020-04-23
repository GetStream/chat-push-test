//
//  AppDelegate.swift
//  PushNotifTest
//
//  Created by Bahadir Oncel on 27.02.2020.
//  Copyright © 2020 Stream.io. All rights reserved.
//

import UIKit
import StreamChatClient
import SwiftJWT

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private var viewController: ViewController? {
        if let window = UIApplication.shared.windows.first, let viewController = window.rootViewController as? ViewController {
            return viewController
        }
        return nil
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // ============== CONFIGURE API KEY AND SECRET HERE ==============
        let apiKey = "<#API_KEY#>"
        let apiSecret = "<#API_SECRET#>"
        // ===============================================================
        
        Client.config = .init(apiKey: apiKey, baseURL: <#Your Server Location#>, stayConnectedInBackground: false)
        
        let possibleNames = ["Alexey", "Bahadir", "Tommaso", "Thierry", "Merel", "Marcelo", "Alessandro", "Ferhat", "Jaap", "Vishal"]
        let randomName = possibleNames.randomElement()!
        let randomUserId = "\(randomName)-\(Int.random(in: 0..<999999))"
        let token = try! generateUserToken(for: randomUserId, from: apiSecret)
        
        print("User ID: \(randomUserId)\nToken: \(token)")
        
        var user = User(id: randomUserId)
        user.name = randomName
        Client.shared.set(user: user, token: token) { connection in
            if connection.isConnected {
                DispatchQueue.main.async {
                    self.viewController?.askForNotificationPermissionIfNeeded()
                }
            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Client.shared.addDevice(deviceToken: deviceToken) { _ in
            DispatchQueue.main.async {
                if let deviceId = User.current.currentDevice?.id {
                    print("Device ID: \(deviceId)")
                    let userId = User.current.id
                    self.viewController?.deviceIdLabel.text = deviceId
                    self.viewController?.commandLabel.text = """
                    stream chat:push:device:add -d \(deviceId) -p apn -u \(userId)
                    stream chat:channel:create -c ios-push-test -d "{}" -n ios-test-push -t messaging -u \(userId) -i "image.jpg" -j
                    stream chat:message:create -c 'ios-push-test' -i 'image.jpg' -m "hello" -u "\(userId)" -t messaging -n "\(userId)" -j
                    stream chat:push:test -u \(userId)
                    """
                    Client.shared.disconnect()
                } else {
                    self.viewController?.deviceIdLabel.text = "Error"
                }
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Remote notification registration error: \(error)")
        viewController?.deviceIdLabel.text = "Remote notification registration error: \(error.localizedDescription)"
    }
    
    private func generateUserToken(for userId: String, from secret: String) throws -> String {
        let header = Header()
        let claims = StreamClaims(user_id: userId)
        var jwt = JWT(header: header, claims: claims)
        guard let secretData = secret.data(using: .utf8) else {
            throw NSError(domain: "jwtTokenError", code: -1, userInfo: nil)
        }
        let jwtSigner = JWTSigner.hs256(key: secretData)
        return try jwt.sign(using: jwtSigner).string
    }
}

struct StreamClaims: Claims {
    let user_id: String
}

