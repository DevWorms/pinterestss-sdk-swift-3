//
//  PopUpViewControllerCompartir.swift
//  MenuDeslizante
//
//  Created by sergio ivan lopez monzon on 27/01/16.
//  Copyright © 2016 sergio ivan lopez monzon. All rights reserved.
//


import UIKit
import QuartzCore
import Parse
import FBSDKShareKit

import TwitterKit

@objc open class PopUpViewControllerCompartir : UIViewController, FBSDKSharingDelegate{
    
    var mainViewController: UIView!

    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var imageViewReceta: UIImageView!
    @IBOutlet weak var labelTitulo: UILabel!
    
    @IBOutlet weak var buttonFB: UIButton!
    @IBOutlet weak var imageViewCompartir: UIImageView!
    

    var context:PrincipalTableViewController!
    var opcion:String!
    var tituloEmpresa:String = "Toukanmango"
    var receta:PFObject!
    
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

    
    
    open func showInView(_ aView: UIView!, animated: Bool, receta:PFObject!, imagenReceta:UIImage){
        
        self.mainViewController = UIView.init(frame:  CGRect(x: 0.0, y: 0.0, width: aView.bounds.height, height: aView.bounds.maxY) )//aView.bounds)
        self.mainViewController.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        self.view.center = CGPoint(x: aView.bounds.width/2, y: aView.bounds.midY)
        
        aView.addSubview( self.mainViewController )
        aView.addSubview( self.view )
        
        self.showAnimate()
        
        self.imageViewReceta.image = imagenReceta
        self.receta = receta
        
        self.opcion = receta["TipoMenu"] as? String
        if(self.opcion != nil && self.opcion == "Viral" ){
            self.imageViewCompartir.image = UIImage(named: "compartirTrofeo")
        }else{
            self.imageViewCompartir.image = UIImage(named: "compartir")
        }
    }
    
