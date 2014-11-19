//
//  ForumCategoryRepositoryTests.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 06/11/14.
//  Copyright (c) 2014 Ivan Fabijanović. All rights reserved.
//

import UIKit
import XCTest

class ForumCategoryRepositoryTests: XCTestCase {

    // MARK: - Properties
    
    var bundle: NSBundle?
    var settings: Settings?
    var repo: ForumCategoryRepository?
    
    let timeout: NSTimeInterval = 3
    let headers = ["Content-Type": "text/html"]
    let passAll: OHHTTPStubsTestBlock = { (request) in
        return true
    }
    let defaultFailure: (NSError) -> Void = { (error) in
        XCTFail("Failed with error \(error)")
    }
    let defaultExpectationHandler: XCWaitCompletionHandler = { (error) in
        if error != nil {
            XCTFail("Failed with error \(error)")
        }
    }
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        
        self.bundle = NSBundle(forClass: SettingsTests.self)
        let path = self.bundle!.pathForResource("Settings", ofType: "plist")!
        self.settings = Settings(path: path)
        self.repo = ForumCategoryRepository(settings: self.settings!)
    }
    
    override func tearDown() {
        self.settings = nil
        self.repo = nil
        OHHTTPStubs.removeAllStubs()
        
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testGetForLanguage_RequestsCorrectUrl() {
        let requestedLanguage = ForumLanguage.English
        let expectedUrl = "\(self.settings!.forumDisplayUrl)?\(self.settings!.categoryQueryParam)=\(requestedLanguage.rawValue)"
        let expectation = expectationWithDescription("")
        
        let testBlock: OHHTTPStubsTestBlock = { (request) in
            return request.URL.absoluteString == expectedUrl
        }
        let responseBlock: OHHTTPStubsResponseBlock = { (request) in
            expectation.fulfill()
            return nil
        }
        
        OHHTTPStubs.stubRequestsPassingTest(testBlock, responseBlock)
        self.repo!.get(language: requestedLanguage, success: { (items) in }, failure: {(error) in })
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGetForCategory_RequestsCorrectUrl() {
        let requestedLanguage = ForumLanguage.English
        let category = ForumCategory(id: 17, title: "Test")
        let expectedUrl = "\(self.settings!.forumDisplayUrl)?\(self.settings!.categoryQueryParam)=\(category.id)"
        let expectation = expectationWithDescription("")
        
        let testBlock: OHHTTPStubsTestBlock = { (request) in
            return request.URL.absoluteString == expectedUrl
        }
        let responseBlock: OHHTTPStubsResponseBlock = { (request) in
            expectation.fulfill()
            return nil
        }
        
        OHHTTPStubs.stubRequestsPassingTest(testBlock, responseBlock)
        self.repo!.get(category: category, success: { (items) in }, failure: {(error) in })
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_EmptyHtml() {
        let expectation = expectationWithDescription("")
        
        OHHTTPStubs.stubRequestsPassingTest(self.passAll) { (request) in
            let path = self.bundle!.pathForResource("forum-category-empty", ofType: "html")
            return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: self.headers)
        }
        
        self.repo!.get(language: ForumLanguage.English, success: { (items) in
            expectation.fulfill()
            
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 0, "")
        }, failure: self.defaultFailure)
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }
    
    func testGet_SingleItem_Valid() {
        let expectation = expectationWithDescription("")
        
        OHHTTPStubs.stubRequestsPassingTest(self.passAll) { (request) in
            let path = self.bundle!.pathForResource("forum-category-single-valid", ofType: "html")
            return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: self.headers)
        }
        
        self.repo!.get(language: ForumLanguage.English, success: { (items) in
            expectation.fulfill()
            
            XCTAssertNotNil(items, "")
            XCTAssertEqual(items.count, 1, "")
            
            // Exception safeguard
            if items.count != 1 { return }
            
            XCTAssertEqual(items[0].id, 5, "")
            XCTAssertEqual(items[0].iconUrl!, "http://www.holonet.test/category_icon5.png", "")
            XCTAssertEqual(items[0].title, "Forum category 5", "")
            XCTAssertEqual(items[0].desc!, "Description 5", "")
            XCTAssertEqual(items[0].stats!, "5 Total Threads, 12 Total Posts", "")
            XCTAssertEqual(items[0].lastPost!, "Last Post: Thread 17", "")
            
        }, failure: self.defaultFailure)
        
        waitForExpectationsWithTimeout(self.timeout, handler: self.defaultExpectationHandler)
    }

}
