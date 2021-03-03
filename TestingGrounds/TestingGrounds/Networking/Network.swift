import Alamofire
import ReactiveSwift
import UIKit

public enum APIError: Error {
    case jsonDecodeError(error: Error)
    case network(error: Error)
    case unknown
    case networkTimedOut
    case networkUnavailable
}

protocol Networkable {
    func requestData(urlRequest: URLRequestConvertible) -> SignalProducer<Data, APIError>
}

protocol Alamofireable {
    func request(_ convertible: URLRequestConvertible, interceptor: RequestInterceptor?) -> DataRequest
}

public final class Network: Networkable {
    /**
     Performs a request using `Alamofire` and sends the next signal via `Signal Producer`
     
     - parameters:
        - urlRequest: `URLRequestConvertible` with the url to make the request
     
     - Returns: a `SignalProducer` containing either `Data` or `APIError>`
     */
    public func requestData(urlRequest: URLRequestConvertible) -> SignalProducer<Data, APIError> {
        return SignalProducer { [weak self] observer, _ in
            self?.requestData(urlRequest: urlRequest, observer: observer)
        }
    }

    /**
     Performs a request using `Alamofire` and send the next signal via `Signal Producer`
     
     - parameters:
        - urlRequest: `URLRequestConvertible` with the url to make the request
        - observer: `Signal.Observer` to send incoming data
     
     - Returns: a `SignalProducer` containing either `Data` or `APIError>`
     */
    private func requestData(urlRequest: URLRequestConvertible, observer: Signal<Data, APIError>.Observer) {
        Alamofire.Session.default.request(urlRequest).validate(statusCode: 200...204).response { response in
            self.handleResponse(response: response, observer: observer)
        }
    }
    
    /**
     Handles an `Alamofire` response and send the next signal via `Signal Producer`
     
     - parameters:
        - urlRequest: `URLRequestConvertible` with the url to make the request
        - response: `AFDataResponse` with the result of the `urlRequest`
        - observer: `Signal.Observer` to send incoming data
     
     - Returns: a `SignalProducer` containing either `Data` or `APIError>`
     */
    func handleResponse(response: AFDataResponse<Data?>, observer: Signal<Data, APIError>.Observer) {
        switch response.result {
        case .success(let value):
            // if there was a successful call with no data we still want to complete
            observer.send(value: value ?? Data())
            observer.sendCompleted()
        case .failure(let error):
            switch error {
            case .sessionTaskFailed(let sessionError):
                if let afError = sessionError as? AFError {
                    observer.send(error: APIError.network(error: afError))
                    observer.sendCompleted()
                    return
                } else if let urlError = sessionError as? URLError {
                    switch urlError.code {
                    case .notConnectedToInternet:
                        observer.send(error: APIError.networkUnavailable)
                        observer.sendCompleted()
                    case .timedOut:
                        observer.send(error: APIError.networkTimedOut)
                        observer.sendCompleted()
                        return
                    default:
                        observer.send(error: APIError.unknown)
                        observer.sendCompleted()
                        return
                    }
                }
            default:
                break
            }
            observer.send(error: APIError.unknown)
            observer.sendCompleted()
        }
    }
}
