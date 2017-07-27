//
//  NewsTableViewCell.swift
//  MenuDeslizante
//
//  Created by sergio ivan lopez monzon on 17/11/15.
//  Copyright © 2015 sergio ivan lopez monzon. All rights reserved.
//


import UIKit

class PrincipalTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var lNumeroRecetas: UILabel!
    @IBOutlet weak var nombreLabelMenu: UILabel!

    
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    
    @IBOutlet weak var imgPagoGratis: UIImageView!
    @IBOutlet weak var imgTopDevider: UIImageView!
    @IBOutlet weak var imgBottomDevider: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        activityLoader.startAnimating()
        activityLoader.isHidden =  false
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
      
    }
    
    


    
}
