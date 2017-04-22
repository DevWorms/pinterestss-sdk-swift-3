//
//  PopUpViewControllerRegistro.swift
//  MenuDeslizante
//
//  Created by sergio ivan lopez monzon on 24/01/16.
//  Copyright © 2016 sergio ivan lopez monzon. All rights reserved.
//

import UIKit
import QuartzCore
import Parse

@objc open class PopUpViewControllerRegistro : UIViewController {

    var mainViewController: UIView!
    @IBOutlet weak var popUpView: UIView!
    
    
    @IBOutlet weak var textfMail: UITextField!
    @IBOutlet weak var textfPassword: UITextField!
    @IBOutlet weak var textfPasswordConfirmation: UITextField!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override public init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        self.popUpView.layer.cornerRadius = 5
        self.popUpView.layer.shadowOpacity = 0.8
        self.popUpView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
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
        let user = PFUser()
        
        if self.textfMail.text?.isEmpty == true || self.textfPassword.text?.isEmpty == true || self.textfPasswordConfirmation.text?.isEmpty == true{
            // User needs to verify email address before continuing
            let alertController = UIAlertController(title: "Error",
                message: "Debe llenar los campos vacios",
                preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addAction(UIAlertAction(title: "OK",
                style: UIAlertActionStyle.default,
                handler: nil))
            // Display alert
            self.present(alertController, animated: true, completion: nil)
        }
        
        if (self.textfPasswordConfirmation.text == textfPassword.text && (self.textfPassword.text?.isEmpty != nil)){
            
        user.password = textfPassword.text
        user.email = textfMail.text?.lowercased()
        user.username = textfMail.text?.lowercased()
        user.signUpInBackground {
            (succeeded, error) in
            if let error = error {
                let errorString = (error._userInfo as! [String:String])["error"]
                
                if (error._code == 125){
                    // User needs to verify email address before continuing
                    let alertController = UIAlertController(title: "Error",
                        message: "Correo electronico inválido",
                        preferredStyle: UIAlertControllerStyle.alert)
                    
                    alertController.addAction(UIAlertAction(title: "OK",
                        style: UIAlertActionStyle.default,
                        handler: nil))
                    // Display alert
                    self.present(alertController, animated: true, completion: nil)
                }
                print(errorString)
                // Show the errorString somewhere and let the user try again.
            } else {
                
                
                // User needs to verify email address before continuing
                let alertController = UIAlertController(title: "Bienvenido",
                    message: "usuario registrado",
                    preferredStyle: UIAlertControllerStyle.alert)
                
                    alertController.addAction(UIAlertAction(title: "OK",
                    style: UIAlertActionStyle.default,
                    handler: { alertController in self.processSignOut()}))
                    // Display alert
                    self.present(alertController, animated: true, completion: nil)
                }
        
            }

        }
        else{
            
            // User needs to verify email address before continuing
            let alertController = UIAlertController(title: "Error",
                message: "Contraseñas no coinciden",
                preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addAction(UIAlertAction(title: "OK",
                style: UIAlertActionStyle.default,
                handler: nil))
            // Display alert
            self.present(alertController, animated: true, completion: nil)
            

        }

    }
    
    
    @IBAction func btnCancelar(_ sender: AnyObject) {
        self.removeAnimate()
    }
    
    func processSignOut() {
        
        // // Sign out
        PFUser.logOut()
        
        self.removeAnimate()
    }
  
}
