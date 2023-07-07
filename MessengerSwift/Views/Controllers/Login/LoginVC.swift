//
//  LoginVC.swift
//  MessengerSwift
//
//  Created by Hakan Baran on 7.07.2023.
//

import UIKit
import FirebaseAuth

class LoginVC: UIViewController {

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
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = "Log In"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        
        
        emailField.delegate = self
        passwordField.delegate = self
        
        
        view.addSubview(scrollView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(imageView)
        scrollView.addSubview(loginButton)
        scrollView.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        
        
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2, y: scrollView.safeAreaInsets.top-40, width: size, height: size)
        
        emailField.frame = CGRect(x: 30, y: imageView.bottom+60, width: scrollView.width-60, height: 40)
        
        passwordField.frame = CGRect(x: 30, y: emailField.bottom+20, width: scrollView.width-60, height: 40)
        
        loginButton.frame = CGRect(x: scrollView.width/2-scrollView.width/4, y: passwordField.bottom+40, width: scrollView.width/2, height: 40)
        
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
        
        // Firebase Log in
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            guard let result = authResult, error == nil else {
                print("Failed to log in in user with email: \(email)")
                return
            }
            
            let user = result.user
            print("Logged In User: \(user)")
            
            
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
