//
//  Species.swift
//  Pokedex
//
//  Created by Nguyen on 10/08/2022.
//

import Foundation
import UIKit

struct SpeciesPoke : Decodable {
    let flavorTextEntries : [flavorTextEntry1]
    let eggGroups : [species]
    let captureRate : Int
    let habitat : species
    let hatchCounter :Int
    let generation : species
    let varieties : [Varity]
    let evolution_chain : url
    enum CodingKeys: String, CodingKey {
        case flavorTextEntries = "flavor_text_entries"
        case eggGroups = "egg_groups"
        case captureRate = "capture_rate"
        case habitat
        case hatchCounter = "hatch_counter"
        case generation
        case varieties
        case evolution_chain
    }
}
struct url : Decodable {
    let url : String
}
struct flavorTextEntry1 : Decodable {
    let flavorText : String
    let language : species
    let version : species
    enum CodingKeys: String, CodingKey {
        case flavorText = "flavor_text"
        case language
        case version = "version"
    }
}

struct Varity : Decodable {
    let is_default : Bool
    let pokemon : species
}


