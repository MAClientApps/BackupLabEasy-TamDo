//
//  AppDelegate.swift
//  Restore Master Pro
//
//  Created by Online on 22/09/22.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseAuth
import MobFlowiOS

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mobFlow : MobiFlowSwift?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       
        mobFlow = MobiFlowSwift(initDelegate: self)
        
        return true
    }
    static func sharedInstance() -> AppDelegate
    {
        UIApplication.shared.delegate as! AppDelegate
    }
   
}

extension AppDelegate: MobiFlowDelegate{

    func present(dic: [String : Any]) {
        DispatchQueue.main.async {
            if let isfirstTimeLogin = UserDefaults.standard.object(forKey: "FirstTimeUserLogin") as? Bool{
                let vc = restoreStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                let nav = UINavigationController(rootViewController: vc)
                self.window?.rootViewController = nav
                self.window?.makeKeyAndVisible()
            }else{
                let vc = restoreStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                let nav = UINavigationController(rootViewController: vc)
                self.window?.rootViewController = nav
                self.window?.makeKeyAndVisible()
            }
        }
    }

    func unloadUnityOnNotificationClick() {

    }
}
