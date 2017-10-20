//
//  NewsTableViewController.swift
//  MenuDeslizante
//
//  Created by sergio ivan lopez monzon on 17/11/15.
//  Copyright © 2015 sergio ivan lopez monzon. All rights reserved.
//

import UIKit
import Parse

class PrincipalTableViewController: UITableViewController {
    @IBOutlet weak var menuButton:UIBarButtonItem!
    
    var backViewController = UIView()
    var vista = UIView()


    //Para decirnos cual es la opcion que corresponde a cada posicion del menu
    
    var tipoMenu = ""
    
    var itemsMenu = [PFObject]()
    var imagesArray = [Int:UIImage]()
    var menuSeleccionado:PFObject!
    //Para almacenar el numero de recetas de ese menú
    var numeroDeRecetasPorMenu = [PFObject:Int]()
    
    // `searchController` cuando el boton de busqueda es presionado
    var searchController: UISearchController!

    var objBusqueda:PFObject!
    var imagenBusqueda:UIImage!
    
    var popAbierto = false
    
    var popViewController: PopUpViewControllerCompartir!
    
    var iMinSessions = 3
    var iTryAgainSessions = 6
    
    func rateMe() {
        let neverRate = UserDefaults.standard.bool(forKey: "neverRate")
        var numLaunches = UserDefaults.standard.integer(forKey: "numLaunches") + 1
        
        if (!neverRate && (numLaunches == iMinSessions || numLaunches >= (iMinSessions + iTryAgainSessions + 1)))
        {
            showRateMe()
            numLaunches = iMinSessions + 1
        }
        UserDefaults.standard.set(numLaunches, forKey: "numLaunches")
    }
    
