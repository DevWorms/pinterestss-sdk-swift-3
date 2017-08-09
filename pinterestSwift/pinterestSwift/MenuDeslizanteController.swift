//
//  MenuDeslizanteController.swift
//  MenuDeslizante
//
//  Created by sergio ivan lopez monzon on 05/05/16.
//  Copyright © 2016 sergio ivan lopez monzon. All rights reserved.
//


class MenuDeslizanteController: UITableViewController {
    
    @IBOutlet weak var itemMenuFondoInicio: UIImageView!
    @IBOutlet weak var itemMenuFondoMeGustan: UIImageView!
    @IBOutlet weak var itemMenuFondoUsuario: UIImageView!
    @IBOutlet weak var itemMenuFondoQuienesSomos: UIImageView!
    
    @IBOutlet weak var itemMenuFondoMisRegalos: UIImageView!
    fileprivate var opciones = [Int:ItemMenu]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        opciones[1] = ItemMenu(fondo: itemMenuFondoInicio)
        opciones[2] = ItemMenu(fondo: itemMenuFondoMeGustan)
        opciones[3] = ItemMenu(fondo: itemMenuFondoMisRegalos)
        opciones[4] = ItemMenu(fondo: itemMenuFondoUsuario)
        opciones[5] = ItemMenu(fondo: itemMenuFondoQuienesSomos)
        
        for opcion in opciones {
            opcion.1.marcarSelsccion(false)
        }
        opciones[1]?.marcarSelsccion(true)
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        for opcion in opciones {
            opcion.1.marcarSelsccion(false)
        }
        let seleccion = indexPath.row
        opciones[seleccion]?.marcarSelsccion(true)
        
    }
    
    fileprivate class ItemMenu{
      
        var fondo:UIImageView!
        
        init(fondo:UIImageView!){
            self.fondo = fondo
        }
        
        func marcarSelsccion(_ seleccionado:Bool) -> Void {
            if seleccionado{
                fondo.image = UIImage(named: "selecteditem")
            }
            else{
                
                fondo.image = UIImage(named: "itemMenu")
            }
        }
    }

}
