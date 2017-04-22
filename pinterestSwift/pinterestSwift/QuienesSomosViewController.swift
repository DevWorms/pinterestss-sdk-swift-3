//
//  QuienesSomosViewController.swift
//  MenuDeslizante
//
//  Created by JUAN CARLOS LOPEZ A on 23/03/16.
//  Copyright © 2016 sergio ivan lopez monzon. All rights reserved.
//


import UIKit

class QuienesSomosViewController: UIViewController {
    

    @IBOutlet weak var menuButton:UIBarButtonItem!
     override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if revealViewController() != nil {
            //            revealViewController().rearViewRevealWidth = 62
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            revealViewController().rightViewRevealWidth = 150
            //    extraButton.target = revealViewController()
            //    extraButton.action = "rightRevealToggle:"
            
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
        
        
        let navBackgroundImage:UIImage! = UIImage(named: "bandasuperior")
        
        let nav = self.navigationController?.navigationBar
        
        nav?.tintColor = UIColor.white
        
        nav!.setBackgroundImage(navBackgroundImage, for:.default)
        

        
    }
    
}
