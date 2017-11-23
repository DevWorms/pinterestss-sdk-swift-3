//
//  RootViewController.swift
//  pinterestSwift
//
//  Created by Luis Gerardo on 01/09/17.
//  Copyright © 2017 Sergio Ivan Lopez Monzon. All rights reserved.
//

import UIKit
import SafariServices

class RootViewController: UIViewController {

    @IBOutlet weak var boton: UIButton!
    @IBOutlet weak var labelTerminos: UILabel!
    @IBOutlet weak var labelPoliticas: UILabel!
    
    let urlStringTerminos = "http://recetasmexicanas.mx/terminos.html"
    let urlStringPoliticas = "http://recetasmexicanas.mx/politica.html"
    
    var statusView: ((Bool) -> Void)?
    
    var pageViewController: UIPageViewController?
    let imagenes = ["Carrusel01png", "Carrusel02", "Carrusel03", "Carrusel04"]
    let titulos = ["Más de 200 recetas", "Nuevas recetas", "Cocina Tradicional", "¡Irresistibles!"]
    let subtitulos = ["Sencillas de preparar y que ¡si salen!", "Descubre cada semana los platillos agregados", "Lo mejor de la cocina mexicana", "Prepara los platillos mas deliciosos desde hoy"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //boton.isHidden = true
        pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageViewController") as? UIPageViewController
        
        self.pageViewController?.dataSource = self
        
        let startViewController = viewControllerAtIndex(index: 0)!
        
        let viewControllers = [startViewController]
        
        self.pageViewController?.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)

        self.pageViewController?.view.frame = CGRect(x: 0, y: 57, width: self.view.frame.width, height: self.view.frame.size.height - 175)
        
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview((self.pageViewController?.view)!)
        self.pageViewController?.didMove(toParentViewController: self)
        
        let tapTerminos = UITapGestureRecognizer(target: self, action: #selector(tapTerminosCondiciones))
        let tapPoliticas = UITapGestureRecognizer(target: self, action: #selector(tapPoliticasPrivacidad))
        labelTerminos.isUserInteractionEnabled = true
        labelPoliticas.isUserInteractionEnabled = true
        labelTerminos.addGestureRecognizer(tapTerminos)
        labelPoliticas.addGestureRecognizer(tapPoliticas)
    }

    func tapTerminosCondiciones() {
        guard let urlTerminos = URL(string: urlStringTerminos) else { return }
        let safari = SFSafariViewController(url: urlTerminos)
        present(safari, animated: true, completion: nil)
    }
    
    func tapPoliticasPrivacidad() {
        guard let urlPoliticas = URL(string: urlStringPoliticas) else { return }
        let safari = SFSafariViewController(url: urlPoliticas)
        present(safari, animated: true, completion: nil)
    }
    
    @IBAction func suscripcion(_ sender: Any) {
        if let status = statusView {
            status(true)
        }
    }
    
    

}

extension RootViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        //boton.isHidden = true
        
        var index = (viewController as! SuscripcionViewController).pageIndex
        
        if index == NSNotFound {
            return nil
        }
        
        index+=1
        
        if index == imagenes.count {
        //    boton.isHidden = false
            return nil
        }
        return self.viewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        //boton.isHidden = true

        var index = (viewController as! SuscripcionViewController).pageIndex
        
        if index == 0 || index == NSNotFound {
            return nil
        }
        
        //if index == imagenes.count {
        //    boton.isHidden = false
        //}
        
        index-=1
        
        return self.viewControllerAtIndex(index: index)
        
    }
    
    
    func viewControllerAtIndex(index: Int) -> SuscripcionViewController? {
        
        if imagenes.count == 0 || index >= imagenes.count {
            return nil
        }
        
        let pageContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "SPageContentController") as! SuscripcionViewController
        pageContentViewController.tituloText = titulos[index]
        pageContentViewController.subtituloText = subtitulos[index]
        pageContentViewController.imagenName = imagenes[index]
        pageContentViewController.pageIndex = index;
        
        return pageContentViewController
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return imagenes.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
