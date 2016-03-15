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
    
    func setmp3 (auxmp3: String) {
        self.mp3 = auxmp3
    }
    
    func settitulo (auxtitulo: String) {
        self.titulo = auxtitulo
    }
    
    func setimages (auximages: String) {
        self.images = auximages
    }
    
    func setfecha (auxfecha: String?) {
        self.fecha = auxfecha
    }
    
    func setmusicas (auxmusicas: NSArray?) {
        self.musicas = auxmusicas
    }
    
    func setlectura (auxlectura: NSArray?) {
        self.lectura = auxlectura
    }
    
    func setdocumentos (auxdocs: NSArray?) {
        self.documentos = auxdocs
    }
    
    func seticono (auxicon: String?) {
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
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(id, forKey: PropertyKey.idKey)
        aCoder.encodeInteger(tipo, forKey: PropertyKey.tipoKey)
        aCoder.encodeObject(mp3, forKey: PropertyKey.mp3Key)
        aCoder.encodeObject(titulo, forKey: PropertyKey.tituloKey)
        aCoder.encodeObject(images, forKey: PropertyKey.imagesKey)
        aCoder.encodeObject(fecha, forKey: PropertyKey.fechaKey)
        aCoder.encodeObject(musicas, forKey: PropertyKey.musicasKey)
        aCoder.encodeObject(lectura, forKey: PropertyKey.lecturaKey)
        aCoder.encodeObject(documentos, forKey: PropertyKey.documentosKey)
        aCoder.encodeObject(icono, forKey: PropertyKey.iconoKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeIntegerForKey(PropertyKey.idKey) as Int
        let tipo = aDecoder.decodeIntegerForKey(PropertyKey.tipoKey) as Int
        let mp3 = aDecoder.decodeObjectForKey(PropertyKey.mp3Key) as! String
        let titulo = aDecoder.decodeObjectForKey(PropertyKey.tituloKey) as! String
        let images = aDecoder.decodeObjectForKey(PropertyKey.imagesKey) as! String
        let fecha = aDecoder.decodeObjectForKey(PropertyKey.fechaKey) as? String
        let musicas = aDecoder.decodeObjectForKey(PropertyKey.musicasKey) as? NSArray
        let lectura = aDecoder.decodeObjectForKey(PropertyKey.lecturaKey) as? NSArray
        let documentos = aDecoder.decodeObjectForKey(PropertyKey.documentosKey) as? NSArray
        let icono = aDecoder.decodeObjectForKey(PropertyKey.iconoKey) as? String
        self.init(auxId: id, auxTipo: tipo, auxmp3: mp3, auxtitulo: titulo, auximages: images, auxfecha: fecha, auxmusicas: musicas, auxlectura: lectura, auxdocs: documentos, auxicon: icono)
    }
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
}
