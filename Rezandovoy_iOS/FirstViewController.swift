//
//  FirstViewController.swift
//  Rezandovoy_iOS
//
//  Created by Rodrigo on 9/11/15.
//  Copyright © 2015 sjdigital. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    var portada : Portada? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
       
        portada = obtenPortada()
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: funciones
    
    func obtenPortada() -> Portada? {
        var portada_aux: Portada? = nil
        let conex = Conexion()
        
        var portada_id_servidor = 0
        
        //Si tenemos portada obtenemos el id del servidor
        conex.getPortadaId{
            portadaId in portada_id_servidor = portadaId.id
            
            //Si el id es distinto de 0 es que hemos recuperado un dato
            //y obtenemos la almacenada en base de datos
            if portada_id_servidor != 0 {
                if let auxiliar = self.cargaPortadaId(){
                    print("Almacenado en base de datos \(auxiliar.id)")
                }
                
                //Si la portada del servidor es superior a la actual recuperamos portada
                if portada_id_servidor > self.cargaPortadaId()?.id{
                    print("Portada nueva")
                    //Recuperamos la portada del servidor y la almacenamos en base de datos
                    conex.getPortada{
                        portada in
                        if portada != nil {
                            self.guardaPortadas(portada!)
                            //Recuperamos el id de portada del servidor y lo guardamos en base de datos
                            conex.getPortadaId{
                                portadaId in self.guardaPortadaId(portadaId)
                                print("Actualizamos con  \(portadaId.id)")
                            }
                            portada_aux = portada
                            print("Portada recuperada de servidor")
                            
                        } else {
                            //TODO: Lo que hagamos cuando no hay portada ni en servidor ni en BD
                            print("No hay portada en ningún lado")
                        }
                        
                        
                    }
                    
                    
                } else {
                    print("Portada existente")
                    
                    //Comprobamos si la portada esta en base de datos
                    if let aux = self.cargaPortadas() {
                        portada_aux = aux
                        print("Portada obtenida de base de datos")
                    } else {
                        
                        //Si la portada no esta en base de datos la recuperamos del servidor
                        conex.getPortada{
                            portada in
                            if portada != nil {
                                self.guardaPortadas(portada!)
                                //Recuperamos el id de portada del servidor y lo guardamos en base de datos
                                conex.getPortadaId{
                                    portadaId in self.guardaPortadaId(portadaId)
                                }
                                portada_aux = portada
                                print("Portada recuperada de servidor")
                                
                            } else {
                                //TODO: Lo que hagamos cuando no hay portada ni en servidor ni en BD
                                print("No hay portada en ningún lado")
                            }
                            
                            
                        }
                    }
                    
                }
            } else {
                
                //Recuperamos la portada en base de datos
                //Comprobamos si la portada esta en base de datos
                if let aux = self.cargaPortadas() {
                    portada_aux = aux
                    print("Portada obtenida de base de datos")
                } else {
                    
                    //TODO: Lo que hagamos cuando no hay portada ni en servidor ni en BD
                    print("No hay portada en ningún lado")
                    
                }
                
            }
        }
        
        return portada_aux

    }
    

    // MARK: Obtención datos BD
    func cargaPortadas() -> Portada? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Portada.ArchiveURL.path!) as? Portada
    }
    
    func cargaPortadaId() -> PortadaId? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(PortadaId.ArchiveURL.path!) as? PortadaId
    }
    
    func guardaPortadas(portada: Portada) -> Bool {
        let exito = NSKeyedArchiver.archiveRootObject(portada, toFile: Portada.ArchiveURL.path!)
        return exito
    }
    
    func guardaPortadaId(portadaId: PortadaId) -> Bool {
        let exito = NSKeyedArchiver.archiveRootObject(portadaId, toFile: PortadaId.ArchiveURL.path!)
        return exito
    }
    
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
}

