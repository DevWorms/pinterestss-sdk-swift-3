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
import UserNotifications
import StoreKit
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    let kPDKExampleFakeAppId = "4815040272566075428"
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let pageController = UIPageControl.appearance()
        pageController.pageIndicatorTintColor = UIColor.lightGray
        pageController.currentPageIndicatorTintColor = UIColor.red
        pageController.backgroundColor = UIColor.clear
    
        PDKClient.configureSharedInstance(withAppId: kPDKExampleFakeAppId)
        // Override point for customization after application launch.
        
        let configuration = ParseClientConfiguration {
            $0.applicationId = "frida"
            $0.clientKey = ""
            $0.server = "https://app-cocina.herokuapp.com/parse"
        }
        Parse.initialize(with: configuration)
        
        PFFacebookUtils.initializeFacebook(applicationLaunchOptions: launchOptions)
        
        SubscriptionService.shared.loadSubscriptionOptions()
        SKPaymentQueue.default().add(self)
        SubscriptionService.shared.restorePurchases()
        
        let vc : UIViewController
        
        let tutorial: Bool? = UserDefaults.standard.bool(forKey: "tutorial")
        
        if tutorial != true {
            
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: "tutorial")
            
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            vc = storyboard.instantiateViewController(withIdentifier: "PageContentController")
            self.window?.rootViewController = vc
        }
        
        let user = PFUser.current()
        
        if user != nil {
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "Home")
            self.window?.rootViewController = vc
        }
        
        // Register for Push Notitications
        if application.applicationState != UIApplicationState.background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let preBackgroundPush = !application.responds(to: #selector(getter: UIApplication.backgroundRefreshStatus))
            
            let oldPushHandlerOnly = !self.responds(to: #selector(UIApplicationDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:)))
            
            var pushPayload = false
            if let options = launchOptions {
                pushPayload = options[UIApplicationLaunchOptionsKey.remoteNotification] != nil
            }
            if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(inBackground: launchOptions)
            }
        }
        
        /*UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert,.sound,.badge],
            completionHandler: { (granted,error) in
                print("granted")
        }
        )*/
        
        registerForRemoteNotification()
        //application.registerForRemoteNotifications()
        
        /*
        let notificationType: UIUserNotificationType = [.alert, .badge, .sound]
        if application.responds(to: #selector(UIApplication.registerUserNotificationSettings(_:))) {
            
            let settings = UIUserNotificationSettings(types: notificationType, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            
            application.registerForRemoteNotifications(matching: [.badge , .alert , .sound])
        }*/
        
        PFFacebookUtils.facebookLoginManager().loginBehavior = FBSDKLoginBehavior.systemAccount
        
        
        PFAnalytics.trackAppOpened(launchOptions: launchOptions)
        
        Twitter.sharedInstance().start(withConsumerKey: "MMWC6DUWHTHQHoa10u4ZU0tRh", consumerSecret: "teJtkCAvVvcLQoba6JTMdzTG53YuuWyTolBJ0CDFxaLO8vmdMa")
        
        return FBSDKApplicationDelegate.sharedInstance().application(application,     didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if Twitter.sharedInstance().application(app, open: url, options: options) {
            return true
        } else if FBSDKApplicationDelegate.sharedInstance().application(app, open: url,    options: options) {
        
        }
        
        return false
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
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let installation = PFInstallation.current()
        installation?.setDeviceTokenFrom(deviceToken as Data)
        installation?.channels = ["global"]
        installation?.saveInBackground()
    }
    
    
    
    func registerForRemoteNotification() {
        if #available(iOS 10.0, *) {
            let center  = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                if error == nil{
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("User Info = ",notification.request.content.userInfo)
        completionHandler([.alert, .badge, .sound])
    }
    
    //Called to let your app know which action was selected by the user for a given notification.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("User Info = ",response.notification.request.content.userInfo)
        completionHandler()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        PFPush.handle(userInfo)
    }
    
   /* func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return PDKClient.sharedInstance().handleCallbackURL(url)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return PDKClient.sharedInstance().handleCallbackURL(url)
    }*/
    
    func handlePurchasingState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        //print("User is attempting to purchase product id: \(transaction.payment.productIdentifier)")
    }
    
    func handlePurchasedState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        //print("User purchased product id: \(transaction.payment.productIdentifier)")
        queue.finishTransaction(transaction)
        SubscriptionService.shared.uploadReceipt { (success) in
            if  success {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: SubscriptionService.purchaseSuccessfulNotification, object: nil)
                }
            }
        }
        
    }
    
    func handleRestoredState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        //print("Purchase restored for product id: \(transaction.payment.productIdentifier)")
        queue.finishTransaction(transaction)
        SubscriptionService.shared.uploadReceipt { (success) in
            if  success {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: SubscriptionService.restoreSuccessfulNotification, object: nil)
                }
            }
        }
    }
    
    func handleFailedState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("Purchase failed for product id: \(transaction.payment.productIdentifier)")
        queue.finishTransaction(transaction)
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: SubscriptionService.failNotification, object: nil)
        }
    }
    
    func handleDeferredState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("Purchase deferred for product id: \(transaction.payment.productIdentifier)")
        queue.finishTransaction(transaction)
    }

}


extension AppDelegate: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                handlePurchasingState(for: transaction, in: queue)
            case .purchased:
                handlePurchasedState(for: transaction, in: queue)
            case .restored:
                handleRestoredState(for: transaction, in: queue)
            case .failed:
                handleFailedState(for: transaction, in: queue)
            case .deferred:
                handleDeferredState(for: transaction, in: queue)
            }
        }
    }
}

