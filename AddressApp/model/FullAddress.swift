//
//  FullAdress.swift
//  AddressApp
//
//  Created by Yerlan Ismailov on 22.06.2018.
//  Copyright © 2018 Yerlan Ismailov. All rights reserved.
//

import Foundation

struct FullAdress: Decodable {
    var parts: [AddressPart] = [AddressPart]()
}
