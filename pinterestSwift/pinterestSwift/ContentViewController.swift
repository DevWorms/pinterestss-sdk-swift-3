//
//  ContentViewController.swift
//  MenuDeslizante
//
//  Created by Emmanuel Valentín Granados López on 26/10/16.
//  Copyright © 2016 sergio ivan lopez monzon. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var pageIndex: Int!
    var imageFile: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.imageView.image = UIImage(named: self.imageFile)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
