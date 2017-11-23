//
//  RegistroViewController.swift
//  MenuDeslizante
//
//  Created by sergio ivan lopez monzon on 18/11/16.
//  Copyright © 2016 sergio ivan lopez monzon. All rights reserved.
//

import UIKit
import QuartzCore
import Parse
//import ParseTwitterUtils
import ParseFacebookUtilsV4
import TwitterKit


class RegistroViewController : UIViewController {

    
    @IBOutlet weak var textfMail: UITextField!
    @IBOutlet weak var textfPassword: UITextField!
    @IBOutlet weak var textfPasswordConfirmation: UITextField!

    
    override func viewWillAppear(_ animated: Bool) {
        /*self.navigationController?.navigationBarHidden = true
        
        
        self.bttonr.imageView?.clipsToBounds = true
        self.bttonr.imageView?.contentMode = UIViewContentMode.ScaleAspectFit*/
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Image Background Navigation Bar
        
        
        let navBackgroundImage:UIImage! = UIImage(named: "bienvenidois")
        
        let nav = self.navigationController?.navigationBar
        
        if nav != nil{
            nav?.tintColor = UIColor.white
        
            nav!.setBackgroundImage(navBackgroundImage, for:.default)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGes))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)
        
    }
    
    func tapGes() {
        textfMail.resignFirstResponder()
        textfPassword.resignFirstResponder()
        textfPasswordConfirmation.resignFirstResponder()
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
                (succeeded, error)  in
                if let error = error {
                    //let errorString = (error._userInfo as! [String:String])["error"]
                    
                    var mensaje = ""
                    
                    if (error._code == 125){
                          mensaje =  "Correo electronico inválido"
                        
                    }else if(error._code == 202){
                        mensaje = "El nombre de usuario ya ha sido tomado"
                    }
                    
                    /*if mensaje == ""{
                        mensaje = errorString!
                    }*/
                    
                    if  mensaje == ""{
                        mensaje = "codigo: " + String(error._code)
                    }
                    
                    // User needs to verify email address before continuing
                    let alertController = UIAlertController(title: "Error",
                        message:mensaje,
                        preferredStyle: UIAlertControllerStyle.alert)
                    
                    alertController.addAction(UIAlertAction(title: "OK",
                        style: UIAlertActionStyle.default,
                        handler: nil))
                    // Display alert
                    self.present(alertController, animated: true, completion: nil)

                    
                    //print(errorString!)
                    // Show the errorString somewhere and let the user try again.
                } else {
                    
                    
                    // User needs to verify email address before continuing
                    let alertController = UIAlertController(title: "Bienvenido",
                        message: "usuario registrado",
                        preferredStyle: UIAlertControllerStyle.alert)
                    
                    alertController.addAction(UIAlertAction(title: "OK",
                        style: UIAlertActionStyle.default,
                        handler: {
                            alertController in self.abrirRecetas()
                    }))
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
    
    
    
    func abrirRecetas(){
        self.performSegue(withIdentifier: "Home", sender: nil)
    }
    
    func ligarFb(_ user: PFUser)
    {
        if !PFFacebookUtils.isLinked(with: user) {
            PFFacebookUtils.linkUser(inBackground: user, withReadPermissions: nil, block: {
                (succeeded, error) -> Void in
                if (error == nil) {
                    //print("Woohoo, the user is linked with Facebook!")
                }
            })
        }
        
    }
    
    
    
    @IBAction func loginFacebook(_ sender: AnyObject) {
        
        //let publishPermissions : [String]? = ["publish_actions"]
        let readPermissions : [String]? = ["email", "user_likes", "user_photos", "user_posts", "user_friends"]
        
        // Log In with Read Permissions
        // Log In with Read Permissions
        PFFacebookUtils.logInInBackground(withReadPermissions: readPermissions, block: { (user, error) in
            if let user = user {
                if user.isNew {
                    //print("User signed up and logged in through Facebook!")
                } else {
                    //print("User logged in through Facebook!")
                }
                
                self.ligarFb(user)
                self.performSegue(withIdentifier: "Home", sender: nil)
                
            } else {
                //print("Uh oh. The user cancelled the Facebook login.")
            }
        })
        
    }
    
}

