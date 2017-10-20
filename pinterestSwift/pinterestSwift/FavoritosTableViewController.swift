//
//  FavoritosTableViewController.swift
//  MenuDeslizante
//
//  Created by sergio ivan lopez monzon on 21/11/15.
//  Copyright © 2015 sergio ivan lopez monzon. All rights reserved.
//

import UIKit
import Parse
//import ParseTwitterUtils
//import ParseFacebookUtilsV4


class FavoritosTableViewController: UITableViewController {
    
    @IBOutlet weak var menuButton:UIBarButtonItem!
    var favoritos = [PFObject]()
    var recetaSeleccionada:PFObject!
    var imagenReceta:UIImage!
    var imagenes = [PFObject:UIImage]()
    var nombreTabla:String = "Favoritos"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
       // self.tableView.editing = true

        if revealViewController() != nil {
            //            revealViewController().rearViewRevealWidth = 62
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            revealViewController().rightViewRevealWidth = 150
            //    extraButton.target = revealViewController()
            //    extraButton.action = "rightRevealToggle:"
            
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
            
            //Si no se fue a la ventana que sigue quiere decir o que no esta suscrito
            var usuario = false
            if PFUser.current() != nil {
                
                /*if PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()!){
                    usuario = true
                }
                else if PFTwitterUtils.isLinkedWithUser(PFUser.currentUser()!) {
                    usuario = true
                    
                }
                else */if PFUser.current() != nil{
                    usuario = true
                    
                }
            }
            
            
            if (usuario == false){
                
                let alertController = UIAlertController(title: "Debe iniciar sesión",
                    message: "Para poder acceder a tu sección de favoritos debe iniciar sesión",
                    preferredStyle: UIAlertControllerStyle.alert)
                
                alertController.addAction(UIAlertAction(title: "OK",
                    style: UIAlertActionStyle.default,
                    handler: nil))
                // Display alert
                self.present(alertController, animated: true, completion: nil)
                
            }

            else{
                consultarFavoritos()
            }
            
            
        }
        
        
        let navBackgroundImage:UIImage! = UIImage(named: "bandasuperior")
        
        let nav = self.navigationController?.navigationBar
        
        nav?.tintColor = UIColor.white
        
        nav!.setBackgroundImage(navBackgroundImage, for:.default)
        
