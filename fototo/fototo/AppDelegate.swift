//
//  AppDelegate.swift
//  DemoExpandingCollection
//
//  Created by Even_cheng on 25/09/19.
//  Copyright © 2019 Even_cheng All rights reserved.
//

import UIKit
import AuthenticationServices
import LeanCloud

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

//    //当前界面支持的方向（默认情况下只能竖屏，不能横屏显示）
//    var interfaceOrientations:UIInterfaceOrientationMask = .portrait{
//        didSet{
//            //强制设置成竖屏
//            if interfaceOrientations == .portrait{
//                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue,
//                                          forKey: "orientation")
//            }
//                //强制设置成横屏
//            else if !interfaceOrientations.contains(.portrait){
//                UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue,
//                                          forKey: "orientation")
//            }
//        }
//    }
//    
//    //返回当前界面支持的旋转方向
//    func application(_ application: UIApplication, supportedInterfaceOrientationsFor
//        window: UIWindow?)-> UIInterfaceOrientationMask {
//        return interfaceOrientations
//    }
    
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureNavigationTabBar()
        
        // 在 Application 初始化代码执行之前执行
        LCApplication.logLevel = .all
        do {
            try LCApplication.default.set(
                id: "FDmvhdfVYiU1IUt5rMSfCbD6-gzGzoHsz",
                key: "R56TGiEd17DMJSusv5FpIyNP",
                serverURL: "https://fdmvhdfv.lc-cn-n1-shared.com"
            )
        } catch {
            print(error)
        }
        //注册子类
        Product.register()
        Comment.register()
        UserInfo.register()

        
        //检查登录授权状态
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let token = KeychainItem.currentUserIdentifier
        if token.count == 0 {
            UserManager.sharedManager.current_user = nil
            return true
        }
        appleIDProvider.getCredentialState(forUserID: KeychainItem.currentUserIdentifier) { (credentialState, error) in
            switch credentialState {
            case .authorized:
                // The Apple ID credential is valid.
                UserManager.sharedManager.login(username: token, pwd: "123456") { (_ res) in
                    print("login with appleID")
                }
                break
                
            default:
                UserManager.sharedManager.current_user = nil
                break
            }
        }
            
        
        return true
    }
}

extension AppDelegate {

    fileprivate func configureNavigationTabBar() {
        //transparent background
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().isTranslucent = true

        let shadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 0, height: 2)
        shadow.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.shadow: shadow,
        ]
    }
}
