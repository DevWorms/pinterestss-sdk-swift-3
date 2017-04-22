//
//  TutorialViewController.swift
//  MenuDeslizante
//
//  Created by Emmanuel Valentín Granados López on 26/10/16.
//  Copyright © 2016 sergio ivan lopez monzon. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController, UIPageViewControllerDataSource {
    
    var pageViewController: UIPageViewController!
    var pageImages: NSArray!
    var popViewController:PopUpViewControllerRegistro!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pageController = UIPageControl.appearance()
        pageController.pageIndicatorTintColor = UIColor.lightGray
        pageController.currentPageIndicatorTintColor = UIColor.red
        pageController.backgroundColor = UIColor.clear

        pageImages = NSArray(objects: "carrusel1","carrusel2","carrusel3")
        
        self.pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "PVController") as! UIPageViewController
        
        self.pageViewController.dataSource = self
        
        let starVC = self.viewControllerAtIndex(1) as ContentViewController
        
        let viewControllers = NSArray(object: starVC)
        
        self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: .forward, animated: true, completion: nil)
        
        self.pageViewController.view.frame = CGRect(x: 0, y: 30, width: self.view.frame.width, height: self.view.frame.size.height - 120)
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMove(toParentViewController: self)
        
    }
    
    
    
    
    @IBAction func showRegistro(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "registro", sender: nil)
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewControllerAtIndex(_ index: Int) -> ContentViewController {
        if self.pageImages.count == 0 || index >= self.pageImages.count {
            return ContentViewController()
        }
        
        let vc: ContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "CVController") as! ContentViewController
        
        vc.imageFile = self.pageImages[index] as! String
        vc.pageIndex = index
        
        return vc
    }
    
    // MARK: - Page View Controller Data Source
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! ContentViewController
        var index = vc.pageIndex as Int
        
        if index == 0 || index == NSNotFound {
            return nil
        }
        
        index -= 1
        
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! ContentViewController
        var index = vc.pageIndex as Int
        
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        
        if index == self.pageImages.count {
            return nil
        }
        
        return self.viewControllerAtIndex(index)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.pageImages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 1
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
