//
//  Datos.swift
//  Rezandovoy_iOS
//
//  Created by Rodrigo on 10/11/15.
//  Copyright © 2015 sjdigital. All rights reserved.
//

import Foundation

let servidor = "http://rvserver.sjdigitaldemo.ovh/"
let format = NSDateFormatter()

class Conexion {
    let session = NSURLSession.sharedSession()
    
    func getPortada(onComplete: (Portada?) -> ()) {
        let postEndpoint: String = "http://rvserver.sjdigitaldemo.ovh:8080/Rezandovoy_server/api/publica/getPortada"
        let postParams: AnyObject = []
        let url = NSURL(string: postEndpoint)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(postParams, options: NSJSONWritingOptions())
            print("Funca")
        } catch {
            print("No funca")
        }
        
        session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            guard let realResponse = response as? NSHTTPURLResponse where realResponse.statusCode == 200 else {
                let respuesta = response as? NSHTTPURLResponse
                print("Not a 200 response is:\n \(respuesta)")
                let aux: Portada? = nil
                onComplete(aux)
                return
            }
            do {
                if let jsonDict = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? NSDictionary {
                    onComplete(Portada(entrada_json: jsonDict))
                } else {
                    print("Error")
                }
            } catch let error as NSError {
                print(error)
            }
        }).resume()
    }
    
    func getPortadaId(onComplete: (PortadaId) -> ()) {
        let postEndpoint: String = "http://rvserver.sjdigitaldemo.ovh:8080/Rezandovoy_server/api/publica/getPortadaId"
        let postParams: AnyObject = []
        let url = NSURL(string: postEndpoint)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(postParams, options: NSJSONWritingOptions())
            print("Funca")
        } catch {
            print("No funca")
        }
        
        session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            guard let realResponse = response as? NSHTTPURLResponse where realResponse.statusCode == 200 else {
                let respuesta = response as? NSHTTPURLResponse
                print("Not a 200 response is:\n \(respuesta)")
                let aux: PortadaId = PortadaId(id: 0)
                onComplete(aux)
                return
            }
            do {
                if let jsonDict = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? NSDictionary {
                    onComplete(PortadaId(entrada_json: jsonDict))
                } else {
                    print("Error")
                }
            } catch let error as NSError {
                print(error)
            }
        }).resume()
    }
    
    func getDocumentos(busqueda: getDocumentosRequest, onComplete: ([DocumentoPublico]) -> ()) {
        let postEndpoint: String = "http://rvserver.sjdigitaldemo.ovh:8080/Rezandovoy_server/api/publica/getDocumentos"
        var documentos: [DocumentoPublico] = []
        let postParams: AnyObject = busqueda.getDictionary()
        let url = NSURL(string: postEndpoint)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        print("Antes conex")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(postParams, options: [])
            print("Funca")
        } catch {
            print("No funca")
        }
        
        session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            guard let realResponse = response as? NSHTTPURLResponse where realResponse.statusCode == 200 else {
                let respuesta = response as? NSHTTPURLResponse
                print("Not a 200 response is:\n \(respuesta)")
                return
            }
            do {
                if let jsonDict = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? NSDictionary {
                    let jsonDocs = jsonDict.valueForKey("documento") as! NSArray
                    for (documento) in jsonDocs {
                        documentos.append(DocumentoPublico(entrada_json: documento as! NSDictionary))
                    }
                    onComplete(documentos)
                } else {
                    print("Error")
                }
            } catch let error as NSError {
                print(error)
            }
        }).resume()
    }
}

// MARK: Clases

class Portada: NSObject, NSCoding {
    var semanaActual: Semana
    var semanaProxima: Semana
    
    struct Keys {
        static let semanaActualKey = "semanaActual"
        static let semanaProximaKey = "semanaProxima"
        static let portada = "portada"
    }
    
    init (entrada_json : NSDictionary) {
        print("Portada\n")
        semanaActual = Semana(entrada_json: entrada_json.valueForKey("semanaActual") as! NSDictionary)
        semanaProxima = Semana(entrada_json: entrada_json.valueForKey("semanaProxima") as! NSDictionary)
    }
    
    init (semact: Semana, semprox: Semana) {
        semanaActual = semact
        semanaProxima = semprox
    }
    
    init (portada: Portada){
        self.semanaActual = portada.semanaActual
        self.semanaProxima = portada.semanaProxima
        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self, forKey: Keys.portada)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let portada_aux = aDecoder.decodeObjectForKey(Keys.portada) as! Portada
        self.init(portada: portada_aux)
    }
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("portada")
}

class PortadaId: NSObject, NSCoding {
    var id: Int
    
    struct Keys {
        static let idKey = "id"
    }
    
    init (entrada_json: NSDictionary){
        print(entrada_json)
        self.id = entrada_json.valueForKey("portadaId") as! Int
    }
    
    init (id: Int){
        self.id = id
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self, forKey: Keys.idKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let id_aux = aDecoder.decodeObjectForKey(Keys.idKey) as! PortadaId
        self.init(id: id_aux.id)
    }
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("portadaId")
    
}

