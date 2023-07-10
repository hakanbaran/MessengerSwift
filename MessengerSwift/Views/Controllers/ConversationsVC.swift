//
//  ViewController.swift
//  MessengerSwift
//
//  Created by Hakan Baran on 7.07.2023.
//

import UIKit
import FirebaseAuth

class ConversationsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        validateAuth()
        
    }
    
    private func validateAuth() {
        
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginVC()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
        
    }


}

