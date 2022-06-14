//
//  APIBase.swift
//  MovieBox
//
// Created by Azamat Bekbolat
//  Copyright © 2022 Azamat Bekbolat. All rights reserved.
//

import UIKit

extension URLSession {
    
    func request<T:Decodable> (
        for: T.Type = T.self,
        _ endpoint: Endpoint,
        returnJSON: Bool = false,
        completion: @escaping (Swift.Result<T, RequestError>) -> Void) {
        let request = createRequest(from: endpoint)
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let jsonData = data else {
                    completion(.failure(.noData))
                    return
                }
                
                guard error == nil else {
                    completion(.failure(.withParameter(message: error!.localizedDescription)))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let jsonResponse = try decoder.decode(T.self, from: jsonData)
                    completion(.success(jsonResponse))
                } catch let e {
                    print(e)
                    if let data = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? NSDictionary {
                        completion(.failure(.withDic(data: data)))
                    } else {
                        completion(.failure(.undefined))
                    }
                }
            }
        }
        
        dataTask.resume()
    }
    
    func requestJSON (
        _ endpoint: Endpoint,
        completion: @escaping (Swift.Result<[String: Any], RequestError>) -> Void)
    {
        let request = createRequest(from: endpoint)
        
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let jsonData = data else {
                    completion(.failure(.noData))
                    return
                }
                
                guard error == nil else {
                    completion(.failure(.withParameter(message: error!.localizedDescription)))
                    return
                }
                
                if let dataResult = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                    completion(.success(dataResult))
                } else {
                    completion(.failure(.undefined))
                }
            }
        }
        
        dataTask.resume()
    }
    
    func createRequest (from endpoint: Endpoint) -> URLRequest {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = Endpoint.baseURL
        urlComponents.path = endpoint.path
        urlComponents.queryItems = endpoint.queryItems
        let request = URLRequest(url: urlComponents.url!)
        return request
    }
    
    func toolchanger(tools: [String], startIndex: Int, target: String) -> Int {
        let count: Int = tools.count;
        let indexes: [Int] = getIndexes(tools: tools, target: target)
        var result: Int = -1
        
        
        for item in indexes {
            let minPartA = abs(startIndex - item)
            let minPartB = startIndex + (count - item + 1)
            let minStep = min(minPartA, minPartB)
                
            if (result == -1 || minStep < result) {
                result = minStep
            }
        }
        
        return result
    }
    
    func getIndexes (tools: [String], target: String) -> [Int] {
        var items: [Int] = []
        
        for i in 0...(tools.count - 1) {
            if (tools[i] == target) {
                items.append(i)
            }
        }
        
        return items
    }
}
