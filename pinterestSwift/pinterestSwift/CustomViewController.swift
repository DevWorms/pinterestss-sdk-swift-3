//
//  CustomViewController.swift
//  pinterestSwift
//
//  Created by Luis Gerardo on 14/09/17.
//  Copyright © 2017 Sergio Ivan Lopez Monzon. All rights reserved.
//

import UIKit

class CustomViewController: UIViewController {

    var backgroundView = UIView()
    var frontView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func showInView(_ aView: UIView){
        
        backgroundView = UIView.init(frame:  CGRect(x: 0.0, y: 0.0, width: aView.bounds.height, height: aView.bounds.maxY) )
        frontView = UIView.init(frame: CGRect(x: 0.0, y: 0.0, width: backgroundView.bounds.width/2, height: backgroundView.bounds.height/1))
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.6)

        let tap = UITapGestureRecognizer(target: self, action: #selector(CustomViewController.tapGesture))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        backgroundView.isUserInteractionEnabled = true
        backgroundView.addGestureRecognizer(tap)
        
        
        
        frontView.center = backgroundView.center
        
        aView.addSubview(backgroundView)
        backgroundView.addSubview(frontView)
        frontView.backgroundColor = UIColor.blue
        self.showAnimate()
    }
    
    func tapGesture() {
        removeAnimate()
    }
    
    func showAnimate()
    {
        self.frontView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.frontView.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.frontView.alpha = 1.0
            self.frontView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.frontView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.frontView.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                self.backgroundView.removeFromSuperview()
                self.frontView.removeFromSuperview()
            }
        })
    }

}
