//
//  Sprites.swift
//  Pokedex
//
//  Created by SMin on 02/08/2022.
//

import Foundation

struct Sprites : Decodable
{
    let other: Other
  
    enum CodingKeys: String, CodingKey {
        case other = "other"
  }
}

struct Other : Decodable
{
    let official: Official
    let home : Home
    enum CodingKeys: String, CodingKey {
        case official = "official-artwork"
        case home
  }
}
struct Home : Decodable {
    let frontDefault : String
    let frontShiny : String
    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
        case frontShiny = "front_shiny"
  }
}
struct Official : Decodable
{
    let img: String
    
    enum CodingKeys: String, CodingKey {
        case img = "front_default"
  }
}
