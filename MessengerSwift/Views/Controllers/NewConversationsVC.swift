//
//  NewConversationsVC.swift
//  MessengerSwift
//
//  Created by Hakan Baran on 7.07.2023.
//

import UIKit
import JGProgressHUD

final class NewConversationsVC: UIViewController {
    
    public var completion: (([String: String]) -> (Void))?


    private let spinner = JGProgressHUD(style: .dark)

    private var users = [[String: String]]()

    private var results = [[String: String]]()

    private var hasFetched = false

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for Users..."
        return searchBar
    }()

    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()

    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Results!!!"
        label.textAlignment = .center
        label.textColor = .green
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noResultsLabel)
        view.addSubview(tableView)

        tableView.delegate = self
        tableView.dataSource = self

        searchBar.delegate = self
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf))
        searchBar.becomeFirstResponder()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultsLabel.frame = CGRect(x: view.width/4,
                                      y: (view.height-200)/2,
                                      width: view.width/2,
                                      height: 200)
    }

    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }

}

extension NewConversationsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",
                                                 for: indexPath)
        
        
        let userList = results[indexPath.row]["name"]
                cell.textLabel?.text = userList

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Start Conversation
        
        let targetUserData = results[indexPath.row]
        
        dismiss(animated: true) { [weak self] in
            self?.completion?(targetUserData)
        }
        
        
    }

    
}

extension NewConversationsVC: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }

        searchBar.resignFirstResponder()

        results.removeAll()
        spinner.show(in: view)

        searchUsers(query: text)
    }

    func searchUsers(query: String) {
        // check if array has firebase results
        if hasFetched {
            // if it does: filter
            filterUsers(with: query)
        }
        else {
            // if not, fetch then filter
            DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
                switch result {
                case .success(let usersCollection):
                    self?.hasFetched = true
                    self?.users = usersCollection
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("Failed to get usres: \(error)")
                }
            })
        }
    }

    func filterUsers(with term: String) {
        // update the UI: eitehr show results or show no results label
//        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String, hasFetched else {
//            return
//        }

//        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)

        self.spinner.dismiss()

        let results: [[String: String]] = users.filter({
//            guard let email = $0["email"], email != safeEmail else {
//                return false
//            }
            guard let name = $0["name"]?.lowercased() else {
                return false
            }

            return name.hasPrefix(term.lowercased())
        })

        self.results = results

        updateUI()
    }

    func updateUI() {
        if results.isEmpty {
            noResultsLabel.isHidden = false
            tableView.isHidden = true
        }
        else {
            noResultsLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }

}
