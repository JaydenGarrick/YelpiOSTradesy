//
//  YelpSearchPresenterTests.swift
//  YelpiOSTradesyTests
//
//  Created by Jayden Garrick on 8/7/20.
//  Copyright © 2020 Jayden Garrick. All rights reserved.
//

import XCTest
@testable import YelpiOSTradesy

class YelpSearchPresenterTests: XCTestCase {
    
    // Mocks
    var mockNetworkClient: NetworkMock!
    var mockView: MockView!
    var mockImageFetchable: MockImageManager!
    var mockLogger: MockLogger!
    var mockLocationManager: MockLocationManager!
    var mockCallHandler: MockCallHandler!
    
    // System Under Test
    var sut: YelpSearchPresenter!

    // MARK: - Setup/TearDown
    override func setUp() {
        mockNetworkClient = NetworkMock()
        mockView = MockView()
        mockImageFetchable = MockImageManager()
        mockLogger = MockLogger()
        mockLocationManager = MockLocationManager()
        mockCallHandler = MockCallHandler()
        
        sut = YelpSearchPresenter(
            mockView,
            networkManager: mockNetworkClient,
            imageManager: mockImageFetchable,
            logger: mockLogger,
            locationManager: mockLocationManager,
            callHandler: mockCallHandler
        )
    }
    
    override func tearDown() {
        mockNetworkClient = nil
        mockView = nil
        mockImageFetchable = nil
        mockLogger = nil
        mockLocationManager = nil
        mockCallHandler = nil
        
        sut = nil
    }
        
    // MARK: - TableView Helpers
    func test_defaultState_shouldShowHeader() {
        // Given
        mockNetworkClient.shouldCompleteWithEmptyBusinesses = true
        
        // When
        sut.search(with: "")
        
        // Then
        XCTAssertTrue(sut.shouldHaveHeader)
    }
    
    func test_defaultState_shouldNotShowHeader() {
        // Given
        mockNetworkClient.completeWithError = false
        mockNetworkClient.shouldCompleteWithEmptyBusinesses = false
        mockLocationManager.isCoordinateNil = false

        // When
        sut.search(with: "")
        
        // Then
        XCTAssertFalse(sut.shouldHaveHeader)
    }
    
    func test_businessForIndexPath_correctBusiness() {
        // Given
        mockNetworkClient.completeWithError = false
        mockNetworkClient.shouldCompleteWithEmptyBusinesses = false
        mockNetworkClient.firstBusiness = nil
        mockLocationManager.isCoordinateNil = false
        
        // When
        sut.search(with: "")
        
        // Then
        XCTAssertEqual(sut.businessFor(IndexPath(item: 0, section: 0)), mockNetworkClient.firstBusiness)
        XCTAssertNotNil(mockNetworkClient.firstBusiness)
    }

    // MARK: Search
    
    func test_searchSuccess_numberOfResults() {
        // Given
        mockNetworkClient.completeWithError = false
        mockNetworkClient.shouldCompleteWithEmptyBusinesses = false
        mockLocationManager.isCoordinateNil = false
        
        // When
        sut.search(with: "")
        
        // Then
        XCTAssertEqual(sut.numberOfRows, 20)
        XCTAssertFalse(mockNetworkClient.hasDecodingError)
    }
    
    func test_searchSuccess_reloadCalled() {
        // Given
        mockNetworkClient.completeWithError = false
        mockLocationManager.isCoordinateNil = false
        mockNetworkClient.hasDecodingError = false
        mockView.reloadWasCalled = false
        mockNetworkClient.shouldCompleteWithEmptyBusinesses = false

        // When
        sut.search(with: "")
        
        // Then
        XCTAssertTrue(mockView.reloadWasCalled)
        XCTAssertFalse(mockNetworkClient.hasDecodingError)
    }
    
