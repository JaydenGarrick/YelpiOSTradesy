//
//  YelpNetworkManager.swift
//  YelpiOSTradesy
//
//  Created by Jayden Garrick on 8/7/20.
//  Copyright © 2020 Jayden Garrick. All rights reserved.
//

import Foundation

enum YelpNetworkError: Error {
    case unableToCreateURL
    case networkError(NetworkError)
}

protocol YelpBusinessFetchable {
    func fetchYelpReviews(with searchTerm: String,
                          coordinate: Coordinate,
                          completion: @escaping (Result<YelpTopLevelJSON, YelpNetworkError>) -> Void)
}

class YelpNetworkManager: YelpBusinessFetchable {
    
    enum Constants {
        static let baseURLString = "https://api.yelp.com/v3/businesses/search"
        static let authorization = "Authorization"
        
        // Note: Typically I'd put auth keys in a .plist and add it to a gitignore
        static let bearer = "Bearer nNsuz-NQ6ae_UaMlsEyyNL2_oQqauUdL-PFx7ReIeeEwjeWvQyKuKJRIzm8V5S0p5dZEl-sXBSxBmpv8j5H4zeRZJ4bDrT7M7A6i1d2mc4Ak-HTFuntR2feOmOsmX3Yx"
        static let clientID = "0lWtt5EMEFI4NlpNTFuJQA"
    }
    
    var networkClient: NetworkRequestRetrievable
    
    init(_ networkClient: NetworkRequestRetrievable = NetworkManager()) {
        self.networkClient = networkClient
    }
    
    func fetchYelpReviews(with searchTerm: String,
                          coordinate: Coordinate,
                          completion: @escaping (Result<YelpTopLevelJSON, YelpNetworkError>) -> Void) {
        guard var url = URL(string: YelpNetworkManager.Constants.baseURLString) else {
            completion(.failure(.unableToCreateURL))
            return
        }
        url.addQueryParameter("term", value: searchTerm)
        url.addQueryParameter("latitude", value: coordinate.latitude)
        url.addQueryParameter("longitude", value: coordinate.longitude)
        
        let headers = [
            Constants.authorization: Constants.bearer
        ]
        
        networkClient.jsonRequest(
            url: url,
            type: YelpTopLevelJSON.self,
            httpMethod: .get,
            headers: headers
        ) { (result) in
            switch result {
            case .success(let businesses):
                completion(.success(businesses))
            case .failure(let networkError):
                completion(.failure(.networkError(networkError)))
            }
        }
    }
}


extension URL {
    mutating func addQueryParameter(_ queryItem: String, value: String) {
        guard var urlComponents = URLComponents(string: absoluteString) else { return }
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []
        let queryItem = URLQueryItem(name: queryItem, value: value)
        queryItems.append(queryItem)
        urlComponents.queryItems = queryItems
        self = urlComponents.url!
    }
}
