//
//  EvoluChain.swift
//  Pokedex
//
//  Created by Nguyen on 12/08/2022.
//

import Foundation
import UIKit

struct Evolution : Decodable {
    let chain : Detail
    let id : Int
}

struct Detail :Decodable {
    //let evolution_details
    let evolves_to : [Detail]
    let is_baby : Bool
    let species : species
    
}

