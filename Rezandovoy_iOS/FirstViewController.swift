//
//  FirstViewController.swift
//  Rezandovoy_iOS
//
//  Created by Rodrigo on 9/11/15.
//  Copyright © 2015 sjdigital. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        /*let conex = Conexion()
        let paginas = Paginacion(lim: 20, off: 0)
        let cadena_busqueda = getDocumentosRequest(cadena: "", pag: paginas)
        conex.getDocumentos(cadena_busqueda) { respuesta in
            print(respuesta)
        }
        conex.getPortada { portada in
            print(portada)
        }*/
        
        if let _ = cargaPortadas() {
            print("Tenemos portada")
        }
        else {
            print("No tenemos portada!")
            let conex = Conexion()
            conex.getPortada { portada in
                self.guardaPortadas(portada)
                print("Se guarada la pordtda")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func cargaPortadas() -> Portada? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Portada.ArchiveURL.path!) as? Portada
    }
    
    func guardaPortadas(portada: Portada) -> Bool {
        let exito = NSKeyedArchiver.archiveRootObject(portada, toFile: Portada.ArchiveURL.path!)
        return exito
    }
}

