//
//  PerfilViewController.swift
//  MenuDeslizante
//
//  Created by sergio ivan lopez monzon on 21/11/15.
//  Copyright © 2015 sergio ivan lopez monzon. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
import ParseFacebookUtilsV4
import TwitterKit
import Alamofire

class PerfilViewController: UIViewController  {
    let producto = "CocinaMexicanaRecetasFaciles"
    
    let productIdentifiers = Set(["CocinaMexicanaRecetasFaciles"])
    var product: SKProduct?
    var productsArray = Array<SKProduct>()
    
    @IBOutlet weak var Subdescripcion: UILabel!
    @IBOutlet weak var menuButton:UIBarButtonItem!
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var lCorreoElectronico: UILabel!
    @IBOutlet weak var lEstatus: UILabel!
    @IBOutlet weak var btnSuscripcion: UIButton!
   
    @IBOutlet weak var loadingAction: UIActivityIndicatorView!
    
    @IBOutlet weak var lHolderName: UILabel!
    @IBOutlet weak var lBrandName: UILabel!
    
    @IBOutlet weak var lCardNumber: UILabel!
    
    @IBOutlet weak var bEliminarTarjeta: UIButton!
    @IBOutlet weak var bTarjeta: UIImageView!
    
    @IBOutlet weak var bCerrarSesion: UIButton!
    @IBOutlet weak var bCancelarSuscripcion: UIButton!
    
    var btnPresionado = false
    var tarjetaObjeto:PFObject!
    var clienteObjeto:PFObject!
    
    var tarjetaSeleccionadaId:String!
    
    var options: [Subscription]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(PerfilViewController.activarSuscripcion), name: SubscriptionService.purchaseSuccessfulNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(PerfilViewController.activarSuscripcion), name: SubscriptionService.restoreSuccessfulNotification, object: nil)
//        Subdescripcion.isHidden = true
//        btnSuscripcion.isHidden = true
//        options = SubscriptionService.shared.options
        
//        if let option = options?.first {
//            let title = option.product.localizedTitle
//            let price = option.formattedPrice
//            Subdescripcion.text = "\(title) \(price)"
//            Subdescripcion.isHidden = false
//            btnSuscripcion.isHidden = false
//        }
        //presentCarrousel()
        //let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        //request.delegate = self
        //request.start()
        //SKPaymentQueue.default().add(self)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        if let suscrip = SubscriptionService.shared.currentSubscription {
            if suscrip.expiresDate > suscrip.purchaseDate {
                self.lEstatus.text = "Suscripcion activa hasta \(formatter.string(from: suscrip.expiresDate))"
                self.bCancelarSuscripcion.isHidden = false
            }
        }
        
        
        self.lEstatus.alpha = 0
        
        // Do any additional setup after loading the view, typically from a nib.
        self.loadingAction.startAnimating()
        self.loadingAction.isHidden = true
        self.bEliminarTarjeta.isHidden = true
        self.bCancelarSuscripcion.isHidden = true
        
        if revealViewController() != nil {
            //            revealViewController().rearViewRevealWidth = 62
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            let navBackgroundImage:UIImage! = UIImage(named: "bandasuperior")
            
            let nav = self.navigationController?.navigationBar
            
            nav?.tintColor = UIColor.white
            
            nav!.setBackgroundImage(navBackgroundImage, for:.default)

            revealViewController().rightViewRevealWidth = 150
            //    extraButton.target = revealViewController()
            //    extraButton.action = "rightRevealToggle:"
            
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
            if PFUser.current() != nil {
                
                if PFFacebookUtils.isLinked(with: PFUser.current()!){
                    getFBUserData()
                } else if(PFUser.current() != nil){
                    getParseUserData()
                    
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func activarSuscripcion() {
        DispatchQueue.main.async {
            self.lEstatus.text = "Suscripcion activa hasta \(String(describing: SubscriptionService.shared.currentSubscription?.expiresDate.description))"
        }
    }
    
    
    func presentCarrousel() {
        let VC = storyboard?.instantiateViewController(withIdentifier: "vc") as! RootViewController
        present(VC, animated: true, completion: nil)
    }
    
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    let dict = result as! NSDictionary
                    print(dict)
                    self.lCorreoElectronico.text = dict.object(forKey: "email") as? String
                
                    //self.restorePurchases()
                    //self.consultarCliente()
                    self.loadFBProfileImage(((dict.object(forKey: "picture") as AnyObject).object(forKey: "data") as AnyObject).object(forKey: "url") as! String)
                }
            })
        }
    }
    
    
    func loadFBProfileImage(_ url:String){
            
            let imgURL: URL = URL(string: url)!
            let request: URLRequest = URLRequest(url: imgURL)
            
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: {
                (data, response, error) -> Void in
                
                if (error == nil && data != nil)
                {
                    func display_image()
                    {
                        self.imageViewProfile.image = UIImage(data: data!)
                       

                        UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                            
                            self.imageViewProfile.alpha = 100
                            self.lCorreoElectronico.alpha = 100
                            self.bCerrarSesion.alpha = 100
                            
                            }, completion: nil)
                        
                    }
                    
                    DispatchQueue.main.async(execute: display_image)
                }
                
            })
            
            task.resume()
    }
    
    func getParseUserData(){
        
        self.lCorreoElectronico.text = PFUser.current()!.email
        self.imageViewProfile.image = UIImage(named: ("frida"))
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                
                self.imageViewProfile.alpha = 100
                
                self.lEstatus.alpha = 100
                
                //self.lNombreUsuario.alpha = 100
                
                self.bCerrarSesion.alpha = 100
                
                self.lCorreoElectronico.alpha = 100
                //self.consultarCliente()
                
            }, completion: nil)
        }
    }
    
