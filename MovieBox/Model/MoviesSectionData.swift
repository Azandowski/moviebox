//
//  MoviesSectionData.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//

import Foundation

struct DataSection<T> {
    var data: [T]
    var page: Int = 1
    var isLoading = false
    var isFinished = false
    
    
    mutating func next (totalPages: Int) {
        if (totalPages > page) {
            page += 1
            isFinished = false
        } else {
            isFinished = true
        }
    }
}

enum MoviesSectionTypes: CaseIterable {
    case topRated, upcoming, topRatedTv, popular, popularTv, nowPlaying, airingToday
    
    var title: String {
        switch self {
        case .topRated:
            return "Top Rated"
        case .upcoming:
            return "Upcoming"
        case .topRatedTv:
            return "Top Rated TV"
        case .popular:
            return "Popular"
        case .popularTv:
            return "Popular TV"
        case .nowPlaying:
            return "Now playing"
        case .airingToday:
            return "Airing Today (TV)"
        }
    }
    
    var mediaType: MediaType {
        switch self {
        case .topRatedTv, .popularTv, .airingToday:
            return .tv
        case .upcoming, .topRated, .popular, .nowPlaying:
            return .movie
        }
    }
    
    var isMovie: Bool {
        return mediaType == .movie
    }
    
    func getEndpoint (apiKey: String, language: String, page: Int) -> Endpoint {
        switch self {
        case .topRated, .topRatedTv:
            return Endpoint.getTopRated(apiKey: apiKey, language: language, page: page, mediaType: mediaType)
        case .upcoming:
            return Endpoint.getUpcomingMovies(apiKey: apiKey, language: language, page: page, mediaType: mediaType)
        case .popular, .popularTv:
            return Endpoint.getPopular(apiKey: apiKey, language: language, page: page, mediaType: mediaType)
        case .nowPlaying:
            return Endpoint.getNowPlaying(apiKey: apiKey, language: language, page: page)
        case .airingToday:
            return Endpoint.getAiringToday(apiKey: apiKey, language: language, page: page)
        }
    }
}
