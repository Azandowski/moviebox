//
//  Episode.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//

import Foundation

struct Season: Decodable {
    var date: String
    var episodeCount: Int
    var id: Int
    var name: String
    var imageURL: String?
    
    enum CodingKeys: CodingKey {
        case air_date, episode_count, season_number, name, overview, poster_path
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        if let _imagePoster = try? values.decode(String.self, forKey: .poster_path) {
            self.imageURL = ImageSize.bigPoster.getURL(imagePath: _imagePoster)
        }
        
        self.name = try values.decode(String.self, forKey: .name)
        self.id = try values.decode(Int.self, forKey: .season_number)
        self.episodeCount = try values.decode(Int.self, forKey: .episode_count)
        self.date = try values.decode(String.self, forKey: .air_date)
    }
}

struct Episode: Decodable {
    var id: Int
    var overview: String
    var title: String
    var imageURL: String?
    var date: String
    var episodeNumber: Int
    
    enum CodingKeys: CodingKey {
        case id, air_date, episode_number, overview, name, still_path
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        if let _imagePoster = try? values.decode(String.self, forKey: .still_path) {
            self.imageURL = ImageSize.smallWallpaper.getURL(imagePath: _imagePoster)
        }
        
        self.title = try values.decode(String.self, forKey: .name)
        self.id = try values.decode(Int.self, forKey: .id)
        self.episodeNumber = try values.decode(Int.self, forKey: .episode_number)
        self.date = try values.decode(String.self, forKey: .air_date)
        self.overview = try values.decode(String.self, forKey: .overview)
    }
}


struct EpisodeResponse: Decodable {
    let episodes: [Episode]
}
