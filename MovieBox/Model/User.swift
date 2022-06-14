//
//  User.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//

import Foundation

class AppUser {
    var name: String = "User"
    var email: String = ""
    var loaded = false
    
    convenience init (name: String, email: String, loaded: Bool = true) {
        self.init()
        self.name = name
        self.email = email
        self.loaded = loaded
    }
}
