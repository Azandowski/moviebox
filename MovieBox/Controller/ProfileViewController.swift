//
//  ProfileViewController.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//

import UIKit
import FirebaseAuth

final class ProfileViewController: UIViewController, Alertable {
    
    // MARK: - Outlet
    
    private(set) lazy var profileHeaderView: ProfileHeaderView = {
        let profileHeaderView = ProfileHeaderView()
        profileHeaderView.editButton.addTarget(self, action: #selector(showNameEditAlert), for: .touchUpInside)
        
        return profileHeaderView
    }()
    
    private lazy var signOutButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .red
        button.setTitle("Sign Out", for: .normal)
        button.snp.makeConstraints { (make) in
            make.height.equalTo(44)
        }
        
        button.addTarget(self, action: #selector(logOut), for: .touchUpInside)
        return button
    }()
    
    private lazy var favoritesButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .blue
        button.setTitle("Favorites", for: .normal)
        button.snp.makeConstraints { (make) in
            make.height.equalTo(44)
        }
        
        return button
    }()
    
    private lazy var logOutSectionView: SectionView = {
        let sectionView = SectionView()
        sectionView.setUp()
        sectionView.headerView.titleLabel.text = "Change account"
        sectionView.contentView.addSubview(signOutButton)
        sectionView.alpha = 1
        return sectionView
    }()
    
    private lazy var favSectionView: SectionView = {
        let sectionView = SectionView()
        sectionView.setUp()
        sectionView.headerView.titleLabel.text = "Your List"
        sectionView.contentView.addSubview(favoritesButton)
        sectionView.alpha = 1
        return sectionView
    }()
    
    
    // MARK: - Life-Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUP()
        self.updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let movieCount = AppStore.shared.favMovies.count
        let movieCountText = "\(movieCount) element\(movieCount == 0 ? "" : "s")"
        
        self.favoritesButton.setTitle(movieCountText, for: .normal)
    }
    
    // MARK: - Network
    
    fileprivate func loadUser () {
        if let user = AppStore.shared.user, !user.loaded {
            ApiService.shared.getCurrentUser(userUID: Auth.auth().currentUser!.uid, completionHandler: { (newUser) in
                AppStore.shared.user = newUser
                self.updateUI()
                self.loadFavs()
            }) { (error) in
                self.showAlert("Error", error)
            }
        }
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
    
    // MARK: - UI
    
    fileprivate func updateUI () {
        if let user = AppStore.shared.user {
            profileHeaderView.nameLbl.text = user.name
            profileHeaderView.emailLbl.text = user.email
            profileHeaderView.avatarView.titleLbl.text = "KK"
        }
    }
    
    fileprivate func setUP () {
        self.navigationItem.title = "Profile"
        self.view.addSubview(profileHeaderView)
        self.view.addSubview(logOutSectionView)
        self.view.addSubview(favSectionView)
        
        profileHeaderView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(24)
            make.leading.trailing.equalToSuperview()
        }
        
        favSectionView.snp.makeConstraints { (make) in
            make.top.equalTo(profileHeaderView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
        }
        
        logOutSectionView.snp.makeConstraints { (make) in
            make.top.equalTo(favSectionView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
        }
        
        signOutButton.snp.makeConstraints { (make) in
            make.leading.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview().offset(-37)
        }
        
        favoritesButton.snp.makeConstraints { (make) in
            make.leading.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview().offset(-37)
        }
    }
}


extension ProfileViewController {
    
    // MARK: - Methods
    
    @objc fileprivate func showNameEditAlert () {
        let alert = UIAlertController(title: "Edit", message: "Enter your fullname", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "John Smith"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            self.updateUserName(newName: textField!.text!)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func updateUserName (newName: String) {
        ApiService.shared.updateUser(name: newName, email: AppStore.shared.user?.email ?? "", userUID: Auth.auth().currentUser?.uid ?? "", completionHandler: { (_) in
            AppStore.shared.user?.name = newName
            self.updateUI()
        }) { (errorMsg) in
            self.showAlert("Error", errorMsg)
        }
    }
    
    @objc fileprivate func logOut () {
        let alertController = UIAlertController(title: "Sign out", message: "Are you sure?", preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Exit", style: .destructive, handler: { (_) in
            self.forceLogOut()
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func forceLogOut () {
        let authViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: AuthViewController.uniqueID) as! AuthViewController
        
        ApiService.shared.logout(completionHandler: { (_) in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NSNotification.Name.favUpdateNotificationKey), object: nil, userInfo: nil)
            self.navigationController?.setViewControllers([authViewController], animated: true)
        }) { (errorMsg) in
            self.showAlert("Error", errorMsg)
        }
    }
}

