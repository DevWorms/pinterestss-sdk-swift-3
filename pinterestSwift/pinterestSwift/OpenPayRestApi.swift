//
//  OpenPayRestApi.swift
//  MenuDeslizante
//
//  Created by JUAN CARLOS LOPEZ A on 23/03/16.
//  Copyright © 2016 sergio ivan lopez monzon. All rights reserved.
//

import Foundation
import Parse

class OpenPayRestApi{
    
    //OpenPay variables
    
    /*
    
    internal static  func consultarPagoReailzadoenTienda(clientId: String!, chargeId:String, callBack: (Bool, String) -> Void ){
    
        let headers = [
        "authorization": pagoOpenPay.auth,
        "cache-control": "no-cache",
        "postman-token": "8f142621-8f8b-ba37-351f-808dd9336947"
        ]
    
        let requestString =  pagoOpenPay.url+pagoOpenPay.merchantId+"/customers/"+clientId+"/charges/"+chargeId+""
        let request = NSMutableURLRequest(URL: NSURL(string:requestString)!,
        cachePolicy: .UseProtocolCachePolicy,
        timeoutInterval: 10.0)
        request.HTTPMethod = "GET"
        request.allHTTPHeaderFields = headers
    
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
        if (error != nil) {
            print(error)
            callBack(false, (error?.description)!)
        } else {
        let httpResponse = response as? NSHTTPURLResponse

            do {
                let respuesta = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! [String:AnyObject]

                let error = (respuesta["error_code"])
                
                var resultado = ""
                if error != nil{
                    resultado = String(error as! NSNumber)
                }
                if resultado.isEmpty{
                    resultado = respuesta["status"] as! String!
                    print(httpResponse)
                    if resultado == "completed"{
                        self.consultarSuscripcion(clientId, callBack: { (resultado) -> Void in
                            if resultado == "1005" ||  resultado == "deleted"{
                        
                                let query = PFQuery(className:"Clientes")
                                query.whereKey("clientID", equalTo: clientId)
                                query.findObjectsInBackgroundWithBlock({ (clientes, error) in
                                    if error != nil {
                                        print(error)
                                    } else if let _ = clientes as [PFObject]? {
                                            for cliente in clientes! {
                                                cliente["Suscrito"] = true
                                            
                                                let today = NSDate()
                                                let caducidad = NSCalendar.currentCalendar().dateByAddingUnit(
                                                    .Day,
                                                    value: NUMERO_DIAS,
                                                    toDate: today,
                                                    options: NSCalendarOptions(rawValue: 0))
                                            
                                                let dateFormater : NSDateFormatter = NSDateFormatter()
                                                dateFormater.dateFormat = "yyyy-MM-dd"
                                            
                                                cliente["Caducidad"] = dateFormater.stringFromDate(caducidad!)
                                                cliente["codigobarras"] = ""
                                                cliente["referenciaentienda"] = ""
                                                
                                                cliente.saveInBackground()
                                                callBack(true, resultado)
                                            break
                                        }
                                    }
                                })
                            }
                        })
                        
                        
                    }
                    else{
                        //  in_progress
                        callBack(false, resultado)
                    }
                }else{
            
                    callBack(false, resultado)
                }
                
                // use anyObj here
            } catch {
                callBack(false, "json error: \(error)")
            }
       
        }
           
            
        })
    
        dataTask.resume()
            
        
    }
    */
    
    
    internal static  func consultarSuscripcion(_ cliente:PFObject){//,callBack: (Bool) -> Void ){
    
        
        if cliente["idsuscripcion"] == nil{
            //callBack(false)
        }
        else{
        
            let clienteId = cliente["clientID"] as! String
            let suscripcionId = cliente["idsuscripcion"] as! String
        
            let headers = [
                "authorization": pagoOpenPay.auth,
                "cache-control": "no-cache",
                "postman-token": "9381cac4-e0cc-9770-eff8-163964830867"
            ]
        
            let consulta = pagoOpenPay.url+pagoOpenPay.merchantId + "/customers/"
        
            let params = clienteId + "/subscriptions/" + suscripcionId
        
            let request = NSMutableURLRequest(url: URL(string: consulta+params)!,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
        
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if (error != nil) {
                   // callBack(false)
                } else {

                    //print(response?.description)
        
                    let resstr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    
                    if(resstr != "[]"){
                        do {
                            var array = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                    
                            
                            if array == nil{
                                array = try (JSONSerialization.jsonObject(with: data!, options: []) as? NSArray)![0] as? NSDictionary
                                
                            }
                            
                            let respuesta = array as! [String:AnyObject]
                        
                            if respuesta["error_code"] != nil{
                       
                                let numeroError = respuesta["error_code"] as! Int
                        
                                if  numeroError == 1005 ||
                                    numeroError == 3001 ||
                                    numeroError == 3002 ||
                                    numeroError == 3003 ||
                                    numeroError == 3004 ||
                                    numeroError == 3005 ||
                                    numeroError == 3006 ||
                                    numeroError == 3007 ||
                                    numeroError == 3008 ||
                                    numeroError == 3009 ||
                                    numeroError == 3010 ||
                                    numeroError == 3011 ||
                                    numeroError == 3012 {
                                        cliente["Suscrito"] = false
                                        cliente["idsuscripcion"] = ""
                                        cliente["Caducidad"] = ""
                                        cliente.saveInBackground()
                                    //  callBack(false)
                                    }
                                }else{
                                    //callBack(true)
                            }
                    
                    
                        } catch {
                            print("error")
                            //callBack(true)
                        }
                    }

                }
            })
        
            dataTask.resume()
        }
    
    }
    
}
