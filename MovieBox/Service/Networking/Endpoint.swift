//
//  Endpoints.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//

import UIKit

enum ServiceBaseURL {
    case main, imagesHost
    
    var value: String {
        switch self {
        case .main:
            return "api.themoviedb.org"
        case .imagesHost:
            return "image.tmdb.org"
        }
    }
}

enum Endpoint {
    case getMovieGenres (apiKey: String, language: String)
    case getShowGenres (apiKey: String, language: String)
    
    // MARK; - List of Movies
    
    case getTopRated (apiKey: String, language: String, page: Int, mediaType: MediaType)
    case getUpcomingMovies (apiKey: String, language: String, page: Int, mediaType: MediaType)
    case getPopular (apiKey: String, language: String, page: Int, mediaType: MediaType)
    case getRecommendedMovies (apiKey: String, language: String, id: Int, page: Int, mediaType: MediaType)
    case getNowPlaying (apiKey: String, language: String, page: Int)
    case getAiringToday (apiKey: String, language: String, page: Int)
    case getMovieCast (apiKey: String, movieID: Int, language: String, mediaType: MediaType)
    case getDetails (apiKey: String, id: Int, language: String, mediaType: MediaType)
    case getImages (apiKey: String, id: Int, language: String, mediaType: MediaType)
    case getPersonMovies (apiKey: String, id: Int, language: String, mediaType: MediaType)
    case getPersonDetails (apiKey: String, id: Int, language: String)
    case getDiscover (apiKey: String, language: String, mediaType: MediaType)
    case searchMedia (apiKey: String, language: String, query: String)
    case getPersonPopular (apiKey: String, language: String, page: Int)
    
    case getEpisodes (apiKey: String, tvID: Int, seasonID: Int, language: String)
    
    static let baseURL: String = ServiceBaseURL.main.value
    
    var path: String {
        switch self {
        case .getShowGenres(_, _):
            return "/3/genre/tv/list"
        case .getMovieGenres(_, _):
            return "/3/genre/movie/list"
        case .getTopRated(_, _, _, mediaType: let type):
            return "/3/\(type.key)/top_rated"
        case .getUpcomingMovies(_, _, _, mediaType: let type):
            return "/3/\(type.key)/upcoming"
        case .getNowPlaying(_, _, _):
            return "/3/movie/now_playing"
        case .getPopular(_, _, _, mediaType: let type):
            return "/3/\(type.key)/popular"
        case .getAiringToday(_, _, _):
            return "/3/tv/airing_today"
        case .getRecommendedMovies(_, _, id: let id, _, mediaType: let type):
            return "/3/\(type.key)/\(id)/recommendations"
        case .getMovieCast(_, movieID: let id, _, mediaType: let type):
            return "/3/\(type.key)/\(id)/credits"
        case .getDetails(_, id: let id, _, mediaType: let type):
            return "/3/\(type.key)/\(id)"
        case .getImages(apiKey: _, id: let id, _, mediaType: let type):
            return "/3/\(type.key)/\(id)/images"
        case .getPersonMovies(_, id: let id, _, mediaType: let type):
            return "/3/person/\(id)/\(type.key)_credits"
        case .getPersonDetails(_, id: let id, _):
            return "/3/person/\(id)"
        case .getDiscover(_, _, mediaType: let type):
            return "/3/discover/\(type.key)"
        case .searchMedia(_, _, _):
            return "/3/search/multi"
        case.getPersonPopular(_, _, _):
            return "/3/person/popular"
        case .getEpisodes(_, tvID: let tvID, seasonID: let seasonID, _):
            return "/3/tv/\(tvID)/season/\(seasonID)"
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .getTopRated(apiKey: let key, language: let language, let page, _),
             .getUpcomingMovies(apiKey: let key, language: let language, let page, _),
             .getPopular(apiKey: let key, language: let language, let page, _),
             .getRecommendedMovies(apiKey: let key, language: let language, _, page: let page, _),
             .getNowPlaying(apiKey: let key, language: let language, page: let page),
             .getAiringToday(apiKey: let key, language: let language, page: let page),
             .getPersonPopular(apiKey: let key, language: let language, page: let page):
            return [
                URLQueryItem(name: "api_key", value: key),
                URLQueryItem(name: "language", value: language),
                URLQueryItem(name: "page", value: "\(page)")
            ]
        case .getMovieCast(apiKey: let key, _, language: let language, _),
             .getDetails(apiKey: let key, _, language: let language, mediaType: _),
             .getShowGenres(apiKey: let key, language: let language),
             .getMovieGenres(apiKey: let key, language: let language),
             .getImages(apiKey: let key, _, language: let language, mediaType: _),
             .getPersonMovies(apiKey: let key, _, language: let language, _),
             .getPersonDetails(apiKey: let key, _, language: let language),
             .getDiscover(apiKey: let key, language: let language, _),
             .getEpisodes (apiKey: let key, _, _, language: let language):
            return [
                URLQueryItem(name: "api_key", value: key),
                URLQueryItem(name: "language", value: language)
            ]
        case .searchMedia(apiKey: let key, language: let language, query: let query):
            return [
                URLQueryItem(name: "api_key", value: key),
                URLQueryItem(name: "language", value: language),
                URLQueryItem(name: "query", value: query)
            ]
        }
    }
}
