//
//  ViewController.swift
//  MyApp
//
//  Created by Maximilian Alexander on 6/14/17.
//  Copyright © 2017 Maximilian Alexander. All rights reserved.
//

import UIKit
import Eureka
import RealmSwift

class LoginViewController: FormViewController {
    
    static let ROS_ENDPOINT = "ROS_ENDPOINT"
    static let USERNAME = "USERNAME"
    static let PASSWORD = "PASSWORD"
    static let CONFIRM = "CONFIRM"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        title = "Login"
        
        form +++ Section()
            <<< TextRow(LoginViewController.ROS_ENDPOINT) { row in
                row.title = "ROS URL:"
            }.onChange({ (row) in
                UserDefaults.standard.rosUrl = row.value
            })
            +++ Section()
            <<< TextRow(LoginViewController.USERNAME) { row in
                row.title = "Username"
                row.cell.textField.autocorrectionType = .no
                row.cell.textField.autocapitalizationType = .none
            }
            <<< PasswordRow(LoginViewController.PASSWORD) { row in
                row.title = "Password"
            }
            +++ Section()
            <<< ButtonRow(LoginViewController.CONFIRM) { row in
                row.title = "Login or Register"
            }
            .onCellSelection({ [weak self] (_, row) in
                self?.attemptLogin()
            })
        
        form.setValues([
            LoginViewController.ROS_ENDPOINT: UserDefaults.standard.rosUrl ?? "http://localhost:9080"
        ])
        
    }
    
    func attemptLogin(){
        let username = form.values()[LoginViewController.USERNAME] as? String ?? ""
        let password = form.values()[LoginViewController.PASSWORD] as? String ?? ""
        
        let loginCreds = SyncCredentials.usernamePassword(username: username, password: password)
        let authUrl = UserDefaults.standard.rosUrl ?? "http://localhost:9080"
        
        let confirmButton = form.rowBy(tag: LoginViewController.CONFIRM)
        confirmButton?.title = "One Moment"
        confirmButton?.disabled = Condition(booleanLiteral: true)
        confirmButton?.reload()
        
        form.rowBy(tag: LoginViewController.CONFIRM)?.disabled = Condition(booleanLiteral: true)
        
        
        SyncUser.logIn(with: loginCreds, server: URL(string: authUrl)!) { [weak self] (user, error) in
            if let user = user {
                // we have a user! let's go to the main view controller
                self?.registerUser(syncUser: user, username: username)
                self?.navigationController?.setViewControllers([ItemsListViewController()], animated: true)
            }else if let authError = error as? SyncAuthError, authError.code == .userDoesNotExist {
                self?.attemptRegister(username: username, password: password)
            }
            else{
                let alert = UIAlertController(title: "Uh Oh", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                self?.present(alert, animated: true, completion: nil)
                let confirmButton = self?.form.rowBy(tag: LoginViewController.CONFIRM)
                confirmButton?.title = "Login or Register"
                confirmButton?.disabled = Condition(booleanLiteral: false)
            }
        }
    }
    
    func attemptRegister(username: String, password: String){
        let authUrl = UserDefaults.standard.authUrl ?? "http://localhost:9080"
        
        form.rowBy(tag: LoginViewController.CONFIRM)?.title = "Registering... One Moment."
        form.rowBy(tag: LoginViewController.CONFIRM)?.disabled = Condition(booleanLiteral: true)
        
        let registerCreds = SyncCredentials.usernamePassword(username: username, password: password, register: true)
        SyncUser.logIn(with: registerCreds, server: URL(string: authUrl)!) { [weak self] (user, error) in
            if let _ = error {
                let alert = UIAlertController(title: "Uh Oh", message: "Your username and password were not correct!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                self?.present(alert, animated: true, completion: nil)
                let confirmButton = self?.form.rowBy(tag: LoginViewController.CONFIRM)
                confirmButton?.title = "Login or Register"
                confirmButton?.disabled = Condition(booleanLiteral: false)
            }
            if let user = user {
                self?.registerUser(syncUser: user, username: username)
                self?.navigationController?.setViewControllers([ItemsListViewController()], animated: true)
            }
        }
    }
    
    func registerUser(syncUser: SyncUser, username: String){
        let realm = User.globalUsersRealm
        try! User.globalUsersRealm.write {
            realm.create(User.self, value: [
                "_id": syncUser.identity!,
                "name": username
            ], update: true)
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

