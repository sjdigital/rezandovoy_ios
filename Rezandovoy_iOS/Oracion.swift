//
//  Oracion.swift
//  Rezandovoy
//
//  Created by Rodrigo on 24/2/16.
//  Copyright © 2016 sjdigital. All rights reserved.
//

import UIKit

class Oracion: NSObject, NSCoding {
    
    let id: Int
    let tipo: Int
    var mp3: String?
    var titulo: String?
    var images: String?
    var fecha: String?
    var musicas: NSArray?
    var lectura: NSArray?
    var documentos: NSArray?
    var icono: String?
    
    struct PropertyKey {
        static let idKey = "id"
        static let tipoKey = "tipo"
        static let mp3Key = "mp3"
        static let tituloKey = "titulo"
        static let imagesKey = "images"
        static let fechaKey = "fecha"
        static let musicasKey = "musicas"
        static let lecturaKey = "lectura"
        static let documentosKey = "documentos"
        static let iconoKey = "icono"
    }
    
    init (auxId: Int, auxTipo: Int) {
        self.id = auxId
        self.tipo = auxTipo
    }
    
    func setmp3 (_ auxmp3: String) {
        self.mp3 = auxmp3
    }
    
    func settitulo (_ auxtitulo: String) {
        self.titulo = auxtitulo
    }
    
    func setimages (_ auximages: String) {
        self.images = auximages
    }
    
    func setfecha (_ auxfecha: String?) {
        self.fecha = auxfecha
    }
    
    func setmusicas (_ auxmusicas: NSArray?) {
        self.musicas = auxmusicas
    }
    
    func setlectura (_ auxlectura: NSArray?) {
        self.lectura = auxlectura
    }
    
    func setdocumentos (_ auxdocs: NSArray?) {
        self.documentos = auxdocs
    }
    
    func seticono (_ auxicon: String?) {
        self.icono = auxicon
    }
    
    init?(auxId: Int, auxTipo: Int, auxmp3: String, auxtitulo: String, auximages: String, auxfecha: String?, auxmusicas: NSArray?, auxlectura: NSArray?, auxdocs: NSArray?, auxicon: String?) {
        self.id = auxId
        self.tipo = auxTipo
        self.mp3 = auxmp3
        self.titulo = auxtitulo
        self.images = auximages
        if let _ = auxfecha {
            self.fecha = auxfecha
        }
        if let _ = auxmusicas {
            self.musicas = auxmusicas
        }
        if let _ = auxlectura {
            self.lectura = auxlectura
        }
        if let _ = auxdocs {
            self.documentos = auxdocs
        }
        if let _ = auxicon {
            self.icono = auxicon
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: PropertyKey.idKey)
        aCoder.encode(tipo, forKey: PropertyKey.tipoKey)
        aCoder.encode(mp3, forKey: PropertyKey.mp3Key)
        aCoder.encode(titulo, forKey: PropertyKey.tituloKey)
        aCoder.encode(images, forKey: PropertyKey.imagesKey)
        aCoder.encode(fecha, forKey: PropertyKey.fechaKey)
        aCoder.encode(musicas, forKey: PropertyKey.musicasKey)
        aCoder.encode(lectura, forKey: PropertyKey.lecturaKey)
        aCoder.encode(documentos, forKey: PropertyKey.documentosKey)
        aCoder.encode(icono, forKey: PropertyKey.iconoKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeInteger(forKey: PropertyKey.idKey) as Int
        let tipo = aDecoder.decodeInteger(forKey: PropertyKey.tipoKey) as Int
        let mp3 = aDecoder.decodeObject(forKey: PropertyKey.mp3Key) as! String
        let titulo = aDecoder.decodeObject(forKey: PropertyKey.tituloKey) as! String
        let images = aDecoder.decodeObject(forKey: PropertyKey.imagesKey) as! String
        let fecha = aDecoder.decodeObject(forKey: PropertyKey.fechaKey) as? String
        let musicas = aDecoder.decodeObject(forKey: PropertyKey.musicasKey) as? NSArray
        let lectura = aDecoder.decodeObject(forKey: PropertyKey.lecturaKey) as? NSArray
        let documentos = aDecoder.decodeObject(forKey: PropertyKey.documentosKey) as? NSArray
        let icono = aDecoder.decodeObject(forKey: PropertyKey.iconoKey) as? String
        self.init(auxId: id, auxTipo: tipo, auxmp3: mp3, auxtitulo: titulo, auximages: images, auxfecha: fecha, auxmusicas: musicas, auxlectura: lectura, auxdocs: documentos, auxicon: icono)
    }
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
}
