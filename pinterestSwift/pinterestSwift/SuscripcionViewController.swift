//
//  SuscripcionViewController.swift
//  pinterestSwift
//
//  Created by Luis Gerardo on 30/08/17.
//  Copyright © 2017 Sergio Ivan Lopez Monzon. All rights reserved.
//

import UIKit

class SuscripcionViewController: UIViewController {

    @IBOutlet weak var vista: UIView!
    @IBOutlet weak var titulo: UILabel!
    @IBOutlet weak var subtitulo: UILabel!
    @IBOutlet weak var imagen: UIImageView!
    var pageIndex = 0
    var tituloText = ""
    var subtituloText = ""
    var imagenName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titulo.text = tituloText
        subtitulo.text = subtituloText
        imagen.image = UIImage(named: imagenName)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


