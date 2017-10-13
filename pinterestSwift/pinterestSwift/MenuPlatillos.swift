//
//  PlatillosView.swift
//  MenuDeslizante
//
//  Created by sergio ivan lopez monzon on 21/11/15.
//  Copyright © 2015 sergio ivan lopez monzon. All rights reserved.
//
import UIKit
import Parse
import ParseFacebookUtilsV4
import Alamofire

//import ParseTwitterUtils
//import ParseFacebookUtilsV4

class MenuPlatillos: UITableViewController {
    
    let producto = "CocinaMexicanasRecetasFaciles"
    
    let productIdentifiers = Set(["CocinaMexicanasRecetasFaciles"])
    var product: SKProduct?
    var productsArray = Array<SKProduct>()
    
    //Esta variable viene desde menu principal y hace referencia a los menus que deben de comprarse
    
    var menuSeleccionado:PFObject!
    var recetaSeleccionada:PFObject!
    var imagenRecetaSeleccionada:UIImage!
    
    // var popViewControllerWallet : PopUpViewControllerWallet!
    //var popViewControllerTarjeta : PopUpViewControllerTarjetas!
    var recetas = [PFObject]()
    var imagenes = [PFObject:UIImage]()
    var popAbierto = false
    
    @IBOutlet weak var labelMenuSeleccionado: UILabel!
    var popViewController : PopUpViewControllerDescripcion!
    
    override func viewWillAppear(_ animated: Bool) {
        
        //Image Background Navigation Bar
        
         //let navBackgroundImage:UIImage! = UIImage(named: "bandasuperior")
         
         //let nav = self.navigationController?.navigationBar
         
         //nav?.tintColor = UIColor.white
         
         //nav!.setBackgroundImage(navBackgroundImage, for:.default)
        
        let backButton = UIBarButtonItem(title: "atrás", style: UIBarButtonItemStyle.plain, target: self, action: nil)
        backButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir Next", size: 20)!], for: UIControlState())
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
        
        consultarRecetasDeMenu()
        
        //self.popViewController = PopUpViewControllerDescripcion(nibName: "PopUpViewControllerDescripcion", bundle: nil)
        //self.popViewController.context = self
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadMenuInformation(labelMenuSeleccionado, nombreMenu: menuSeleccionado["NombreMenu"] as! String)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
       
    }
    
    func consultarRecetasDeMenu() {
        let query = PFQuery(className:"Recetas")
        query.whereKey("Menu", equalTo:self.menuSeleccionado)
        query.whereKey("Activada", equalTo:true)
        //query.cachePolicy = .CacheElseNetwork
        query.findObjectsInBackground {
            (objects, error) in
            
            if error == nil {
                // The find succeeded.
                //print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    
                    self.recetas = objects
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }

                }
            } else {
                // Log details of the failure
                //print("Error: \(error!) \(String(describing: error!._userInfo))")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlatilloCell", for: indexPath) as! MenuPlatillosTableViewCell
        
        cargarContenido(cell, indexPath: indexPath)
        
        return cell
    }
    
    func cargarContenido(_ cell: MenuPlatillosTableViewCell, indexPath:IndexPath ){
        let receta = self.recetas[indexPath.row]
        
        let imgReceta = self.imagenes[receta]
        
        if (imgReceta == nil){
            self.loadCellInformation(cell.imagenRecetaView, urlString: receta["Url_Imagen"] as! String, nombreRecetaLabel: cell.nombreRecetaLabel, nombreRecetaStr: receta["Nombre"] as! String, nivelRecetaImagen: cell.imgDificultad, nivelRecetaStr:  receta["Nivel"] as! String, porcionesRecetaLabel: cell.porcionesRecetaLabel, porcionesRecetaStr: receta["Porciones"] as! String, tiempoRecetaLabel: cell.tiempoRecetaLabel, tiempoRecetaStr:receta["Tiempo"] as! String, objReceta:receta)
        }
        else{
            loadCellInformationCache(cell.imagenRecetaView, urlString: receta["Url_Imagen"] as! String, nombreRecetaLabel: cell.nombreRecetaLabel, nombreRecetaStr: receta["Nombre"] as! String, nivelRecetaImagen: cell.imgDificultad, nivelRecetaStr:  receta["Nivel"] as! String, porcionesRecetaLabel: cell.porcionesRecetaLabel, porcionesRecetaStr: receta["Porciones"] as! String, tiempoRecetaLabel: cell.tiempoRecetaLabel, tiempoRecetaStr:receta["Tiempo"] as! String, imgReceta:imgReceta!)
        }
        

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recetas.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.recetaSeleccionada = self.recetas[indexPath.row]
        imagenRecetaSeleccionada = imagenes[recetaSeleccionada];
        abrirReceta(indexPath)
    }
    
    
    func abrirReceta( _ indexPath:IndexPath ){
        
        if (self.menuSeleccionado["TipoMenu"] as AnyObject).lowercased == "pago"{
            
            if let fechaEx = SubscriptionService.shared.currentSubscription?.expiresDate {
                if fechaEx > Date() {
                    self.performSegue(withIdentifier: "PlatilloSegue", sender: nil)
                }
            }
            
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
                    message: "Para poder acceder al contenido de pago debe iniciar sesión",
                    preferredStyle: UIAlertControllerStyle.alert)
                
                alertController.addAction(UIAlertAction(title: "OK",
                    style: UIAlertActionStyle.default,
                    handler: nil))
            }
            else{
                //self.restorePurchases()
                //consultarSuscripcion()
            }
        }
        else
        {
            self.performSegue(withIdentifier: "PlatilloSegue", sender: nil)
        }
    }
    
