//
//  RegalosTableViewController.swift
//  MenuDeslizante
//
//  Created by sergio ivan lopez monzon on 08/02/16.
//  Copyright © 2016 sergio ivan lopez monzon. All rights reserved.
//

import UIKit
import Parse

//import ParseTwitterUtils
import ParseFacebookUtilsV4


class RegalosTableViewController: UITableViewController {
    
    
    @IBOutlet weak var menuButton:UIBarButtonItem!
    var itemsMenu = [PFObject]()
    
    var elimando = false
    //Para almacenar el numero de recetas de ese menú
    var numeroDeRecetasPorMenu = [PFObject:Int]()
    
    var imagesArray = [Int:UIImage]()
    
    var recetaSeleccionada:PFObject!
    var imagenReceta:UIImage!
    var imagenes = [PFObject:UIImage]()
    var nombreTabla:String = "Regalos"
    
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
        
        
        
        tableView.backgroundView = UIImageView(image: UIImage(named: "fondorecetario"))
        
        let backButton = UIBarButtonItem(title: "atrás", style: UIBarButtonItemStyle.plain, target: self, action: nil)
        backButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir Next", size: 20)!], for: UIControlState())
        navigationItem.backBarButtonItem = backButton
        
        
    }
    
    func consultarFavoritos(){
        
        
        self.numeroDeRecetasPorMenu.removeAll()
        self.numeroDeRecetasPorMenu = [PFObject:Int]()
        
        let query = PFQuery(className: nombreTabla)
        //    query.cachePolicy = .CacheElseNetwork
        query.whereKey("username", equalTo: PFUser.current()!)
        query.includeKey("Recetario")
        
        query.findObjectsInBackground {
            (menus, error) in
            // comments now contains the comments for myPost
            
            if error == nil {
                
                //Si hay un cliente recupera su clientID y sale del metodo
                if let _ = menus as [PFObject]? {
                    
                    self.itemsMenu = menus!
                    
                    for item in self.itemsMenu {
                        //Contar elementos de recetas en el menu principal
                        let queryReceta = PFQuery(className:"Recetas")
                        //queryReceta.cachePolicy = .CacheElseNetwork
                        queryReceta.whereKey("Menu", equalTo: item.object(forKey: "Recetario") as! PFObject)
                        queryReceta.countObjectsInBackground {
                            (count, error) in
                            if error == nil {
                                self.numeroDeRecetasPorMenu[item]=Int(count)
                                if self.numeroDeRecetasPorMenu.count == self.itemsMenu.count{
                                    DispatchQueue.main.async {
                                        
                                        self.tableView.reloadData()
                                    }
                                }
                                
                            }
                        }
                    }
                    
                    if(self.elimando){
                        DispatchQueue.main.async {
                            self.elimando = false
                            self.tableView.reloadData()
                        }
                    }

                   
                }
                else{
                    if(self.elimando){
                        DispatchQueue.main.async {
                            self.elimando = false
                            self.tableView.reloadData()
                        }
                    }
                    
                }
            }
            else
            {
                print(error)
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
    
    // para cuadrar las imagenes
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return pantallaSizeHeight();//Choose your custom row height
    }
    
    func pantallaSizeHeight()->CGFloat!
    {
        var strPantalla = CGFloat(224.0) //iphone 5
        if (UIDevice.current.userInterfaceIdiom == .pad)
        {
            strPantalla = UIScreen.main.bounds.size.height * CGFloat(0.47)
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

    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Borrar"
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete{
            self.itemsMenu[indexPath.row].deleteInBackground { (succeeded, error) in
                
                self.elimando = true
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
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.itemsMenu.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PrincipalTableViewCell
        
        self.recetaSeleccionada = itemsMenu[indexPath.row]
        
        self.performSegue(withIdentifier: "recetarios", sender: nil)
       
        
        
    }
    func loadCellInformation(_ imagenCell:UIImageView, numeroLabelView:UILabel, urlString:String, numeroRedecetas:Int, tipoMenuLabel:UILabel, nombreMenu:String, rowIndex:Int)
    {
        
        if self.imagesArray.count <= rowIndex {
            
            self.cargarImagenInternet(imagenCell, numeroLabelView: numeroLabelView, urlString:urlString, numeroRedecetas: numeroRedecetas , tipoMenuLabel: tipoMenuLabel, nombreMenu: nombreMenu, rowIndex:  rowIndex)
        }
        else{
            
            self.cargarImagenesMemoria(imagenCell, numeroLabelView: numeroLabelView, urlString:urlString, numeroRedecetas: numeroRedecetas , tipoMenuLabel: tipoMenuLabel, nombreMenu: nombreMenu, rowIndex:  rowIndex)
        }
        
        
    }
    
    func cargarImagenesMemoria(_ imagenCell:UIImageView, numeroLabelView:UILabel, urlString:String, numeroRedecetas:Int, tipoMenuLabel:UILabel, nombreMenu:String, rowIndex:Int){
        func display_image()
        {
            imagenCell.image = self.imagesArray[rowIndex]
            numeroLabelView.text = String(numeroRedecetas)+" recetas";
            tipoMenuLabel.text = nombreMenu
            
            UIView.animate(withDuration: 0.1, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                
                imagenCell.alpha = 100
                
                
                }, completion: nil)
            
            
        }
        
        DispatchQueue.main.async(execute: display_image)
        
    }
    
    func cargarImagenInternet(_ imagenCell:UIImageView, numeroLabelView:UILabel, urlString:String, numeroRedecetas:Int, tipoMenuLabel:UILabel, nombreMenu:String, rowIndex:Int){
        
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
                    self.imagesArray[rowIndex]=imagenCell.image
                    numeroLabelView.text = String(numeroRedecetas)+" recetas";
                    tipoMenuLabel.text = nombreMenu
                    
                    UIView.animate(withDuration: 0.1, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                        
                        imagenCell.alpha = 100
                        
                        
                        }, completion: nil)
                    
                    
                }
                
                DispatchQueue.main.async(execute: display_image)
            }
        })
        task.resume()
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PrincipalTableViewCell
        
        cell.lNumeroRecetas.transform = CGAffineTransform(rotationAngle: CGFloat(-0.85))
        
        let menu = self.itemsMenu[indexPath.row]
        
        let item = menu.object(forKey: "Recetario") as! PFObject
        print(item.objectId)
        

        //ocultamos si es tipo menu viral el icono de postit
      /*  if ((item["TipoMenu"] as? String)?.lowercaseString) == "viral"{
            cell.lNumeroRecetas.hidden = true
            cell.imgCinta.hidden = true
            cell.imgPaquete.hidden = true
            cell.imgPagoGratis.hidden = true
            
        }*/
        //se carga la informacion del menu
        
        
        if(indexPath.row == 0){
            cell.imgBottomDevider.isHidden = true;
        }
        
        if(indexPath.row == self.itemsMenu.count-1){
            cell.imgTopDevider.isHidden = true;
        }
        
        let urlImagen = item["Url_Imagen"] as? String!
        
        var numeroRecetas = 10
        if let checkedNumeroRecetas: AnyObject? = self.numeroDeRecetasPorMenu[item] as AnyObject??{
            if let _ = checkedNumeroRecetas as? NSNull{ numeroRecetas = 10 }
            else { numeroRecetas = checkedNumeroRecetas as! Int } }
        else { numeroRecetas = 10 }
        
        //let numeroRecetas = 2
        let nombre = (item["NombreMenu"] as? String)!
        
        self.loadCellInformation(cell.postImageView, numeroLabelView:  cell.lNumeroRecetas, urlString:urlImagen!, numeroRedecetas: numeroRecetas , tipoMenuLabel: cell.nombreLabelMenu, nombreMenu: nombre, rowIndex:  indexPath.row)
        
        

        
        
        return cell
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "recetarios"{
            let menu = segue.destination as!  MenuPlatillos
            menu.menuSeleccionado = self.recetaSeleccionada.object(forKey: "Recetario") as! PFObject
        }
        
    }
    
    
}

