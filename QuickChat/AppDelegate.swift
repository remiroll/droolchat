//  MIT License

//  Copyright (c) 2017 Haik Aslanyan

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


import UIKit
import GlidingCollection
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var actIdc = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var container: UIView!
    
    class func instance() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func showActivityIndicator() {
        if let window = window {
            container = UIView()
            container.frame = window.frame
            container.center = window.center
            container.backgroundColor = UIColor(white: 0, alpha: 0.8)
            
            actIdc.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            actIdc.hidesWhenStopped = true
            actIdc.center = CGPoint(x: container.frame.size.width / 2, y: container.frame.size.height / 2)
            
            container.addSubview(actIdc)
            window.addSubview(container)
            
            actIdc.startAnimating()
        }
    }
    
    func dismissActivityIndicatos() {
        if let _ = window {
            container.removeFromSuperview()
        }
    }
    
 
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        setupGlidingCollection()
        
        
        FIRApp.configure()
        
//        
//        let navBackgroundImage:UIImage! = UIImage(named: "navigation")
//        UINavigationBar.appearance().setBackgroundImage(navBackgroundImage, for: .default)
       UINavigationBar.appearance().barTintColor = UIColor(red: 240.0/255.0, green: 73.0/255.0, blue: 115.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        UINavigationBar.appearance().shadowImage = UIImage()
        
               

        return true
    }
    
    func setupGlidingCollection() {
        var config = GlidingConfig.shared
        config.buttonsFont = UIFont.boldSystemFont(ofSize: 22)
        config.inactiveButtonsColor = config.activeButtonColor
        GlidingConfig.shared = config
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
}




