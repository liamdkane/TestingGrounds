import Alamofire
import Foundation

enum GiphyRequest: GiphyURLRequestConvertible {
    
    case fetchQuery(query: String, offset: Int = 0)
    
    var method: HTTPMethod {
        return .get
    }
    
    var encoding: ParameterEncoding? {
        return URLEncoding.default
    }

    var path: String {
        return "search"
    }
    
    var params: [String : Any]? {
        switch self {
        case let .fetchQuery(query, page):
            var params = defaultParams
            params.updateValue(query, forKey: "q")
            params.updateValue(page, forKey: "offset")
            return params
        }
    }
}