        let backButton = UIBarButtonItem(title: "atrás", style: UIBarButtonItemStyle.plain, target: self, action: nil)
        backButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 20)!], for: UIControlState())
        navigationItem.backBarButtonItem = backButton
        
        
        
        //Create the UIImage
        let image = UIImage(named: "fondorecetario")
        
        //Create a container view that will take all of the tableView space and contain the imageView on top
        let containerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width , height: UIScreen.main.bounds.size.height))
        
        //Create the UIImageView that will be on top of our table
        let imageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width , height: UIScreen.main.bounds.size.height))
        
        //Set the image
        imageView.image = image
        
        //Clips to bounds so the image doesnt go over the image size
        imageView.clipsToBounds = true
        
        //Scale aspect fill so the image doesn't break the aspect ratio to fill in the header (it will zoom)
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        
        containerView.addSubview(imageView)
        
        self.tableView.backgroundView = containerView
        
    }
    
    func consultarFavoritos(){
        let query = PFQuery(className: nombreTabla)
    //    query.cachePolicy = .CacheElseNetwork
        query.whereKey("username", equalTo: PFUser.current()!)
        query.includeKey("Recetas")
        query.findObjectsInBackground {
            (favoritos, error) -> Void in
            // comments now contains the comments for myPost
            
            if error == nil {
                
                //Si hay un cliente recupera su clientID y sale del metodo
                if let _ = favoritos as [PFObject]? {
                    self.favoritos = favoritos!
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                else{
                    
                    
                }
            }
            else
            {
                //print(error!)
            }
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete{
            self.favoritos[indexPath.row].deleteInBackground{
                (succeeded, error)  in
                
                // The object has been saved.
                let alertController = UIAlertController(title: "Receta Borrada",
                    message: "¡Esta receta ya no forma parte de tus " + self.nombreTabla.lowercased(),
                    preferredStyle: UIAlertControllerStyle.alert)
                
                alertController.addAction(UIAlertAction(title: "OK",
                    style: UIAlertActionStyle.default,
                    handler: nil))
                
                self.consultarFavoritos()
            }
            
        }
    }
    
    override func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return true
    }
    
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Borrar"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        
        if self.favoritos.count == 0 {
            
            let noDataLabel = UILabel.init(frame: CGRect(x: 10, y: 0, width: tableView.bounds.width-20, height: tableView.bounds.height))
            noDataLabel.numberOfLines = 0
            noDataLabel.font = UIFont(name: "AvenirNext-Bold", size: 28)
            noDataLabel.textColor = #colorLiteral(red: 0.9450579286, green: 0.4093458652, blue: 0.4025487006, alpha: 1)
            noDataLabel.textAlignment = .center
            noDataLabel.text = "Aún no tienes nada que te guste."
            
            tableView.backgroundView?.addSubview( noDataLabel )
            
        } else {
            tableView.backgroundView = UIImageView(image: UIImage(named: "fondorecetario"))
        }
        
        return self.favoritos.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.recetaSeleccionada = self.favoritos[indexPath.row].object(forKey: "Recetas") as! PFObject
        self.imagenReceta = self.imagenes[self.recetaSeleccionada]
        
        self.performSegue(withIdentifier: "PlatilloSegueFavoritos", sender: nil)
        
    }
    
    // para cuadrar las imagenes
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return pantallaSizeHeight();//Choose your custom row height
    }
    
    func pantallaSizeHeight()->CGFloat!
    {
        var strPantalla = 224.0 //iphone 5
        if (UIDevice.current.userInterfaceIdiom == .pad)
        {
            strPantalla = 500.0
        }
        else
        {
            
            if UIScreen.main.bounds.size.width > 320 {
                if UIScreen.main.scale == 3 { //iphone 6 plus
                    strPantalla = 286.0
                }
                else{
                    strPantalla = 266.0 //iphone 6
                }
            }
        }
        return CGFloat(strPantalla)
    }

    
    func loadCellInformation(_ imagenCell:UIImageView, urlString:String, nombreRecetaLabel:UILabel, nombreRecetaStr:String,  nivelRecetaImagen:UIImageView, nivelRecetaStr:String,  porcionesRecetaLabel:UILabel, porcionesRecetaStr:String,  tiempoRecetaLabel:UILabel, tiempoRecetaStr:String, receta:PFObject)
    {
        
        nombreRecetaLabel.text = nombreRecetaStr
        if (nivelRecetaStr.lowercased() == "principiante"){
            nivelRecetaImagen.image = UIImage(named: "flor1")
        }else if(nivelRecetaStr.lowercased() == "intermedio"){
            nivelRecetaImagen.image = UIImage(named: "flor2")
        }
        else{
            nivelRecetaImagen.image = UIImage(named: "flor3")
        }
        
        porcionesRecetaLabel.text = porcionesRecetaStr
        tiempoRecetaLabel.text = tiempoRecetaStr
        
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            
            nombreRecetaLabel.alpha = 100
            nivelRecetaImagen.alpha = 100
            porcionesRecetaLabel.alpha = 100
            tiempoRecetaLabel.alpha = 100
            
            
            }, completion: nil)
        

        if(self.imagenes[receta] == nil) {
        
            let imgURL: URL = URL(string: urlString)!
            let request: URLRequest = URLRequest(url: imgURL)
        
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: {
                (data, response, error) -> Void in
            
                if (error == nil && data != nil)
                {
                    func display_image()
                    {
                        imagenCell.image = UIImage(data: data!)
                    
                        self.imagenes[receta] = UIImage(data: data!)
                    
                        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                        
                        imagenCell.alpha = 100
                        
                        
                        }, completion: nil)

                    }
                
                    DispatchQueue.main.async(execute: display_image)
                }
            
            })
        
            task.resume()
        
        }
        else{
            imagenCell.image = self.imagenes[receta]
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MenuPlatillosTableViewCell
        
        let receta =  self.favoritos[indexPath.row].object(forKey: "Recetas") as! PFObject
        
        self.loadCellInformation(cell.imagenRecetaView, urlString: receta["Url_Imagen"] as! String, nombreRecetaLabel: cell.nombreRecetaLabel, nombreRecetaStr: receta["Nombre"] as! String, nivelRecetaImagen: cell.imgDificultad, nivelRecetaStr:  receta["Nivel"] as! String, porcionesRecetaLabel: cell.porcionesRecetaLabel, porcionesRecetaStr: receta["Porciones"] as! String, tiempoRecetaLabel: cell.tiempoRecetaLabel, tiempoRecetaStr:receta["Tiempo"] as! String, receta: receta)
        
        
        return cell
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "PlatilloSegueFavoritos"{
            let receta = segue.destination as!  PlatillosViewController
            receta.objReceta = self.recetaSeleccionada
        }

        
    }
    
    
}

