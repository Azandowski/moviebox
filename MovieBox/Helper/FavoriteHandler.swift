//
//  FavoriteHandler.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//

import UIKit
import FirebaseAuth

extension Notification.Name {
    static let favUpdateNotificationKey = "favUpdateNotificationKey"
}



protocol FavoriteHandler: UIViewController, Alertable {}

extension FavoriteHandler {

    func addToFavorite (movie: FavItem) {
        if let user = Auth.auth().currentUser {
            ApiService.shared.addToFavorite(userUID: user.uid, favItem: movie, completionHandler: { (_) in
                
                AppStore.shared.favMovies[movie.id] = movie
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NSNotification.Name.favUpdateNotificationKey), object: nil, userInfo: nil)
                
            }) { (msg) in
                self.showAlert("Error", msg)
            }
        } else {
            self.showAlert("Error", "You have to sign in")
        }
    }
    
    func removeFromFavourite (id: Int) {
        if let user = Auth.auth().currentUser {
            ApiService.shared.removeFromFavorite(userUID: user.uid, movieID: id, completionHandler: { (_) in
                AppStore.shared.favMovies[id] = nil
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NSNotification.Name.favUpdateNotificationKey), object: nil, userInfo: nil)
            }, complitionHandlerError: { (msg) in
                self.showAlert("Error", msg)
            })
        } else {
            self.showAlert("Error", "You have to sign in")
        }
    }
}


protocol FavoriteChangeResponser {
    func responseToChangeInFavs (notification: NSNotification)
}
