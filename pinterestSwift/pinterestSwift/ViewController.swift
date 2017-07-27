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
/*import FacebookCore
import FacebookLogin
*/
class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var bttonr: UIButton!
    var popViewController:PopUpViewControllerRegistro!
    var popViewControllerRecuperar:PopUpViewControllerRecuperar!
    @IBOutlet weak var textfMail: UITextField!
    @IBOutlet weak var textfPassword: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        
        
        self.bttonr.imageView?.clipsToBounds = true
        self.bttonr.imageView?.contentMode = UIViewContentMode.scaleAspectFit
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Image Background Navigation Bar
        
        UserDefaults.standard.set("false", forKey: "7 dias mostrado")
        UserDefaults.standard.setValue("", forKey: guardarEnMemoria.clienteId)
        
        UserDefaults.standard.setValue("", forKey: guardarEnMemoria.tarjetaId)
        
        
        let navBackgroundImage:UIImage! = UIImage(named: "bienvenidois")
        
        let nav = self.navigationController?.navigationBar
        
        nav?.tintColor = UIColor.white
        
        nav!.setBackgroundImage(navBackgroundImage, for:.default)

        // Do any additional setup after loading the view, typically from a nib.
            textfMail.delegate = self
            textfPassword.delegate = self
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
    }

    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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
        
        
        PFUser.logInWithUsername(inBackground: mail!, password:pass!) {
            (user, error) in
            if user != nil {
                
                DispatchQueue.main.async {
                    // Do stuff after successful login.
                    self.performSegue(withIdentifier: "Home", sender: nil)
                
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
                if (error == nil) {
                    print("Woohoo, the user is linked with Facebook!")
                }
            })
        }
    }

   
    
    @IBAction func loginFacebook(_ sender: AnyObject) {
        
        //let publishPermissions : [String]? = ["publish_actions"]
        
        
        let readPermissions : [String]? = ["public_profile","email", "user_likes", "user_photos", "user_posts", "user_friends"]
        
        /*let loginManager = LoginManager()
        loginManager.logIn([ .publicProfile ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in!")
            }
        }*/
    
        
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
    
    func abrirVentanaPopRegistro(){
        
        self.popViewController = PopUpViewControllerRegistro(nibName: "PopUpViewControllerRegistro", bundle: nil)
        self.popViewController.showInView(self.view, animated: true)
        
    }
    
    @IBAction func registrarse(_ sender: AnyObject) {
      // self.performSegueWithIdentifier("registro", sender: nil)
        
        // self.abrirVentanaPopRegistro()
    }
    
    func abrirVentanaPopRecupera(){
        
        self.popViewControllerRecuperar = PopUpViewControllerRecuperar(nibName: "PopUpViewControllerRecuperar", bundle: nil)
        self.popViewControllerRecuperar.showInView(self.view, animated: true)
        //self.popViewControllerRecuperar.sho
        
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

