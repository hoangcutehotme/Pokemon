//
//  EvolutionTableCell.swift
//  Pokedex
//
//  Created by Nguyen on 12/08/2022.
//

import UIKit

class EvolutionTableCell: UITableViewCell {

    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var labelImage1: UILabel!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var labelImage2: UILabel!
    @IBOutlet weak var levelUp: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
