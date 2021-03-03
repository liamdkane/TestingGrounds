@testable import TestingGrounds
import ReactiveSwift
import XCTest
import YYImage

class RequestTest: XCTestCase {
    
    var sut: Request? = nil
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        self.sut = nil
    }
    
    func testValidFetchGiphyInfo() throws {
        let data = try MockNetworkable.mockJson("response")
        let mockNetwork = MockNetworkable(data: data, error: nil)
        
        let expectedResults = try JSONDecoder().decode(GiphyInfoContainer.self, from: data)
        let expectation = XCTestExpectation(description: "will retrieve data and decode it into expected object")
        
        self.sut = Request(mockNetwork)
        
        self.sut?.fetchGiphyInfo(GiphyRequest.fetchQuery(query: "hello")).startWithResult({ result in
            switch result {
            case let .success(testInfo):
                zip(testInfo.data, expectedResults.data).forEach { (testResult, expectedResult) in
                    XCTAssertEqual(testResult.images.fixed_width.url, expectedResult.images.fixed_width.url)
                }
                expectation.fulfill()
            case .failure:
                XCTAssertTrue(false)
            }
        })
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testInvalidFetchGiphyInfo() throws {
        let mockNetwork = MockNetworkable(data: nil, error: APIError.networkTimedOut)
        
        self.sut = Request(mockNetwork)
        
        let expectation = XCTestExpectation(description: "will receive a `networkTimedOut` error")
        
        self.sut?.fetchGiphyInfo(GiphyRequest.fetchQuery(query: "hello")).startWithResult({ result in
            switch result {
            case .success:
                XCTAssertTrue(false)
            case let .failure(error):
                switch error {
                case .networkTimedOut:
                    expectation.fulfill()
                default:
                    break
                }
            }
        })
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testInvalidJson() throws {
        let data = try MockNetworkable.mockJson("invalidresponse")
        let mockNetwork = MockNetworkable(data: data, error: nil)
        
        let expectation = XCTestExpectation(description: "will retrieve data and fail to decode it into expected object")
        
        self.sut = Request(mockNetwork)
        
        self.sut?.fetchGiphyInfo(GiphyRequest.fetchQuery(query: "hello")).startWithResult({ result in
            switch result {
            case .success:
                XCTAssertTrue(false)
            case let .failure(error):
                switch error {
                case .jsonDecodeError:
                    expectation.fulfill()
                default:
                    break
                }
            }
        })
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testValidImageDownload() throws {
        let expectedResult = UIImage(named: "testImage")!
        let mockImageData = expectedResult.pngData()
        let mockNetwork = MockNetworkable(data: mockImageData, error: nil)

        let expectation = XCTestExpectation(description: "will retrieve the image and make it a `YYImage` object")
        
        self.sut = Request(mockNetwork)
        
        self.sut?.downloadImage(URL(string:"www.google.com")!).startWithResult({ result in
            switch result {
            case let .success(testResult):
                XCTAssertTrue(testResult is YYImage)
                expectation.fulfill()
            case .failure:
                XCTAssertTrue(false)
            }
        })
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testInvalidImageDownload() throws {
        let mockNetwork = MockNetworkable(data: nil, error: APIError.unknown)

        let expectation = XCTestExpectation(description: "will retrieve data and decode it into expected object")
        
        self.sut = Request(mockNetwork)
        
        self.sut?.downloadImage(URL(string:"www.google.com")!).startWithResult({ result in
            switch result {
            case .success:
                XCTAssertTrue(false)
            case let .failure(error):
                switch error {
                case .unknown:
                    expectation.fulfill()
                default:
                    break
                }
            }
        })
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testInvalidDataImageDownload() throws {
        let mockNetwork = MockNetworkable(data: Data(), error: nil)

        let expectation = XCTestExpectation(description: "will retrieve the image and fail to make it a YYImage and fall back to placeholder")
        
        self.sut = Request(mockNetwork)
        
        self.sut?.downloadImage(URL(string:"www.google.com")!).startWithResult({ result in
            switch result {
            case let .success(testResult):
                XCTAssertEqual(testResult, Constants.Ui.placeholderImage)
                expectation.fulfill()
            case .failure:
                XCTAssertTrue(false)
            }
        })
        
        wait(for: [expectation], timeout: 10)
    }
}
