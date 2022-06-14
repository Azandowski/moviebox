//
//  LoadingViewController.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//

import UIKit
import FirebaseAuth

final class LoadingViewController: UIViewController, Alertable, UniqueIdHelper {
    
    static var uniqueID: String = "LoadingViewController"
    
    var loadedGenresByMediaType: [MediaType: Bool] = [
        MediaType.tv : false, MediaType.movie : false
    ]
    
    var loadedUserAndFavs: Bool = false
    
    var loadedEverything: Bool {
        var loaded = true
        
        MediaType.allCases.forEach { (mediaType) in
            loaded = loadedGenresByMediaType[mediaType] ?? false
        }
        
        return loaded && loadedUserAndFavs
    }
    
    lazy var loadingLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = "Loading..."
        lbl.textColor = .red
        return lbl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(loadingLbl)
        self.view.backgroundColor = .darkColor
        
        loadingLbl.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        loadGenres()
        loadUser()
    }
    
    // MARK: - Networking
    
    private func loadGenres () {
        MediaType.allCases.forEach { (mediaType) in
            ApiService.shared.loadGenres(mediaType: mediaType, complitionHandler: { (genres) in
                AppStore.shared.genres.append(contentsOf: genres)
                self.loadedGenresByMediaType[mediaType] = true
                
                if (self.loadedEverything) {
                    self.loadedEverythingCallback()
                }
            }) { (errorMsg) in
                self.showAlert("Error", errorMsg)
            }
        }
    }
    
    private func loadUser () {
        if let user = Auth.auth().currentUser {
            ApiService.shared.getCurrentUser(userUID: user.uid, completionHandler: { (newUser) in
                AppStore.shared.user = newUser
                ApiService.shared.getFavorites(userUID: user.uid, completionHandler: { (response) in
                    AppStore.shared.favMovies = response
                    self.loadedUserAndFavs = true
                    
                    if (self.loadedEverything) {
                        self.loadedEverythingCallback()
                    }
                }) { (error) in
                    self.showAlert("Error", error)
                }
            }) { (error) in
                self.showAlert("Error", error)
            }
        } else {
            loadedUserAndFavs = true
        }
    }
    
    private func loadedEverythingCallback () {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: MainViewController.uniqueID) as! UITabBarController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}