class PortadaInfantil {
    var oraciones: [OracionPeriodica] = []
    
    init(entrada_json: NSDictionary) {
        
    }
}

class PortadaEspecialesAdulto {
    var especial: [OracionEspecial] = []
    
    init(entrada_json: NSDictionary) {
        
    }
}

class PortadaEspecialesInfantil {
    var especial: [OracionEspecial] = []
    
    init(entrada_json: NSDictionary) {
        
    }
}

class ResultadoBusquedaDocumentos {
    var documento: [DocumentoPublico] = []
    
    init(entrada_json: NSDictionary) {
        
    }
}

class Semana {
    var oracionesPeriodicaAdulto: [OracionPeriodica] = []
    var oracionEspecialAdulto: OracionEspecial?
    var oracionInfantil: OracionPeriodica
    var color: String?
    var aviso: String?
    var zip: String
    var semanaLiturgica: String

    
    init(entrada_json : NSDictionary) {
        print("Semana")
        if let especial = entrada_json.valueForKey("oracionEspecial") as? NSDictionary {
            oracionEspecialAdulto = OracionEspecial(entrada_json: especial)
        }
        let infantil = entrada_json.valueForKey("oracionInfantil") as? NSDictionary
        oracionInfantil = OracionPeriodica(entrada_json: infantil! as NSDictionary)
        let periodica = entrada_json.valueForKey("oraciones") as! NSArray
        for (oracion) in periodica {
            oracionesPeriodicaAdulto.append(OracionPeriodica(entrada_json: oracion as! NSDictionary))
        }
        color = entrada_json.valueForKey("color") as? String
        if (color == nil) {
            color = String("#A82939")
        }
        aviso = entrada_json.valueForKey("aviso") as? String
        zip = String("\(servidor)\(entrada_json.valueForKey("zip"))")
        semanaLiturgica = entrada_json.valueForKey("semanaLiturgica") as! String
        print("\n*****\n\n")
    }
    
    init(oracionesPeriodicasAdulto : [OracionPeriodica], oracionEspecialAdulto: OracionEspecial?, oracionInfantil: OracionPeriodica, color: String?, aviso: String?, zip: String, semanaLiturgica: String){
        self.oracionesPeriodicaAdulto = oracionesPeriodicasAdulto
        self.oracionEspecialAdulto = oracionEspecialAdulto
        self.oracionInfantil = oracionInfantil
        self.color = color
        self.aviso = aviso
        self.zip = zip
        self.semanaLiturgica = semanaLiturgica
    }

}

class Oracion {
    var id: Int
    var titulo: String
    var lectura: NSArray
    var documentos: [Documento] = []
    var oracion_link : String
    var musicas: [Musica] = []
    var ficheroImagenes: String
    var tweet: String?
    
    init (id_oracion: Int, titulo_oracion: String, lecturas_oracion: NSArray, link: String, imagenes: String, twit: String?, docs: NSArray, mus: NSArray) {
        print("Oracion")
        id = id_oracion
        titulo = titulo_oracion
        lectura = lecturas_oracion
        oracion_link = link
        ficheroImagenes = imagenes
        tweet = twit
        for (documento) in docs {
            documentos.append(Documento(entrada_json: documento as! NSDictionary))
        }
        for (musica) in mus {
            musicas.append(Musica(entrada_json: musica as! NSDictionary))
        }
        print("\n")
    }
}

class OracionPeriodica: Oracion {
    var tiempoLiturgico: String?
    var fecha: NSDateComponents
    
    init(entrada_json : NSDictionary) {
        print("OracionPeridocia")
        tiempoLiturgico = entrada_json.valueForKey("tiempoLiturgico") as? String
        format.dateFormat = "MMM d, yyyy"
        let aux = String(entrada_json.valueForKey("fecha")!)
        let fecha_aux = format.dateFromString(aux)!
        let esp = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        esp.timeZone = NSTimeZone(name: "Europe/Madrid")!
        let requestedDateComponents: NSCalendarUnit = [.Year,.Month,.Day]
        fecha = esp.components(requestedDateComponents, fromDate: fecha_aux)
        let aux_id = entrada_json.valueForKey("id") as! Int
        let aux_titulo = entrada_json.valueForKey("titulo") as! String
        let aux_lecturas = entrada_json.valueForKey("lectura") as! NSArray
        let aux_link = String("\(servidor)\(entrada_json.valueForKey("oracion_link")!)")
        let aux_imagenes = entrada_json.valueForKey("ficheroImagenes") as! String
        let aux_tweet = entrada_json.valueForKey("tweet") as? String
        let aux_docs = entrada_json.valueForKey("documentos") as! NSArray
        let aux_mus = entrada_json.valueForKey("musicas") as! NSArray
        super.init(id_oracion: aux_id, titulo_oracion: aux_titulo, lecturas_oracion: aux_lecturas, link: aux_link, imagenes: aux_imagenes, twit: aux_tweet, docs: aux_docs, mus: aux_mus)
    }
}

