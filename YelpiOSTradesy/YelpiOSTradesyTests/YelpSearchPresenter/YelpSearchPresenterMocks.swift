//
//  YelpSearchPresenterMocks.swift
//  YelpiOSTradesyTests
//
//  Created by Jayden Garrick on 8/7/20.
//  Copyright © 2020 Jayden Garrick. All rights reserved.
//

import XCTest
@testable import YelpiOSTradesy

extension YelpSearchPresenterTests {
    // MARK: - YelpBusinessFetchable
    class NetworkMock: YelpBusinessFetchable {
        var completeWithError: Bool = false
        var hasDecodingError: Bool = false
        var shouldCompleteWithEmptyBusinesses = false
        var firstBusiness: Business? = nil
        
        func fetchYelpReviews(with searchTerm: String, coordinate: Coordinate, completion: @escaping (Result<YelpTopLevelJSON, YelpNetworkError>) -> Void) {
            if shouldCompleteWithEmptyBusinesses {
                completion(.success(YelpTopLevelJSON(businesses: [])))
                return
            }
            
            if completeWithError {
                completion(.failure(YelpNetworkError.networkError(.unknownError(message: "Forced Failure"))))
            } else {
                let decoder = JSONDecoder()
                do {
                    let bundle = Bundle(for: YelpSearchPresenterTests.self)
                    if let path = bundle.path(forResource: "TestData", ofType: "json"), let data = try String(contentsOfFile: path).data(using: .utf8) {
                        let topLevelJSON = try decoder.decode(YelpTopLevelJSON.self, from: data)
                        firstBusiness = topLevelJSON.businesses.first // Set the first business so we can test businessFor(indexPath:)
                        completion(.success(topLevelJSON))
                    }
                } catch {
                    hasDecodingError = true
                    completion(.failure(.networkError(.unableToDecode)))
                }
            }
        }
    }
    
    // MARK: - BusinessResultable
    class MockView: BusinessResultable {
        var reloadWasCalled: Bool = false
        var errorsLogged: [String: Bool] = [:]
        
        func navigateToDetailViewController(with business: Business) {
            // TODO: - Add Tests for this last minute addition
        }

        func reload() {
            reloadWasCalled = true
        }
        
        func presentError(_ message: String) {
            errorsLogged[message] = true
        }
    }
    
    // MARK: - ImageFetchable
    class MockImageManager: ImageFetchable {
        var completeWithError: Bool = false
        var unableToDecodeImage: Bool = false
        
        func fetchImage(with urlString: String,
                        completion: @escaping (Result<UIImage, ImageError>) -> Void)
        {
            if completeWithError {
                completion(.failure(ImageError.unknownError("Forced Failure")))
            } else {
                guard let image = UIImage(systemName: "pencil") else {
                    unableToDecodeImage = true
                    completion(.failure(.unknownError("Unable to find pencil image")))
                    return
                }
                completion(.success(image))
            }
        }
    }
    
    // MARK: - Logger
    class MockLogger: Loggable {
        var eventLogged: [String: Bool] = [:]
        
        func logEvent(_ event: String) {
            eventLogged[event] = true
        }
    }
    
    // MARK: - LocationRequestable
    class MockLocationManager: LocationRequestable {
        var isCoordinateNil: Bool = false
        
        var coordinate: Coordinate?
        
        func requestLocation() {
            
        }
        
        func getLocation() -> Coordinate? {
            return isCoordinateNil ? nil : Coordinate(latitude: "0", longitude: "0")
        }
    }
    
    // MARK: - Callable
    class MockCallHandler: Callable {
        var canOpenURL: Bool = false
        var openCalled: Bool = false
        
        func canOpenURL(_ url: URL) -> Bool {
            return canOpenURL
        }
        
        func open(_ url: URL) {
            openCalled = true
        }
    }
    
}
