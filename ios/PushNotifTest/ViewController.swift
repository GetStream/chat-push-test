//
//  ViewController.swift
//  PushNotifTest
//
//  Created by Bahadir Oncel on 27.02.2020.
//  Copyright © 2020 Stream.io. All rights reserved.
//

import UIKit
import StreamChatClient

class ViewController: UIViewController {

    @IBOutlet weak var userIdLabel: CopyableLabel!
    @IBOutlet weak var deviceIdLabel: CopyableLabel!
    @IBOutlet weak var commandLabel: CopyableLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userIdLabel.text = User.current.id
        
        commandLabel.font = .monospacedSystemFont(ofSize: 17, weight: .regular)
        commandLabel.backgroundColor = .secondarySystemBackground
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        userIdLabel.text = User.current.id
    }
    
    func askForNotificationPermissionIfNeeded() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .notDetermined {
                self.askForNotificationPermission()
            } else if settings.authorizationStatus == .denied {
                DispatchQueue.main.async {
                    self.deviceIdLabel.text = "You need to allow notifications to be able to test!"
                }
            } else if settings.authorizationStatus == .authorized {
                self.registerForRemoteNotifications()
            }
        }
    }
    
    private func askForNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { didAllow, error in
            guard didAllow else {
                DispatchQueue.main.async {
                    self.deviceIdLabel.text = "You need to allow notifications to be able to test!"
                }
                return
            }
            self.registerForRemoteNotifications()
        }
    }
    
    private func registerForRemoteNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
}

class CopyableLabel: UILabel {
    override public var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }

    func sharedInit() {
        isUserInteractionEnabled = true
        addGestureRecognizer(UILongPressGestureRecognizer(
            target: self,
            action: #selector(showMenu(sender:))
        ))
    }

    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = text
        UIMenuController.shared.hideMenu()
    }

    @objc func showMenu(sender: Any?) {
        becomeFirstResponder()
        let menu = UIMenuController.shared
        if !menu.isMenuVisible {
            menu.showMenu(from: self, rect: bounds)
        }
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return (action == #selector(copy(_:)))
    }
}

