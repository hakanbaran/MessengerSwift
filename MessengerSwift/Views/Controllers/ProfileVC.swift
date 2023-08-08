//
//  ProfileVC.swift
//  MessengerSwift
//
//  Created by Hakan Baran on 7.07.2023.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import SDWebImage


final class ProfileVC: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var logOutButton: UIButton!
    
    
    var data = [ProfileViewModel]()
    
    let sectionsData = [
            ["Set Profile Photo", "Set Username"],
            ["Saved Messages", "Chat Folders"],
            ["Notification and Sounds", "Privacy and Security", "Appearance", "Data Storage"]
        ]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        logOutButton.addTarget(self, action: #selector(logOutButtonTapped), for: .touchUpInside)
        
//        tableView.separatorStyle = .none
        
        data.append(ProfileViewModel(viewModelType: .info, title: "\(UserDefaults.standard.value(forKey: "name") as? String ?? "No Name")", handler: nil))
        
        data.append(ProfileViewModel(viewModelType: .info, title: "\(UserDefaults.standard.value(forKey: "email") as? String ?? "No Email")", handler: nil))
        
        data.append(ProfileViewModel(viewModelType: .logout, title: "LogOut", handler: { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            
            let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .alert)
            actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
                
                guard let strongSelf = self else {
                    return
                }
                
                UserDefaults.standard.setValue(nil, forKey: "email")
                UserDefaults.standard.set(nil, forKey: "name")
                
                // Log Out Facebook
                
                FBSDKLoginKit.LoginManager().logOut()
                
                // Google Log Out
                
                GIDSignIn.sharedInstance.signOut()
                
                do {
                    try FirebaseAuth.Auth.auth().signOut()
                    
                    let vc = LoginVC()
                    let nav = UINavigationController(rootViewController: vc)
                    nav.modalPresentationStyle = .fullScreen
                    strongSelf.present(nav, animated: true)
                } catch {
                    print("Failed to Log Out!!!")
                }
                
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            strongSelf.present(actionSheet, animated: true)
            
            
        }))
        
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        
        tableView.register(ProfileCell.self, forCellReuseIdentifier: ProfileCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableHeaderView = createTableHeader()

        
    }
    
    @objc func logOutButtonTapped() {
        
        
        
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .alert)
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
            
            guard let strongSelf = self else {
                return
            }
            
            UserDefaults.standard.setValue(nil, forKey: "email")
            UserDefaults.standard.set(nil, forKey: "name")
            
            // Log Out Facebook
            
            FBSDKLoginKit.LoginManager().logOut()
            
            // Google Log Out
            
            GIDSignIn.sharedInstance.signOut()
            
            do {
                try FirebaseAuth.Auth.auth().signOut()
                
                let vc = LoginVC()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true)
            } catch {
                print("Failed to Log Out!!!")
            }
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(actionSheet, animated: true)
        
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
    }
    
    func createTableHeader() -> UIView? {
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let fileName = safeEmail + "_profile_picture.png"
        
        let path = "images/"+fileName
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 220))
        
        let headerImageView = UIImageView()
        headerImageView.translatesAutoresizingMaskIntoConstraints = false
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.backgroundColor = .white
        headerImageView.layer.borderColor = UIColor.white.cgColor
        headerImageView.layer.borderWidth = 3
        headerImageView.layer.masksToBounds = true
        headerImageView.layer.cornerRadius = 60
        headerView.addSubview(headerImageView)
        
        headerImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 10).isActive = true
        headerImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: (headerView.width/2-60)).isActive = true
        headerImageView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        headerImageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        StorageManager.shared.downloadURL(for: path) { result in
            switch result {
            case .success(let url):
                headerImageView.sd_setImage(with: url)
            case .failure(let error):
                print("Failed to get download url: \(error)")
            }
        }
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textAlignment = .center
        nameLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        nameLabel.text = data[0].title
        headerView.addSubview(nameLabel)
        
        nameLabel.topAnchor.constraint(equalTo: headerImageView.bottomAnchor, constant: 0).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: (headerView.width/2-(headerView.width-100)/2)).isActive = true
        nameLabel.widthAnchor.constraint(equalToConstant: headerView.width-100).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let emailLabel = UILabel()
        emailLabel.textAlignment = .center
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.font = .systemFont(ofSize: 18, weight: .regular)
        emailLabel.text = data[1].title
        headerView.addSubview(emailLabel)
        
        emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: -15).isActive = true
        emailLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: (headerView.width/2-(headerView.width-100)/2)).isActive = true
        emailLabel.widthAnchor.constraint(equalToConstant: headerView.width-100).isActive = true
        emailLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        return headerView
    }
}

extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionsData[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileCell.identifier, for: indexPath) as? ProfileCell else {
            return UITableViewCell()
        }
        cell.nameLabel.text = sectionsData[indexPath.section][indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        data[indexPath.row].handler?()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " "
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}
