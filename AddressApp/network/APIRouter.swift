//
//  APIRouter.swift
//  AddressApp
//
//  Created by Yerlan Ismailov on 21.06.2018.
//  Copyright © 2018 Yerlan Ismailov. All rights reserved.
//

import Foundation
import Alamofire

enum APIRouter: URLRequestConvertible {
    
    case popular
    case recommended
    case recent
    case salon(id: Int)
    case settlements
    case childSettlements(parentId: Int)
    
    // MARK: - HTTPMethod
    private var method: HTTPMethod {
        switch self {
        case .popular, .recent, .recommended, .settlements:
            return .get
        default:
            return .get
        }
    }
    
    // MARK: - Path
    private var path: String {
        switch self {
        case .popular:
            return "/salon/getPopular"
        case .recommended:
            return "/salon/getRecommended"
        case .recent:
            return "/salon/getRecentlyAdded"
        case .salon(let id):
            return "/salon/page?id=\(id)"
        case .settlements:
            return "/api/kato"
        case .childSettlements(let id):
            return "/api/kato/\(id)"
        }
    }
    
    private var parameters: Parameters? {
        switch self {
        default:
            return nil
        }
    }
    
    private var parametersEncoding: ParameterEncoding {
        switch self {
        default:
            return JSONEncoding.default
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        
        let url = URL(string: "\(K.ProductionServer.baseURL)\(path)")!
        print("asURLRequest: \(url.absoluteString)")
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest = try parametersEncoding.encode(urlRequest, with: nil)
        
        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.acceptType.rawValue)
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        
        
        if let parameters = parameters {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
            }
        }
        
        return urlRequest
        
    }
    
}
