//
//  Moves.swift
//  Pokedex
//
//  Created by Nguyen on 11/08/2022.
//

import Foundation
import UIKit

struct Moves : Decodable {
    let move : species
    let versionGroupDetails : [versionGroupDetail]
    enum CodingKeys: String, CodingKey {
        case move
        case versionGroupDetails = "version_group_details"
    }
}
struct versionGroupDetail :Decodable {
    let level_learned_at : Int
    let move_learn_method :species
    let version_group : species
}

struct MoveDetail : Decodable {
    let type : species
}
