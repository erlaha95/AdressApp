//
//  Client.swift
//  AddressApp
//
//  Created by Yerlan Ismailov on 6/20/18.
//  Copyright © 2018 Yerlan Ismailov. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import RxCocoa


protocol ClientProtocol {
    func request<Response>(_ endpoint: Endpoint<Response>) -> Single<Response>
}

final class Client: ClientProtocol {
    private let manager: Alamofire.SessionManager
    private let baseURL = URL(string: "<your_server_base_url>")!
    private let queue = DispatchQueue(label: "<your_queue_label>")
    
    init(accessToken: String) {
        var defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        defaultHeaders["Authorization"] = "Bearer \(accessToken)"
        
        let configuration = URLSessionConfiguration.default
        
        // Add `Auth` header to the default HTTP headers set by `Alamofire`
        configuration.httpAdditionalHeaders = defaultHeaders
        
        self.manager = Alamofire.SessionManager(configuration: configuration)
        self.manager.retrier = OAuth2Retrier()
    }
    
    func request<Response>(_ endpoint: Endpoint<Response>) -> Single<Response> {
        return Single<Response>.create { observer in
            let request = self.manager.request(
                self.url(path: endpoint.path),
                method: httpMethod(from: endpoint.method),
                parameters: endpoint.parameters
            )
            request
                .validate()
                .responseData(queue: self.queue) { response in
                    let result = response.result.flatMap(endpoint.decode)
                    switch result {
                    case let .success(val): observer(.success(val))
                    case let .failure(err): observer(.error(err))
                    }
            }
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    private func url(path: Path) -> URL {
        return baseURL.appendingPathComponent(path)
    }
}

private func httpMethod(from method: Method) -> Alamofire.HTTPMethod {
    switch method {
    case .get: return .get
    case .post: return .post
    case .put: return .put
    case .patch: return .patch
    case .delete: return .delete
    }
}


private class OAuth2Retrier: Alamofire.RequestRetrier {
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        if (error as? AFError)?.responseCode == 401 {
            // TODO: implement your Auth2 refresh flow
            // See https://github.com/Alamofire/Alamofire#adapting-and-retrying-requests
        }
        completion(false, 0)
    }
}
