import Alamofire
@testable import TestingGrounds
import ReactiveSwift
import XCTest

class NetworkTest: XCTestCase {
    
    struct Helper {
        static func make(result: Result<Data?, AFError>) -> AFDataResponse<Data?> {
            AFDataResponse<Data?>(request: nil, response: nil, data: nil, metrics: nil, serializationDuration: 10, result: result)
        }
    }
    
    var sut: Network? = nil
    var mockResponse: AFDataResponse<Data?>!
    var testProducer: SignalProducer<Data, APIError>!
    
    override func setUpWithError() throws {
        self.testProducer = SignalProducer<Data, APIError> { [weak self] observer, _ in
            guard let self = self else {
                observer.sendInterrupted()
                return
            }
            self.sut?.handleResponse(response: self.mockResponse, observer: observer)
        }
    }
    
    override func tearDownWithError() throws {
        self.sut = nil
        self.mockResponse = nil
        self.testProducer = nil
    }
    
    func testHandleResponseSuccess() throws {
        sut = Network()
        
        let expectedData = try MockNetworkable.mockJson("response")
        self.mockResponse = Helper.make(result: .success(expectedData))

        let expectation = XCTestExpectation(description: "response will be handled successfully and return data")
                
        testProducer.startWithResult { result in
            switch result {
            case let .success(responseData):
                XCTAssertEqual(responseData, expectedData)
                expectation.fulfill()
            case .failure:
                XCTAssertFalse(false, "Unexpected Failure")
            }
        }

        wait(for: [expectation], timeout: 10)
    }
    
    func testHandleResponseTimedOut() throws {
        sut = Network()
        
        mockResponse = Helper.make(result: .failure(.sessionTaskFailed(error: URLError(.timedOut))))
        
        let expectation = XCTestExpectation(description: "response will be fail with networkTimeOut")
                
        testProducer.startWithResult { result in
            switch result {
            case .success:
                XCTAssertFalse(false, "Unexpected Success")
            case let .failure(error):
                switch error {
                case .networkTimedOut:
                    expectation.fulfill()
                default:
                    break
                }
            }
        }

        wait(for: [expectation], timeout: 10)
    }
    
    
    func testHandleResponseUnknown() throws {
        sut = Network()
        
        mockResponse = Helper.make(result: .failure(.sessionTaskFailed(error: URLError(.badURL))))
        
        let expectation = XCTestExpectation(description: "response will be fail with unknown")
        
        testProducer.startWithResult { result in
            switch result {
            case .success:
                XCTAssertFalse(false, "Unexpected Success")
            case let .failure(error):
                switch error {
                case .unknown:
                    expectation.fulfill()
                default:
                    break
                }
            }
        }

        wait(for: [expectation], timeout: 10)
    }
}