class OracionEspecial: Oracion {
    var icono_link: String
    var texto: String?
    var imagen_link: String
    
    init(entrada_json : NSDictionary) {
        print("Oracionespecial")
        icono_link = String("\(servidor)\(entrada_json.valueForKey("icono_link")!)")
        texto = entrada_json.valueForKey("texto") as? String
        imagen_link = entrada_json.valueForKey("imagen_link") as! String
        let aux_id = entrada_json.valueForKey("id") as! Int
        let aux_titulo = entrada_json.valueForKey("titulo") as! String
        let aux_lecturas = entrada_json.valueForKey("lectura") as! NSArray
        let aux_link = String("\(servidor)\(entrada_json.valueForKey("oracion_link")!)")
        let aux_imagenes = entrada_json.valueForKey("ficheroImagenes") as! String
        let aux_tweet = entrada_json.valueForKey("tweet") as! String
        let aux_docs = entrada_json.valueForKey("documentos") as! NSArray
        let aux_mus = entrada_json.valueForKey("musicas") as! NSArray
        super.init(id_oracion: aux_id, titulo_oracion: aux_titulo, lecturas_oracion: aux_lecturas, link: aux_link, imagenes: aux_imagenes, twit: aux_tweet, docs: aux_docs, mus: aux_mus)
    }
}

class Documento {
    var link: String
    var nombre: String
    
    init(entrada_json : NSDictionary) {
        print("Documento")
        link = String("\(servidor)\(entrada_json.valueForKey("link")!)")
        nombre = entrada_json.valueForKey("nombre") as! String
    }
}

class Musica {
    var cancion: Cancion
    var coleccion: Coleccion
    var permiso: Permiso
    
    init(entrada_json : NSDictionary) {
        print("Musica")
        cancion = Cancion(entrada_json: entrada_json.valueForKey("cancion") as! NSDictionary)
        coleccion = Coleccion(entrada_json: entrada_json.valueForKey("coleccion") as! NSDictionary)
        permiso = Permiso(entrada_json: entrada_json.valueForKey("permiso") as! NSDictionary)
    }
}

class Cancion {
    var id: Int
    var titulo: String
    var autor: String?
    var interprete: String?
    var id_coleccion: Int
    
    init(entrada_json: NSDictionary) {
        print("Cancion")
        id = entrada_json.valueForKey("id") as! Int
        titulo = entrada_json.valueForKey("titulo") as! String
        autor = entrada_json.valueForKey("autor") as? String
        interprete = entrada_json.valueForKey("interprete") as? String
        id_coleccion = entrada_json.valueForKey("id_coleccion") as! Int
    }
}

class Coleccion {
    var id: Int
    var nombre: String
    var url_compra: String
    var id_permiso: Int
    
    init(entrada_json: NSDictionary) {
        print("Coleccion")
        id = entrada_json.valueForKey("id") as! Int
        nombre = entrada_json.valueForKey("nombre") as! String
        url_compra = entrada_json.valueForKey("url_compra") as! String
        id_permiso = entrada_json.valueForKey("id_permiso") as! Int
    }
}

class Permiso {
    var id: Int
    var formula: String
    var propietario: String
    var url: String
    
    init(entrada_json: NSDictionary) {
        print("Permiso")
        id = entrada_json.valueForKey("id") as! Int
        formula = entrada_json.valueForKey("formula") as! String
        propietario = entrada_json.valueForKey("propietario") as! String
        url = entrada_json.valueForKey("url") as! String
    }
}

class Paginacion {
    var limit: Int?
    var offset: Int?
    
    init(lim: Int, off: Int) {
        limit = lim
        offset = off
    }
    
    func getDictionary () -> NSDictionary {
        let dictionary: NSDictionary = ["limit": limit!, "offset": offset!]
        return dictionary
    }
}

class DocumentoPublico {
    var documento: Documento
    var fecha: NSDateComponents
    
    init(entrada_json: NSDictionary) {
        let aux_doc = entrada_json.valueForKey("documento") as! NSDictionary
        documento = Documento(entrada_json: aux_doc)
        format.dateFormat = "MMM d, yyyy hh:mm:ss a"
        let aux = String(entrada_json.valueForKey("fecha")!)
        let fecha_aux = format.dateFromString(aux)!
        let esp = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        esp.timeZone = NSTimeZone(name: "Europe/Madrid")!
        let requestedDateComponents: NSCalendarUnit = [.Year,.Month,.Day]
        fecha = esp.components(requestedDateComponents, fromDate: fecha_aux)
    }
}

class getDocumentosRequest {
    var busqueda: String
    var paginacion: Paginacion
    
    init (cadena: String, pag: Paginacion) {
        busqueda = cadena
        paginacion = pag
    }
    
    func getDictionary () -> NSDictionary {
        let dictionary: NSDictionary = ["busqueda": "\(busqueda)", "pag": paginacion.getDictionary()]
        return dictionary
    }
}