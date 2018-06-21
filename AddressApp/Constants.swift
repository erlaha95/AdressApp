//
//  Constants.swift
//  KhanTestApp
//
//  Created by Yerlan Ismailov on 18.03.2018.
//  Copyright © 2018 ismailov.com. All rights reserved.
//

import UIKit

struct K {
    struct ProductionServer {
        static let baseURL = "http://data.egov.kz/api/v2/kato"
//        static let imageBaseURL = "http://zp.jgroup.kz"
    }
    
    struct APIParameterKey {
        static let password = "password"
        static let email = "email"
    }
}

enum HTTPHeaderField: String {
    case authentication = "Authorization"
    case contentType = "Content-Type"
    case acceptType = "Accept"
    case acceptEncoding = "Accept-Encoding"
}

enum ContentType: String {
    case json = "application/json"
}
/*
struct Constants {
    
    static let column: CGFloat = 3
    
    static let minLineSpacing: CGFloat = 1.0
    static let minItemSpacing: CGFloat = 1.0
    
    static let offset: CGFloat = 1.0 // TODO: for each side, define its offset
    
    static func getItemWidth(boundWidth: CGFloat) -> CGFloat {
        
        // totalCellWidth = (collectionview width or tableview width) - (left offset + right offset) - (total space x space width)
        let totalWidth = boundWidth - (offset + offset) - ((column - 1) * minItemSpacing)
        
        return totalWidth / column
    }
}
*/
