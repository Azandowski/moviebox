//
//  Movie.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//

import Foundation

enum ImageSize {
    case poster, wallpaper, bigPoster, smallWallpaper
    
    var path: String {
        switch self {
        case .poster:
            return "t/p/w220_and_h330_face"
        case .wallpaper:
            return "t/p/w1920_and_h800_multi_faces"
        case .bigPoster:
            return "t/p/w600_and_h900_bestv2"
        case .smallWallpaper:
            return "t/p/w227_and_h127_bestv2"
        }
    }
    
    func getURL (imagePath: String) -> String {
        return "https://\(ServiceBaseURL.imagesHost.value)/\(path)/\(imagePath)"
    }
}

protocol MediaData: Decodable {
    var id: Int { get set }
    var imageUrl: String? { get set }
    var bigImageUrl: String? { get set }
    var title: String { get set }
    var date: String? { get set }
    var genres: [Genre] { get set }
    var status: String? { get set }
    var initialLanguage: String? { get set }
    var overview: String { get set }
    var voteAverage: Double { get set }
    var character: String? { get set }
    var isFavorite: Bool { get set }
}

extension MediaData {
    func getMediaType () -> MediaType {
        if (self is Movie) {
            return .movie
        } else {
            return .tv
        }
    }
    
    func getFavItem () -> FavItem {
        return FavItem(id: id, imageUrl: imageUrl ?? "", title: title, mediaType: self.getMediaType().key)
    }
}


struct Movie: MediaData, Decodable {
    var id: Int
    var imageUrl: String? = ""
    var bigImageUrl: String? = ""
    var title: String
    var date: String?
    var genres: [Genre] = []
    var status: String? = "Выпущено"
    var initialLanguage: String? = "Казахский"
    var sbory: String? = "$359,900,000.00"
    var overview: String
    var voteAverage: Double
    var originalCountries: [Country]?
    var character: String?
    var isFavorite: Bool = false
    
    
    enum CodingKeys: CodingKey {
        case backdrop_path, genre_ids, id, original_language, poster_path, release_date, revenue, status, title, overview, vote_average, production_countries, character
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(Int.self, forKey: .id)
        self.title = (try? values.decode(String.self, forKey: .title)) ?? ""
        self.date = try? values.decode(String.self, forKey: .release_date)
        self.sbory = try? values.decode(String.self, forKey: .revenue)
        self.initialLanguage = try? values.decode(String.self, forKey: .original_language)
        self.overview = (try? values.decode(String.self, forKey: .overview)) ?? ""
        self.imageUrl = ImageSize.poster.getURL(imagePath: (try? values.decode(String.self, forKey: .poster_path)) ?? "")
        self.genres = ((try? values.decode([Int].self, forKey: .genre_ids)) ?? []).map {
            AppStore.shared.getGenre(from: $0)
        }
        self.character = try? values.decode(String.self, forKey: .character)
        
        self.voteAverage = try values.decode(Double.self, forKey: .vote_average)
        self.originalCountries = try? values.decode([Country].self, forKey: .production_countries)
        
        if let _imageBig = try? values.decode(String.self, forKey: .backdrop_path) {
            self.bigImageUrl = ImageSize.wallpaper.getURL(imagePath: _imageBig)
        }
    }
    
    static func getFakeMovies () -> [Movie] {
       return []
    }
}

struct TvShow: MediaData, Decodable {
    var id: Int
    var imageUrl: String? = ""
    var bigImageUrl: String? = ""
    var title: String
    var date: String?
    var genres: [Genre] = []
    var status: String?
    var initialLanguage: String?
    var overview: String
    var numberOfEpisodes: Int?
    var numberOfSeasons: Int?
    var voteAverage: Double
    var originalCoutries: [String]?
    var character: String?
    var isFavorite: Bool = false
    var seasons: [Season]?
    
    enum CodingKeys: CodingKey {
        case backdrop_path, genre_ids, id, original_language, poster_path, first_air_date,  status, name, overview, number_of_episodes, number_of_seasons, vote_average, origin_country, character, seasons
    }
    
    var hasFacts: Bool {
        return numberOfEpisodes != nil && numberOfSeasons != nil && originalCoutries != nil
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(Int.self, forKey: .id)
        self.title = (try? values.decode(String.self, forKey: .name)) ?? ""
        self.date = try? values.decode(String.self, forKey: .first_air_date)
        self.initialLanguage = try? values.decode(String.self, forKey: .original_language)
        self.overview = (try? values.decode(String.self, forKey: .overview)) ?? ""
        self.numberOfSeasons = try? values.decode(Int.self, forKey: .number_of_seasons)
        self.numberOfEpisodes = try? values.decode(Int.self, forKey: .number_of_episodes)
        self.character = try? values.decode(String.self, forKey: .character)
        
        self.imageUrl = ImageSize.poster.getURL(imagePath: (try? values.decode(String.self, forKey: .poster_path)) ?? "")
        self.genres = ((try? values.decode([Int].self, forKey: .genre_ids)) ?? []).map {
            AppStore.shared.getGenre(from: $0)
        }
        self.voteAverage = try values.decode(Double.self, forKey: .vote_average)
        self.originalCoutries = try? values.decode([String].self, forKey: .origin_country)
        
        if let _imageBig = try? values.decode(String.self, forKey: .backdrop_path) {
            self.bigImageUrl = ImageSize.wallpaper.getURL(imagePath: _imageBig)
        }
        
        self.seasons = try? values.decode([Season].self, forKey: .seasons)
    }
}

struct CastMoviesResponse<T: MediaData> : Decodable {
    let cast: [T]
}
