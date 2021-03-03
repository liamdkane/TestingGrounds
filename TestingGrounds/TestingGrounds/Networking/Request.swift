import Alamofire
import ReactiveCocoa
import ReactiveSwift
import UIKit
import YYImage

enum DateError: String, Error {
    case invalidDate
}

protocol BaseURLRequestConvertible: URLRequestConvertible {
    var baseURL: String { get }
    var method: HTTPMethod { get }
    var encoding: ParameterEncoding? { get }
    var path: String { get }
    var params: [String: Any]? { get }
}

protocol GiphyURLRequestConvertible: BaseURLRequestConvertible {
    //Intentionally Blank
}

extension GiphyURLRequestConvertible {
    public func asURLRequest() throws -> URLRequest {
        let url = try baseURL.asURL().appendingPathComponent(self.path)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.cachePolicy = .reloadRevalidatingCacheData
        
        if let encoding = encoding {
            return try encoding.encode(urlRequest, with: params)
        }
        
        return urlRequest
    }
    
    var baseURL: String {
        get {
            return Constants.Api.giphyBaseUrl
        }
    }
    
    var defaultParams: [String: Any] {
        get {
            return ["api_key": Constants.Api.apiKey]
        }
    }
}

protocol Requestable {
    func fetchGiphyInfo(_ urlRequest: GiphyRequest) -> SignalProducer<GiphyInfoContainer, APIError>
    func downloadImage(_ url: URL) -> SignalProducer<UIImage, APIError>
}

public final class Request: Requestable {
    
    let networkable: Networkable
    
    init(_ incomingNetworkable: Networkable) {
        networkable = incomingNetworkable
    }
    
    /**
     Retrieves objects returned by the API and decodes it into an object type passed as a parameter.
     
     - Returns: a `SignalProducer` containing either a `T` of Decodable Type or an `APIError`
     */
    private func object<T: Decodable>(_ type: T.Type, from urlRequest: BaseURLRequestConvertible) -> SignalProducer<T, APIError> {
        return networkable.requestData(urlRequest: urlRequest).attemptMap { data in
            do {
                let decoder = JSONDecoder()
                let object = try decoder.decode(type.self, from: data)
                return .success(object)
            } catch {
                return .failure(APIError.jsonDecodeError(error: error))
            }
        }
    }
    
    /**
     Retrieves data from `/search` API to fetch queried term related GIF ids
     
     - Returns: a `Signal Producer` containing either `[GiphyInfo]` or `ApiError`
     */
    func fetchGiphyInfo(_ urlRequest: GiphyRequest) -> SignalProducer<GiphyInfoContainer, APIError> {
        return object(GiphyInfoContainer.self, from: urlRequest)
    }
    
    /**
     Retrieves `image/gif` data from API, initialises it as a `YYImage` or defaults to a placeholder.
     
     - Returns: a `Signal Producer` containing either `UIImage` or `ApiError`
     */
    
    func downloadImage(_ url: URL) -> SignalProducer<UIImage, APIError> {        
        return networkable.requestData(urlRequest: URLRequest(url: url))
            .map { data in YYImage(data: data) ?? Constants.Ui.placeholderImage}
    }
}
