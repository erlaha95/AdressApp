//
//  SettlementChild.swift
//  AddressApp
//
//  Created by Yerlan Ismailov on 27.06.2018.
//  Copyright © 2018 Yerlan Ismailov. All rights reserved.
//

import Foundation

struct SettlementChild {
    
    var parent: Int
    var nameKaz: String
    var areaType: Int
    var level: Int
    var nameRus: String
    var id: Int
    var code: Int
    
    init(parent: Int, nameKaz: String, areaType: Int, level: Int, nameRus: String, id: Int, code: Int) {
        self.parent = parent
        self.nameKaz = nameKaz
        self.areaType = areaType
        self.level = level
        self.nameRus = nameRus
        self.id = id
        self.code = code
    }
}

extension SettlementChild: Decodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SettlementCodingKeys.self)
        
        let parent: Int = try container.decode(Int.self, forKey: .parent)
        let nameKaz: String = try container.decode(String.self, forKey: .nameKaz)
        let areaType: Int = try container.decode(Int.self, forKey: .areaType)
        let level: Int = try container.decode(Int.self, forKey: .level)
        let nameRus: String = try container.decode(String.self, forKey: .nameRus)
        let id: Int = try container.decode(Int.self, forKey: .id)
        let code: Int = try container.decode(Int.self, forKey: .code)
        
        self.init(parent: parent, nameKaz: nameKaz, areaType: areaType, level: level, nameRus: nameRus, id: id, code: code)
    }
    
    enum SettlementCodingKeys: String, CodingKey {
        case parent = "Parent"
        case nameKaz = "NameKaz"
        case areaType = "AreaType"
        case level = "Level"
        case nameRus = "NameRus"
        case id = "Id"
        case code = "Code"
    }
}
