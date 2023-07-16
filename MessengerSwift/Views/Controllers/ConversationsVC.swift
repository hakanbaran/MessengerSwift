//
//  ViewController.swift
//  MessengerSwift
//
//  Created by Hakan Baran on 7.07.2023.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class ConversationsVC: UIViewController {
    
    
    private let spinner = JGProgressHUD(style: .extraLight)
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let noConversationsLabel: UILabel = {
        let label = UILabel()
        
        label.text = "No Conversations!"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self,
                                                            action: #selector(didTapComposeButton))
        
        view.addSubview(tableView)
        view.addSubview(noConversationsLabel)
        
        setupTableView()
        fetchConversations()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        validateAuth()
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    @objc func didTapComposeButton() {
        
        let vc = NewConversationsVC()
        vc.completion = { [weak self] result in
            print("\(result)")
            self?.createNewConversation(result: result)
            
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
        
    }
    
    private func createNewConversation(result: [String: String]) {
        
        guard let name = result["name"],
              let email = result["email"] else {
            return
        }
        
        let vc = ChatVC(with: email)
        vc.isNewConversation = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    private func validateAuth() {
        
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginVC()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
        
    }
    
    private func setupTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    private func fetchConversations() {
        tableView.isHidden = false
        
    }


}

extension ConversationsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            return UITableViewCell()
        }
        cell.textLabel?.text = "Hakan Baran"
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = ChatVC(with: "dldqdşqwdqlwdqwş@gmail.com")
        vc.title = "Hakan Baran"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        
        
        
    }
    
}

