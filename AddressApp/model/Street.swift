//
//  Street.swift
//  AddressApp
//
//  Created by Yerlan Ismailov on 22.06.2018.
//  Copyright © 2018 Yerlan Ismailov. All rights reserved.
//

import Foundation

struct Street: Decodable {
    var addressRus: String = ""
    var addressKaz: String = ""
    var fullAddress: FullAdress?
}
