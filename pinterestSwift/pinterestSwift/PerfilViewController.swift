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


class PerfilViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver  {
    let producto = "CocinaMexicanaRecetasFaciles"
    
    let productIdentifiers = Set(["CocinaMexicanaRecetasFaciles"])
    var product: SKProduct?
    var productsArray = Array<SKProduct>()
    
    @IBOutlet weak var menuButton:UIBarButtonItem!
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var lCorreoElectronico: UILabel!
    @IBOutlet weak var lEstatus: UILabel!
   
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SKPaymentQueue.default().add(self)
        
        self.lEstatus.alpha = 0
        
        // Do any additional setup after loading the view, typically from a nib.
        self.loadingAction.startAnimating()
        self.loadingAction.isHidden = false
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
    
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    let dict = result as! NSDictionary
                    print(dict)
                    self.lCorreoElectronico.text = dict.object(forKey: "email") as? String
                
                    self.restorePurchases()
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
        
        func display_image()
        {
            UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            
                self.imageViewProfile.alpha = 100
                
                self.lEstatus.alpha = 100
                
                //self.lNombreUsuario.alpha = 100
                
                self.bCerrarSesion.alpha = 100
                
                self.lCorreoElectronico.alpha = 100
                self.consultarCliente()
                
            }, completion: nil)
            
        }
        
        DispatchQueue.main.async(execute: display_image)
        
    }
    
    @IBAction func cerrarSesion(_ sender: AnyObject) {
        
       PFUser.logOutInBackground { (error) -> Void in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "Login")
                self.present( vc! , animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
        
    }
    
    @available(iOS 3.0, *)
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            
            switch transaction.transactionState {
                
            case SKPaymentTransactionState.purchased:
                print("Transaction Approved")
                print("Product Identifier: \(transaction.payment.productIdentifier)")
                self.deliverProduct(transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case SKPaymentTransactionState.failed:
                print("Transaction Failed")
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case SKPaymentTransactionState.restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
            default:
                break
            }
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        var products = response.products
        
        if (products.count != 0) {
            for i in 0 ..< products.count
            {
                self.product = products[i]
                self.productsArray.append(product!)
            }
            /*self.viewDidLoad()
             self.viewWillAppear(true)
             */
        } else {
            print("No products found")
        }
        print(response.description)
        //let productos = response.invalidProductIdentifiers
        
        for product in 0 ..< products.count
        {
            print("Product not found: \(product)")
        }
    }

    func deliverProduct(_ transaction:SKPaymentTransaction) {
        
        if transaction.payment.productIdentifier == "com.brianjcoleman.testiap1"
        {
            print("Consumable Product Purchased")
            // Unlock Feature
        }
        else if transaction.payment.productIdentifier == "com.brianjcoleman.testiap2"
        {
            print("Non-Consumable Product Purchased")
            // Unlock Feature
        }
        else if transaction.payment.productIdentifier == "CocinaMexicanaRecetasFaciles"
        {
            print("Auto-Renewable Subscription Product Purchased")
            
            
            // Unlock Feature
        }
        else if transaction.payment.productIdentifier == "com.brianjcoleman.testiap4"
        {
            print("Free Subscription Product Purchased")
            // Unlock Feature
        }
        else if transaction.payment.productIdentifier == "com.brianjcoleman.testiap5"
        {
            print("Non-Renewing Subscription Product Purchased")
            // Unlock Feature
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("Transactions Restored")
        
        // var purchasedItemIDS = Array()
        for transaction:SKPaymentTransaction in queue.transactions {
            
            if transaction.payment.productIdentifier == "com.brianjcoleman.testiap1"
            {
                print("Consumable Product Purchased")
                // Unlock Feature
            }
            else if transaction.payment.productIdentifier == "com.brianjcoleman.testiap2"
            {
                print("Non-Consumable Product Purchased")
                // Unlock Feature
            }
            else if transaction.payment.productIdentifier == "CocinaMexicanaRecetasFaciles"
            {
                print("Auto-Renewable Subscription Product Purchased")
                // Unlock Feature
                
                consultarCliente()
                //print(transaction.payment.rec)
            }
            else if transaction.payment.productIdentifier == "com.brianjcoleman.testiap4"
            {
                print("Free Subscription Product Purchased")
                // Unlock Feature
            }
            else if transaction.payment.productIdentifier == "com.brianjcoleman.testiap5"
            {
                print("Non-Renewing Subscription Product Purchased")
                // Unlock Feature
            }
            
            if transaction.transactionState == SKPaymentTransactionState.restored {
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
            }
        }
        
    }

    func consultarCliente() {
        self.lEstatus.alpha = 0
        
        
        let receiptURL = Bundle.main.appStoreReceiptURL
        
        let receipt = NSData(contentsOf: receiptURL!)
        
        let requestContents: [String: Any] = [
            
            "receipt-data": receipt!.base64EncodedString(options: []),
            
            "password": "b7f13ceae7454c23aba22b373352337b"
            
        ]
        
        
        let appleServer = receiptURL?.lastPathComponent == "sandboxReceipt" ? "sandbox" : "buy"
        
        
        
        let stringURL = "https://\(appleServer).itunes.apple.com/verifyReceipt"
        
        
        
        print("Loading user receipt: \(stringURL)...")
        
        
        
        _ = Alamofire.request(stringURL, method: .post, parameters: requestContents, encoding: JSONEncoding.default)
            
            .responseJSON { response in
                
                if let value = response.result.value as? NSDictionary {
                    //  print(value)
                    
                    
                    if let json = value["latest_receipt_info"] {
                        
                        
                        
                        var jsonStr = String(describing:json)
                        jsonStr.remove(at: jsonStr.index(before: jsonStr.endIndex))
                        jsonStr.remove(at: jsonStr.startIndex)
                        jsonStr = jsonStr.replacingOccurrences(of: ";", with: ",")
                        jsonStr = jsonStr.replacingOccurrences(of: "=", with: ":")
                        jsonStr = jsonStr.replacingOccurrences(of: "quantity", with: "\"quantity\"")
                        jsonStr = jsonStr.replacingOccurrences(of: self.producto, with: "\""+self.producto+"\"")
                        jsonStr = jsonStr.replacingOccurrences(of: ",\n    }", with: "\n    }")
                        jsonStr = " [ "+jsonStr+" ] "
                        print(jsonStr)
                        
                        
                        if let data = jsonStr.data(using: .utf8) {
                            do {
                                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]{
                                    print(jsonArray.count)
                                    let ultimaSubscripcion = jsonArray.last
                                    if var dateString = ultimaSubscripcion?["expires_date"] as? String{
                                        dateString = dateString.replacingOccurrences(of: "Etc/GMT", with: "")
                                        print(dateString)
                                        
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //Your date format
                                        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT") as TimeZone!
                                        
                                        let date = dateFormatter.date(from: dateString) //according to date format your date string
                                        
                                        let fechaActual =  NSDate()
                                        
                                        print(date ?? "", fechaActual) //Convert String to Date
                                        
                                        var suscrito = false
                                        if date! < fechaActual as Date{
                                            print("suscripcion esta expirada")
                                            suscrito = false
                                            
                                        }
                                        else{
                                            print("suscripcion activa")
                                            suscrito = true

                                        }
                                        
                                        if suscrito {
                                            self.lEstatus.text = "Suscrito"
                                           
                                        }
                                        else{
                                            self.lEstatus.text = "Sin inscripción actual"
                                            
                                        }
                                        
                                        
                                        func display_image()
                                        {
                                            
                                            UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                                                
                                                self.imageViewProfile.alpha = 100
                                                self.lEstatus.alpha = 100
                                                //self.lNombreUsuario.alpha = 100
                                                self.bCerrarSesion.alpha = 100
                                                self.lCorreoElectronico.alpha = 100
                                                self.loadingAction.stopAnimating()
                                                self.loadingAction.isHidden = true
                                                //self.consultarCliente()
                                            }, completion: nil)
                                            
                                        }
                                        
                                        DispatchQueue.main.async(execute: display_image)
                                        
                                    }
                                    
                                }
                                
                                
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                        
                        
                    }
                } else {
                    print("Receiving receipt from App Store failed: \(response.result)")
                }
        }
    }
    
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
                    UserDefaults.standard.setValue(tarjetaId, forKey: guardarEnMemoria.tarjetaId)
                    

                    
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
        
        let headers = [
            "content-type": "application/json",
            "authorization": pagoOpenPay.auth,
            "cache-control": "no-cache",
            "postman-token": "be18bd94-8ab2-4c9f-03ac-c298ae52c8c5"
        ]
        
        let clienteId = UserDefaults.standard.value(forKey: guardarEnMemoria.clienteId)! as? String
        
        let suscripcion =  (self.clienteObjeto["idsuscripcion"] as? String)!
        
        let  strUrl = pagoOpenPay.url+pagoOpenPay.merchantId+"/customers/"
        let strParams = clienteId! + "/subscriptions/"+suscripcion
        let request = NSMutableURLRequest(url: URL(string: strUrl+strParams)!,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.httpMethod = "DELETE"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
                self.loadingAction.stopAnimating()
                self.loadingAction.isHidden = true
                self.bCancelarSuscripcion.isHidden = true
                self.btnPresionado = false
                let alertController = UIAlertController(title: "Error de cancelación",
                    message: "La suscripción no puede darse de baja por el momento, intente mas tarde",
                    preferredStyle: UIAlertControllerStyle.alert)
                
                alertController.addAction(UIAlertAction(title: "OK",
                    style: UIAlertActionStyle.default,
                    handler: nil))
                
                // Display alert
                self.present(alertController, animated: true, completion: nil)
                
            
            } else {
            
                    print(response)
                    let httpResponse = response as? HTTPURLResponse
                    print(httpResponse)
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
                            
                        self.consultarCliente()
                        
                    })
                
                }
        })
        
        dataTask.resume()
      }
    }
    
    @IBAction func btnEliminarTarjeta(_ sender: AnyObject) {
        
        if self.btnPresionado == false{
            btnPresionado = true
        
        self.loadingAction.startAnimating()
        self.loadingAction.isHidden = false
            
            
            let headers = [
                "content-type": "application/json",
                "authorization": pagoOpenPay.auth,
                "cache-control": "no-cache",
                "postman-token": "9528190e-c10d-887a-3588-55fce902c283"
            ]
            let clienteId = UserDefaults.standard.value(forKey: guardarEnMemoria.clienteId)! as? String
            let tarjeId = UserDefaults.standard.value(forKey: guardarEnMemoria.tarjetaId)! as? String
            
            let strUrl =  pagoOpenPay.url+pagoOpenPay.merchantId+"/customers/"+clienteId!+"/cards/"+tarjeId!
            
            let request = NSMutableURLRequest(url: URL(string:strUrl)!,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            request.httpMethod = "DELETE"
            request.allHTTPHeaderFields = headers
            
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if (error != nil) {
                    print(error)
                    self.loadingAction.stopAnimating()
                    self.loadingAction.isHidden = true
                    self.bCancelarSuscripcion.isHidden = true
                    let alertController = UIAlertController(title: "Error de eliminacion",
                        message: "La tarjeta no puede darse de baja por el momento, intente mas tarde",
                        preferredStyle: UIAlertControllerStyle.alert)
                    
                    alertController.addAction(UIAlertAction(title: "OK",
                        style: UIAlertActionStyle.default,
                        handler: nil))
                    
                    // Display alert
                    self.present(alertController, animated: true, completion: nil)
                    
                    
                } else {
                    let httpResponse = response as? HTTPURLResponse
                    print(httpResponse)
                    
                    do {
                        
                        let resstr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                        print(resstr)
                        
                        if resstr != ""{
                        let respuesta = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:AnyObject]
                        
                        
                        let error = (respuesta["error_code"])
                        
                        if (error == nil){
                            
                            print(response)
                            let httpResponse = response as? HTTPURLResponse
                            print(httpResponse)
                            
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
                                    
                                    self.consultarCliente()
                                    
                                    
                                    
                                }
                                
                                DispatchQueue.main.async(execute: refresh)
                                
                            }
                            
                        }else{
                            
                            if error as? Int == 1005{
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
                                        
                                        self.consultarCliente()
                                        
                                        
                                        
                                    }
                                    
                                    DispatchQueue.main.async(execute: refresh)
                                    
                                }

                            }
                            else {
                                func refresh()
                                    
                                {
                                    self.loadingAction.stopAnimating()
                                    self.loadingAction.isHidden = true
                                    self.btnPresionado = false
                            
                                    if let err = error{
                                        let alertController = UIAlertController(title: "Error de eliminacion",
                                        message: Errores().getError(String(describing: err)),
                                        preferredStyle: UIAlertControllerStyle.alert)
                            
                                        alertController.addAction(UIAlertAction(title: "OK",
                                            style: UIAlertActionStyle.default,
                                            handler: nil))
                                        // Display alert
                                        self.present(alertController, animated: true, completion: nil)
                                    }
                                }
                                DispatchQueue.main.async(execute: refresh)

                            }
                        }
                        }else{
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
                                    
                                    self.consultarCliente()
                                    
                                    
                                    
                                }
                                
                                DispatchQueue.main.async(execute: refresh)
                                
                            }

                        }
                    }catch let error as NSError
                    {
                        self.loadingAction.stopAnimating()
                        self.loadingAction.isHidden = true
                        self.btnPresionado = false
                        
                        print(error)
                    }
                }
            })
            
            dataTask.resume()
        
        
        
          
    }
  }

}
