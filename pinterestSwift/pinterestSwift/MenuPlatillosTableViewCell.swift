//
//  MenuPlatillosTableViewCell.swift
//  MenuDeslizante
//
//  Created by sergio ivan lopez monzon on 26/01/16.
//  Copyright © 2016 sergio ivan lopez monzon. All rights reserved.
//

import Foundation
class MenuPlatillosTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imagenRecetaView: UIImageView!
    @IBOutlet weak var nombreRecetaLabel: UILabel!
    @IBOutlet weak var porcionesRecetaLabel: UILabel!
    @IBOutlet weak var tiempoRecetaLabel: UILabel!
    @IBOutlet weak var imgDificultad: UIImageView!
    
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        activityLoader.isHidden = false
        activityLoader.startAnimating()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        
    }
    
    
    
}
