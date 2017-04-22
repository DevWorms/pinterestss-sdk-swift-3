//
//  PopUpViewControllerRecuperar.swift
//  MenuDeslizante
//
//  Created by sergio ivan lopez monzon on 24/01/16.
//  Copyright © 2016 sergio ivan lopez monzon. All rights reserved.
//

import UIKit
import QuartzCore
import Parse

@objc open class PopUpViewControllerRecuperar : UIViewController {
    
    var mainViewController: UIView!
    @IBOutlet weak var popUpView: UIView!
    
    
    @IBOutlet weak var textfMail: UITextField!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override public init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.popUpView.layer.cornerRadius = 5
        self.popUpView.layer.shadowOpacity = 0.8
        self.popUpView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.view.backgroundColor = UIColor.clear
        
    }
    
    
    open func showInView(_ aView: UIView!, animated: Bool){
        
        self.mainViewController = UIView.init(frame:  aView.frame)
        self.mainViewController.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        aView.addSubview( self.mainViewController )
        
        self.view.center = aView.center
        
        aView.addSubview( self.view )
        self.showAnimate()
    }
    
    
    func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
            }, completion:{(finished : Bool)  in
                if (finished)
                {
                    self.mainViewController.removeFromSuperview()
                    self.view.removeFromSuperview()
                }
        });
    }
    
    
    @IBAction func btnEnviar(_ sender: AnyObject) {
        
        if (self.textfMail.text?.isEmpty == nil || self.textfMail.text?.isEmpty  == true ) {
            // User needs to verify email address before continuing
            let alertController = UIAlertController(title: "Error",
                message: "Ingrese su correo electronico",
                preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addAction(UIAlertAction(title: "OK",
                style: UIAlertActionStyle.default,
                handler: nil))
            // Display alert
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            PFUser.requestPasswordResetForEmail(inBackground: textfMail.text!, block: { (sucess, error) -> Void in
                if error == nil{
                    // User needs to verify email address before continuing
                    let alertController = UIAlertController(title: "Reestablecer cuenta",
                        message: "Le hemos mandado un correo electronico",
                        preferredStyle: UIAlertControllerStyle.alert)
                    
                    alertController.addAction(UIAlertAction(title: "OK",
                        style: UIAlertActionStyle.default,
                        handler: { alertController in self.processSignOut()}))
                    // Display alert
                    self.present(alertController, animated: true, completion: nil)
                }
                else{
                    
                    var mensaje = ""
                    print(error?._code)
                    print(error?.localizedDescription)
                    if (error?._code == 125){
                        mensaje = "Correo inválido"
                    }else{
                        mensaje = "Ha ocurrido un error, revise sus datos o su conexión a internet"
                    }
                    
                    // User needs to verify email address before continuing
                    let alertController = UIAlertController(title: "Reestablecer cuenta",
                        message: mensaje,
                        preferredStyle: UIAlertControllerStyle.alert)
                    
                    alertController.addAction(UIAlertAction(title: "OK",
                        style: UIAlertActionStyle.default,
                        handler: { alertController in self.processSignOut()}))
                    // Display alert
                    self.present(alertController, animated: true, completion: nil)
                    
                }
            })
            
        }
        
    }
    
    
    @IBAction func btnCancelar(_ sender: AnyObject) {
        self.removeAnimate()
    }
    
    func processSignOut() {
                
        self.removeAnimate()
    }
    
}
