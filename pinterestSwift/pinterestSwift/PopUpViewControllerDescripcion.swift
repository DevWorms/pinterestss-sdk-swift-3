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

@objc open class PopUpViewControllerDescripcion : UIViewController {
    
    var context:PrincipalTableViewController!
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
      
        
    }
    
    
    open func showInView(_ aView: UIView!)
    {
        self.mainViewController = UIView.init(frame:  CGRect(x: 0.0, y: 0.0, width: aView.bounds.height, height: aView.bounds.maxY) )//aView.bounds)
        self.mainViewController.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        self.view.center = CGPoint(x: aView.bounds.width/2, y: aView.bounds.midY)
        
        
        aView.addSubview( self.mainViewController )
        aView.addSubview( self.view )
        if context != nil {
            self.context.popAbierto = true
            self.context.tableView.isScrollEnabled = false
        }else if contextSearch != nil{
            self.contextSearch.popAbierto = true
            self.contextSearch.tableView.isScrollEnabled = false

        }
        
    }
    
    @IBAction func tapGestu(_ sender: Any) {
        removeAnimate()
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
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
        })
    }
   
    
}
