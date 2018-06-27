//
//  KazpostObject.swift
//  AddressApp
//
//  Created by Yerlan Ismailov on 27.06.2018.
//  Copyright © 2018 Yerlan Ismailov. All rights reserved.
//

import Foundation

struct KazpostObject: Decodable {
    var id: String
    var nameKaz: String
    var nameRus: String
    var type: KazpostObjectType
    var parentId: String
    var actual: String?
}
