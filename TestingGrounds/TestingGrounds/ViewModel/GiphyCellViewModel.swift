import ReactiveSwift
import UIKit

class GiphyCellViewModel: RequestingViewModel {
    
    let image = MutableProperty<UIImage?>(nil)
    private(set) var data: ImageData
    
    /**
     Initialise with imageData and call for image on background thread.
     
     -parameters:
     - incomingImageData: `ImageData` to be managed by the view model.
     - incomingRequestable: `Requestable` to make call for gif.
     
     */
    init(with incomingImageData: ImageData,
         _ incomingRequestable: Requestable) {
        self.data = incomingImageData
        super.init(incomingRequestable)
        
        self.disposable += self.fetchGif(for: self.data)
            .start(on: QueueScheduler(qos: .background))
            .observe(on: QueueScheduler.main)
            .start()
    }
    
    required public init() {
        fatalError("init(with incomingImageData: ImageData) has not been called")
    }
    
    required init(_ incomingRequestable: Requestable) {
        fatalError("init(with incomingImageData: ImageData) has not been called")
    }
    
    /**
     Performs a request using `Request` and sends the next `UIImage` or `APIError` via `Signal Producer` if there is a nil value for `image`. Toggles `isLoading` on start and completion of the call. On failure it provides a default `UIImage` to `image`.
     
     - parameters:
     - data: `ImageData` containing the URL for the .gif
     
     - Returns: `SignalProducer` containing either `UIImage` or `APIError`
     */
    
    private func fetchGif(for data: ImageData) -> SignalProducer<UIImage, APIError> {
        if let validImage = self.image.value {
            return SignalProducer(value: validImage)
        } else {
            return self.requestable.downloadImage(data.url)
                .on(
                    starting: { [weak self] () in
                        self?.isLoading.value = true
                    },
                    failed: { [weak self] error in
                        self?.image.value = Constants.Ui.placeholderImage
                    },
                    disposed: { [weak self] () in
                        self?.isLoading.value = false
                    },
                    value: { [weak self] image in
                        self?.image.value = image
                    })
        }
    }
}
