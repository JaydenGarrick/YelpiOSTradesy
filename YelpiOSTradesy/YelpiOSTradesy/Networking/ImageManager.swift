//
//  ImageManager.swift
//  YelpiOSTradesy
//
//  Created by Jayden Garrick on 8/7/20.
//  Copyright © 2020 Jayden Garrick. All rights reserved.
//

import UIKit

enum ImageError: Error {
    case unableToCreateURL
    case unknownError(String)
    case noData
    case unableToCreateImageFromData
    case unableToRetainSelf
}

protocol ImageFetchable {
    func fetchImage(with urlString: String,
                    completion: @escaping (Result<UIImage,ImageError>) -> Void)
}

class ImageManager: ImageFetchable {
    
    // MARK: - Properties
    let urlSession: URLSessionRetrievable
    
    // TODO: - Expand and create custom cache
    let imageCache = NSCache<NSString,UIImage>()
    
    // MARK: - Initialization
    init(_ urlSession: URLSessionRetrievable = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    // MARK: - Methods
    func fetchImage(with urlString: String,
                    completion: @escaping (Result<UIImage,ImageError>) -> Void) {
        // Check to see if we've cached the image
        if let image = imageCache.object(forKey: NSString(string: urlString)) {
            completion(.success(image))
            return
        }
        
        guard let url = URL(string: urlString) else {
            completion(.failure(.unableToCreateURL))
            return
        }
        
        // If it isn't in the cache, fetch it
        urlSession.dataTask(with: URLRequest(url: url)) { [weak self] (data, _, error) in
            guard let self = self else {
                completion(.failure(.unableToRetainSelf))
                return
            }
            if let error = error {
                completion(.failure(.unknownError(error.localizedDescription)))
                return
            }
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            guard let image = UIImage(data: data) else {
                completion(.failure(.unableToCreateImageFromData))
                return
            }
            // Once we got the image successfully, store it in the cache
            self.imageCache.setObject(image, forKey: NSString(string: urlString))
            completion(.success(image))
        }.resume()
    }
}
