//
//  Datos.swift
//  Rezandovoy_iOS
//
//  Created by Rodrigo on 10/11/15.
//  Copyright © 2015 sjdigital. All rights reserved.
//

import Foundation

let servidor = "http://sjdigitaldemo.ovh/"
let format = NSDateFormatter()

class Conexion {
    let session = NSURLSession.sharedSession()
    
    func getPortada(onComplete: (Portada?) -> ()) {
        let postEndpoint: String = "http://sjdigitaldemo.ovh:8080/Rezandovoy_server/api/publica/getPortada"
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
        let postEndpoint: String = "http://sjdigitaldemo.ovh:8080/Rezandovoy_server/api/publica/getPortadaId"
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
        let postEndpoint: String = "http://sjdigitaldemo.ovh:8080/Rezandovoy_server/api/publica/getDocumentos"
        var documentos: [DocumentoPublico] = []
        let postParams: AnyObject = busqueda.getDictionary()
        let url = NSURL(string: postEndpoint)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
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
    
    init (sem_act: Semana, sem_prox: Semana){
        semanaActual = sem_act
        semanaProxima = sem_prox
        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(semanaActual, forKey: Keys.semanaActualKey)
        aCoder.encodeObject(semanaProxima, forKey: Keys.semanaProximaKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let semana_act = aDecoder.decodeObjectForKey(Keys.semanaActualKey) as! Semana
        let semana_prox = aDecoder.decodeObjectForKey(Keys.semanaProximaKey) as! Semana
        self.init(sem_act: semana_act, sem_prox: semana_prox)
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
        aCoder.encodeObject(id, forKey: Keys.idKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let id_aux = aDecoder.decodeObjectForKey(Keys.idKey) as! Int
        self.init(id: id_aux)
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

class Semana: NSObject, NSCoding {
    var oracionesPeriodicaAdulto: [OracionPeriodica] = []
    var oracionEspecialAdulto: OracionEspecial?
    var oracionInfantil: OracionPeriodica
    var color: String?
    var aviso: String?
    var zip: String
    var semanaLiturgica: String

    struct Keys {
        static let oracionesPeriodicaAdultoKey = "oracionesPeriodicaAdulto"
        static let oracionEspecialAdultoKey = "oracionEspecialAdulto"
        static let oracionInfantilKey = "oracionInfantil"
        static let colorKey = "color"
        static let avisoKey = "aviso"
        static let zipKey = "zip"
        static let semanaLiturgicaKey = "semanaLiturgica"
    }
    
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
    
    init(oracionesPeriodicasAdulto: [OracionPeriodica], oracionEspecialAdulto: OracionEspecial?, oracionInfantil: OracionPeriodica, color: String?, aviso: String?, zip: String, semanaLiturgica: String){
        self.oracionesPeriodicaAdulto = oracionesPeriodicasAdulto
        self.oracionEspecialAdulto = oracionEspecialAdulto
        self.oracionInfantil = oracionInfantil
        self.color = color
        self.aviso = aviso
        self.zip = zip
        self.semanaLiturgica = semanaLiturgica
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(oracionesPeriodicaAdulto, forKey: Keys.oracionesPeriodicaAdultoKey)
        aCoder.encodeObject(oracionEspecialAdulto, forKey:  Keys.oracionEspecialAdultoKey)
        aCoder.encodeObject(oracionInfantil, forKey: Keys.oracionInfantilKey)
        aCoder.encodeObject(color, forKey: Keys.colorKey)
        aCoder.encodeObject(aviso, forKey: Keys.avisoKey)
        aCoder.encodeObject(zip, forKey: Keys.zipKey)
        aCoder.encodeObject(semanaLiturgica, forKey: Keys.semanaLiturgicaKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let oracionesPeriodicaAdulto_aux = aDecoder.decodeObjectForKey(Keys.oracionesPeriodicaAdultoKey) as! [OracionPeriodica]
        let oracionEspecialAdulto_aux = aDecoder.decodeObjectForKey(Keys.oracionEspecialAdultoKey) as? OracionEspecial
        let oracionInfantil_aux = aDecoder.decodeObjectForKey(Keys.oracionInfantilKey) as! OracionPeriodica
        let color_aux = aDecoder.decodeObjectForKey(Keys.colorKey) as? String
        let aviso_aux = aDecoder.decodeObjectForKey(Keys.avisoKey) as? String
        let zip_aux = aDecoder.decodeObjectForKey(Keys.zipKey) as! String
        let semanaLiturgica_aux = aDecoder.decodeObjectForKey(Keys.semanaLiturgicaKey) as! String
        self.init(oracionesPeriodicasAdulto: oracionesPeriodicaAdulto_aux, oracionEspecialAdulto: oracionEspecialAdulto_aux, oracionInfantil: oracionInfantil_aux, color: color_aux, aviso: aviso_aux, zip: zip_aux, semanaLiturgica: semanaLiturgica_aux)
    }

}

class Oracion: NSObject, NSCoding {
    var id: Int
    var titulo: String
    var lectura: [Lectura] = []
    var documentos: [Documento] = []
    var oracion_link : String
    var musicas: [Musica] = []
    var ficheroImagenes: String
    var tweet: String?
    
    struct Keys {
        static let idKey = "id"
        static let tituloKey = "titulo"
        static let lecturaKey = "lectura"
        static let documentosKey = "documentos"
        static let oracion_linkKey = "oracion_link"
        static let musicasKey = "musicas"
        static let ficheroImagenesKey = "ficheroImagenes"
        static let tweetKey = "tweet"
        static let tiempoLiturgicoKey = "tiempoLiturgico"
        static let fechaKey = "fecha"
        static let icono_linkKey = "icono_link"
        static let textoKey = "texto"
        static let imagen_linkKey = "imagen_link"
    }
    
    init (id_oracion: Int, titulo_oracion: String, lecturas_oracion: NSArray?, link: String, imagenes: String, twit: String?, docs: NSArray, mus: NSArray) {
        print("Oracion")
        id = id_oracion
        titulo = titulo_oracion
        if let _ = lecturas_oracion {
            for (lectura_aux) in lecturas_oracion! {
                lectura.append(Lectura(entrada_json: lectura_aux as! NSDictionary))
            }
        }
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
    
    init (id: Int, titulo: String, lectura: [Lectura], documentos: [Documento], oracion_link: String, musicas: [Musica], ficheroImagenes: String, tweet: String?) {
        self.id = id
        self.titulo = titulo
        self.lectura = lectura
        self.documentos = documentos
        self.oracion_link = oracion_link
        self.musicas = musicas
        self.ficheroImagenes = ficheroImagenes
        self.tweet = tweet
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: Keys.idKey)
        aCoder.encodeObject(titulo, forKey: Keys.tituloKey)
        aCoder.encodeObject(lectura, forKey: Keys.lecturaKey)
        aCoder.encodeObject(documentos, forKey: Keys.documentosKey)
        aCoder.encodeObject(oracion_link, forKey: Keys.oracion_linkKey)
        aCoder.encodeObject(musicas, forKey: Keys.musicasKey)
        aCoder.encodeObject(ficheroImagenes, forKey: Keys.ficheroImagenesKey)
        aCoder.encodeObject(tweet, forKey: Keys.tweetKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let id_aux = aDecoder.decodeObjectForKey(Keys.idKey) as! Int
        let titulo_aux = aDecoder.decodeObjectForKey(Keys.tituloKey) as! String
        let lectura_aux = aDecoder.decodeObjectForKey(Keys.lecturaKey) as! [Lectura]
        let documentos_aux = aDecoder.decodeObjectForKey(Keys.documentosKey) as! [Documento]
        let oracion_link_aux = aDecoder.decodeObjectForKey(Keys.oracion_linkKey) as! String
        let musicas_aux = aDecoder.decodeObjectForKey(Keys.musicasKey) as! [Musica]
        let ficheroImagenes_aux = aDecoder.decodeObjectForKey(Keys.ficheroImagenesKey) as! String
        let tweet_aux = aDecoder.decodeObjectForKey(Keys.tweetKey) as? String
        self.init(id: id_aux, titulo: titulo_aux, lectura: lectura_aux, documentos: documentos_aux, oracion_link: oracion_link_aux, musicas: musicas_aux, ficheroImagenes: ficheroImagenes_aux, tweet: tweet_aux)
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
        let aux_lecturas = entrada_json.valueForKey("lectura") as? NSArray
        let aux_link = String("\(servidor)\(entrada_json.valueForKey("oracion_link")!)")
        let aux_imagenes = entrada_json.valueForKey("ficheroImagenes") as! String
        let aux_tweet = entrada_json.valueForKey("tweet") as? String
        let aux_docs = entrada_json.valueForKey("documentos") as! NSArray
        let aux_mus = entrada_json.valueForKey("musicas") as! NSArray
        super.init(id_oracion: aux_id, titulo_oracion: aux_titulo, lecturas_oracion: aux_lecturas, link: aux_link, imagenes: aux_imagenes, twit: aux_tweet, docs: aux_docs, mus: aux_mus)
    }
    
    init (id: Int, titulo: String, lectura: [Lectura], documentos: [Documento], oracion_link: String, musicas: [Musica], ficheroImagenes: String, tweet: String?, tiempoLiturgico: String?, fecha: NSDateComponents) {
        self.tiempoLiturgico = tiempoLiturgico
        self.fecha = fecha
        super.init(id: id, titulo: titulo, lectura: lectura, documentos: documentos, oracion_link: oracion_link, musicas: musicas, ficheroImagenes: ficheroImagenes, tweet: tweet)
    }

    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(tiempoLiturgico, forKey: Keys.tiempoLiturgicoKey)
        aCoder.encodeObject(fecha, forKey: Keys.fechaKey)
        aCoder.encodeObject(id, forKey: Keys.idKey)
        aCoder.encodeObject(titulo, forKey: Keys.tituloKey)
        aCoder.encodeObject(lectura, forKey: Keys.lecturaKey)
        aCoder.encodeObject(documentos, forKey: Keys.documentosKey)
        aCoder.encodeObject(oracion_link, forKey: Keys.oracion_linkKey)
        aCoder.encodeObject(musicas, forKey: Keys.musicasKey)
        aCoder.encodeObject(ficheroImagenes, forKey: Keys.ficheroImagenesKey)
        aCoder.encodeObject(tweet, forKey: Keys.tweetKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let tiempoLiturgico_aux = aDecoder.decodeObjectForKey(Keys.tiempoLiturgicoKey) as? String
        let fecha_aux = aDecoder.decodeObjectForKey(Keys.fechaKey) as! NSDateComponents
        let id_aux = aDecoder.decodeObjectForKey(Keys.idKey) as! Int
        let titulo_aux = aDecoder.decodeObjectForKey(Keys.tituloKey) as! String
        let lectura_aux = aDecoder.decodeObjectForKey(Keys.lecturaKey) as! [Lectura]
        let documentos_aux = aDecoder.decodeObjectForKey(Keys.documentosKey) as! [Documento]
        let oracion_link_aux = aDecoder.decodeObjectForKey(Keys.oracion_linkKey) as! String
        let musicas_aux = aDecoder.decodeObjectForKey(Keys.musicasKey) as! [Musica]
        let ficheroImagenes_aux = aDecoder.decodeObjectForKey(Keys.ficheroImagenesKey) as! String
        let tweet_aux = aDecoder.decodeObjectForKey(Keys.tweetKey) as? String
        self.init(id: id_aux, titulo: titulo_aux, lectura: lectura_aux, documentos: documentos_aux, oracion_link: oracion_link_aux, musicas: musicas_aux, ficheroImagenes: ficheroImagenes_aux, tweet: tweet_aux, tiempoLiturgico: tiempoLiturgico_aux, fecha: fecha_aux)
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
        let aux_lecturas = entrada_json.valueForKey("lectura") as? NSArray
        let aux_link = String("\(servidor)\(entrada_json.valueForKey("oracion_link")!)")
        let aux_imagenes = entrada_json.valueForKey("ficheroImagenes") as! String
        let aux_tweet = entrada_json.valueForKey("tweet") as! String
        let aux_docs = entrada_json.valueForKey("documentos") as! NSArray
        let aux_mus = entrada_json.valueForKey("musicas") as! NSArray
        super.init(id_oracion: aux_id, titulo_oracion: aux_titulo, lecturas_oracion: aux_lecturas, link: aux_link, imagenes: aux_imagenes, twit: aux_tweet, docs: aux_docs, mus: aux_mus)
    }

    init (id: Int, titulo: String, lectura: [Lectura], documentos: [Documento], oracion_link: String, musicas: [Musica], ficheroImagenes: String, tweet: String?, icono_link: String, texto: String?, imagen_link: String) {
        self.icono_link = icono_link
        self.texto = texto
        self.imagen_link = imagen_link
        super.init(id: id, titulo: titulo, lectura: lectura, documentos: documentos, oracion_link: oracion_link, musicas: musicas, ficheroImagenes: ficheroImagenes, tweet: tweet)
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(icono_link, forKey: Keys.icono_linkKey)
        aCoder.encodeObject(texto, forKey: Keys.textoKey)
        aCoder.encodeObject(imagen_link, forKey: Keys.imagen_linkKey)
        aCoder.encodeObject(id, forKey: Keys.idKey)
        aCoder.encodeObject(titulo, forKey: Keys.tituloKey)
        aCoder.encodeObject(lectura, forKey: Keys.lecturaKey)
        aCoder.encodeObject(documentos, forKey: Keys.documentosKey)
        aCoder.encodeObject(oracion_link, forKey: Keys.oracion_linkKey)
        aCoder.encodeObject(musicas, forKey: Keys.musicasKey)
        aCoder.encodeObject(ficheroImagenes, forKey: Keys.ficheroImagenesKey)
        aCoder.encodeObject(tweet, forKey: Keys.tweetKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let icono_link_aux = aDecoder.decodeObjectForKey(Keys.icono_linkKey) as! String
        let texto_aux = aDecoder.decodeObjectForKey(Keys.textoKey) as? String
        let imagen_link_aux = aDecoder.decodeObjectForKey(Keys.imagen_linkKey) as! String
        let id_aux = aDecoder.decodeObjectForKey(Keys.idKey) as! Int
        let titulo_aux = aDecoder.decodeObjectForKey(Keys.tituloKey) as! String
        let lectura_aux = aDecoder.decodeObjectForKey(Keys.lecturaKey) as! [Lectura]
        let documentos_aux = aDecoder.decodeObjectForKey(Keys.documentosKey) as! [Documento]
        let oracion_link_aux = aDecoder.decodeObjectForKey(Keys.oracion_linkKey) as! String
        let musicas_aux = aDecoder.decodeObjectForKey(Keys.musicasKey) as! [Musica]
        let ficheroImagenes_aux = aDecoder.decodeObjectForKey(Keys.ficheroImagenesKey) as! String
        let tweet_aux = aDecoder.decodeObjectForKey(Keys.tweetKey) as? String
        self.init(id: id_aux, titulo: titulo_aux, lectura: lectura_aux, documentos: documentos_aux, oracion_link: oracion_link_aux, musicas: musicas_aux, ficheroImagenes: ficheroImagenes_aux, tweet: tweet_aux, icono_link: icono_link_aux, texto: texto_aux, imagen_link: imagen_link_aux)
    }
}

class Lectura: NSObject, NSCoding {
    var id: Int
    var cita: String
    var texto: String?
    
    struct Keys {
        static let idKey = "id"
        static let citaKey = "cita"
        static let textoKey = "texto"
    }
    
    init(entrada_json : NSDictionary) {
        id = entrada_json.valueForKey("id") as! Int
        cita = entrada_json.valueForKey("cita") as! String
        texto = entrada_json.valueForKey("texto") as? String
    }
    
    init(id: Int, cita: String, texto: String?) {
        self.id = id
        self.cita = cita
        self.texto = texto
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: Keys.idKey)
        aCoder.encodeObject(cita, forKey: Keys.citaKey)
        aCoder.encodeObject(texto, forKey: Keys.textoKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let id_aux = aDecoder.decodeObjectForKey(Keys.idKey) as! Int
        let cita_aux = aDecoder.decodeObjectForKey(Keys.citaKey) as! String
        let texto_aux = aDecoder.decodeObjectForKey(Keys.textoKey) as? String
        self.init(id: id_aux, cita: cita_aux, texto: texto_aux)
    }
}

class Documento: NSObject, NSCoding {
    var texto: String
    var nombre: String
    
    struct Keys {
        static let textoKey = "texto"
        static let nombreKey = "nombre"
    }
    
    init(entrada_json : NSDictionary) {
        print("Documento")
        texto = String("\(servidor)\(entrada_json.valueForKey("texto")!)")
        nombre = entrada_json.valueForKey("nombre") as! String
    }
    
    init(texto: String, nombre: String) {
        self.texto = texto
        self.nombre = nombre
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(texto, forKey: Keys.textoKey)
        aCoder.encodeObject(nombre, forKey: Keys.nombreKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let texto_aux = aDecoder.decodeObjectForKey(Keys.textoKey) as! String
        let nombre_aux = aDecoder.decodeObjectForKey(Keys.nombreKey) as! String
        self.init(texto: texto_aux, nombre: nombre_aux)
    }
}

class Musica: NSObject, NSCoding {
    var cancion: Cancion
    var coleccion: Coleccion
    var permiso: Permiso
    
    struct Keys {
        static let cancionKey = "cancion"
        static let coleccionKey = "coleccion"
        static let permisoKey = "permiso"
    }
    
    init(entrada_json : NSDictionary) {
        print("Musica")
        cancion = Cancion(entrada_json: entrada_json.valueForKey("cancion") as! NSDictionary)
        coleccion = Coleccion(entrada_json: entrada_json.valueForKey("coleccion") as! NSDictionary)
        permiso = Permiso(entrada_json: entrada_json.valueForKey("permiso") as! NSDictionary)
    }
    
    init(cancion: Cancion, coleccion: Coleccion, permiso: Permiso) {
        self.cancion = cancion
        self.coleccion = coleccion
        self.permiso = permiso
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(cancion, forKey: Keys.cancionKey)
        aCoder.encodeObject(coleccion, forKey: Keys.coleccionKey)
        aCoder.encodeObject(permiso, forKey: Keys.permisoKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let cancion_aux = aDecoder.decodeObjectForKey(Keys.cancionKey) as! Cancion
        let coleccion_aux = aDecoder.decodeObjectForKey(Keys.coleccionKey) as! Coleccion
        let permiso_aux = aDecoder.decodeObjectForKey(Keys.permisoKey) as! Permiso
        self.init(cancion: cancion_aux, coleccion: coleccion_aux, permiso: permiso_aux)
    }
}

class Cancion: NSObject, NSCoding {
    var id: Int
    var titulo: String
    var autor: String?
    var interprete: String?
    var id_coleccion: Int
    
    struct Keys {
        static let idKey = "id"
        static let tituloKey = "titulo"
        static let autorKey = "autor"
        static let interpreteKey = "interprete"
        static let id_coleccionKey = "id_coleccion"
    }
    
    init(entrada_json: NSDictionary) {
        print("Cancion")
        id = entrada_json.valueForKey("id") as! Int
        titulo = entrada_json.valueForKey("titulo") as! String
        autor = entrada_json.valueForKey("autor") as? String
        interprete = entrada_json.valueForKey("interprete") as? String
        id_coleccion = entrada_json.valueForKey("id_coleccion") as! Int
    }
    
    init(id: Int, titulo: String, autor: String?, interprete: String?, id_coleccion: Int) {
        self.id = id
        self.titulo = titulo
        self.autor = autor
        self.interprete = interprete
        self.id_coleccion = id_coleccion
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: Keys.idKey)
        aCoder.encodeObject(titulo, forKey: Keys.tituloKey)
        aCoder.encodeObject(autor, forKey: Keys.autorKey)
        aCoder.encodeObject(interprete, forKey: Keys.interpreteKey)
        aCoder.encodeObject(id_coleccion, forKey: Keys.id_coleccionKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let id_aux = aDecoder.decodeObjectForKey(Keys.id_coleccionKey) as! Int
        let titulo_aux = aDecoder.decodeObjectForKey(Keys.tituloKey) as! String
        let autor_aux = aDecoder.decodeObjectForKey(Keys.autorKey) as? String
        let interprete_aux = aDecoder.decodeObjectForKey(Keys.interpreteKey) as? String
        let id_coleccion_aux = aDecoder.decodeObjectForKey(Keys.id_coleccionKey) as! Int
        self.init(id: id_aux, titulo: titulo_aux, autor: autor_aux, interprete: interprete_aux, id_coleccion: id_coleccion_aux)
    }
    
}

class Coleccion: NSObject, NSCoding {
    var id: Int
    var nombre: String
    var url_compra: String
    var id_permiso: Int
    
    struct Keys {
        static let idKey = "id"
        static let nombreKey = "nombre"
        static let url_compraKey = "url_compra"
        static let id_permisoKey = "id_permiso"
    }
    
    init(entrada_json: NSDictionary) {
        print("Coleccion")
        id = entrada_json.valueForKey("id") as! Int
        nombre = entrada_json.valueForKey("nombre") as! String
        url_compra = entrada_json.valueForKey("url_compra") as! String
        id_permiso = entrada_json.valueForKey("id_permiso") as! Int
    }
    
    init(id: Int, nombre: String, url_compra: String, id_permiso: Int) {
        self.id = id
        self.nombre = nombre
        self.url_compra = url_compra
        self.id_permiso = id_permiso
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: Keys.idKey)
        aCoder.encodeObject(nombre, forKey: Keys.nombreKey)
        aCoder.encodeObject(url_compra, forKey: Keys.url_compraKey)
        aCoder.encodeObject(id_permiso, forKey: Keys.id_permisoKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let id_aux = aDecoder.decodeObjectForKey(Keys.idKey) as! Int
        let nombre_aux = aDecoder.decodeObjectForKey(Keys.nombreKey) as! String
        let url_compra_aux = aDecoder.decodeObjectForKey(Keys.url_compraKey) as! String
        let id_permiso_aux = aDecoder.decodeObjectForKey(Keys.id_permisoKey) as! Int
        self.init(id: id_aux, nombre: nombre_aux, url_compra: url_compra_aux, id_permiso: id_permiso_aux)
    }
}

class Permiso: NSObject, NSCoding {
    var id: Int
    var formula: String
    var propietario: String
    var url: String
    
    struct Keys {
        static let idKey = "id"
        static let formulaKey = "formula"
        static let propietarioKey = "propietario"
        static let urlKey = "url"
    }
    
    init(entrada_json: NSDictionary) {
        print("Permiso")
        id = entrada_json.valueForKey("id") as! Int
        formula = entrada_json.valueForKey("formula") as! String
        propietario = entrada_json.valueForKey("propietario") as! String
        url = entrada_json.valueForKey("url") as! String
    }
    
    init(id: Int, formula: String, propietario: String, url: String) {
        self.id = id
        self.formula = formula
        self.propietario = propietario
        self.url = url
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: Keys.idKey)
        aCoder.encodeObject(formula, forKey: Keys.formulaKey)
        aCoder.encodeObject(propietario, forKey: Keys.propietarioKey)
        aCoder.encodeObject(url, forKey: Keys.urlKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let id_aux = aDecoder.decodeObjectForKey(Keys.idKey) as! Int
        let formula_aux = aDecoder.decodeObjectForKey(Keys.formulaKey) as! String
        let propietario_aux = aDecoder.decodeObjectForKey(Keys.propietarioKey) as! String
        let url_aux = aDecoder.decodeObjectForKey(Keys.urlKey) as! String
        self.init(id: id_aux, formula: formula_aux, propietario: propietario_aux, url: url_aux)
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

// MARK: funciones

func obtenPortada() {
    let semaphore = dispatch_semaphore_create(0)
    //var portada_aux: Portada? = nil
    let conex = Conexion()
    
    var portada_id_servidor = 0
    
    //Si tenemos portada obtenemos el id del servidor
    conex.getPortadaId {
        portadaId in
        portada_id_servidor = portadaId.id
        
        //Si el id es distinto de 0 es que hemos recuperado un dato
        //y obtenemos la almacenada en base de datos
        if portada_id_servidor != 0 {
            if let auxiliar = cargaPortadaId(){
                print("Almacenado en base de datos \(auxiliar.id)")
            }
            
            //Si la portada del servidor es superior a la actual recuperamos portada
            if portada_id_servidor > cargaPortadaId()?.id{
                print("Portada nueva")
                print(portadaId)
                guardaPortadaId(portadaId)
                //Recuperamos la portada del servidor y la almacenamos en base de datos
                conex.getPortada{
                    portada in
                    if portada != nil {
                        guardaPortadas(portada!)
                        //Recuperamos el id de portada del servidor y lo guardamos en base de datos
                        //portada_aux = portada
                        print("Portada recuperada de servidor")
                        dispatch_semaphore_signal(semaphore)
                        
                    } else {
                        //TODO: Lo que hagamos cuando no hay portada ni en servidor ni en BD
                        print("No hay portada en ningún lado")
                    }
                    
                    
                }
                
                
            } else {
                print("Portada existente")
                
                //Comprobamos si la portada esta en base de datos
                if let _ = cargaPortadas() {
                    //portada_aux = aux
                    print("Portada obtenida de base de datos")
                    dispatch_semaphore_signal(semaphore)
                } else {
                    
                    //Si la portada no esta en base de datos la recuperamos del servidor
                    conex.getPortada{
                        portada in
                        if portada != nil {
                            guardaPortadas(portada!)
                            //Recuperamos el id de portada del servidor y lo guardamos en base de datos
                            conex.getPortadaId{
                                portadaId in guardaPortadaId(portadaId)
                            }
                            //portada_aux = portada
                            print("Portada recuperada de servidor")
                            dispatch_semaphore_signal(semaphore)
                            
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
            if let _ = cargaPortadas() {
                //portada_aux = aux
                print("Portada obtenida de base de datos")
                dispatch_semaphore_signal(semaphore)
            } else {
                
                //TODO: Lo que hagamos cuando no hay portada ni en servidor ni en BD
                print("No hay portada en ningún lado")
                
            }
            
        }
    }
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    //return portada_aux
    
}

// MARK: Obtención datos BD
func cargaPortadas() -> Portada? {
    let aux = NSKeyedUnarchiver.unarchiveObjectWithFile(Portada.ArchiveURL.path!) as? Portada
    print(Portada.ArchiveURL.path!)
    return aux
}

func cargaPortadaId() -> PortadaId? {
    let aux = NSKeyedUnarchiver.unarchiveObjectWithFile(PortadaId.ArchiveURL.path!) as? PortadaId
    print(PortadaId.ArchiveURL.path!)
    return aux
}

func guardaPortadas(portada: Portada) {
    NSKeyedArchiver.archiveRootObject(portada, toFile: Portada.ArchiveURL.path!)
    print(Portada.ArchiveURL.path!)
}

func guardaPortadaId(portadaId: PortadaId) {
    NSKeyedArchiver.archiveRootObject(portadaId, toFile: PortadaId.ArchiveURL.path!)
    print(PortadaId.ArchiveURL.path!)
}