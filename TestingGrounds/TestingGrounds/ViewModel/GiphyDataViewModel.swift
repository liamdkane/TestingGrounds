import Foundation
import ReactiveSwift

fileprivate typealias PagingData = (term: String, total: Int)

class GiphyDataViewModel: RequestingViewModel {
    
    private(set) var cellViewModels: [String: GiphyCellViewModel] = [:]
    private var gifs = [GiphyInfo]()
    private var pagingData: PagingData? = nil
    
    let isNotEmpty = MutableProperty<Bool>(false)
    let searchTerm = MutableProperty<String?>(nil)
    var gifCount: Int {
        return self.gifs.count
    }
    
    required init(_ incomingRequestable: Requestable) {
        super.init(incomingRequestable)
    }
    
    required public init() {
        fatalError("init() has not been implemented")
    }
    
    /**
     `Signal` mapping the `materialized()` `search()` function with the `searchTerm` values to maintain a stream of results
     */
    private(set) lazy var searchResult = searchTerm.signal
        .debounce(Constants.Reactive.debounce, on: QueueScheduler.main)
        .skipNil()
        .skipRepeats()
        .filter { !$0.isEmpty }
        .flatMap(.latest, { [weak self] searchTerm in
            self?.initialSearch(searchTerm)
                .materialize() ?? SignalProducer.empty
        })
    
    
    //MARK: API Calls
    /**
     Performs a request and send the next `GiphyInfoContainer` or `APIError` via `Signal Producer`. Clears the local "cache" and updates `gifs`  and`isNotEmpty` with the incoming data, updates the `pagingData`
     
     - parameters:
     - text: `String` to send to the API for associated results
     
     - Returns: `SignalProducer` containing either `GiphyInfoContainer` or `APIError`
     */
    
    private func initialSearch(_ text: String) -> SignalProducer<GiphyInfoContainer, APIError> {
        return fetchWithErrorHandling(term: text).on( value: { [weak self] incomingGifs in
                    ///Reset "cache"
                    self?.cellViewModels = [:]
                    self?.gifs = incomingGifs.data
                    self?.isNotEmpty.value = incomingGifs.data.count > 0
                    
                    ///Reset paging variables
            
                    self?.pagingData = PagingData(text, incomingGifs.pagination.total_count)
                })
    }
    
    /**
     Performs a request using `Request` and send the next `GiphyInfoContainer` or `APIError` via `Signal Producer`. Clears the local "cache" and updates `gifs`  and`isNotEmpty` with the incoming data.
     
     - Returns: `SignalProducer` containing either `GiphyInfoContainer` or `APIError` with next page information

     */
    func nextPage() -> SignalProducer<GiphyInfoContainer, APIError> {
        ///This is to ensure that we have an active search and we have not hit the end of the available data.
        guard let term = self.pagingData?.term,
              let total = self.pagingData?.total,
              self.gifCount < total else {
            return SignalProducer.empty
        }
        
        return fetchWithErrorHandling(term: term, offset: gifCount)
            .on(value: { [weak self] incomingData in
                    self?.gifs.append(contentsOf: incomingData.data)
                })
    }
    
    
    /**
     Performs a request using `Request` and send the next `GiphyInfoContainer` or `APIError` via `Signal Producer`. Tacks on errorHandling to ensure all calls are handled the same way.
     
     - Returns: `SignalProducer` containing either `GiphyInfoContainer` or `APIError` with next page information

     */
    private func fetchWithErrorHandling(term: String, offset: Int = 0) -> SignalProducer<GiphyInfoContainer, APIError> {
        return self.requestable.fetchGiphyInfo(.fetchQuery(query: term, offset: offset)).on(
            failed: { [weak self] error in
                self?.errorObserver.send(value: error)
            })
    }
        
    //MARK: CellViewModel Creation
    /**
     Read the local "cache" for a `GiphyCellViewModel` and return it, if it is not found, create one. Triggers API Call.
     
     - parameters:
     - index: `indexPath.row` from `CollectionViewDataSource` for the cell requesting the viewModel
     
     - Returns: `GiphyCellViewModel` from stored dictionary or a brand new one.
     */
    func cellViewModel(for index: Int) -> GiphyCellViewModel {
        
        let gif = self.gifs[index].images.fixed_width
        let key = gif.url.absoluteString
        
        if let viewModel = self.cellViewModels[key] {
            return viewModel
        }
        
        let viewModel = GiphyCellViewModel(with: gif, requestable)
        self.cellViewModels[key] = viewModel
        return viewModel
    }
}
