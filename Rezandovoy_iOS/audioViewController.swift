//
//  audioViewController.swift
//  Rezandovoy_iOS
//
//  Created by Rodrigo on 20/1/16.
//  Copyright © 2016 sjdigital. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class audioViewController: UIViewController, AVAudioPlayerDelegate {
    
    var audioPlayer: AVPlayer?
    var imageView: UIImageView?
    var index = 0
    let animationDuration: NSTimeInterval = 1
    let switchingInterval: NSTimeInterval = 240
    var diaLabel: UILabel?
    var mesLabel: UILabel?
    var numLabel: UILabel?
    var iconoLabel: UIImageView?
    var iconoMusica: UIImageView?
    var musicaLabel: UILabel?
    var datosView: UIView?
    
    @IBOutlet var controles: UIView!
    @IBOutlet var botonPlay: UIButton!
    @IBOutlet var audioSlider: UISlider!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var vistaScroll: UIScrollView!
    @IBOutlet var hojaView: UIView!
    @IBOutlet var infoView: UIView!
    @IBOutlet var dentroScroll: UIView!
    
    @IBAction func reproductor(sender: UIButton) {
        if (audioPlayer?.rate != 0.0) {
            audioPlayer?.pause()
            sender.setImage(UIImage(named: "ic_play"), forState: UIControlState.Normal)
        } else {
            audioPlayer?.play()
            sender.setImage(UIImage(named: "ic_pause"), forState: UIControlState.Normal)
        }
    }
    
    @IBAction func forward(sender: AnyObject?) {
        var auxTime = audioPlayer?.currentItem?.currentTime()
        auxTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(auxTime!) + 15, (auxTime?.timescale)!)
        audioPlayer?.currentItem?.seekToTime(auxTime!)
    }
    
    @IBAction func backward(sender: AnyObject?) {
        var auxTime = audioPlayer?.currentItem?.currentTime()
        auxTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(auxTime!) - 15, (auxTime?.timescale)!)
        audioPlayer?.currentItem?.seekToTime(auxTime!)
    }
    
    @IBAction func sliderValue(sender: UISlider) {
        var tiempoSegs = Float64(sender.value)
        tiempoSegs /= 100.0
        let duracion = CMTimeGetSeconds((self.audioPlayer?.currentItem!.duration)!)
        let normalizedTime = tiempoSegs * duracion
        let tiempo = CMTimeMakeWithSeconds(normalizedTime, 1000)
        audioPlayer?.currentItem?.seekToTime(tiempo)
    }
    
    @IBAction func sliderPlay(sender: UISlider) {
        if (audioPlayer!.rate == 0.0) {
            reproductor(botonPlay)
        }
        else {
            reproductor(botonPlay)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Deshabilitar el gesto de ir hacia atras
        self.navigationController!.interactivePopGestureRecognizer!.enabled = false
        
        //Ocultar Tab Bar y cambio de colores de la barra de navegacion.
        self.tabBarController?.tabBar.hidden = true
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 10/255, green: 50/255, blue: 66/255, alpha: 0.7)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        //Recibir eventos bloqueado
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        
        //Poner borde a la hoja de calendario
        self.hojaView.layer.borderWidth = 1.0
        self.hojaView.layer.borderColor = UIColor.whiteColor().CGColor
        
        //Color de fondo del dia, de la scroll view y de la barra de controles
        self.infoView.backgroundColor = UIColor(red: 10/255, green: 50/255, blue: 66/255, alpha: 0.7)
        self.controles.backgroundColor = UIColor(red: 10/255, green: 50/255, blue: 66/255, alpha: 0.7)
        
        //Background audio
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            print("AVAudioSession Category Playback OK")
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                print("AVAudioSession is Active")
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        print(id)
        print(tipo)
        self.imageView = UIImageView(frame: self.view.bounds)
        if tipo == 1 {
            getOracionPeriodicaAdultoById()
        } else if tipo == 2 {
            getOracionEspecialAdultaById()
        }
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if (event?.subtype == UIEventSubtype.RemoteControlPause) {
            self.reproductor(botonPlay)
        }
        else if (event?.subtype == UIEventSubtype.RemoteControlNextTrack) {
            forward(event)
        }
        else if (event?.subtype == UIEventSubtype.RemoteControlPreviousTrack) {
            backward(event)
        }
        else if (event?.subtype == UIEventSubtype.RemoteControlPlay) {
            self.reproductor(botonPlay)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        if (self.isMovingFromParentViewController()) {
            self.audioPlayer?.pause()
            self.tabBarController?.tabBar.hidden = false
            self.navigationController?.navigationBar.barTintColor = nil
            self.navigationController?.navigationBar.tintColor = self.view.tintColor
            UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
            do {
                try AVAudioSession.sharedInstance().setActive(false)
                print("AVAudioSession is Stop")
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Llamada al servidor REST para recibir la periodica
    func getOracionPeriodicaAdultoById() -> AnyObject {
        // Variables peticion JSON
        let session = NSURLSession.sharedSession()
        let postEndpoint: String = "http://rezandovoy.ovh:8080/Rezandovoy_server/api/publica/getPeriodicaAdultaById"
        let postParams: NSDictionary = ["id": "\(id)"]
        let url = NSURL(string: postEndpoint)!
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(postParams, options: NSJSONWritingOptions())
            print("Funca by id")
        } catch {
            print("No funca by id")
        }
        
        session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            guard let realResponse = response as? NSHTTPURLResponse where realResponse.statusCode == 200 else {
                let respuesta = response as? NSHTTPURLResponse
                print("Not a 200 response is:\n \(respuesta)")
                return
            }
            do {
                if let jsonDict = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? NSDictionary {
                    
                    // Recuperar el link de la oración
                    var aux_mp3 = "http://rezandovoy.ovh/"
                    aux_mp3 += jsonDict.valueForKey("oracion_link") as! String
                    self.reproductorInit(aux_mp3)
                    
                    // LLamada a la funcion para poner el titulo
                    self.cambiaTitulo(jsonDict.valueForKey("titulo") as! String)
                    
                    // LLamada a la funcion para recuperar imagenes
                    self.recuperarImagenes(jsonDict.valueForKey("ficheroImagenes") as! String)
                
                    // LLamada a la funcion para recuperar fecha
                    self.recuperarFecha(jsonDict.valueForKey("fecha") as? String)
                    
                    // LLamada a la funcion para recuperar musicas
                    self.recuperarMusica((jsonDict.valueForKey("musicas") as? NSArray)!)
                    
                } else {
                    print("Error")
                }
            } catch let error as NSError {
                print(error)
            }
        }).resume()
        return true
    }
    
    // Llamada al servidor REST para recibir la especial
    func getOracionEspecialAdultaById() -> AnyObject {
        // Variables peticion JSON
        let session = NSURLSession.sharedSession()
        let postEndpoint: String = "http://rezandovoy.ovh:8080/Rezandovoy_server/api/publica/getEspecialAdultaById"
        let postParams: NSDictionary = ["id": "\(id)"]
        let url = NSURL(string: postEndpoint)!
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(postParams, options: NSJSONWritingOptions())
            print("Funca by id")
        } catch {
            print("No funca by id")
        }
        
        session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            guard let realResponse = response as? NSHTTPURLResponse where realResponse.statusCode == 200 else {
                let respuesta = response as? NSHTTPURLResponse
                print("Not a 200 response is:\n \(respuesta)")
                return
            }
            do {
                if let jsonDict = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? NSDictionary {
                    
                    // Recuperar el link de la oración
                    var aux_mp3 = "http://rezandovoy.ovh/"
                    aux_mp3 += jsonDict.valueForKey("oracion_link") as! String
                    self.reproductorInit(aux_mp3)
                    
                    // LLamada a la funcion para poner el titulo
                    self.cambiaTitulo(jsonDict.valueForKey("titulo") as! String)
                    
                    // LLamada a la funcion para recuperar imagenes
                    self.recuperarImagenes(jsonDict.valueForKey("ficheroImagenes") as! String)
                    
                    // LLamada a la funcion para recuperar fecha
                    self.recuperarIcono(jsonDict.valueForKey("icono_link") as? String)
                    
                } else {
                    print("Error")
                }
            } catch let error as NSError {
                print(error)
            }
        }).resume()
        return true
    }
    
    // Inicializar reproductor
    func reproductorInit(var aux: String)->Void {
        aux = aux.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let mp3url = AVPlayerItem(URL: NSURL(string:aux)!)
        self.audioPlayer = AVPlayer(playerItem: mp3url)
        self.audioPlayer?.addPeriodicTimeObserverForInterval(CMTimeMake(1, 10), queue: dispatch_get_main_queue()) {
            time in
            if (self.audioPlayer?.currentItem!.currentTime() < self.audioPlayer?.currentItem!.duration) {
                // Poner tiempo en texto
                let currentMins = Int(CMTimeGetSeconds(time)) / 60
                let currentSecs = Int(CMTimeGetSeconds(time)) % 60
                var timeString: String = ""
                if (currentSecs>=10 && currentMins<10) {
                    timeString = "0\(currentMins):\(currentSecs)"
                }
                else if (currentSecs<10 && currentMins<10) {
                    timeString = "0\(currentMins):0\(currentSecs)"
                }
                else if (currentSecs>=10 && currentMins>=10) {
                    timeString = "\(currentMins):\(currentSecs)"
                }
                else {
                    timeString = "\(currentMins):0\(currentSecs)"
                }
                if (UIApplication.sharedApplication().applicationState == .Active) {
                    self.timeLabel.text = timeString
                } else {
                    print("Background: \(timeString)")
                }
                
                //Actualizar la posicion del slider
                if (self.audioSlider.touchInside == false) {
                    let tiempoActual = CMTimeGetSeconds((self.audioPlayer?.currentItem!.currentTime())!)
                    let duracion = CMTimeGetSeconds((self.audioPlayer?.currentItem!.duration)!)
                    let normalizedTime = Float(tiempoActual * 100.0 / duracion)
                    self.audioSlider.value = normalizedTime
                }
            }
            else {
                self.audioPlayer?.pause()
                self.botonPlay.setImage(UIImage(named: "ic_play"), forState: UIControlState.Normal)
                self.audioSlider.value = 0.0
                self.audioPlayer?.seekToTime(CMTimeMake(0, 1))
            }
        }
        self.reproductor(self.botonPlay)
    }
    
    // Recuperar las músicas y darlas formato
    func recuperarMusica(aux_mus: NSArray)-> Void {
        dispatch_async(dispatch_get_main_queue()) {
            var alto = 0
            self.iconoMusica = UIImageView(frame: CGRect(x: 8, y: 8, width: 32, height: 32))
            self.iconoMusica!.image = UIImage(named: "ic_musicas")
            var cadena1: NSAttributedString?
            var cadena2: NSAttributedString?
            var cadena3: NSAttributedString?
            var cadena4: NSAttributedString?
            let normal = [ NSFontAttributeName: UIFont(name: "Aleo-Regular", size: 12)! ] as [String : AnyObject]
            let bold = [ NSFontAttributeName: UIFont(name: "Aleo-Bold", size: 12)! ] as [String : AnyObject]
            let italic = [ NSFontAttributeName: UIFont(name: "Aleo-Italic", size: 12)! ] as [String : AnyObject]
            for (musica) in aux_mus {
                self.datosView = UIView(frame: CGRect(x: 0, y: alto, width: Int(self.dentroScroll.frame.width), height: 0))
                self.dentroScroll.addSubview(self.datosView!)
                self.datosView!.addSubview(self.iconoMusica!)
                let cancion = musica.valueForKey("cancion")
                let coleccion = musica.valueForKey("coleccion")
                let permiso = musica.valueForKey("permiso")
                let titulo = cancion?.valueForKey("titulo")
                cadena1 = NSAttributedString(string: String(titulo!), attributes: bold)
                if (cancion?.valueForKey("autor") as! String == "" && cancion?.valueForKey("interprete") as! String != "") {
                    let interprete = cancion?.valueForKey("interprete")
                    cadena2 = NSAttributedString(string: "interpretado por \(interprete!)", attributes: normal)
                }
                else if (cancion?.valueForKey("interprete") as! String == "" && cancion?.valueForKey("autor") as! String != "") {
                    let autor = cancion?.valueForKey("autor")
                    cadena2 = NSAttributedString(string: "de \(autor!)", attributes: normal)
                }
                else if (cancion?.valueForKey("interprete") as! String != "" && cancion?.valueForKey("autor") as! String != "") {
                    let interprete = cancion?.valueForKey("interprete")
                    let autor = cancion?.valueForKey("autor")
                    cadena2 = NSAttributedString(string: "de \(autor) interpretado por \(interprete!)", attributes: normal)
                }
                let cd = coleccion?.valueForKey("nombre")
                cadena3 = NSAttributedString(string: "\(cd!)", attributes: italic)
                let formula = permiso?.valueForKey("formula")
                let propietario = permiso?.valueForKey("propietario")
                cadena4 = NSAttributedString(string: "\(formula!) \(propietario!)", attributes: normal)
                let cadenaMusica: NSMutableAttributedString = NSMutableAttributedString(string: "")
                cadenaMusica.appendAttributedString(cadena1!)
                cadenaMusica.appendAttributedString(cadena2!)
                cadenaMusica.appendAttributedString(cadena3!)
                cadenaMusica.appendAttributedString(cadena4!)
                self.musicaLabel = UILabel(frame: CGRect(x: self.iconoMusica!.frame.origin.x+48, y: 8, width: self.dentroScroll.frame.width-56, height: 0))
                self.musicaLabel?.attributedText = cadenaMusica
                self.musicaLabel?.numberOfLines = 0
                self.musicaLabel?.textColor = UIColor.whiteColor()
                self.musicaLabel?.sizeToFit()
                alto += Int(self.musicaLabel!.frame.height)+8
                self.datosView!.addSubview(self.musicaLabel!)
            }
        }
    }
    
    // Cambiar el titulo de la barra de navegacion
    func cambiaTitulo(var aux_titulo: String!)-> Void {
        dispatch_async(dispatch_get_main_queue()) {
            aux_titulo = aux_titulo.uppercaseString
            let atributos: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Aleo-Regular", size: 12)!]
            self.navigationController?.navigationBar.titleTextAttributes = atributos as? [String : AnyObject]
            self.navigationController?.navigationBar.topItem!.title = aux_titulo
        }
    }
    
    // Recuperar el icono y darle formato.
    func recuperarIcono(aux_icono: String!)-> Void {
        dispatch_async(dispatch_get_main_queue()) {
            self.hojaView.layer.borderWidth = 0.0
            var aux = "http://rezandovoy.ovh/"
            aux += aux_icono
            aux = aux.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            let filePath = NSURL(string: aux)
            let icono = NSData(contentsOfURL: filePath!)
            self.iconoLabel = UIImageView(frame: self.hojaView.bounds)
            self.iconoLabel?.image = UIImage(data: icono!)
            self.hojaView.addSubview(self.iconoLabel!)
        }
    }
    
    // Recuperar la fecha y darle formato
    func recuperarFecha(aux_fecha: String!)-> Void {
        format.dateFormat = "MMM d, yyyy"
        let fecha_aux = format.dateFromString(aux_fecha!)!
        let esp = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        esp.timeZone = NSTimeZone(name: "Europe/Madrid")!
        let requestedDateComponents: NSCalendarUnit = [.Year,.Month,.Day]
        let fecha = esp.components(requestedDateComponents, fromDate: fecha_aux)
        let calendario = NSCalendar.currentCalendar().dateFromComponents(fecha)
        format.locale = NSLocale(localeIdentifier: "es_ES")
        format.dateFormat = "MMMM"
        let mes = format.stringFromDate(calendario!)
        format.dateFormat = "EEEE"
        let dia = format.stringFromDate(calendario!)
        self.datosFecha(mes, aux_diaNum: String(fecha.day), aux_dia: dia)
    }
    
    // Maqueta la hoja del calendario
    func datosFecha(aux_mes: NSString?, aux_diaNum: NSString?, aux_dia: NSString?)->Void {
        dispatch_async(dispatch_get_main_queue()) {
            
            // Etiqueta para poner el número del día
            self.numLabel = UILabel(frame: CGRectMake(0,21,self.hojaView.frame.size.width,60))
            self.numLabel?.textAlignment = NSTextAlignment.Center
            self.numLabel?.textColor = UIColor.whiteColor()
            self.numLabel?.font = UIFont(name: "Aleo-Regular", size: 50)
            self.numLabel?.text = aux_diaNum as? String
            self.hojaView.addSubview(self.numLabel!)

            // Etiqueta para poner el nombre del mes
            self.mesLabel = UILabel(frame: CGRectMake(0,0,self.hojaView.frame.size.width,21))
            self.mesLabel?.textAlignment = NSTextAlignment.Center
            self.mesLabel?.textColor = UIColor.whiteColor()
            self.mesLabel?.font = UIFont(name: "Aleo-Regular", size: 17)
            self.mesLabel?.text = aux_mes as? String
            self.hojaView.addSubview(self.mesLabel!)
            
            // Etiqueta para poner el dia en texto
            self.diaLabel = UILabel(frame: CGRectMake(0,self.hojaView.frame.size.height-21,self.hojaView.frame.size.width,21))
            self.diaLabel?.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.2)
            self.diaLabel?.textAlignment = NSTextAlignment.Center
            self.diaLabel?.textColor = UIColor.whiteColor()
            self.diaLabel?.font = UIFont(name: "Aleo-Regular", size: 17)
            self.diaLabel?.text = aux_dia as? String
            self.hojaView.addSubview(self.diaLabel!)
        }
    }
    
    // Recuperar el fichero de imagenes y comprobar si esta cargado en la APP, si no usar default.
    func recuperarImagenes(ficheroImagenes: String!)-> Void {
        let nombreImagenes = ficheroImagenes.characters.split{$0 == "/"}.map(String.init)
        var imagenes = ["\(nombreImagenes[2])_1","\(nombreImagenes[2])_2","\(nombreImagenes[2])_3","\(nombreImagenes[2])_4"]
        let pruebaImg: UIImage? = UIImage(named: "\(nombreImagenes[2])_1")
        if pruebaImg != nil {
            imagenes.shuffle()
            self.fotoFondo(imagenes)
        }
        else {
            imagenes = ["default_1","default_2","default_3","default_4"]
            imagenes.shuffle()
            self.fotoFondo(imagenes)
        }
    }
    
    // Cargar las imagenes en el fondo
    func fotoFondo(nombre: NSArray)-> Void {
        dispatch_async(dispatch_get_main_queue()) {
            let images = [
                UIImage(named: nombre[0] as! String)!,
                UIImage(named: nombre[1] as! String)!,
                UIImage(named: nombre[2] as! String)!,
                UIImage(named: nombre[3] as! String)!
            ]
            self.imageView!.image = images[self.index++]
            self.animateImageView(images)
            self.view.addSubview(self.imageView!)
            self.view.bringSubviewToFront(self.controles)
            self.view.bringSubviewToFront(self.infoView)
        }
    }
    
    // Crear slider de las imagenes de fondo
    func animateImageView (imagenes: NSArray) {
        CATransaction.begin()
        
        CATransaction.setAnimationDuration(animationDuration)
        CATransaction.setCompletionBlock {
            let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(self.switchingInterval * NSTimeInterval(NSEC_PER_SEC)))
            dispatch_after(delay, dispatch_get_main_queue()) {
                self.animateImageView(imagenes)
            }
        }
        
        let transition = CATransition()
        transition.type = kCATransitionFade
    
        self.imageView?.layer.addAnimation(transition, forKey: kCATransition)
        self.imageView?.image = imagenes[index] as? UIImage
        
        CATransaction.commit()
        
        index = index < imagenes.count - 1 ? index + 1 : 0
    }
}
