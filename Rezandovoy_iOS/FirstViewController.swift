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
        let conex = Conexion()
        let paginas = Paginacion(lim: 20, off: 0)
        let cadena_busqueda = getDocumentosRequest(cadena: "", pag: paginas)
        conex.getDocumentos(cadena_busqueda) { respuesta in
            print(respuesta)
        }
        conex.getPortada { portada in
            print(portada)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

