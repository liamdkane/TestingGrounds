import Alamofire
@testable import TestingGrounds
import ReactiveSwift
import UIKit
import YYImage

struct MockRequestable: Requestable {
    
    let info: GiphyInfoContainer?
    let image: UIImage?
    
    func fetchGiphyInfo(_ urlRequest: GiphyRequest) -> SignalProducer<GiphyInfoContainer, APIError> {
        if let validInfo = self.info {
            return SignalProducer(value: validInfo)
        }
        return SignalProducer(error: APIError.unknown)
    }
    
    func downloadImage(_ url: URL) -> SignalProducer<UIImage, APIError> {
        if let validImage = self.image {
            return SignalProducer(value: validImage)
        }
        return SignalProducer(error: APIError.unknown)
    }
}

struct MockNetworkable: Networkable {
    
    /**
        This is a snippet I've used in previous projects to pull json files and convert into data for testing
     */
    static func mockJson(_ named: String) throws -> Data {
        let bundles = Bundle.allBundles.filter { bundle -> Bool in
            guard bundle.url(forResource: named, withExtension: "json") != nil else {
                return false
            }
            return true
        }
        let path = bundles[0].url(forResource: named, withExtension: "json")!
        let data = try Data(contentsOf: path, options: .mappedIfSafe)
        return data
    }
    
    let data: Data?
    let error: APIError?
    
    func requestData(urlRequest: URLRequestConvertible) -> SignalProducer<Data, APIError> {
        if let data = self.data {
            return SignalProducer(value: data)
        }
        
        if let error = self.error {
            return SignalProducer(error: error)
        }
        
        return SignalProducer.empty
    }
}
