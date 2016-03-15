//
//  celdaOracion.swift
//  Rezandovoy
//
//  Created by Rodrigo on 14/3/16.
//  Copyright © 2016 sjdigital. All rights reserved.
//

import UIKit

class celdaOracion: UITableViewCell {

    @IBOutlet var titulo: UILabel!
    @IBOutlet var logoOracion: UIImageView!
    @IBOutlet var fondo: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