    func showAnimate()
    {
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
                    
                    self.opcion = self.self.receta["TipoMenu"] as? String
                    if(self.opcion != nil && self.opcion == "Viral" ){
                        self.context.popAbierto = false;
                        self.context.tableView.isScrollEnabled = true
                    }
                }
        });
    }
    
    
    
    @IBAction func btnFacebook(_ sender: AnyObject) {
        
        
        let link : FBSDKShareLinkContent = FBSDKShareLinkContent()
        
        let url = receta["Url_Imagen"] as! String
        link.contentTitle = receta["Nombre"] as! String
        link.contentDescription = "¡Cocina deliciosas y fáciles recetas con Frida!   \nDescarga la app"
        link.imageURL = URL(string: url)
        link.contentURL = URL(string: "http://recetasmexicanas.mx")
        
        
        /*let button : FBSDKShareButton = FBSDKShareButton()
        button.shareContent = link
        button.frame = CGRectMake(buttonFB.bounds.width/2, buttonFB.bounds.midY, 100, 25)
        //button.alpha =*/
        //self.view.addSubview(button)
 
       let shared = FBSDKShareDialog()
        shared.mode = FBSDKShareDialogMode.native
        shared.shareContent = link
        shared.delegate = self
        shared.fromViewController = self
        if (!shared.canShow()) {
            // fallback presentation when there is no FB app
            shared.mode = FBSDKShareDialogMode.feedBrowser
        }
       shared.show()
        //let button : FBSDKShareButton = FBSDKShareButton()
        //button.shareContent = content
        
    }
    
    func completeFbShare(){
        self.removeAnimate()
    }
    
    open func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable: Any]!) {
       
        
        if self.opcion != nil && self.opcion.lowercased() == "viral" {
            
            let date = Date()
            let calendar = Calendar.current
            let components = (calendar as NSCalendar).components([.day , .month , .year], from: date)
            
            let year =  components.year
            let month = components.month
            
            let trimestre = month!/3
            
            let trimestreR = Int(Double(trimestre) + 0.7)

            
            let favorito = PFObject(className:"Regalos")
            favorito["username"] = PFUser.current()
            favorito["Anio"] = year
            favorito["Mes"] = month
            favorito["Trimestre"] = trimestreR
            favorito["Recetario"] = self.receta
            
            favorito.saveInBackground {
                (success, error) in
                if (success) {
                    // The object has been saved.
                    self.context.menuSeleccionado = self.receta
                    self.context.popAbierto = false;
                    self.context.imagenBusqueda = self.imageViewReceta.image
                    
                    self.context.performSegue(withIdentifier: "recetarios", sender: nil)

                } else {
                    // There was a problem, check error.description
                }
            }
            
        }
        
        print(results.description)
       
        self.removeAnimate()
        
    }
    
    
    open func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        print(error)
    }
    
    open func sharerDidCancel(_ sharer: FBSDKSharing!) {
        print(sharer.debugDescription)
    }
    
    @IBAction func btnTwitter(_ sender: AnyObject) {
        
        print("hola")
        
        if (Twitter.sharedInstance().sessionStore.hasLoggedInUsers()) {
            // App must have at least one logged-in user to compose a Tweet
            let poemImage = self.imageViewReceta.image
            
            let composer = TWTRComposerViewController(initialText: "¡Cocina deliciosas y fáciles recetas con Frida! http://recetasmexicanas.mx", image: poemImage, videoURL:nil)
            
            self.present(composer, animated: true) {
                if self.opcion != nil && self.opcion.lowercased() == "viral" {
                    let date = Date()
                    let calendar = Calendar.current
                    let components = (calendar as NSCalendar).components([.day , .month , .year], from: date)
                    
                    let year =  components.year
                    let month = components.month
                    
                    let trimestre = month!/3
                    
                    let trimestreR = Int(Double(trimestre) + 0.7)
                    
                    
                    let favorito = PFObject(className:"Regalos")
                    favorito["username"] = PFUser.current()
                    favorito["Anio"] = year
                    favorito["Mes"] = month
                    favorito["Trimestre"] = trimestreR
                    favorito["Recetario"] = self.receta
                    
                    favorito.saveInBackground {
                        (success, error) in
                        if (success) {
                            
                            self.context.menuSeleccionado = self.receta
                            self.context.imagenBusqueda = self.imageViewReceta.image
                            self.context.popAbierto = false;
                            self.context.performSegue(withIdentifier: "recetarios", sender: nil)
                        }
                        else{
                            
                        }
                    }
                }
            }
        } else {
            
            // Log in, and then check again
            Twitter.sharedInstance().logIn { session, error in
                if session != nil { // Log in succeeded
                    let poemImage = self.imageViewReceta.image
                    
                    let composer = TWTRComposerViewController(initialText: "¡Cocina deliciosas y fáciles recetas con Frida! http://recetasmexicanas.mx", image: poemImage, videoURL:nil)
                    //composer.delegate = self
                    
                    self.present(composer, animated: true) {
                        if self.opcion != nil && self.opcion.lowercased() == "viral" {
                            let date = Date()
                            let calendar = Calendar.current
                            let components = (calendar as NSCalendar).components([.day , .month , .year], from: date)
                            
                            let year =  components.year
                            let month = components.month
                            
                            let trimestre = month!/3
                            
                            let trimestreR = Int(Double(trimestre) + 0.7)
                            
                            
                            let favorito = PFObject(className:"Regalos")
                            favorito["username"] = PFUser.current()
                            favorito["Anio"] = year
                            favorito["Mes"] = month
                            favorito["Trimestre"] = trimestreR
                            favorito["Recetario"] = self.receta
                            
                            favorito.saveInBackground {
                                (success, error) in
                                if (success) {
                                    
                                    self.context.menuSeleccionado = self.receta
                                    self.context.imagenBusqueda = self.imageViewReceta.image
                                    self.context.popAbierto = false;
                                    self.context.performSegue(withIdentifier: "recetarios", sender: nil)
                                }
                                else{
                                    
                                }
                            }
                        }
                    }
                } else {
                    let alert = UIAlertController(title: "No Twitter Accounts Available", message: "You must log in before presenting a composer.", preferredStyle: .alert)
                    self.present(alert, animated: false, completion: nil)
                }
            }
        }
        
    }
    
    @IBAction func btnPinteres(_ sender: AnyObject) {
       
      
    
        var url : NSString = receta["Url_Imagen"] as! String as NSString
        var urlStr = url.addingPercentEscapes(using: String.Encoding.utf8.rawValue)!
        let imgURL = URL(string: urlStr as String)!
        url = "http://recetasmexicanas.mx"
        urlStr = url.addingPercentEscapes(using: String.Encoding.utf8.rawValue)!
        let direccion  = URL(string: urlStr as String)!
        
        PDKPin.pin(withImageURL: imgURL, link: direccion, suggestedBoardName: "ToukanMango", note: "Me encanta esta receta", from: self, withSuccess: {
            //print("successfully pinned pin")
            if self.opcion != nil && self.opcion.lowercased() == "viral" {
                
                let date = Date()
                let calendar = Calendar.current
                
                let year = calendar.component(.year, from: date)
                let month = calendar.component(.month, from: date)
                
                let trimestre = month/3
                
                let trimestreR = Int(Double(trimestre) + 0.7)
                
                
                let favorito = PFObject(className:"Regalos")
                favorito["username"] = PFUser.current()
                favorito["Anio"] = year
                favorito["Mes"] = month
                favorito["Trimestre"] = trimestreR
                favorito["Recetario"] = self.receta
                
                favorito.saveInBackground {
                    (success, error) in
                    if (success) {
                        self.context.menuSeleccionado = self.receta
                        self.context.imagenBusqueda = self.imageViewReceta.image
                        self.context.popAbierto = false;
                        self.context.performSegue(withIdentifier: "recetarios", sender: nil)
                    }
                    else{
                        
                    }
                }
            }
            
            self.removeAnimate()
            
        }) { (error) in
            print("pin it failed", error)
        }
       
    }
    
    @IBAction func tapView(_ sender: AnyObject) {
        self.removeAnimate()
    }
    
}
