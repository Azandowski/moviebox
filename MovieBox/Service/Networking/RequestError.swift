//
//  RequestError.swift
//  MovieBox
//
// Created by Yelzhan Yerkebula
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//

import UIKit

enum RequestError: Error {
    case noData
    case withParameter (message: String)
    case withDic(data: NSDictionary)
    case undefined
}

extension RequestError {
    var errorMsg: String {
        switch self {
        case .noData:
            return "Не удалось найти данные"
        case .withParameter(message: let msg):
            return msg
        case .withDic(data: let data):
            return data["message"] as? String ?? "Ничего не найдено"
        case .undefined:
            return "Ничего не найдено"
        }
    }
}
