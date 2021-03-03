@testable import TestingGrounds
import ReactiveSwift
import XCTest
import YYImage


class GiphyCellViewModelTest: XCTestCase {
    
    var sut: GiphyCellViewModel? = nil

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testNilImage() throws {
        let mockData = ImageData(url: URL(string:"www.google.com")!)
        sut = GiphyCellViewModel(with: mockData, MockRequestable(info: nil, image: nil))
        
        let isLoadingExpectation = XCTestExpectation(description: "starts loading")
        let isDoneLoadingExpectation = XCTestExpectation(description: "stops loading")
        
        sut?.image.producer.skip(first: 1).startWithValues{ image in
            XCTAssertEqual(image, Constants.Ui.placeholderImage)
        }
        
        sut?.isLoading.producer.startWithValues { value in
            if value {
                isLoadingExpectation.fulfill()
            } else {
                isDoneLoadingExpectation.fulfill()
            }
        }
        
        wait(for: [isLoadingExpectation, isDoneLoadingExpectation], timeout: 10.0, enforceOrder: true)
    }

    func testValidImage() throws {
        let mockData = ImageData(url: URL(string:"www.google.com")!)
        let mockImage = UIImage(named: "testImage")
        sut = GiphyCellViewModel(with: mockData, MockRequestable(info: nil, image: mockImage))
        
        let isLoadingExpectation = XCTestExpectation(description: "starts loading")
        let isDoneLoadingExpectation = XCTestExpectation(description: "stops loading")
        
        sut?.image.producer.skip(first: 1).startWithValues{ image in
            XCTAssertEqual(image, mockImage)
        }
        
        sut?.isLoading.producer.startWithValues { value in
            if value {
                isLoadingExpectation.fulfill()
            } else {
                isDoneLoadingExpectation.fulfill()
            }
        }
        
        wait(for: [isLoadingExpectation, isDoneLoadingExpectation], timeout: 10.0, enforceOrder: true)
    }
}