//    func consultarCliente() {
//        
//        //self.lEstatus.alpha = 0
//        
//        let receiptURL = Bundle.main.appStoreReceiptURL
//        print(receiptURL!)
//        
//        do {
//            
//            
//            
//            let receipt = try Data(contentsOf: receiptURL!)
//            print(receipt)
//            
//            print("\n\n ******QUIERO SABER SI ESTOY AQUI****** \n\n")
//            
//            
//            
//            let requestContents: [String: Any] = [
//                "receipt-data": receipt.base64EncodedString(options: []),
//                "password": "b7f13ceae7454c23aba22b373352337b"
//            ]
//            
//            
//            let appleServer = receiptURL?.lastPathComponent == "sandboxReceipt" ? "sandbox" : "buy"
//            
//            let stringURL = "https://\(appleServer).itunes.apple.com/verifyReceipt"
//            
//            print("Loading user receipt: \(stringURL)...")
//            
//            _ = Alamofire.request(stringURL, method: .post, parameters: requestContents, encoding: JSONEncoding.default)
//                
//                .responseJSON { response in
//                    
//                    if let value = response.result.value as? NSDictionary {
//                        //  print(value)
//                        
//                        if let json = value["latest_receipt_info"] {
//                            
//                            var jsonStr = String(describing:json)
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
//                                            var suscrito = false
//                                            if date! < fechaActual as Date{
//                                                print("suscripcion esta expirada")
//                                                suscrito = false
//                                                
//                                            }
//                                            else{
//                                                print("suscripcion activa")
//                                                suscrito = true
//                                                
//                                            }
//                                            
//                                            if suscrito {
//                                                self.lEstatus.text = "Suscrito"
//                                                
//                                            }
//                                            else{
//                                                self.lEstatus.text = "Sin inscripción actual"
//                                                
//                                            }
//                                            
//                                            
//                                            func display_image()
//                                            {
//                                                
//                                                UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
//                                                    
//                                                    self.imageViewProfile.alpha = 100
//                                                    self.lEstatus.alpha = 100
//                                                    //self.lNombreUsuario.alpha = 100
//                                                    self.bCerrarSesion.alpha = 100
//                                                    self.lCorreoElectronico.alpha = 100
//                                                    self.loadingAction.stopAnimating()
//                                                    self.loadingAction.isHidden = true
//                                                    //self.consultarCliente()
//                                                }, completion: nil)
//                                                
//                                            }
//                                            
//                                            DispatchQueue.main.async(execute: display_image)
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
//        } catch { print("Couldn't read receipt data with error: " + error.localizedDescription) }
//        
//        
//    }

    
    @IBAction func cerrarSesion(_ sender: AnyObject) {
        
       PFUser.logOutInBackground { (error) -> Void in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "Login")
                self.present( vc! , animated: true, completion: nil)
        }
    }
    
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
//                
//            case SKPaymentTransactionState.restored:
//                SKPaymentQueue.default().finishTransaction(transaction)
//                SKPaymentQueue.default().remove(self)
//            default:
//                break
//            }
//        }
//    }
    
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
//
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
//    
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
//                consultarCliente()
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
//            if transaction.transactionState == SKPaymentTransactionState.restored {
//                SKPaymentQueue.default().finishTransaction(transaction)
//                SKPaymentQueue.default().remove(self)
//            }
//        }
//    }

    func load_image(_ urlString:String) {
        let imgURL: URL = URL(string: urlString)!
        let request: URLRequest = URLRequest(url: imgURL)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) -> Void in
            
            if (error == nil && data != nil)
            {
                func display_image()
                {
            //        self.imageViewBarCode.image = UIImage(data: data!)
                    self.loadingAction.stopAnimating()
                    self.loadingAction.isHidden = true
              //      self.lMensaje.hidden=true
                    
                }
                
                DispatchQueue.main.async(execute: display_image)
            }
            
        })
        
        task.resume()
    }

    func consultarWallet(_ cliente: PFObject ) {
        let query = PFQuery(className:"Tarjetas")
        query.whereKey("cliente", equalTo: cliente)
        query.findObjectsInBackground {
            (results, error) -> Void in
          //  self.lMensaje.hidden = true
            self.loadingAction.isHidden = true
            self.loadingAction.stopAnimating()
            
            if error == nil {
                // results
                for card in results!{
                    self.tarjetaObjeto = card
                    self.lBrandName.text = card["brand"] as? String!
                    self.lHolderName.text = cliente["nombre"] as? String!
                    /*let referenciaN = cliente["referenciaentienda"] as? String!
                    if referenciaN != nil && referenciaN != "" {
            //            self.lNumeroReferencia.text = referenciaN
                    }*/
                    
                    
                    let tarjetaId = (card["tarjetaPrincipal"] as? String)!
                    UserDefaults.standard.setValue(tarjetaId, forKey: "tarjetaId")
                    

                    
                    self.lCardNumber.text = card["numero"] as? String!
                    self.tarjetaSeleccionadaId = card["tarjetaPrincipal"] as? String!
                    self.lBrandName.isHidden = false
                    self.lHolderName.isHidden = false
                    self.lCardNumber.isHidden = false
                    
                    self.bEliminarTarjeta.isHidden = false
                    self.bTarjeta.isHidden = false
                    let EstatusInscrito =  (cliente["Suscrito"] as? Bool)!
                    if EstatusInscrito {
                        self.bCancelarSuscripcion.isHidden = false
                    }
                    
                }
                
            }
        }
    }
    
    @IBAction func btnCancelarSuscripcion(_ sender: AnyObject) {
        
      if btnPresionado == false{
        self.btnPresionado = true
        self.loadingAction.startAnimating()
        self.loadingAction.isHidden = false
        
        self.clienteObjeto["Suscrito"] = false
        self.clienteObjeto["codigobarras"] = ""
        self.clienteObjeto["idsuscripcion"] = ""
        self.clienteObjeto["caducidad"] = ""
        self.clienteObjeto["transaction_id_tienda"] = ""
        
        self.clienteObjeto.saveInBackground(block: { (sucess, error) -> Void in
            
            self.loadingAction.stopAnimating()
            self.loadingAction.isHidden = true
            self.bCancelarSuscripcion.isHidden = true
            self.btnPresionado = false
            let alertController = UIAlertController(title: "Suscripción cancelada",
                                                    message: "La suscripción se dió de baja correctamente",
                                                    preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addAction(UIAlertAction(title: "OK",
                                                    style: UIAlertActionStyle.default,
                                                    handler: nil))
            // Display alert
            self.present(alertController, animated: true, completion: nil)
            
            //self.consultarCliente()
            
        })
        
      }
    }
    
    @IBAction func btnEliminarTarjeta(_ sender: AnyObject) {
        
        if self.btnPresionado == false{
            
            btnPresionado = true
        
            self.loadingAction.startAnimating()
            self.loadingAction.isHidden = false
            
            self.tarjetaObjeto.deleteInBackground { (sucess, error) -> Void in
                
                
                func refresh()
                    
                {
                    self.loadingAction.stopAnimating()
                    self.loadingAction.isHidden = true
                    self.btnPresionado = false
                    self.lHolderName.isHidden = true
                    self.lBrandName.isHidden = true
                    self.lCardNumber.isHidden = true
                    //              self.lMensaje.hidden = true
                    
                    self.bEliminarTarjeta.isHidden = true
                    self.bTarjeta.isHidden = true
                    self.btnPresionado = false
                    
                    let alertController = UIAlertController(title: "Tarjeta Borrada",
                                                            message: "La tarjeta no se recuerda para este cliente",
                                                            preferredStyle: UIAlertControllerStyle.alert)
                    
                    alertController.addAction(UIAlertAction(title: "OK",
                                                            style: UIAlertActionStyle.default,
                                                            handler: nil))
                    // Display alert
                    self.present(alertController, animated: true, completion: nil)
                    
                    //self.consultarCliente()
                    
                    
                    
                }
                
                DispatchQueue.main.async(execute: refresh)
                
            }
        
          
        }
    }

}
