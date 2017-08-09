//
//  PopUpViewControllerDescripcion.swift
//  Pods
//
//  Created by sergio ivan lopez monzon on 01/01/16.
//
// https://github.com/saturngod/IAPHelper

import UIKit
import QuartzCore
import Parse
//import IAPHelper
import Alamofire

@objc open class PopUpViewControllerDescripcion : UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    let producto = "CocinaMexicanaRecetasFaciles"
    
    let productIdentifiers = Set(["CocinaMexicanaRecetasFaciles"])
    var product: SKProduct?
    var productsArray = Array<SKProduct>()
    
   // var popViewController : PopUpViewControllerTarjetas!
    var context:MenuPlatillos!
    var contextSearch:SearchResultsViewController!
    
    var tipoSuscripcion :Bool = false
    var mainViewController :UIView!
    
    @IBOutlet weak var popUpView: UIView!
    
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
      
        //let objParse = PFObject(className:"Clientes")
        
        
        SKPaymentQueue.default().add(self)
        requestProductData()

        
        
        
    }
    
    
    open func showInView(_ aView: UIView!)
    {
        self.mainViewController = UIView.init(frame:  CGRect(x: 0.0, y: 0.0, width: aView.bounds.height, height: aView.bounds.maxY) )//aView.bounds)
        self.mainViewController.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        self.view.center = CGPoint(x: aView.bounds.width/2, y: aView.bounds.midY)
        
        aView.addSubview( self.mainViewController )
        aView.addSubview( self.view )

        //let formatter = NSNumberFormatter()
        
        if context != nil {
            self.context.popAbierto = true
            self.context.tableView.isScrollEnabled = false
        }else if contextSearch != nil{
            self.contextSearch.popAbierto = true
            self.contextSearch.tableView.isScrollEnabled = false

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
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
            }, completion:{(finished : Bool)  in
                if (finished)
                {
                    if self.context != nil{
                        self.context.popAbierto = false
                        self.context.tableView.isScrollEnabled = true
                    }else if self.contextSearch != nil{
                        self.contextSearch.popAbierto = false
                        self.contextSearch.tableView.isScrollEnabled = true
                    }
                    self.mainViewController.removeFromSuperview()
                    self.view.removeFromSuperview()
                }
        });
    }
    
    func seguir()
    {
        
       // pagos.setParametros(parent: self, baseDatos: objParse)
         
        
       // pagos.requestProductData()
        

        
        /*
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
            }, completion:{(finished : Bool)  in
                if (finished)
                {
                    self.removeAnimate()
                    self.popViewController = PopUpViewControllerTarjetas(nibName: "PopUpViewControllerTarjetas", bundle: nil)

                    if self.self.context != nil{
                        self.popViewController.context = self.self.context
                        self.context.tableView.isScrollEnabled = false
                        self.context.popAbierto = true
                    }
                    else if self.self.contextSearch != nil{
                        self.popViewController.contextSearch = self.self.contextSearch
                        self.contextSearch.tableView.isScrollEnabled = false
                        self.contextSearch.popAbierto = true
                    }
                    self.popViewController.showInView(self.self.context.view)
                }
        });*/
    }
    
    
    @IBAction func btnContinuar(_ sender: AnyObject) {
        //self.seguir();
        
        if(productsArray.count > 0){
            let payment = SKPayment(product: productsArray[sender.tag])
            SKPaymentQueue.default().add(payment)
        }
    }
    
    @IBAction func cancelar(_ sender: AnyObject) {
        self.removeAnimate();
    }
    
    
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    
    override open func viewWillDisappear(_ animated: Bool) {
        SKPaymentQueue.default().remove(self)
    }
    
    // In-App Purchase Methods
    
    func requestProductData()
    {
        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers:
                self.productIdentifiers as Set<String>)
            request.delegate = self
            request.start()
        } else {
            let alert = UIAlertController(title: "In-App Purchases Not Enabled", message: "Please enable In App Purchase in Settings", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.default, handler: { alertAction in
                alert.dismiss(animated: true, completion: nil)
                
                let url: URL? = URL(string: UIApplicationOpenSettingsURLString)
                if url != nil
                {
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                }
                
            }))
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { alertAction in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
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
        //print(response.description)
        
        for product in 0 ..< products.count {
            print("Product not found: \(product)")
        }
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
            default:
                break
            }
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
            self.removeAnimate()
            
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
    
    func restorePurchases(_ sender: UIButton) {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
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
            
            
        }
        
        let vc_alert = UIAlertController(title: "Thank You", message: "Your purchase(s) were restored.", preferredStyle: .alert)
        vc_alert.addAction(UIAlertAction(title: "OK", style: .cancel , handler: nil))
        self.present(vc_alert, animated: true, completion: nil)
    }
    
}
