//
//  AuthViewController.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//

import UIKit
import FirebaseAuth

final class AuthViewController: UIViewController, Alertable, UniqueIdHelper {
    
    static var uniqueID: String = "AuthViewController"
    
    // MARK: - Outlets
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var modeToggleBtn: UIButton!
    
    @IBOutlet weak var titleLbl: UILabel!
    
    // MARK: - Props
    
    private(set) var currentMode: LoginMode = .login {
        didSet {
            titleLbl.text = currentMode.title
            modeToggleBtn.setTitle(currentMode.hintText, for: .normal)
        }
    }
    
    // MARK: - UI Actions
    
    @objc fileprivate func onSubmitClick (sender: UIButton) {
        if (currentMode == .login) {
            ApiService.shared.login(email: emailField.text ?? "", password: passwordField.text ?? "", completionHandler: { (user) in
                self.loginRegisterResponseHandler()
            }) { (msg) in
                self.showAlert("Error", msg)
            }
        } else {
            ApiService.shared.register(email: emailField.text ?? "", password: passwordField.text ?? "", completionHandler: { (user) in
                self.loginRegisterResponseHandler()
            }) { (msg) in
                self.showAlert("Error", msg)
            }
        }
    }
    
    @objc fileprivate func toggleLoginMode (sender: UIButton) {
        currentMode = currentMode == LoginMode.login ? LoginMode.register : LoginMode.login
    }
}


// MARK: - Private methods

extension AuthViewController {
    fileprivate func loginRegisterResponseHandler () {
        self.navigationController?.setViewControllers([ProfileViewController()], animated: true)
        self.loadFavs()
    }
    
    fileprivate func loadFavs () {
        if let user = AppStore.shared.user, !user.loaded {
            ApiService.shared.getFavorites(userUID: Auth.auth().currentUser!.uid, completionHandler: { (items) in
                AppStore.shared.favMovies = items
            }) { (error) in
                self.showAlert("Error", error)
            }
        }
    }
}


// MARK: - Config

extension AuthViewController {
    enum LoginMode {
        case login, register
        
        var title: String {
            switch (self) {
            case .login:
                return "Login"
            case .register:
                return "Register"
            }
        }
        
        var hintText: String {
            switch (self) {
            case .login:
                return "I do not have an account"
            case .register:
                return "I have an account"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitBtn.addTarget(self, action: #selector(onSubmitClick(sender:)), for: .touchUpInside)
        
        modeToggleBtn.addTarget(self, action: #selector(toggleLoginMode(sender:)), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (AppStore.shared.user != nil) {
            self.navigationController?.setViewControllers([ProfileViewController()], animated: true)
        }
    }
}
