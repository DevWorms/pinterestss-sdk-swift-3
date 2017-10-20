//
//  PlatillosViewController.swift
//  MenuDeslizante
//
//  Created by sergio ivan lopez monzon on 06/12/15.
//  Copyright © 2015 sergio ivan lopez monzon. All rights reserved.
//


import UIKit
import Parse
import ParseFacebookUtilsV4

class PlatillosViewController: UIViewController{
    @IBOutlet weak var imageViewReceta: UIImageView!
    
    @IBOutlet weak var labelTitulo: UILabel!
    @IBOutlet weak var imgButtonLike: UIImageView!
    @IBOutlet weak var textAreaReceta: UITextView!
    
    @IBOutlet weak var labelPorciones: UILabel!
    @IBOutlet weak var labelTiempo: UILabel!
    var objReceta:PFObject!
    var imagenReceta:UIImage!
    
    @IBOutlet weak var imagenDificultad: UIImageView!

    
    @IBOutlet weak var contenidoDeLaRecetaView: UIView!
    
    var popViewController: PopUpViewControllerCompartir!

    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    
    var posicionInicialContenedor:CGFloat!
    var scrollHaciaArriba = true
    
    
    override func viewWillAppear(_ animated: Bool) {
        let query = PFQuery(className: "Favoritos")
        
        query.includeKey("Recetas")
        query.whereKey("username", equalTo: PFUser.current()!)
        query.whereKey("Recetas", equalTo: self.objReceta)
        query.findObjectsInBackground {
            (recetas, error) in
            // comments now contains the comments for myPost
            
            if error == nil {
                
                //Revisa si ese cliente tiene esa receta para mandar un mensaje de error al tratar de añadirla de nuevo
                if recetas != nil && (recetas?.count)!>0 {
                    self.imgButtonLike.image = UIImage(named: "like release")
                }
                else{
                    
                    
                }
                
            }
            else
            {
                //print(error!)
            }
        }
        
        
        //let navBackgroundImage:UIImage! = UIImage(named: "bandasuperior")
        //let nav = self.navigationController?.navigationBar
        //nav?.tintColor = UIColor.white
        //nav!.setBackgroundImage(navBackgroundImage, for:.default)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityLoader.isHidden = false
        activityLoader.startAnimating()
        
        self.loadRecetaInformation()
        
        let pangesture = UIPanGestureRecognizer(target: self, action: #selector(PlatillosViewController.dragview(_:)))
        contenidoDeLaRecetaView.addGestureRecognizer(pangesture)
        self.posicionInicialContenedor = CGFloat(0.0)
        
        let backButton = UIBarButtonItem(title: "atrás", style: UIBarButtonItemStyle.plain, target: self, action: nil)
        backButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 20)!], for: UIControlState())
        navigationItem.backBarButtonItem = backButton
       
    }

    func dragview(_ panGestureRecognizer:UIPanGestureRecognizer) {
        let touchlocation = panGestureRecognizer.velocity(in: self.view)
        
        if  self.posicionInicialContenedor == CGFloat(0){
            self.posicionInicialContenedor = contenidoDeLaRecetaView.center.y
            scrollHaciaArriba = true
        }
        //CGFloat(8)//
        var delta = abs(touchlocation.y * 0.03)
        
        
        if touchlocation.y < 0 && contenidoDeLaRecetaView.center.y>0{
            
            let ajuste = contenidoDeLaRecetaView.center.y - delta
            if ajuste < 0{
                delta = abs(delta + ajuste)
            }
            
            contenidoDeLaRecetaView.center.y -= delta
        }else{
            
            let ajuste = contenidoDeLaRecetaView.center.y + delta
            if ajuste > self.posicionInicialContenedor + pantallaSizeScroll(){
                delta = 0
            }
            
            if touchlocation.y > 0 && contenidoDeLaRecetaView.center.y < self.posicionInicialContenedor + pantallaSizeScroll(){
                contenidoDeLaRecetaView.center.y += delta
            }
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        func display_image()
        {
                self.labelTitulo.text = ""
                self.imagenDificultad.image = nil
                self.labelPorciones.text = ""
                self.labelTiempo.text = ""
                self.textAreaReceta.text = ""
                self.textAreaReceta.text = ""
                self.imageViewReceta.image = nil
                self.imageViewReceta.alpha = 0.0
            
        }
        
        DispatchQueue.main.async(execute: display_image)

    }

    func loadRecetaInformation() {
        func display_image()
        {
            
            if (self.imagenReceta == nil){
                cargarImagen(self.objReceta["Url_Imagen"] as! String)
            }
            else{
                self.imageViewReceta.image = self.imagenReceta
            }

            self.labelTitulo.text = (self.objReceta["Nombre"] as! String)
            let nivelRecetaStr = (self.objReceta["Nivel"] as! String)
            
            if (nivelRecetaStr.lowercased() == "Principiante"){
                self.imagenDificultad.image = UIImage(named: "dificultadprincipiante")
            }else if(nivelRecetaStr.lowercased() == "intermedio"){
                self.imagenDificultad.image = UIImage(named: "dificultadmedia")
            }
            else{
                self.imagenDificultad.image = UIImage(named: "dificultadavanzado")
            }
            
            
            
            self.labelPorciones.text = (self.objReceta["Porciones"] as! String)
            self.labelTiempo.text = (self.objReceta["Tiempo"] as! String)
            
            var text: String = "Ingredientes \n" + (self.objReceta["Ingredientes"] as! String)
            text = text + ("\n\nProcedimiento\n" + (self.objReceta["Procedimiento"] as! String))
            let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: text)
            let str = NSString(string: text)
        
            let theRange1 = str.range(of: "Ingredientes")
            attributedText.addAttribute(NSFontAttributeName, value:UIFont.boldSystemFont(ofSize: pantallaSizeTitulo()), range: theRange1)
            let theRange2 = str.range(of: "Procedimiento")
            attributedText.addAttribute(NSFontAttributeName, value:UIFont.boldSystemFont(ofSize: pantallaSizeTitulo()), range: theRange2)
            
            let theRangeIngrediente = str.range(of: self.objReceta["Ingredientes"] as! String)
            attributedText.addAttribute(NSFontAttributeName, value:UIFont.systemFont(ofSize: pantallaSizeCuerpo()), range: theRangeIngrediente)
            let theRangeProcedimiento = str.range(of: self.objReceta["Procedimiento"] as! String)
            attributedText.addAttribute(NSFontAttributeName, value:UIFont.systemFont(ofSize: pantallaSizeCuerpo()), range: theRangeProcedimiento)
            
            self.textAreaReceta.attributedText = attributedText
            
            UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                
                self.imageViewReceta.alpha = 100
                
                
                }, completion: nil)
            
        }
        
        DispatchQueue.main.async(execute: display_image)
       
    }
    
    
    func pantallaSizeCuerpo()->CGFloat! {
        var strPantalla = 15 //iphone 5
        if (UIDevice.current.userInterfaceIdiom == .pad)
        {
            strPantalla = 25
        }
        else
        {
            
            if UIScreen.main.bounds.size.width > 320 {
                if UIScreen.main.scale == 3 { //iphone 6 plus
                    strPantalla = 15
                }
                else{
                    strPantalla = 15 //iphone 6
                }
            }
        }
        return CGFloat(strPantalla)
    }
    
    func pantallaSizeScroll()->CGFloat! {
        var strPantalla = 0 //iphone 5
        if (UIDevice.current.userInterfaceIdiom == .pad)
        {
            strPantalla = 0
        }
        else
        {
            
            if UIScreen.main.bounds.size.width > 320 {
                if UIScreen.main.scale == 3 { //iphone 6 plus
                    strPantalla = 100
                }
                else{
                    strPantalla = 100 //iphone 6
                }
            }
        }
        return CGFloat(strPantalla)
    }

    func pantallaSizeTitulo()->CGFloat! {
        var strPantalla = 20 //iphone 5
        if (UIDevice.current.userInterfaceIdiom == .pad)
        {
            strPantalla = 40
        }
        else
        {
            
            if UIScreen.main.bounds.size.width > 320 {
                if UIScreen.main.scale == 3 { //iphone 6 plus
                    strPantalla = 20
                }
                else{
                    strPantalla = 20 //iphone 6
                }
            }
        }
        return CGFloat(strPantalla)
    }
    
    func cargarImagen(_ url:String){
        
        let imgURL: URL = URL(string: url)!
        let request: URLRequest = URLRequest(url: imgURL)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: {
        (data, response, error) -> Void in
        
        if (error == nil && data != nil)
        {
             self.imageViewReceta.image = UIImage(data: data!)
        }
        
        })
        
        task.resume()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func bCompartir(_ sender: AnyObject) {
        abrirVentanaPop()
        
    }
    
    @IBAction func bLike(_ sender: AnyObject) {
        
        
        var usuario = false
        if PFUser.current() != nil {
            
            if PFFacebookUtils.isLinked(with: PFUser.current()!){
                usuario = true
            }
           /* else if PFTwitterUtils.isLinkedWithUser(PFUser.currentUser()!) {
                usuario = true
                
            }*/
            else if PFUser.current() != nil{
                usuario = true
                
            }
        }
        
        
        if (usuario == false){
            
            let alertController = UIAlertController(title: "Iniciar sesión obligatorio",
                message: "Para poder añadir esta reseta a favoritos es necesario iniciar sesión",
                preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addAction(UIAlertAction(title: "OK",
                style: UIAlertActionStyle.default,
                handler: nil))
            // Display alert
            self.present(alertController, animated: true, completion: nil)
            
        }
        else{
            let query = PFQuery(className: "Favoritos")
            query.includeKey("Recetas")
            query.whereKey("username", equalTo: PFUser.current()!)
            query.whereKey("Recetas", equalTo: self.objReceta)
            query.findObjectsInBackground {
                (recetas, error) -> Void in
                // comments now contains the comments for myPost
            
                if error == nil {
                
                    //Revisa si ese cliente tiene esa receta para mandar un mensaje de error al tratar de añadirla de nuevo
                    if recetas != nil && (recetas?.count)!>0 {
                 
                        // The object has been saved.
                        let alertController = UIAlertController(title: "¡Esta receta ya fue añadida!",
                        message: "Tu receta ya esta en la seccion de favoritos",
                        preferredStyle: UIAlertControllerStyle.alert)
                    
                        alertController.addAction(UIAlertAction(title: "OK",
                        style: UIAlertActionStyle.default,
                        handler: nil))
                        // Display alert
                        self.present(alertController, animated: true, completion: nil)
                }
                    //Añade la receta a favoritos
                else{
                 
                    let date = Date()
                    let calendar = Calendar.current
                    let components = (calendar as NSCalendar).components([.day , .month , .year], from: date)
                    
                    let year =  components.year
                    let month = components.month
                    let trimestre = Int(  (Double(month!)/3) + 0.7)
                    
                    
                    let favorito = PFObject(className:"Favoritos")
                    favorito["username"] = PFUser.current()
                    favorito["Anio"] = year
                    favorito["Mes"] = month
                    favorito["Trimestre"] = trimestre
                    favorito["Recetas"] = self.objReceta
                    
                    favorito.saveInBackground {
                        (success, error) -> Void in
                        if (success) {
                            self.imgButtonLike.image = UIImage(named: "like release")
                            
                            
                            // The object has been saved.
                            let alertController = UIAlertController(title: "Añadido a favoritos",
                                message: "¡Tu receta ya esta disponible en la seccion de favoritos!",
                                preferredStyle: UIAlertControllerStyle.alert)
                            
                                alertController.addAction(UIAlertAction(title: "OK",
                                style: UIAlertActionStyle.default,
                                handler: nil))
                                // Display alert
                                self.present(alertController, animated: true, completion: nil)
                            } else {
                                // There was a problem, check error.description
                            }
                        }
                    }
                }
                else
                {
                    //print(error!)
                }
            }
        }
    }
    
    func abrirVentanaPop(){

        self.popViewController = PopUpViewControllerCompartir(nibName: "PopUpViewControllerCompartir", bundle: nil)
        self.popViewController.showInView(self.view, animated: true, receta: self.objReceta, imagenReceta: self.imageViewReceta.image!)
        
    }
    
}
