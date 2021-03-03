import Foundation
import ReactiveSwift

/*
 
 Just some boiler code I've gotten accostumed to having when working to help ensure the proper clean up of disposables, add uniform error handling, whatever else needs to be going into all the view models.
 
 */

open class BaseViewModel: NSObject {
    var disposable = CompositeDisposable()
    let isLoading = MutableProperty<Bool>(false)
    var errorObserver: Signal<APIError, Never>.Observer
    var errorSignal: Signal<APIError, Never>
    

    override required public init() {
        let (errorSignal, errorObserver) = Signal<APIError, Never>.pipe()
        self.errorSignal = errorSignal
        self.errorObserver = errorObserver
    }
    
    deinit {
        self.disposable.dispose()
    }

}

class RequestingViewModel: BaseViewModel {
    let requestable: Requestable
    
    required init(_ incomingRequestable: Requestable) {
        self.requestable = incomingRequestable
        super.init()
    }
    
    required public init() {
        fatalError("init() has not been implemented")
    }
}
