//
//  ConsejosView.swift
//  MenuDeslizante
//
//  Created by sergio ivan lopez monzon on 21/11/15.
//  Copyright © 2015 sergio ivan lopez monzon. All rights reserved.
//


import UIKit


class ConsejosView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var menuButton:UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if revealViewController() != nil {
            //            revealViewController().rearViewRevealWidth = 62
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            revealViewController().rightViewRevealWidth = 150
            //    extraButton.target = revealViewController()
            //    extraButton.action = "rightRevealToggle:"
            
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell = tableView.dequeueReusableCellWithIdentifier("PlatilloCell") as UITableViewCell!
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlatilloCell", for: indexPath) as! TableViewCell
        
        
        if indexPath.row == 0 {
            cell.imagePropia.image = UIImage(named: "arabe")
        } else if indexPath.row == 1{
            cell.imagePropia.image = UIImage(named: "images")
        }else if indexPath.row == 2{
            cell.imagePropia.image = UIImage(named: "arabe")
        }else {
            cell.imagePropia.image = UIImage(named: "arabe")
        }
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "pasos", sender: nil)
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
