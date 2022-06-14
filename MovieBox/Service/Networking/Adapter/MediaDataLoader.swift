//
//  MediaDataLoader.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//

import Foundation
import SVProgressHUD

class MediaDataLoader <T: MediaData>: MediaDataLoaderService {
    
    var apiKey: String!
    
    func loadMovieShowBySection(
        mediaType: MediaType,
        section: MoviesSectionTypes,
        page: Int,
        complitionHandler: @escaping ((MediaDataResponse) -> Void),
        complitionHandlerError: @escaping ((String) -> Void)) {
        
        let endpoint: Endpoint = section.getEndpoint(apiKey: apiKey, language: "en", page: page)
        
        URLSession.shared.request(for: MediaDataResponseShape<T>.self, endpoint) { (result) in
            switch (result) {
            case .success(let moviesResponse):
                complitionHandler(moviesResponse.convertedToResponse())
            case .failure(let err):
                complitionHandlerError(err.errorMsg)
            }
        }
    }
    
    func loadRecommendationsMovie(
        mediaType: MediaType,
        id: Int,
        page: Int = 1,
        complitionHandler: @escaping ((MediaDataResponse)-> Void),
        complitionHandlerError: @escaping ((String) -> Void)
    ) {
        let endpoint = Endpoint.getRecommendedMovies(apiKey: apiKey, language: "en", id: id, page: page, mediaType: mediaType)
        
        URLSession.shared.request(for: MediaDataResponseShape<T>.self, endpoint) { (result) in
            switch (result) {
            case .success(let moviesResponse):
                complitionHandler(moviesResponse.convertedToResponse())
            case .failure(let err):
                complitionHandlerError(err.errorMsg)
            }
        }
    }
    
    func getDetail(
        mediaType: MediaType,
        id: Int,
        showLoading: Bool,
        completionHandler: @escaping ((MediaData) -> Void),
        complitionHandlerError: @escaping ((String) -> Void)
    ) {
        let endpoint = Endpoint.getDetails(apiKey: apiKey, id: id, language: "en", mediaType: mediaType)
        
        if (showLoading) { SVProgressHUD.show() }
        
        URLSession.shared.request(for: T.self, endpoint) { (result) in
            
            if (showLoading) { SVProgressHUD.dismiss() }
            
            switch (result) {
            case .success(let mediaDataRespnse):
                completionHandler(mediaDataRespnse)
            case .failure(let err):
                complitionHandlerError(err.errorMsg)
            }
        }
    }
    
    func getPersonMovies(
        mediaType: MediaType,
        id: Int,
        completionHandler: @escaping (([MediaData]) -> Void),
        complitionHandlerError: @escaping ((String) -> Void)
    ) {
        let endpoint = Endpoint.getPersonMovies(apiKey: apiKey, id: id, language: "en", mediaType: mediaType)
        
        URLSession.shared.request(for: CastMoviesResponse<T>.self, endpoint) { (result) in
            switch (result) {
            case .success(let mediaDataRespnse):
                completionHandler(mediaDataRespnse.cast)
            case .failure(let err):
                complitionHandlerError(err.errorMsg)
            }
        }
    }
    
    func getDiscoverMedia(
        mediaType: MediaType,
        completionHandler: @escaping ((MediaDataResponse) -> Void),
        complitionHandlerError: @escaping ((String) -> Void))
    {
        let endpoint = Endpoint.getDiscover(apiKey: apiKey, language: "en", mediaType: mediaType)
        
        URLSession.shared.request(for: MediaDataResponseShape<T>.self, endpoint) { (result) in
            switch (result) {
            case .success(let mediaDataRespnse):
                completionHandler(mediaDataRespnse.convertedToResponse())
            case .failure(let err):
                complitionHandlerError(err.errorMsg)
            }
        }
    }
}