    func test_searchFailed_errorLogged_forcedFailure() {
        // Given
        mockNetworkClient.completeWithError = true
        mockLocationManager.isCoordinateNil = false
        mockNetworkClient.shouldCompleteWithEmptyBusinesses = false
        
        // When
        sut.search(with: "")
        
        // Then
        let logExpectation = "Error fetching reviews with \(""): \(YelpNetworkError.networkError(.unknownError(message: "Forced Failure")).localizedDescription)"
        let errorExpectation = "Error Fetching: \(YelpNetworkError.networkError(.unknownError(message: "Forced Failure")))"
        
        XCTAssertTrue(mockLogger.eventLogged[logExpectation, default: false])
        XCTAssertTrue(mockView.errorsLogged[errorExpectation, default: false])
    }
    
    func test_searchFailed_errorLogged_noCoordinates() {
        // Given
        mockNetworkClient.completeWithError = false
        mockLocationManager.isCoordinateNil = true
        mockNetworkClient.shouldCompleteWithEmptyBusinesses = false

        // When
        sut.search(with: "")
        
        // Then
        let assumedMessage = "Unable to get location"
        XCTAssertTrue(mockView.errorsLogged[assumedMessage, default: false])
    }
    
    // ImageFetcher
    func test_badURL_fallBackImage() {
        // Given
        // Setting business imageURLString nil just in case we can't get one
        let businessWithBadimageURLString = Business(name: "", rating: 0, phoneNumber: "", imageURLString: nil, distance: 0, displayPhone: "", location: Location(address1: "", address2: "", address3: "", city: "", zipCode: "", country: "", state: ""), price: "")
        
        // When
        sut.getImageFor(businessWithBadimageURLString) { (fallbackImage) in
            // Then
            let expectedImage = UIImage(systemName: "photo.fill")!
            XCTAssertEqual(expectedImage, fallbackImage)
        }
    }
    
    func test_fetchImageFailure_logged() {
        // Given
        mockImageFetchable.completeWithError = true
        let dummyBusiness = Business(name: "", rating: 0, phoneNumber: "", imageURLString: "", distance: 0, displayPhone: "", location: Location(address1: "", address2: "", address3: "", city: "", zipCode: "", country: "", state: ""), price: "")

        
        // When
        sut.getImageFor(dummyBusiness) { (_) in }
        
        // Then
        let expectedLog = "Unable to fetch image: \(ImageError.unknownError("Forced Failure"))"
        XCTAssertTrue(mockLogger.eventLogged[expectedLog, default: false])
    }
    
    func test_fetchImageSuccess_success() {
        // Given
        mockImageFetchable.completeWithError = false
        let dummyBusiness = Business(name: "", rating: 0, phoneNumber: "", imageURLString: "", distance: 0, displayPhone: "", location: Location(address1: "", address2: "", address3: "", city: "", zipCode: "", country: "", state: ""), price: "")

        // When
        sut.getImageFor(dummyBusiness) { (returnedImage) in
            // Then
            let expectedImage = UIImage(systemName: "pencil")
            let fallbackImage = UIImage(systemName: "photo.fill")
            XCTAssertEqual(expectedImage, returnedImage)
            XCTAssertNotEqual(returnedImage, fallbackImage)
            
        }
    }
    
    func test_callSuccess_called() {
        // Given
        mockCallHandler.canOpenURL = true
        mockCallHandler.openCalled = false
        
        // When
        let number = "+18013553161"
        sut.callButtonTapped(number: number)
        
        // Then
        let expectedLog = "Attempting to call \(number)"
        XCTAssertTrue(mockLogger.eventLogged[expectedLog, default: false])
        XCTAssertTrue(mockCallHandler.openCalled)
    }
    
    func test_callSuccess_eventLogged() {
        // Given
        mockCallHandler.canOpenURL = false
        mockCallHandler.openCalled = false
        
        // When
        let number = "+18013553161"
        sut.callButtonTapped(number: number)
        
        // Then
        let expectedLog = "Couldn't call number \(number)"
        XCTAssertTrue(mockLogger.eventLogged[expectedLog, default: false])
        XCTAssertFalse(mockCallHandler.openCalled)

    }

}

