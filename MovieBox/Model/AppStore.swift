//
//  AppStore.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//

import Foundation


enum MediaType: CaseIterable {
    case movie, tv
    
    var key: String {
        switch self {
        case .movie:
            return "movie"
        default:
            return "tv"
        }
    }
}

final class AppStore {
    static let shared = AppStore()
    
    var user: AppUser?
    
    var genres: [Genre] = []
    
    var favMovies: [Int: FavItem] = [:]
    
    
    func getGenre (from id: Int) -> Genre {
       if let genId = genres.first(where: { (genre) -> Bool in
            genre.id == id
       }) {
        return genId
       }
        return Genre(id: 0, name: "")
    }
}
