//
//  YelpSearchPresenter.swift
//  YelpiOSTradesy
//
//  Created by Jayden Garrick on 8/7/20.
//  Copyright © 2020 Jayden Garrick. All rights reserved.
//

import UIKit

// Methods to be able to mock UIApplication.shared dependency
protocol Callable {
    func canOpenURL(_ url: URL) -> Bool
    func open(_ url: URL)
}
extension UIApplication: Callable {
    func open(_ url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

// MARK: YelpSearchPresenter
final class YelpSearchPresenter {
    
    // MARK: - Properties
    
    // Dependencies
    let networkManager: YelpBusinessFetchable
    let imageManager: ImageFetchable
    let view: BusinessResultable
    let logger: Loggable
    let locationManager: LocationRequestable
    let callHandler: Callable
    
    // Source of Truth
    private var businesses: [Business] = []
    
    var shouldHaveHeader: Bool {
        return businesses.isEmpty
    }
    
    var numberOfRows: Int {
        return businesses.count
    }
    
    // MARK: - Initialization
    
    init(_ view: BusinessResultable,
         networkManager: YelpBusinessFetchable = YelpNetworkManager(),
         imageManager: ImageFetchable = ImageManager(),
         logger: Loggable = Logger(),
         locationManager: LocationRequestable = LocationManager(),
         callHandler: Callable = UIApplication.shared) {
        self.view = view
        self.networkManager = networkManager
        self.imageManager = imageManager
        self.logger = logger
        self.locationManager = locationManager
        self.callHandler = callHandler
    }
    
    // MARK: TableViewHelpers
    
    func businessFor(_ indexPath: IndexPath) -> Business {
        return businesses[indexPath.row]
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        let business = self.businessFor(indexPath)
        view.navigateToDetailViewController(with: business)
    }
    
    // MARK: - Actions
    
    func search(with searchTerm: String) {
        guard let coordinate = locationManager.getLocation() else {
            view.presentError("Unable to get location")
            return
        }
        networkManager.fetchYelpReviews(with: searchTerm,
                                        coordinate: coordinate) { [weak self](result) in
            switch result {
            case .success(let fetchedBusinesses):
                self?.businesses = fetchedBusinesses.businesses
                self?.view.reload()
            case .failure(let error):
                self?.logger.logEvent("Error fetching reviews with \(searchTerm): \(error.localizedDescription)")
                self?.view.presentError("Error Fetching: \(error)")
            }
        }
    }
    
    func getImageFor(_ business: Business, completion: @escaping (UIImage) -> Void) {
        let fallbackImage = UIImage(systemName: "photo.fill")! // Force unwrapping bad
        guard let urlString = business.imageURLString else {
            completion(fallbackImage)
            return
        }
        imageManager.fetchImage(with: urlString) { (result) in
            switch result {
            case .success(let image):
                completion(image)
                return
            case .failure(let error):
                self.logger.logEvent("Unable to fetch image: \(error)")
                completion(fallbackImage)
                return
            }
        }
    }
    
}

// MARK: - BusinessTableViewCellDelegate
extension YelpSearchPresenter: BusinessTableViewCellDelegate {
    func callButtonTapped(number: String) {
        logger.logEvent("Attempting to call \(number)")
        if let url = URL(string: "tel://\(number)"), callHandler.canOpenURL(url) {
            callHandler.open(url)
        } else {
            logger.logEvent("Couldn't call number \(number)")
        }
    }
}
