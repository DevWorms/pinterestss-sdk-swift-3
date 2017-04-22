//
//  AppDelegate.swift
//  pinterestSwift
//
//  Created by Sergio Ivan Lopez Monzon on 05/04/17.
//  Copyright © 2017 Sergio Ivan Lopez Monzon. All rights reserved.
//


import UIKit
import Parse
import Bolts
import ParseFacebookUtilsV4
import Fabric
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let kPDKExampleFakeAppId = "4815040272566075428"
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        PDKClient.configureSharedInstance(withAppId: kPDKExampleFakeAppId)
        // Override point for customization after application launch.
        
        let configuration = ParseClientConfiguration {
            $0.applicationId = "chemasid"
            $0.clientKey = ""
            $0.server = "https://young-citadel-54232.herokuapp.com/parse"
        }
        Parse.initialize(with: configuration)
        
        let vc : UIViewController
        
        
        let tutorial: Bool? = UserDefaults.standard.bool(forKey: "tutorial")
        
        if tutorial != true {
            
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: "tutorial")
            
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            vc = storyboard.instantiateViewController(withIdentifier: "PageContentController")
            self.window?.rootViewController = vc
        }
        
 
       
        PFFacebookUtils.initializeFacebook(applicationLaunchOptions: launchOptions)
        
        
        
        
        
        // Register for Push Notitications
        if application.applicationState != UIApplicationState.background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let preBackgroundPush = !application.responds(to: #selector(getter: UIApplication.backgroundRefreshStatus))
            
            let oldPushHandlerOnly = !self.responds(to: #selector(UIApplicationDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:)))
            
            var pushPayload
                
                = false
            if let options = launchOptions {
                pushPayload = options[UIApplicationLaunchOptionsKey.remoteNotification] != nil
            }
            if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(inBackground: launchOptions)
            }
        }
        let notificationType: UIUserNotificationType = [.alert, .badge, .sound]
        if application.responds(to: #selector(UIApplication.registerUserNotificationSettings(_:))) {
            
            let settings = UIUserNotificationSettings(types: notificationType, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            
            application.registerForRemoteNotifications(matching: [.badge , .alert , .sound])
        }
        
        
        
        
        
        
        let userNotificationTypes: UIUserNotificationType = [.alert, .badge, .sound]
        
        let settings = UIUserNotificationSettings(types: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        

        
        
        PFFacebookUtils.facebookLoginManager().loginBehavior = FBSDKLoginBehavior.systemAccount
        
        
        PFAnalytics.trackAppOpened(launchOptions: launchOptions)
        
        
        Fabric.with([Twitter.self])

        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return PDKClient.sharedInstance().handleCallbackURL(url)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return PDKClient.sharedInstance().handleCallbackURL(url)
    }
    

}

