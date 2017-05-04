//
//  SearchResultsViewController.swift
//  BuscadorSwift
//
//  Created by sergio ivan lopez monzon on 17/02/16.
//  Copyright © 2016 devworms. All rights reserved.
//

import UIKit
import Parse
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

//import ParseTwitterUtils
//import  ParseFacebookUtilsV4

class SearchResultsViewController: SearchControllerBaseViewController, UISearchResultsUpdating {
    // MARK: Types
    
    var searchController: UISearchController!

    //var popViewControllerWallet : PopUpViewControllerWallet!
    //var popViewControllerTarjeta : PopUpViewControllerTarjetas!
    var popAbierto = false
    
    struct StoryboardConstants {
        /**
         The identifier string that corresponds to the `SearchResultsViewController`'s
         view controller defined in the main storyboard.
         */
        static let identifier = "SearchResultsViewControllerStoryboardIdentifier"
        
        
        
    }
    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        /*
        `updateSearchResultsForSearchController(_:)` is called when the controller is
        being dismissed to allow those who are using the controller they are search
        as the results controller a chance to reset their state. No need to update
        anything if we're being dismissed.
        */
        guard searchController.isActive else { return }
        
        self.searchController = searchController
        self.searchController.searchBar.placeholder = "buscar"
         filterString = searchController.searchBar.text
         //busqueda = searchController.searchBar.text
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = UIImageView(image: UIImage(named: "fondorecetario"))
        obtenerTags()
        
    }
    
    func obtenerTags(){
        
        let query = PFQuery(className: "Tags")
        query.includeKey("Receta")
        query.findObjectsInBackground(block: { (tags, error) in
            if error == nil {
                
                //Si hay un cliente recupera su clientID y sale del metodo
                if let _ = tags as [PFObject]? {
                    
                    for tag in tags! {
                        
                        if  tag.object(forKey: "Receta") != nil {
                            let objReceta = (tag.object(forKey: "Receta") as? PFObject)!
                            
                            self.allResults.append((tag["Tag"] as? String)!)
                            self.allTags[(tag["Tag"] as? String)!] = objReceta
                        }
                    }
                }
            }
                
            else{
                
                
            }
        })
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MenuPlatillosTableViewCell
        
        if visibleResults.count >= 1{
            let keyString = self.visibleResults[indexPath.row]
            let objReceta = self.allTags[keyString]
            let imgReceta = self.imagenes[objReceta!]
            
            cell.imagenRecetaView.image = imgReceta
            cell.nombreRecetaLabel.text = objReceta!["Nombre"] as? String
            cell.porcionesRecetaLabel.text = objReceta!["Porciones"] as? String
            cell.tiempoRecetaLabel.text = objReceta!["Tiempo"] as? String
            let nivelRecetaStr = objReceta!["Nivel"] as! String
            
            
            if (nivelRecetaStr.lowercased() == "principiante"){
                cell.imgDificultad.image = UIImage(named: "flor1")
            }else if(nivelRecetaStr.lowercased() == "intermedio"){
                cell.imgDificultad.image = UIImage(named: "flor2")
            }
            else{
                cell.imgDificultad.image = UIImage(named: "flor3")
            }
            
            
           
            
            if(imgReceta == nil){
                cargarImagenes(objReceta!, imagenRecetaView:  cell.imagenRecetaView, nombreRecetaLabel:cell.nombreRecetaLabel,  porcionesRecetaLabel:cell.porcionesRecetaLabel, tiempoRecetaLabel:cell.tiempoRecetaLabel, imgDificultad:cell.imgDificultad)
            }else{
                display_image(cell.imagenRecetaView, nombreRecetaLabel:cell.nombreRecetaLabel,  porcionesRecetaLabel:cell.porcionesRecetaLabel, tiempoRecetaLabel:cell.tiempoRecetaLabel, imgDificultad:cell.imgDificultad)
            }
            
            
            
            print(keyString)
            
            
        }
        
        return cell
    }
    
    
    func cargarImagenes(_ receta:PFObject, imagenRecetaView: UIImageView, nombreRecetaLabel:UILabel,  porcionesRecetaLabel:UILabel, tiempoRecetaLabel:UILabel, imgDificultad:UIImageView){
        
        let urlImagen = receta["Url_Imagen"] as? String
        let imgURL: URL = URL(string: urlImagen!)!
        let request: URLRequest = URLRequest(url: imgURL)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) -> Void in
            
            if (error == nil && data != nil){
                //let tagString = (tag["Tag"] as? String)!
                
                
                self.imagenes[receta] = UIImage(data: data!)
                imagenRecetaView.image = UIImage(data: data!)
                
                func display_image()
                {
                    
                    UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                        
                        imagenRecetaView.alpha = 100
                        nombreRecetaLabel.alpha = 100
                        porcionesRecetaLabel.alpha = 100
                        tiempoRecetaLabel.alpha = 100
                        imgDificultad.alpha = 100
                        
                        
                        }, completion: nil)
                    
                    
                }
                
                DispatchQueue.main.async(execute: display_image)
                
                
                
                
            }
        })
        task.resume()
        
    }
    
    func display_image(_ imagenRecetaView: UIImageView, nombreRecetaLabel:UILabel,  porcionesRecetaLabel:UILabel, tiempoRecetaLabel:UILabel, imgDificultad:UIImageView)
    {
        
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            
            imagenRecetaView.alpha = 100
            nombreRecetaLabel.alpha = 100
            porcionesRecetaLabel.alpha = 100
            tiempoRecetaLabel.alpha = 100
            imgDificultad.alpha = 100
            
            
            }, completion: nil)
        
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let keyString = self.visibleResults[indexPath.row]
        let objReceta = self.allTags[keyString]
        self.recetaSeleccionada = objReceta
        self.imagenRecetaSeleccionada = self.imagenes[recetaSeleccionada]
        abrirReceta(objReceta!)
    }
    
    func abrirReceta(_ objReceta:PFObject){
        
        let objMenu = (objReceta.object(forKey: "Menu") as? PFObject)!
        let identificador = objMenu.objectId;
        let query = PFQuery(className: "Menus")
        
        query.whereKey("objectId", equalTo: identificador!)
        query.findObjectsInBackground {
            (lstMenus, error) in
            // comments now contains the comments for myPost
            
            if error == nil {
                
                //Si hay un cliente recupera su clientID y sale del metodo
                if let _ = lstMenus as [PFObject]? {
                    
                    for menu in lstMenus! {
                        
                        if (menu["TipoMenu"] as AnyObject).lowercased == "pago"{
                            var usuario = false
                            if PFUser.current() != nil {
                                /*
                                if PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()!){
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
                                    message: "Para poder acceder al contenido de pago debe iniciar sesión",
                                    preferredStyle: UIAlertControllerStyle.alert)
                                
                                alertController.addAction(UIAlertAction(title: "OK",
                                    style: UIAlertActionStyle.default,
                                    handler: nil))
                                // Display alert
                                self.present(alertController, animated: true, completion: nil)
                                
                            }
                            else{
                                self.consultarSuscripcion()
                            }
                        }
                        else
                        {

                            self.parentViewView.objBusqueda = self.recetaSeleccionada
                            self.parentViewView.imagenBusqueda = self.imagenRecetaSeleccionada
                            self.searchController.isActive = false
                            self.parentViewView.performSegue(withIdentifier: "PlatilloSegueBuscador", sender: nil)
                        }
                        
                    }
                }
            }
        }
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
    

    
    func consultarSuscripcion(){
        let query = PFQuery(className: "Clientes")
        //query.cachePolicy = .CacheElseNetwork
        query.whereKey("username", equalTo: PFUser.current()!)
        query.findObjectsInBackground {
            (clientes, error) in
            // comments now contains the comments for myPost
            
            if error == nil {
                
                //Si hay un cliente recupera su clientID y sale del metodo
                if let _ = clientes as [PFObject]? {
                    for cliente in clientes! {
                        
                        
                        let clientId = (cliente["clientID"] as? String)!
                        
                        UserDefaults.standard.setValue(clientId, forKey: guardarEnMemoria.clienteId)
                        
                        
                        
                        OpenPayRestApi.consultarSuscripcion(cliente)
                        
                        
                        
                        // This does not require a network access.
                        if ((cliente["Suscrito"] as? Bool) != nil && (cliente["Suscrito"] as? Bool)==true){
                            self.parentViewView.objBusqueda = self.recetaSeleccionada
                            self.parentViewView.imagenBusqueda = self.imagenRecetaSeleccionada
                            self.searchController.isActive = false
                            
                            self.parentViewView.performSegue(withIdentifier: "PlatilloSegueBuscador", sender: nil)
                            
                            
                            /*// se consulta si se pago en la tienda
                             let today = NSDate()
                             
                             let dateFormatter = NSDateFormatter()
                             dateFormatter.dateFormat = "yyyy-MM-dd"
                             
                             let date = dateFormatter.dateFromString((cliente["Caducidad"] as? String)!)
                             
                             if today.compare(date!) != NSComparisonResult.OrderedDescending
                             {
                             self.performSegueWithIdentifier("PlatilloSegue", sender: nil)
                             }
                             else{
                             
                             OpenPayRestApi.consultarSuscripcion(cliente["clientID"] as? String, callBack: { (mensaje) -> Void in
                             
                             if(mensaje == "cancelled" || mensaje == "unpaid" || mensaje == "1005"){
                             cliente["Suscrito"] = false
                             cliente.saveInBackground()
                             self.abrirVentana(cliente)
                             }
                             
                             })
                             }*/
                            
                            //self.abrirVentana(cliente)
                        }
                        else{
                            self.abrirVentana(cliente)
                            
                        }
                        
                        break
                    }
                    
                    if (clientes?.count==0)
                    {
                        if let savedValue = UserDefaults.standard.string(forKey: "7 dias mostrado") {
                            // Do something with savedValue
                            if(savedValue != "true"){
                                UserDefaults.standard.set("false", forKey: "7 dias mostrado")
                                print("7 días?1")
                                self.abrirVentanaPop()
                            }
                            else{
                             /*   self.popViewControllerTarjeta = PopUpViewControllerTarjetas(nibName: "PopUpViewControllerTarjetas", bundle: nil)
                                self.popViewControllerTarjeta.contextSearch = self
                                
                                self.popViewControllerTarjeta.showInView(self.view)*/
                            }
                        } else {
                            UserDefaults.standard.set("false", forKey: "7 dias mostrado")
                            
                            self.abrirVentanaPop()
                        }
                        
                        
                    }
                }
                else{
                    
                }
            }
            else
            {
                print(error)
            }
        }
        
    }
    
    func abrirVentana(_ cliente: PFObject){
        //let clienteId = cliente["clientID"] as? String
        //   let transaccionId = cliente["transaction_id_tienda"]
        //   let barras = cliente["codigobarras"]
        
        /*if clienteId != nil && transaccionId != nil && barras != nil && (barras as? String) != ""   {
         OpenPayRestApi.consultarPagoReailzadoenTienda(cliente["clientID"] as? String, chargeId:     (cliente["transaction_id_tienda"] as? String)!, callBack: { (exito, mensaje) -> Void in
         
         if exito {
         self.performSegueWithIdentifier("PlatilloSegue", sender: nil)
         }
         else{
         print("7 días?1")
         self.abrirVentanaPop(self.precioPlan, suscripcion:  true, planId:  self.planId)
         }
         })
         }else{
         print("7 días?2")
         self.abrirVentanaPop(self.precioPlan, suscripcion:  true, planId:  self.planId)
         }*/
        
        if popAbierto == false {
            popAbierto = true
        
        print(cliente.objectId)
        let query = PFQuery(className: "Tarjetas")
        query.whereKey("cliente", equalTo: cliente)
        query.findObjectsInBackground {
            (tarjetas, error) in
            // comments now contains the comments for myPost
            
            if error == nil {
                
                //Si hay un cliente recupera su clientID y sale del metodo
                if let _ = tarjetas as [PFObject]? {
                    if(tarjetas?.count>0){
                        for _ in tarjetas! {
                        /*
                            self.popViewControllerWallet = PopUpViewControllerWallet(nibName: "PopUpViewControllerWallet", bundle: nil)
                            self.popViewControllerWallet.ventanaSearch = self
                            
                            self.popViewControllerWallet.showInView(self.view)
                            */
                            break
                        }
                    }
                    else{
                        
                        
                        if let savedValue = UserDefaults.standard.string(forKey: "7 dias mostrado") {
                            // Do something with savedValue
                            if(savedValue != "true"){
                                UserDefaults.standard.set("false", forKey: "7 dias mostrado")
                                print("7 días?1")
                                self.abrirVentanaPop()
                            }
                            else{
                             /*   self.popViewControllerTarjeta = PopUpViewControllerTarjetas(nibName: "PopUpViewControllerTarjetas", bundle: nil)
                                self.popViewControllerTarjeta.contextSearch = self
                                
                                self.popViewControllerTarjeta.showInView(self.view)*/
                            }
                        } else {
                            UserDefaults.standard.set("false", forKey: "7 dias mostrado")
                            
                            self.abrirVentanaPop()
                        }
                        
                        
                    }
                    
                }
                else{
                    
                    if let savedValue = UserDefaults.standard.string(forKey: "7 dias mostrado") {
                        // Do something with savedValue
                        if(savedValue != "true"){
                            UserDefaults.standard.set("false", forKey: "7 dias mostrado")
                            print("7 días?1")
                            self.abrirVentanaPop()
                        }
                        else{
                          /*  self.popViewControllerTarjeta = PopUpViewControllerTarjetas(nibName: "PopUpViewControllerTarjetas", bundle: nil)
                            self.popViewControllerTarjeta.contextSearch = self
                            
                            self.popViewControllerTarjeta.showInView(self.view)*/
                        }
                    } else {
                        UserDefaults.standard.set("false", forKey: "7 dias mostrado")
                        
                        self.abrirVentanaPop()
                    }
                    
                    
                }
                
            }
            else
            {
                print(error)
            }
        }
        }
        
        
    }

    func abrirVentanaPop(){
        
        if popAbierto == false {
            popAbierto = true
            
            let popViewController = PopUpViewControllerDescripcion(nibName: "PopUpViewControllerDescripcion", bundle: nil)
            popViewController.contextSearch = self
            self.tableView.isScrollEnabled = false
            popViewController.showInView(self.view)
            
        }
        
    } 

}
