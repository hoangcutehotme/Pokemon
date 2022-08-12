//
//  AbilityCell.swift
//  Pokedex
//
//  Created by Nguyen on 10/08/2022.
//

import UIKit

class AbilityCell: UITableViewCell {


    @IBOutlet var decripText: UILabel!
    @IBOutlet var nameAbility: UILabel!
    @IBOutlet weak var hideImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
