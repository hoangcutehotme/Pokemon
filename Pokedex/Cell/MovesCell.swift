//
//  MovesCell.swift
//  Pokedex
//
//  Created by Nguyen on 11/08/2022.
//

import UIKit

class MovesCell: UITableViewCell {

    @IBOutlet weak var imgPower: UIImageView!
    @IBOutlet weak var nameMove: UILabel!
    @IBOutlet weak var level: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