    func showRateMe() {
        let alert = UIAlertController(title: nil, message: "\n\n\n\n\n\n\n\n\n", preferredStyle: UIAlertControllerStyle.alert)
        
        let imageView = UIImageView(frame: CGRect(x: 50, y: 5, width: 180, height: 240))
        imageView.image = UIImage(named: "califica")
        
        alert.view.addSubview(imageView)
        
        alert.addAction(UIAlertAction(title: "Califica nuestra App", style: UIAlertActionStyle.default, handler: { alertAction in
            
            UIApplication.shared.open( URL(string: "itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=1295822690")! , options: [:], completionHandler: nil)
            
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "No gracias", style: UIAlertActionStyle.default, handler: { alertAction in
            UserDefaults.standard.set(true, forKey: "neverRate")
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Talvez después", style: UIAlertActionStyle.default, handler: { alertAction in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
       //Image Background Navigation Bar
        
        let img = pantallaSizeWeight()
        
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)
        
        navigationController?.navigationBar.tintColor = UIColor.black
        
        navigationController?.navigationBar.barStyle = UIBarStyle.default
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        
        let backButton = UIBarButtonItem(title: "atrás", style: UIBarButtonItemStyle.plain, target: self, action: nil)
        backButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir Next", size: 20)!], for: UIControlState())
        navigationItem.backBarButtonItem = backButton
        
      ///  navigationController?.navigationBar.topItem?.title = "¿Qué se te antoja comer?"
        
        
        //Create the UIImage
        let image = UIImage(named: "fondo")
        
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
        
        
        
        self.numeroDeRecetasPorMenu.removeAll()
        self.numeroDeRecetasPorMenu = [PFObject:Int]()
       
      
        // cargamos las imagenes
            let query = PFQuery(className: "Menus")
            query.whereKey("Activo", equalTo: true)
            //query.cachePolicy = .CacheElseNetwork
            query.order(byAscending: "Orden")
            query.findObjectsInBackground {
                (items, error) -> Void in
                // comments now contains the comments for myPost
                
                if error == nil {
                    //Si hay un cliente recupera su clientID y sale del metodo
                    if let _ = items as [PFObject]? {
                        self.itemsMenu = items!
                        
                        for item in items! {
                            //Contar elementos de recetas en el menu principal
                            let queryReceta = PFQuery(className:"Recetas")
                            //queryReceta.cachePolicy = .CacheElseNetwork
                            queryReceta.whereKey("Menu", equalTo: item)
                            queryReceta.whereKey("Activada", equalTo: true)
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
    
    override func viewDidLoad() {
     super.viewDidLoad()
     self.tableView.delegate = self
     
        self.tableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(PrincipalTableViewController.fail), name: SubscriptionService.failNotification, object: nil)
        
        if revealViewController() != nil {
            //            revealViewController().rearViewRevealWidth = 62
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            revealViewController().rightViewRevealWidth = 150
        //    extraButton.target = revealViewController()
        //    extraButton.action = "rightRevealToggle:"
            
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
            
        }
        
        self.rateMe()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fail() {
        showAlertDefault(title: "Error", message: "No se pudo procesar tu compra")
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.itemsMenu.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        //let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PrincipalTableViewCell
        
        self.menuSeleccionado = itemsMenu[indexPath.row]
        
        let goto=(self.menuSeleccionado["TipoMenu"] as AnyObject).lowercased

        if goto=="gratis"
        {
            self.performSegue(withIdentifier: "recetarios", sender: nil)
        } else if goto == "pago" {
            //SubscriptionService.shared.restorePurchases()
            if let fechaEx = SubscriptionService.shared.currentSubscription?.expiresDate {
                if fechaEx > Date() {
                    self.performSegue(withIdentifier: "recetarios", sender: nil)
                }
            } else {
                //if UserDefaults.standard.bool(forKey: "carrouselSuscripcion") {
                //    showAlert(title: "Suscripcion", message: "Suscribete y obten acceso a información")
                //} else {
                    presentCarrousel()
                //}
            }

        }
        else if goto=="viral" && imagesArray.count > 0
        {
            
           
            let query = PFQuery(className: "Regalos")
            query.whereKey("username", equalTo: PFUser.current()!)
            query.whereKey("Recetario", equalTo: self.menuSeleccionado)
            query.findObjectsInBackground {
                (regalos, error) -> Void in
                // comments now contains the comments for myPost
                
                if error == nil {
                    
                    //Si hay un cliente recupera su clientID y sale del metodo
                    if let _ = regalos as [PFObject]? {
                       if (regalos?.count)! > 0 {
                            
                            self.performSegue(withIdentifier: "recetarios", sender: nil)
                        }
                       else{
                            let imagen =   self.imagesArray[indexPath.row]
                            self.abrirVentanaPop(self.menuSeleccionado, imageViewReceta: imagen)
                        
                        
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
        
        
    }
     
    func abrirVentanaPop(_ objMenu:PFObject!, imageViewReceta: UIImage!){
        
        if(imageViewReceta != nil && popAbierto == false){
            self.popViewController = PopUpViewControllerCompartir(nibName: "PopUpViewControllerCompartir", bundle: nil)
            self.popAbierto = true
            self.tableView.isScrollEnabled = false
            self.popViewController.context = self
            self.popViewController.opcion = "viral"
            let imagen = imageViewReceta
            self.popViewController.showInView(self.view, animated: true, receta: objMenu, imagenReceta: imagen!)
        }
        
        
    }
    
    func presentCarrousel() {
        
        backViewController = UIView.init(frame:  CGRect(x: 0.0, y: 0.0, width: view.bounds.height, height: view.bounds.maxY) )//aView.bounds)
        backViewController.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        vista = UIView.init(frame: CGRect(x: (view.bounds.width/8)*1, y: ((view.bounds.height/8)*1), width: (view.bounds.width/8)*6, height: (view.bounds.height/8)*6))
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(PrincipalTableViewController.tapGes))
        backViewController.addGestureRecognizer(tap)
        
        vista.center = CGPoint(x: view.bounds.width/2, y: view.bounds.midY+32)
        let VC = storyboard?.instantiateViewController(withIdentifier: "vc") as! RootViewController
        self.addChildViewController(VC)
        vista.addSubview(VC.view)
        VC.didMove(toParentViewController: self)

        VC.view.frame = vista.bounds
        VC.view.translatesAutoresizingMaskIntoConstraints = false
        
        
        let width = NSLayoutConstraint(item: VC.view, attribute: .width, relatedBy: .equal, toItem: vista, attribute: .width, multiplier: 1.0, constant: 0)
        let height = NSLayoutConstraint(item: VC.view, attribute: .height, relatedBy: .equal, toItem: vista, attribute: .height, multiplier: 1.0, constant: 0)
        let top = NSLayoutConstraint(item: VC.view, attribute: .top, relatedBy: .equal, toItem: vista, attribute: .top, multiplier: 1.0, constant: 0)
        let leading = NSLayoutConstraint(item: VC.view, attribute: .leading, relatedBy: .equal, toItem: vista, attribute: .leading, multiplier: 1.0, constant: 0)
        
        vista.addConstraint(width)
        vista.addConstraint(height)
        vista.addConstraint(top)
        vista.addConstraint(leading)
        
        view.addSubview(backViewController)
        view.addSubview(vista)
        
        self.popAbierto = true
        self.tableView.isScrollEnabled = false
        
        showAnimate()
        
        
        VC.statusView = { (value) in
            if value {
                self.removeAnimate()
                //UserDefaults.standard.set(true, forKey: "carrouselSuscripcion")
                if let suscrip = SubscriptionService.shared.options?.first {
                    SubscriptionService.shared.purchase(subscription: suscrip)
                }
            }
        }

    }
    
    func tapGes() {
        removeAnimate()
    }
    
    func showAnimate()
    {
        vista.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        vista.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.vista.alpha = 1.0
            self.vista.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.vista.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.vista.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                self.backViewController.removeFromSuperview()
                self.vista.removeFromSuperview()
                
                self.popAbierto = false
                self.tableView.isScrollEnabled = true
                
            }
        });
    }

    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { (action) in
            if let suscrip = SubscriptionService.shared.options?.first {
                SubscriptionService.shared.purchase(subscription: suscrip)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func showAlertDefault(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PrincipalTableViewCell
        
        cell.imgBottomDevider.isHidden = false
        cell.imgTopDevider.isHidden = false
      
        
        cell.lNumeroRecetas.transform = CGAffineTransform(rotationAngle: CGFloat(-0.85))
        
        let item = self.itemsMenu[indexPath.row]
        let tipoMenu = (item["TipoMenu"] as? String)?.lowercased()
        
        cell.lNumeroRecetas.isHidden = false
        //cell.imgCinta.hidden = false
        //cell.imgPaquete.hidden = false
        cell.imgPagoGratis.isHidden = false
        
        //ocultamos si es tipo menu viral el icono de postit
        if  tipoMenu == "viral"{
        
            cell.imgPagoGratis.image = UIImage(named: "viral")
        } else if tipoMenu == "gratis"{
            cell.imgPagoGratis.image = UIImage(named: "gratis")
        
        }else{
            cell.imgPagoGratis.image = UIImage(named: "premium")
        }
        //se carga la informacion del menu
        
        
        if(indexPath.row == 0){
            cell.imgBottomDevider.isHidden = true;
        }
        
        if(indexPath.row == self.itemsMenu.count-1){
            cell.imgTopDevider.isHidden = true;
        }
        
        let urlImagen = item["Url_Imagen"] as? String!
        
        //print(item.objectId)
        //print(self.numeroDeRecetasPorMenu)
        
        var numeroRecetas = 10
        
        
        
        if let checkedNumeroRecetas: AnyObject = self.numeroDeRecetasPorMenu[item] as AnyObject?{
            if let _ = checkedNumeroRecetas as? NSNull{ numeroRecetas = 10 }
            else { numeroRecetas = checkedNumeroRecetas as! Int } }
            else { numeroRecetas = 10 }
        
        
        //let numeroRecetas  = 2
        let nombre = (item["NombreMenu"] as? String)!
        
        self.loadCellInformation(cell.postImageView, numeroLabelView:  cell.lNumeroRecetas, urlString:urlImagen!, numeroRedecetas: numeroRecetas , tipoMenuLabel: cell.nombreLabelMenu, nombreMenu: nombre, rowIndex:  indexPath.row)
        
      
        return cell
 
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "recetarios"{
            let menu = segue.destination as!  MenuPlatillos
            menu.menuSeleccionado = self.menuSeleccionado
        }
       
        else if segue.identifier == "buscador"{
            
            
            // Create the search results view controller and use it for the `UISearchController`.
            //let destinationNavigationController = segue.destinationViewController as! UINavigationController
            //let searchResultsController = destinationNavigationController.topViewController as!  SearchResultsViewController
            
            let searchResultsController = segue.destination as!  SearchResultsViewController
            searchResultsController.parentViewView = self
            // Create the search controller and make it perform the results updating.
            searchController = UISearchController(searchResultsController: searchResultsController)
            searchController.searchResultsUpdater = searchResultsController
            searchController.hidesNavigationBarDuringPresentation = false
            
            
            // Present the view controller.
            present(searchController, animated: true, completion: nil)

        }else if segue.identifier == "PlatilloSegueBuscador"{
            
            let receta = segue.destination as!  PlatillosViewController
            receta.imagenReceta = self.imagenBusqueda
            receta.objReceta = self.objBusqueda
            
          
        }
        
        
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
    
    // para cuadrar las imagenes
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return pantallaSizeHeight();//Choose your custom row height
    }
    
    
    func pantallaSizeWeight()->UIImage!{
        var strPantalla = "fondofloresiphone5"
        if (UIDevice.current.userInterfaceIdiom == .pad)
        {
            if (UIScreen.main.bounds.size.width >= 768 && UIScreen.main.bounds.size.width<2048){
                strPantalla = "fondofloresipadmini"
            }else{
                strPantalla = "fondofloresipad"
            }
            
        }
        else
        {
            
            if UIScreen.main.bounds.size.width > 320 {
                if UIScreen.main.scale == 3 { //iphone 6 plus
                    strPantalla = "fondofloresiphone6plus"
                }
                else{
                    strPantalla = "fondofloresiphone6" //iphone 6
                }
            }
        }
        
        
        return UIImage(named: strPantalla)?.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 15, 0, 15), resizingMode: UIImageResizingMode.stretch)
        
      }
    func pantallaSizeHeight()->CGFloat!
    {
        var strPantalla = CGFloat(224.0) //iphone 5
        if (UIDevice.current.userInterfaceIdiom == .pad)
        {
            strPantalla = 510//UIScreen.mainScreen().bounds.size.height * CGFloat(0.47)
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
    
    
    // buscador
    
    @IBAction func searchButtonClicked(_ button: UIBarButtonItem) {

        self.performSegue(withIdentifier: "buscador", sender: nil)
    }

    

}