//    func restorePurchases() {
//        SKPaymentQueue.default().add(self)
//        SKPaymentQueue.default().restoreCompletedTransactions()
//    }
//    
//    @available(iOS 3.0, *)
//    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
//        
//        for transaction in transactions {
//            
//            switch transaction.transactionState {
//                
//            case SKPaymentTransactionState.purchased:
//                print("Transaction Approved")
//                print("Product Identifier: \(transaction.payment.productIdentifier)")
//                self.deliverProduct(transaction)
//                SKPaymentQueue.default().finishTransaction(transaction)
//                
//            case SKPaymentTransactionState.failed:
//                print("Transaction Failed")
//                SKPaymentQueue.default().finishTransaction(transaction)
//            default:
//                break
//            }
//        }
//    }
//    
//    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
//        
//        var products = response.products
//        
//        if (products.count != 0) {
//            for i in 0 ..< products.count
//            {
//                self.product = products[i]
//                self.productsArray.append(product!)
//            }
//            /*self.viewDidLoad()
//             self.viewWillAppear(true)
//             */
//        } else {
//            print("No products found")
//        }
//        print(response.description)
//        //let productos = response.invalidProductIdentifiers
//        
//        for product in 0 ..< products.count
//        {
//            print("Product not found: \(product)")
//        }
//    }
    
    
//    func deliverProduct(_ transaction:SKPaymentTransaction) {
//        
//        if transaction.payment.productIdentifier == "com.brianjcoleman.testiap1"
//        {
//            print("Consumable Product Purchased")
//            // Unlock Feature
//        }
//        else if transaction.payment.productIdentifier == "com.brianjcoleman.testiap2"
//        {
//            print("Non-Consumable Product Purchased")
//            // Unlock Feature
//        }
//        else if transaction.payment.productIdentifier == "CocinaMexicanaRecetasFaciles"
//        {
//            print("Auto-Renewable Subscription Product Purchased")
//            
//            
//            // Unlock Feature
//        }
//        else if transaction.payment.productIdentifier == "com.brianjcoleman.testiap4"
//        {
//            print("Free Subscription Product Purchased")
//            // Unlock Feature
//        }
//        else if transaction.payment.productIdentifier == "com.brianjcoleman.testiap5"
//        {
//            print("Non-Renewing Subscription Product Purchased")
//            // Unlock Feature
//        }
//    }
    
//    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
//        print("Transactions Restored")
//        
//        // var purchasedItemIDS = Array()
//        for transaction:SKPaymentTransaction in queue.transactions {
//            
//            if transaction.payment.productIdentifier == "com.brianjcoleman.testiap1"
//            {
//                print("Consumable Product Purchased")
//                // Unlock Feature
//            }
//            else if transaction.payment.productIdentifier == "com.brianjcoleman.testiap2"
//            {
//                print("Non-Consumable Product Purchased")
//                // Unlock Feature
//            }
//            else if transaction.payment.productIdentifier == "CocinaMexicanaRecetasFaciles"
//            {
//                print("Auto-Renewable Subscription Product Purchased")
//                // Unlock Feature
//                
//                self.consultarSuscripcion()
//                //print(transaction.payment.rec)
//            }
//            else if transaction.payment.productIdentifier == "com.brianjcoleman.testiap4"
//            {
//                print("Free Subscription Product Purchased")
//                // Unlock Feature
//            }
//            else if transaction.payment.productIdentifier == "com.brianjcoleman.testiap5"
//            {
//                print("Non-Renewing Subscription Product Purchased")
//                // Unlock Feature
//            }
//            
//            
//        }
//        
//        /*var alert = UIAlertView(title: "Thank You", message: "Your purchase(s) were restored.", delegate: nil, cancelButtonTitle: "OK")
//         alert.show()*/
//    }
    

    
    
