//
//  LoginVC.swift
//  MessengerSwift
//
//  Created by Hakan Baran on 7.07.2023.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import JGProgressHUD
import GoogleSignIn
import GoogleSignInSwift
import FirebaseCore


class LoginVC: UIViewController {
    
    private let spinner = JGProgressHUD(style: .extraLight)

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "messenger")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    let facebookLoginButton : FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["public_profile", "email"]
        return button
    }()
    
    let googLeButton = GIDSignInButton()
    
    
//    let googleSignInButton : UIButton = {
//
//        let button = UIButton()
//        button.setImage(UIImage(systemName: "person"), for: .normal)
//
//        button.setTitle("BARANYUM", for: .normal)
//
//        button.contentHorizontalAlignment = .left
//        button.contentVerticalAlignment = .center
//
//        button.titleLabel?.textAlignment = .center
//
//
//
//        button.titleColor(for: .normal)
//
//
//        button.backgroundColor = .lightGray
//
//
//        return button
//    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = "Log In"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
//        googleSignInButton.addTarget(self, action: #selector(googleSignIn), for: .touchUpInside)
        
        googLeButton.addTarget(self, action: #selector(googleSignIn), for: .touchUpInside)
        
        
        emailField.delegate = self
        passwordField.delegate = self
        
        facebookLoginButton.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(imageView)
        scrollView.addSubview(loginButton)
        scrollView.addGestureRecognizer(tapGesture)
        scrollView.addSubview(facebookLoginButton)
//        scrollView.addSubview(googleSignInButton)
        
        
        view.addSubview(googLeButton)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        
        
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2, y: scrollView.safeAreaInsets.top-40, width: size, height: size)
        
        emailField.frame = CGRect(x: 30, y: imageView.bottom+60, width: scrollView.width-60, height: 40)
        
        passwordField.frame = CGRect(x: 30, y: emailField.bottom+20, width: scrollView.width-60, height: 40)
        
        loginButton.frame = CGRect(x: scrollView.width/2-scrollView.width/4, y: passwordField.bottom+40, width: scrollView.width/2, height: 40)
        
        facebookLoginButton.frame = CGRect(x: scrollView.width/2-scrollView.width/4, y: passwordField.bottom+40, width: scrollView.width/2, height: 40)
        
//        googleSignInButton.frame = CGRect(x: scrollView.width/2-scrollView.width/4, y: facebookLoginButton.bottom+80, width: scrollView.width/1.5, height: 40)
        
        
        googLeButton.frame = CGRect(x: scrollView.width/2-scrollView.width/4, y: facebookLoginButton.bottom+160, width: scrollView.width/2, height: 40)
        
        
        facebookLoginButton.center = scrollView.center
        facebookLoginButton.frame.origin.y = loginButton.bottom+20
        
    }
    
    
    @objc func googleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: self) {  result, error in
            guard error == nil else {
                return
            }
            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                return
            }
            
            print("Did sign in with Google: \(user)")
            
            guard let email = user.profile?.email,
                  let firstName = user.profile?.givenName,
                  let lastName = user.profile?.familyName else {
                return
            }
                    
                    
            DatabaseManager.shared.userExists(with: email) { exists in
                if !exists {
                    // insert to database
                    DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName,
                                                                        lastName: lastName,
                                                                        emailAddress: email))
                }
            }
            
            
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            FirebaseAuth.Auth.auth().signIn(with: credential) { authResult, error in
                
                guard authResult != nil, error == nil else {
                    return
                }
                print("Successfully signed in with Google cred...")
                
                
                self.dismiss(animated: true)
            }
            
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func loginButtonTapped() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserLoginError()
            return
        }
        
        spinner.show(in: view)
        
        // Firebase Log in
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            
            
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard let result = authResult, error == nil else {
                print("Failed to log in in user with email: \(email)")
                return
            }
            
            let user = result.user
            print("Logged In User: \(user)")
            
            strongSelf.navigationController?.dismiss(animated: true)
            
        }
        
        
        
        
    }
    
    func alertUserLoginError() {
        
        let alert = UIAlertController(title: "Woops!!!", message: "Please enter all information to log in...", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alert, animated: true)
        
    }
    
    @objc func didTapRegister() {
        let vc = RegisterVC()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    
}

extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            loginButtonTapped()
        }
        return true
    }

}

extension LoginVC: LoginButtonDelegate {


    func loginButton(_ loginButton: FBSDKLoginKit.FBLoginButton, didCompleteWith result: FBSDKLoginKit.LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("User failed to log in with facebook!!!")
            return
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields": "email, name"],
                                                         tokenString: token,
                                                         version: nil,
                                                         httpMethod: .get)
        
        facebookRequest.start { _, result, error in
            guard let result = result as? [String: Any],
                  error == nil else {
                print("Failed to make facebook graph request")
                return
            }
            
            guard let userName = result["name"] as? String,
                  let email = result["email"] as? String else {
                print("Failed to get email and name from fb result")
                return
            }
            
            let nameComponents = userName.components(separatedBy: " ")
            guard nameComponents.count == 2 else {
                return
            }
            
            let firstName = nameComponents[0]
            let lastName = nameComponents[1]
            
            DatabaseManager.shared.userExists(with: email) { exists in
                if !exists {
                    DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName,
                                                                        lastName: lastName,
                                                                        emailAddress: email))
                }
            }
        }
        
        

        let credential = FacebookAuthProvider.credential(withAccessToken: token)

        FirebaseAuth.Auth.auth().signIn(with: credential) { [weak self] authResult, error in

            guard let strongSelf = self else {
                return
            }

            guard authResult != nil, error == nil else {
                print("Facebook credential login failed, MFA may be needed")
                return
            }

            print("Successfully logged user in...")

            strongSelf.navigationController?.dismiss(animated: true)
        }
    }

    func loginButtonDidLogOut(_ loginButton: FBSDKLoginKit.FBLoginButton) {
        // No Operation
    }
    
    
    
    
}
