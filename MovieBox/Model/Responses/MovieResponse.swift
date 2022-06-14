//
//  MovieResponse.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//

import Foundation

struct MediaDataResponseShape<T: MediaData>: Decodable {
    var results: [T]
    
    var total_pages: Int
    
    func convertedToResponse () -> MediaDataResponse {
        return MediaDataResponse(
            results: results,
            total_pages: total_pages
        )
    }
}

struct MediaDataResponse {
    
    var results: [MediaData]
    
    var total_pages: Int
}


