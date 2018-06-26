//
//  AddressPart.swift
//  AddressApp
//
//  Created by Yerlan Ismailov on 25.06.2018.
//  Copyright © 2018 Yerlan Ismailov. All rights reserved.
//

import Foundation

struct AddressPart: Decodable {
    var nameRus: String = ""
    var nameKaz: String = ""
    
    var type: PartType
}
