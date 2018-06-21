//
//  APIClient.swift
//  AddressApp
//
//  Created by Yerlan Ismailov on 21.06.2018.
//  Copyright © 2018 Yerlan Ismailov. All rights reserved.
//

import Foundation
import Alamofire

class APIClient {
    
    @discardableResult
    private static func performRequest(route: APIRouter, decoder: JSONDecoder = JSONDecoder(), completion:@escaping (Result<Any>)->Void) -> DataRequest {
        
        return Alamofire.request(route).responseJSON { response in
            completion(response.result)
        }
    }
    
    static func getSettlements(completion:@escaping (Result<Any>) -> Void) {
        let jsonDecoder = JSONDecoder()
        performRequest(route: APIRouter.settlements, decoder: jsonDecoder, completion: completion)
    }
    
    static func getChildSettlements(with parentId: Int, completion:@escaping (Result<Any>) -> Void) {
        let jsonDecoder = JSONDecoder()
        performRequest(route: .childSettlements(parentId: parentId), decoder: jsonDecoder, completion: completion)
    }
}

