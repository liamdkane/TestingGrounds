@testable import TestingGrounds
import ReactiveSwift
import XCTest
import YYImage

class GiphyDataViewModelTest: XCTestCase {
    
    var sut: GiphyDataViewModel!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        self.sut = nil
    }

    func testEmptyState() throws {
        self.sut = GiphyDataViewModel(MockRequestable(info: nil, image: nil))
        XCTAssert(sut.isNotEmpty.value == false)
        XCTAssertNil(sut.searchTerm.value)
        XCTAssertEqual(sut!.gifCount, 0)
    }

    func testValidSearchResults() throws {
        
        let mockData = ImageData(url: URL(string: "www.google.com")!)
        let mockImagesData = ImagesData(fixed_width: mockData)
        let mockInfo = GiphyInfo(images: mockImagesData)
        let pagination = GiphyPageData(offset: 0, total_count: 0)
        let mockContainer = GiphyInfoContainer(data: [mockInfo], pagination: pagination)
        
        self.sut = GiphyDataViewModel(MockRequestable(info: mockContainer, image: nil))
        
        let expectation = XCTestExpectation(description: "will come back with results")
        let emptyExpect = XCTestExpectation(description: "will not trigger")
        emptyExpect.isInverted = true
        
        self.sut.searchResult
            .observeResult{ result in
            switch(result) {
            case let .success(result):
                switch(result) {
                case let .value(value):
                    XCTAssert(value.data[0].images.fixed_width.url == mockContainer.data[0].images.fixed_width.url)
                    expectation.fulfill()
                default:
                    break
                }
            default:
                XCTAssertFalse(true)
                emptyExpect.fulfill()
            }
        }
        
        let testSearchString = MutableProperty("hello")
        self.sut?.searchTerm <~ testSearchString
        
        wait(for: [expectation, emptyExpect], timeout: 1.0)
    }
    
    func testApiErrorSearchResults() throws {
        
        self.sut = GiphyDataViewModel(MockRequestable(info: nil, image: nil))
        
        let expectation = XCTestExpectation(description: "will come back with error")
        let emptyExpect = XCTestExpectation(description: "will not have anything yet")
        emptyExpect.isInverted = true
        
        self.sut.searchResult
            .observeResult{ result in
            switch(result) {
            case let .success(result):
                switch(result) {
                case .failed:
                    expectation.fulfill()
                default:
                    break
                }
            default:
                XCTAssertFalse(true)
                emptyExpect.fulfill()
            }
        }
        
        let testSearchString = MutableProperty("hello")
        self.sut?.searchTerm <~ testSearchString
        
        wait(for: [expectation, emptyExpect], timeout: 10.0)
    }

    
    func testCellModelCreation() {
        let mockData = ImageData(url: URL(string: "www.google.com")!)
        let mockImagesData = ImagesData(fixed_width: mockData)
        let mockInfo = GiphyInfo(images: mockImagesData)
        let pagination = GiphyPageData(offset: 0, total_count: 0)
        let mockContainer = GiphyInfoContainer(data: [mockInfo], pagination: pagination)
        
        self.sut = GiphyDataViewModel(MockRequestable(info: mockContainer, image: Constants.Ui.placeholderImage))

        let expectation = XCTestExpectation(description: "will have gifs to create a viewmodel with")
        
        XCTAssertTrue(self.sut.cellViewModels.isEmpty)
        XCTAssertEqual(self.sut.gifCount, 0)

        self.sut?.searchResult.observeResult{ [weak self] result in
            guard let self = self else { return }
            let testViewModel = self.sut.cellViewModel(for: 0)
            XCTAssertFalse(self.sut.cellViewModels.isEmpty)
            XCTAssertEqual(testViewModel.data.url, self.sut.cellViewModels["www.google.com"]!.data.url)
            expectation.fulfill()
        }
        let testSearchString = MutableProperty("hello")
        self.sut?.searchTerm <~ testSearchString
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testFetchNextPage() {
        let mockData = ImageData(url: URL(string: "www.google.com")!)
        let mockImagesData = ImagesData(fixed_width: mockData)
        let mockInfo = GiphyInfo(images: mockImagesData)
        let pagination = GiphyPageData(offset: 0, total_count: 2)
        let mockContainer = GiphyInfoContainer(data: [mockInfo], pagination: pagination)
        
        self.sut = GiphyDataViewModel(MockRequestable(info: mockContainer, image: nil))
        
        let expectation = XCTestExpectation(description: "will come back with results")
        let expectationPagination = XCTestExpectation(description: "will come back with results, pagination")
        let emptyExpect = XCTestExpectation(description: "will not trigger")
        emptyExpect.isInverted = true
        
        XCTAssertEqual(self.sut.gifCount, 0)
        
        self.sut.searchResult
            .observeResult{ result in
            switch(result) {
            case let .success(result):
                switch(result) {
                case let .value(value):
                    XCTAssert(value.data[0].images.fixed_width.url == mockContainer.data[0].images.fixed_width.url)
                    expectation.fulfill()
                    XCTAssertEqual(self.sut.gifCount, 1)
                    
                    self.sut.nextPage().start(on: QueueScheduler(qos: .background))
                        .observe(on: UIScheduler())
                        .startWithCompleted { [weak self] in
                            XCTAssertEqual(self?.sut.gifCount, 2)
                            expectationPagination.fulfill()
                        }
                    
                default:
                    break
                }
            default:
                XCTAssertFalse(true)
                emptyExpect.fulfill()
            }
        }
        

            
        
        let testSearchString = MutableProperty("hello")
        self.sut?.searchTerm <~ testSearchString
        
        wait(for: [expectation, emptyExpect, expectationPagination], timeout: 10.0)

    }
}
