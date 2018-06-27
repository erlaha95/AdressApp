//
//  File.swift
//  AddressApp
//
//  Created by Yerlan Ismailov on 6/20/18.
//  Copyright © 2018 Yerlan Ismailov. All rights reserved.
//

import Foundation

enum AreaType: Int, Decodable {
    case region = 0
    case city = 1
    case district = 2
    case cityAkimat = 3
    case districtType2 = 4
}

struct Settlement {
    
    var parent: String
    var nameKaz: String
    var areaType: AreaType
    var level: Int
    var nameRus: String
    var id: Int
    var code: Int
    var nameRusWithoutAffix: String {
        get {
            let possibleSuffixes = ["г.", "область", "район", "\""]
            var formatted = nameRus
            for suffix in possibleSuffixes {
                if formatted.hasPrefix(suffix) || formatted.hasSuffix(suffix) {
                    formatted = formatted.replacingOccurrences(of: suffix, with: "")
                }
            }
            return formatted
                .trimmingCharacters(in: .whitespaces)
                .components(separatedBy: .decimalDigits)
                .joined()
        }
    }
    
    init(parent: String, nameKaz: String, areaType: AreaType, level: Int, nameRus: String, id: Int, code: Int) {
        self.parent = parent
        self.nameKaz = nameKaz
        self.areaType = areaType
        self.level = level
        self.nameRus = nameRus
        self.id = id
        self.code = code
    }
}

extension Settlement: Decodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SettlementCodingKeys.self)
        
        var parent: String = ""
        
        do {
            parent = try container.decode(String.self, forKey: .parent)
        } catch {
            parent = String(try container.decode(Int.self, forKey: .parent))
        }
        
        let nameKaz: String = try container.decode(String.self, forKey: .nameKaz)
        let areaType: AreaType = try container.decode(AreaType.self, forKey: .areaType)
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