//    func consultarSuscripcion(){
//        
//       /* let suscripcion = PagosIAP()
//        suscripcion.requestProductData()
//        suscripcion.isSubscripcionActiva(resultado: { (res) in
//            if(res){
//                self.performSegue(withIdentifier: "PlatilloSegue", sender: nil)
//            }
//            else{
//                self.abrirVentanaPop()
//    
//            }
//            
//        })*/
//        
//            
//            
//            //NSDictionary *dictLatestReceiptsInfo = response[@"latest_receipt_info"];
//            //long expirationDateMs = [dictLatestReceiptsInfo valueForKeyPath:@"@max.expires_date_ms"];
//            
//        
//        let receiptURL = Bundle.main.appStoreReceiptURL
//        
//        let receipt = NSData(contentsOf: receiptURL!)
//        
//        let requestContents: [String: Any] = [
//        
//            "receipt-data": receipt!.base64EncodedString(options: []),
//            
//            "password": "b7f13ceae7454c23aba22b373352337b"
//            
//        ]
//            
//        
//        let appleServer = receiptURL?.lastPathComponent == "sandboxReceipt" ? "sandbox" : "buy"
//        
//        
//        
//        let stringURL = "https://\(appleServer).itunes.apple.com/verifyReceipt"
//        
//        
//        
//        print("Loading user receipt: \(stringURL)...")
//        
//        
//        
//        _ = Alamofire.request(stringURL, method: .post, parameters: requestContents, encoding: JSONEncoding.default)
//        
//            .responseJSON { response in
//            
//                if let value = response.result.value as? NSDictionary {
//                        //  print(value)
//                        
//                
//                    if let json = value["latest_receipt_info"] {
//                            
//                            
//                    
//                        var jsonStr = String(describing:json)
//                            jsonStr.remove(at: jsonStr.index(before: jsonStr.endIndex))
//                            jsonStr.remove(at: jsonStr.startIndex)
//                            jsonStr = jsonStr.replacingOccurrences(of: ";", with: ",")
//                            jsonStr = jsonStr.replacingOccurrences(of: "=", with: ":")
//                            jsonStr = jsonStr.replacingOccurrences(of: "quantity", with: "\"quantity\"")
//                            jsonStr = jsonStr.replacingOccurrences(of: self.producto, with: "\""+self.producto+"\"")
//                            jsonStr = jsonStr.replacingOccurrences(of: ",\n    }", with: "\n    }")
//                            jsonStr = " [ "+jsonStr+" ] "
//                            print(jsonStr)
//                            
//                            
//                            if let data = jsonStr.data(using: .utf8) {
//                                do {
//                                    if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]{
//                                        print(jsonArray.count)
//                                        let ultimaSubscripcion = jsonArray.last
//                                        if var dateString = ultimaSubscripcion?["expires_date"] as? String{
//                                            dateString = dateString.replacingOccurrences(of: "Etc/GMT", with: "")
//                                            print(dateString)
//                                            
//                                            let dateFormatter = DateFormatter()
//                                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //Your date format
//                                            dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT") as TimeZone!
//                                            
//                                            let date = dateFormatter.date(from: dateString) //according to date format your date string
//                                            
//                                            let fechaActual =  NSDate()
//                                            
//                                            print(date ?? "", fechaActual) //Convert String to Date
//                                            
//                                            if date! < fechaActual as Date{
//                                                print("suscripcion esta expirada")
//                                                self.abrirVentanaPop()
//                                            }
//                                            else{
//                                                print("suscripcion activa")
//                                                
//                                                self.performSegue(withIdentifier: "PlatilloSegue", sender: nil)
//                                            }
//                                            
//                                        }
//                                        
//                                    }
//                                    
//                                    
//                                } catch {
//                                    print(error.localizedDescription)
//                                }
//                            }
//                            
//                            
//                        }
//                    } else {
//                        print("Receiving receipt from App Store failed: \(response.result)")
//                    }
//            }
//            
//            
//            
//            // let currentTime = NSDate().timeIntervalSince1970 let expired = currentTime > expiresTime
//        
//
//    }
    
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
        
        //print(cliente.objectId)
        let query = PFQuery(className: "Tarjetas")
        query.whereKey("cliente", equalTo: cliente)
        query.findObjectsInBackground {
            (tarjetas, error) in
            // comments now contains the comments for myPost
            
            if error == nil {
                
                //Si hay un cliente recupera su clientID y sale del metodo
                if let _ = tarjetas as [PFObject]? {
                    if((tarjetas?.count)!>0){
                        for _ in tarjetas! {
                       
                   /*         self.popViewControllerWallet = PopUpViewControllerWallet(nibName: "PopUpViewControllerWallet", bundle: nil)
                            self.popViewControllerWallet.ventanaMenuPlatillos = self
                        
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
                                //print("7 días?1")
                                self.abrirVentanaPop()
                            }
                            else{
                          /*      self.popViewControllerTarjeta = PopUpViewControllerTarjetas(nibName: "PopUpViewControllerTarjetas", bundle: nil)
                                self.popViewControllerTarjeta.context = self
                                
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
                            //print("7 días?1")
                            self.abrirVentanaPop()
                        }
                        else{
                           /* self.popViewControllerTarjeta = PopUpViewControllerTarjetas(nibName: "PopUpViewControllerTarjetas", bundle: nil)
                            self.popViewControllerTarjeta.context = self
                            
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
                //print(error!)
            }
        }

        

    }
    
    /*override func viewWillDisappear(_ animated: Bool) {
        let img = pantallaSizeWeight()
        
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)
        
        navigationController?.navigationBar.tintColor = UIColor.black
        
        navigationController?.navigationBar.barStyle = UIBarStyle.default
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        
        let backButton = UIBarButtonItem(title: "atrás", style: UIBarButtonItemStyle.plain, target: self, action: nil)
        backButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir Next", size: 20)!], for: UIControlState())
        navigationItem.backBarButtonItem = backButton
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
        
    }*/

    
    func loadCellInformationCache(_ imagenCell:UIImageView, urlString:String, nombreRecetaLabel:UILabel, nombreRecetaStr:String,  nivelRecetaImagen:UIImageView, nivelRecetaStr:String,  porcionesRecetaLabel:UILabel, porcionesRecetaStr:String,  tiempoRecetaLabel:UILabel, tiempoRecetaStr:String, imgReceta: UIImage)
    {
        
        
            func display_image()
                {
                    imagenCell.image = imgReceta
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
                        
                        imagenCell.alpha = 100
                        nombreRecetaLabel.alpha = 100
                        nivelRecetaImagen.alpha = 100
                        porcionesRecetaLabel.alpha = 100
                        tiempoRecetaLabel.alpha = 100
                        
                        
                        }, completion: nil)
                    
                }
                
                DispatchQueue.main.async(execute: display_image)
        
    }
    
    func loadCellInformation(_ imagenCell:UIImageView, urlString:String, nombreRecetaLabel:UILabel, nombreRecetaStr:String,  nivelRecetaImagen:UIImageView, nivelRecetaStr:String,  porcionesRecetaLabel:UILabel, porcionesRecetaStr:String,  tiempoRecetaLabel:UILabel, tiempoRecetaStr:String, objReceta: PFObject)
    {
        
        func display_image()
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
        
        }
        
        DispatchQueue.main.async(execute: display_image)

        
        let imgURL: URL = URL(string: urlString)!
        let request: URLRequest = URLRequest(url: imgURL)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) -> Void in
            
            if (error == nil && data != nil)
            {
                self.imagenes[objReceta] = UIImage(data: data!)

                func display_image()
                {
                    imagenCell.image = self.imagenes[objReceta]
                    
                    
                    UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                        
                        imagenCell.alpha = 100
                        
                        
                        }, completion: nil)

                }
                
                DispatchQueue.main.async(execute: display_image)
            }
            
        })
        
        task.resume()
    }

    
    func loadMenuInformation(_ tipoMenuLabel:UILabel, nombreMenu:String)
    {
    
        tipoMenuLabel.text = nombreMenu
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

    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
        if segue.identifier == "PlatilloSegue"{
            let receta = segue.destination as!  PlatillosViewController
          
            receta.objReceta = self.recetaSeleccionada
            receta.imagenReceta = imagenes[self.recetaSeleccionada]
        }
        
    }
    
    
    func abrirVentanaPop(){
        
        if popAbierto == false {
           popAbierto = true
         
            self.tableView.isScrollEnabled = false
            self.popViewController.showInView(self.view)
        }
        
    }

}
