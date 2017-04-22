//
//  TuCuentaView.swift
//  MenuDeslizante
//
//  Created by sergio ivan lopez monzon on 21/11/15.
//  Copyright © 2015 sergio ivan lopez monzon. All rights reserved.
//

//
//  ViewController.swift
//  App Cocina
//
//  Created by Emmanuel Valentín Granados López on 26/09/15.
//  Copyright © 2015 DevWorms. All rights reserved.
//

import UIKit
import Parse
//import ParseTwitterUtils
import ParseFacebookUtilsV4
import TwitterKit

class TuCuentaView: UIViewController, UITextFieldDelegate {
    
    var popViewController:PopUpViewControllerRegistro!
    var popViewControllerRecuperar:PopUpViewControllerRecuperar!
    
    @IBOutlet weak var textfMail: UITextField!
    @IBOutlet weak var textfPassword: UITextField!
    @IBOutlet weak var menuButton:UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            // Do any additional setup after loading the view, typically from a nib.
            textfMail.delegate = self
            textfPassword.delegate = self
        if revealViewController() != nil {
            //            revealViewController().rearViewRevealWidth = 62
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            revealViewController().rightViewRevealWidth = 150
            //    extraButton.target = revealViewController()
            //    extraButton.action = "rightRevealToggle:"
            
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
    }
    
    
    @IBAction func loginMail(_ sender: AnyObject) {
        if  (textfMail.text == nil || textfMail.text == "") || (textfPassword.text == nil || textfPassword.text == "") {
            // User needs to verify email address before continuing
            let alertController = UIAlertController(title: "Favor de ingresar correo y contraseña",
                message: "Ingrese sus datos para poder ingresar\nSi aun no estas registrado selecciona el boton de nuevo usuario",
                preferredStyle: UIAlertControllerStyle.alert)
    
            alertController.addAction(UIAlertAction(title: "OK",
                style: UIAlertActionStyle.default,
                handler: nil))
            // Display alert
            self.present(alertController, animated: true, completion: nil)
        }
        else{
    
            self.logueoMail()
        }
}


func logueoMail(){
    
    let mail = textfMail.text?.lowercased()
    let pass = textfPassword.text
    
    
    
    
    PFUser.logInWithUsername(inBackground: mail!, password: pass!) { (user, error) in
        
       if user != nil {
            
            DispatchQueue.main.async {
                // Do stuff after successful login.
                self.performSegue(withIdentifier: "cerrarsesion", sender: nil)
                
            }
            
        } else {
            // The login failed. Check error to see why.
            
            let alertController = UIAlertController(title: "Error al iniciar sesión",
                message: "correo o usuario incorrectos",
                preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addAction(UIAlertAction(title: "OK",
                style: UIAlertActionStyle.default,
                handler: nil))
            // Display alert
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    
}



    func processSignOut() {
        
        // // Sign out
        PFUser.logOut()
        
    }


    func ligarFb(_ user: PFUser)
    {
        if !PFFacebookUtils.isLinked(with: user) {
            PFFacebookUtils.linkUser(inBackground: user, withReadPermissions: nil, block: {
                (succeeded, error) -> Void in
                if (succeeded != nil) {
                    print("Woohoo, the user is linked with Facebook!")
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
                    print("User signed up and logged in through Facebook!")
                } else {
                    print("User logged in through Facebook!")
                }
                
                self.ligarFb(user)
                self.performSegue(withIdentifier: "Home", sender: nil)
                
            } else {
                print("Uh oh. The user cancelled the Facebook login.")
            }
        })
        
    }
    
    @IBAction func loginTwitter(_ sender: AnyObject) {
        
      /*  PFTwitterUtils.logInWithBlock {
            (user: PFUser?, error: NSError?) -> Void in
            
            let user = user
            
            if (user != nil) {
                if user!.isNew {
                    print("User signed up and logged in with Twitter!")
                } else {
                    print("User logged in with Twitter! " )
                }
                
                self.performSegueWithIdentifier("cerrarsesion", sender: nil)
                
            } else {
                print("Uh oh. The user cancelled the Twitter login.")
            }
        }*/
/*//nativa
        
        Twitter.sharedInstance().logInWithCompletion { session, error in
            if (session != nil) {
                print("signed in as \(session!.userName)");
                
                // Swift
                let store = Twitter.sharedInstance().sessionStore
                self.performSegueWithIdentifier("cerrarsesion", sender: nil)
                
            } else {
                print("error: \(error!.localizedDescription)");
            }
        }
  */
        
        
    }
    
    
    
    @IBAction func registrarse(_ sender: AnyObject) {
        self.abrirVentanaPopRegistro()
    }
    
    func abrirVentanaPopRegistro(){
        
        self.popViewController = PopUpViewControllerRegistro(nibName: "PopUpViewControllerRegistro", bundle: nil)
        self.popViewController.showInView(self.view, animated: true)
    }
    
    func abrirVentanaPopRecupera(){
        
        self.popViewControllerRecuperar = PopUpViewControllerRecuperar(nibName: "PopUpViewControllerRecuperar", bundle: nil)
        self.popViewControllerRecuperar.showInView(self.view, animated: true)
    }
    
    
    @IBAction func restablecer(_ sender: AnyObject) {
        self.abrirVentanaPopRecupera()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITextFieldDelegate    <- mark + : do section
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Hide the keyboard.
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //make something with the letters that being typed
    }
    
    
    

    
    
}

