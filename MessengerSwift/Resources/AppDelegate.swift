//
//  AppDelegate.swift
//  MessengerSwift
//
//  Created by Hakan Baran on 7.07.2023.
//



import UIKit
import FirebaseCore
import FacebookCore
import FBSDKCoreKit
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
    
    FirebaseApp.configure()
    
//    guard let clientID = FirebaseApp.app()?.options.clientID else {
//        return false
//    }
//
//    let config = GIDConfiguration(clientID: clientID)
//    GIDSignIn.sharedInstance.configuration = config
//
//    GIDSignIn.sharedInstance.signIn(withPresenting: LoginVC()) {  result, error in
//        guard error == nil else {
//            return
//        }
//
//        guard let user = result?.user, let idToken = user.idToken?.tokenString else {
//            return
//        }
//
//        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
//    }

    
    
    
    ApplicationDelegate.shared.application(
        application,
        didFinishLaunchingWithOptions: launchOptions
    )
    
    
    

    return true
}
      
func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
) -> Bool {
    ApplicationDelegate.shared.application(
        app,
        open: url,
        sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
        annotation: options[UIApplication.OpenURLOptionsKey.annotation]
    )
    
    return GIDSignIn.sharedInstance.handle(url)
}
    
    
    
}



