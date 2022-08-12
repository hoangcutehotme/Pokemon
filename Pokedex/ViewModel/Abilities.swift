//
//  Abilities.swift
//  Pokedex
//
//  Created by SMin on 08/08/2022.
//

struct ListAbility : Decodable
{
    let ability: Ability
    let isHidden: Bool
    
    enum CodingKeys: String, CodingKey {
        case ability = "ability"
        case isHidden = "is_hidden"
    }
}

struct Ability : Decodable
{
    let name: String
    let url :String
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case url
    }
}

struct Effect : Decodable {
    let flavorTextEntries : [flavorTextEntry]
    let id : Int
    let name : String
    enum CodingKeys: String, CodingKey {
        
        case flavorTextEntries = "flavor_text_entries"
        case id
        case name
    }
}

struct flavorTextEntry : Decodable {
    let flavorText : String
    let language : species
    let versionGroup : species
    enum CodingKeys: String, CodingKey {
        case flavorText = "flavor_text"
        case language
        case versionGroup = "version_group"
    }
}

struct species : Decodable {
    let name : String
    let url : String
}
