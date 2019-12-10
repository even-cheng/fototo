//
//  FT_LoginController.swift
//  fototo
//
//  Created by Even_cheng on 2019/10/12.
//  Copyright © 2019 Even_cheng All rights reserved.
//

import Foundation
import AuthenticationServices

class FT_LoginController: UIViewController {

    @IBOutlet weak var loginBgView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var loginStackView: UIStackView!
    
    open var closeDone = {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))

        setupProviderLoginView()
    }
    
    func KEYCHAIN_IDENTIFIER(_ a: String?) -> String? {
        (Bundle.main.bundleIdentifier ?? "") + "_" + (a ?? "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func endEditing() {
        view.endEditing(true)
    }
  
    @IBAction func closeAction(_ sender: Any) {
        closeDone()
    }
}

extension FT_LoginController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing()
        return true
    }
}

extension FT_LoginController {

    func setupProviderLoginView() {
        let authorizationButton = ASAuthorizationAppleIDButton.init(authorizationButtonType: ASAuthorizationAppleIDButton.ButtonType.default, authorizationButtonStyle: ASAuthorizationAppleIDButton.Style.white)
        authorizationButton.isUserInteractionEnabled = true
        authorizationButton.cornerRadius = 10
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchDown)
        self.loginStackView.addArrangedSubview(authorizationButton)
    }
    
    @objc
    func handleAuthorizationAppleIDButtonPress() {
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension FT_LoginController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {

        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            let userIdentifier = appleIDCredential.user

            UserManager.sharedManager.registerUser(username: userIdentifier, pwd: "123456") { (_ res) in
                
                UserManager.sharedManager.login(username: userIdentifier, pwd: "123456") { (_ res) in
                    
                    if res {
                        try? KeychainItem(service: Bundle.main.bundleIdentifier ?? "com.even-cheng.photo", account: "userIdentifier").saveItem(userIdentifier)
                        self.closeDone()
                    } else {
                        self.view.toastError("登录失败")
                    }
                }
                
            }
            
        } else if let passwordCredential = authorization.credential as? ASPasswordCredential {

            let username = passwordCredential.user
            let password = passwordCredential.password
            let userIdentifier = username+password
            
            UserManager.sharedManager.registerUser(username: userIdentifier, pwd: "123456") { (_ res) in
                
                UserManager.sharedManager.login(username: userIdentifier, pwd: "123456") { (_ res) in
                    
                    if res {
                        try? KeychainItem(service: Bundle.main.bundleIdentifier ?? "com.even-cheng.photo", account: "userIdentifier").saveItem(userIdentifier)
                        self.closeDone()
                    } else {
                        self.view.toastError("登录失败")
                    }
                }
                
            }
        
        } else {
        // Fallback on earlier versions
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        view.toastError("授权失败")
    }
}

extension FT_LoginController: ASAuthorizationControllerPresentationContextProviding {

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
