//
//  KazpostObjectApiResponse.swift
//  AddressApp
//
//  Created by Yerlan Ismailov on 27.06.2018.
//  Copyright © 2018 Yerlan Ismailov. All rights reserved.
//

import Foundation

struct KazpostObjectApiResponse: Decodable {
    var data: [KazpostObject] = [KazpostObject]()
    var total: Int
    var from: Int
}
