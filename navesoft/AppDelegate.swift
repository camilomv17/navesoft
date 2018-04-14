//
//  AppDelegate.swift
//  navesoft
//
//  Created by Camilo Mariño on 2/8/16.
//  Copyright © 2016 Camilo Mariño. All rights reserved.
//

import UIKit
import GoogleMaps
import AudioToolbox


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey("AIzaSyD7nFWXuovcWjLcYFdoVmE8hGx_b2AWEzI")
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        if(Brain.sharedBrain().currentUser != nil){
            let mainViewController = UINavigationController(rootViewController: MainViewController())
            self.window?.rootViewController = mainViewController;
        }
        else{
            let mainViewController = UINavigationController(rootViewController: SelectViewController())
            self.window?.rootViewController = mainViewController;
        }
        
        self.window?.autoresizingMask = UIViewAutoresizing.FlexibleHeight;
        self.window?.autoresizesSubviews = true;
        self.window?.makeKeyAndVisible()
        
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func finishLogin(){
        let controller = UINavigationController(rootViewController: MainViewController())
        self.window?.rootViewController = controller
    }
    
    func signOut(){
        let controller = UINavigationController(rootViewController: RegisterViewController())
        self.window?.rootViewController = controller
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        let deviceTokenString = (NSString(format: "%@", deviceToken) as String).stringByReplacingOccurrencesOfString("<", withString: "").stringByReplacingOccurrencesOfString(">", withString: "").stringByReplacingOccurrencesOfString(" ", withString: "")
        NSLog("%@",deviceTokenString)
        
        let preferences = NSUserDefaults.standardUserDefaults()

        let currentLevelKey = "token"
        
        preferences.setObject(deviceTokenString, forKey: currentLevelKey)
        
        //  Save to disk
        let didSave = preferences.synchronize()
        
        if !didSave {
            //  Couldn't save (I've never seen this happen in real world testing)
        }
        
        
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        application.applicationIconBadgeNumber = 0;

        if(application.applicationState == .Active){
            NSNotificationCenter.defaultCenter().postNotificationName("newMessage", object: Brain.sharedBrain(), userInfo: nil)
            //let banner = Banner(title: "Alerta", subtitle: "Tienes un nuevo mensaje.", image: UIImage(named: "Icon"), backgroundColor: BLUE_COLOR)
         //   banner.dismissesOnTap = true
           // banner.show(duration: 3.0)
            AudioServicesPlaySystemSound(1007)
            
        }
    }
    
    
    
    
  


}

