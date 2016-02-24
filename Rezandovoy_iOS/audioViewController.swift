//
//  audioViewController.swift
//  Rezandovoy_iOS
//
//  Created by Rodrigo on 20/1/16.
//  Copyright © 2016 sjdigital. All rights reserved.
//

/* TODO: La ventana de la informacion sale oculta cuando arranca el reproductor y las etiquetas de informacion tambien */

import UIKit
import AVKit
import AVFoundation

var format = NSDateFormatter()

extension UIView {
    
    func resizeToFitSubviews() {
        
        let subviewsRect = subviews.reduce(CGRect.zero) {
            $0.union($1.frame)
        }
        
        let fix = subviewsRect.origin
        subviews.forEach {
            $0.frame.offsetInPlace(dx: -fix.x, dy: -fix.y)
        }
        
        frame.offsetInPlace(dx: fix.x, dy: fix.y)
        frame.size = subviewsRect.size
    }
}

class audioViewController: UIViewController, AVAudioPlayerDelegate, NSURLSessionDownloadDelegate {
    
    var audioPlayer: AVPlayer?
    var imageView: UIImageView?
    var index = 0
    let animationDuration: NSTimeInterval = 1
    let switchingInterval: NSTimeInterval = 240
    let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
    var diaLabel: UILabel?
    var mesLabel: UILabel?
    var numLabel: UILabel?
    var iconoLabel: UIImageView?
    var iconoMusica: UIImageView?
    var musicaLabel: UILabel?
    var datosView: UIView?
    var lineaView: UIView?
    var botonCita: UIButton?
    var citaLabel: UILabel?
    var citasView: UIView?
    var botonCompartir: UIButton?
    var compartirView: UIView?
    var docsView: UIView?
    var bottonDocs: UIButton?
    var docsLabel: UILabel?
    var mp3Url: String?
    private var downloadTask: NSURLSessionDownloadTask?

    
    @IBOutlet var controles: UIView!
    @IBOutlet var botonPlay: UIButton!
    @IBOutlet var audioSlider: UISlider!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var vistaScroll: UIScrollView!
    @IBOutlet var hojaView: UIView!
    @IBOutlet var infoView: UIView!
    @IBOutlet var dentroScroll: UIView!
    @IBOutlet var downloadButton: UIBarButtonItem!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var progressView: ProgressView!
    @IBOutlet var modalView: UIView!
    
    @IBAction func reproductor(sender: UIButton) {
        if (audioPlayer?.rate != 0.0) {
            audioPlayer?.pause()
            sender.setImage(UIImage(named: "ic_play"), forState: UIControlState.Normal)
            self.infoView.hidden = false
        } else {
            audioPlayer?.play()
            sender.setImage(UIImage(named: "ic_pause"), forState: UIControlState.Normal)
            self.infoView.hidden = true
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
    
    @IBAction func toggleInfo(sender: UIButton) {
        if (self.infoView.hidden == true) {
            self.infoView.hidden = false
        }
        else {
            self.infoView.hidden = true
        }
    }
    
    @IBAction func descargar(sender: UIBarButtonItem) {
        self.modalView.hidden = false
        self.view.bringSubviewToFront(self.modalView)
        statusLabel.text = "Descargando oración"
        createDownloadTask()
    }
    
    @IBAction func downloadButtonPressed() {
        self.downloadTask!.cancel()
        self.modalView.hidden = true
    }

    func imageTap() {
        if (self.infoView.hidden == true) {
            self.infoView.hidden = false
        }
        else {
            self.infoView.hidden = true
        }
    }
    
    func toggleCita(sender: UIButton) {
        let supervista = sender.superview
        if (supervista?.subviews.last!.hidden == true) {
            supervista?.subviews.last!.sizeToFit()
            supervista?.subviews.last!.hidden = false
        }
        else {
            supervista?.subviews.last!.frame.size = CGSize(width: self.citaLabel!.frame.width, height: 0.0)
            supervista?.subviews.last!.hidden = true
        }
        supervista!.resizeToFitSubviews()
        self.recolocar()
        self.redimensionar()
    }
    
    func toggleDocs(sender: UIButton) {
        let supervista = sender.superview
        if (supervista?.subviews.last!.hidden == true) {
            supervista?.subviews.last!.sizeToFit()
            supervista?.subviews.last!.hidden = false
        }
        else {
            supervista?.subviews.last!.frame.size = CGSize(width: self.citaLabel!.frame.width, height: 0.0)
            supervista?.subviews.last!.hidden = true
        }
        supervista!.resizeToFitSubviews()
        self.recolocar()
        self.redimensionar()
    }
    
    func toggleCompartir() {
        var url: String?
        let miTexto = "Rezandovoy - Una oración diaria en mp3"
        if tipo == 1 {
            url = "http://www.rezandovoy.org/reproductor/adulta/\(id)"
        }
        else if tipo == 2 {
            url = "http://www.rezandovoy.org/reproductor/especial-adulta/\(id)"
        }
        else if tipo == 3 {
            url = "http://www.rezandovoy.org/reproductor/infantil/\(id)"
        }
        else if tipo == 4 {
            url = "http://www.rezandovoy.org/reproductor/especial-infantil/\(id)"
        }
        let miSitio = NSURL(string: url!)
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [miTexto, miSitio!], applicationActivities: nil)
        
        // This lines is for the popover you need to show in iPad
        activityViewController.popoverPresentationController?.sourceView = self.controles
        
        // This line remove the arrow of the popover to show in iPad
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [
            UIActivityTypePostToWeibo,
            UIActivityTypePrint,
            UIActivityTypeAssignToContact,
            UIActivityTypeSaveToCameraRoll,
            UIActivityTypeAddToReadingList,
            UIActivityTypePostToFlickr,
            UIActivityTypePostToVimeo,
            UIActivityTypePostToTencentWeibo
        ]
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Ocultar la vista de informacion
        self.infoView.hidden = true
        
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
        } else if tipo == 3 {
            getOracionPeriodicaInfantilById()
        } else if tipo == 4 {
            getOracionEspecialInfantilById()
        }
        
        statusLabel.text = ""
        modalView.frame = view.bounds
        modalView.backgroundColor = UIColor(red: 10/255, green: 50/255, blue: 66/255, alpha: 0.7)
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
                    
                    // LLamada a la funcion para recuperar la cita
                    self.recuperaCita((jsonDict.valueForKey("lectura") as? NSArray)!)
                    
                    // LLamada a la funcion para recuperar los documentos
                    self.recuperaDocs((jsonDict.valueForKey("documentos") as? NSArray)!)
                    
                    // LLamada a la funcion para crear el boton de compartir
                    self.compartir()
                    
                } else {
                    print("Error")
                }
            } catch let error as NSError {
                print(error)
            }
        }).resume()
        return true
    }
    
    // Llamada al servidor REST para recibir la infantil
    func getOracionPeriodicaInfantilById() -> AnyObject {
        // Variables peticion JSON
        let session = NSURLSession.sharedSession()
        let postEndpoint: String = "http://rezandovoy.ovh:8080/Rezandovoy_server/api/publica/getPeriodicaInfantilById"
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
                    
                    // LLamada a la funcion para recuperar el titulo y maquetarlo
                    self.recuperarTitulo(jsonDict.valueForKey("titulo") as? String)
                    
                    // LLamada a la funcion para recuperar musicas
                    self.recuperarMusica((jsonDict.valueForKey("musicas") as? NSArray)!)
                    
                    // LLamada a la funcion para recuperar la cita
                    self.recuperaCita((jsonDict.valueForKey("lectura") as? NSArray)!)
                    
                    // LLamada a la funcion para recuperar los documentos
                    self.recuperaDocs((jsonDict.valueForKey("documentos") as? NSArray)!)
                    
                    // LLamada a la funcion para crear el boton de compartir
                    self.compartir()
                    
                } else {
                    print("Error")
                }
            } catch let error as NSError {
                print(error)
            }
        }).resume()
        return true
    }
    
    // Llamada al servidor REST para recibir la especial infantil
    func getOracionEspecialInfantilById() -> AnyObject {
        // Variables peticion JSON
        let session = NSURLSession.sharedSession()
        let postEndpoint: String = "http://rezandovoy.ovh:8080/Rezandovoy_server/api/publica/getEspecialInfantilById"
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
                    self.recuperarTitulo(jsonDict.valueForKey("titulo") as? String)
                    
                    // LLamada a la funcion para recuperar musicas
                    self.recuperarMusica((jsonDict.valueForKey("musicas") as? NSArray)!)
                    
                    // LLamada a la funcion para recuperar la cita
                    self.recuperaCita((jsonDict.valueForKey("lectura") as? NSArray)!)
                    
                    // LLamada a la funcion para recuperar los documentos
                    self.recuperaDocs((jsonDict.valueForKey("documentos") as? NSArray)!)
                    
                    // LLamada a la funcion para crear el boton de compartir
                    self.compartir()
                    
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
                    
                    // LLamada a la funcion para recuperar musicas
                    self.recuperarMusica((jsonDict.valueForKey("musicas") as? NSArray)!)
                    
                    // LLamada a la funcion para recuperar la cita
                    if let _ : AnyObject = jsonDict.valueForKey("lectura") {
                        self.recuperaCita((jsonDict.valueForKey("lectura") as? NSArray)!)
                    }
                    
                    // LLamada a la funcion para recuperar los documentos
                    self.recuperaDocs((jsonDict.valueForKey("documentos") as? NSArray)!)
                    
                    // LLamada a la funcion para crear el boton de compartir
                    self.compartir()
                    
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
        self.mp3Url = aux
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
                self.infoView.hidden = false
            }
        }
        self.reproductor(self.botonPlay)
    }
    
    // Recuperar los documentos y darles formato, puede estar vacio
    func recuperaDocs(aux_docs: NSArray?)->Void {
        dispatch_async(dispatch_get_main_queue()) {
            if aux_docs!.count > 0 {
                for (doc) in aux_docs! {
                    self.docsView = UIView(frame: CGRect(x: 0, y: Int(self.lineaView!.frame.origin.y)+9, width: Int(self.dentroScroll!.frame.width), height: 0))
                    self.dentroScroll!.addSubview(self.docsView!)
                    self.bottonDocs = UIButton(frame: CGRect(x: 8, y: 0, width: Int(self.dentroScroll!.frame.width)-8, height: 32))
                    self.bottonDocs?.titleLabel?.font = UIFont(name: "Aleo-Regular", size: 13)
                    self.bottonDocs?.setTitle(doc.valueForKey("nombre") as? String, forState: UIControlState.Normal)
                    self.bottonDocs?.setImage(UIImage(named: "ic_docs"), forState: UIControlState.Normal)
                    self.bottonDocs?.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
                    self.bottonDocs?.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
                    self.bottonDocs?.titleEdgeInsets.left = 10.0
                    self.bottonDocs?.addTarget(self, action: Selector("toggleDocs:"), forControlEvents: .TouchUpInside)
                    self.docsView?.addSubview(self.bottonDocs!)
                    self.docsLabel = UILabel(frame: CGRect(x: 8, y: 40, width: Int(self.dentroScroll!.frame.width)-8, height: 0))
                    self.docsLabel?.text = doc.valueForKey("texto") as? String
                    self.docsLabel?.numberOfLines = 0
                    self.docsLabel?.textColor = UIColor.whiteColor()
                    self.docsLabel?.font = UIFont(name: "Aleo-Regular", size: 13)
                    //self.docsLabel?.sizeToFit()
                    self.docsLabel?.hidden = true
                    self.docsView?.addSubview(self.docsLabel!)
                    self.docsView?.resizeToFitSubviews()
                    let aux_y = Int((self.docsView?.frame.origin.y)!) + Int((self.docsView?.frame.height)!) + 8
                    self.lineaView = UIView(frame: CGRect(x: 8, y: aux_y, width: Int(self.dentroScroll!.frame.width)-16, height: 1))
                    self.lineaView!.layer.borderWidth = 1.0
                    self.lineaView!.layer.borderColor = UIColor.whiteColor().CGColor
                    self.dentroScroll!.addSubview(self.lineaView!)
                }
            }
        }
    }
    
    // Recuperar la cita y darla formato
    func recuperaCita(aux_citas: NSArray?)-> Void {
        dispatch_async(dispatch_get_main_queue()) {
            if aux_citas!.count > 0 {
                for (aux_cita) in aux_citas! {
                    self.citasView = UIView(frame: CGRect(x: 0, y: Int(self.dentroScroll!.subviews.last!.frame.origin.y)+8+Int(self.dentroScroll!.subviews.last!.frame.height), width: Int(self.datosView!.frame.width), height: 0))
                    self.dentroScroll!.addSubview(self.citasView!)
                    self.botonCita = UIButton(frame: CGRect(x: 8, y: 0, width: Int(self.dentroScroll!.frame.width)-8, height: 32))
                    self.botonCita?.titleLabel?.font = UIFont(name: "Aleo-Regular", size: 13)
                    self.botonCita?.setTitle(aux_cita.valueForKey("cita") as? String, forState: UIControlState.Normal)
                    self.botonCita?.setImage(UIImage(named: "ic_lectura"), forState: UIControlState.Normal)
                    self.botonCita?.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
                    self.botonCita?.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
                    self.botonCita?.titleEdgeInsets.left = 10.0
                    self.botonCita?.addTarget(self, action: Selector("toggleCita:"), forControlEvents: .TouchUpInside)
                    self.citasView?.addSubview(self.botonCita!)
                    self.citaLabel = UILabel(frame: CGRect(x: 8, y: 40, width: Int(self.dentroScroll!.frame.width)-8, height: 0))
                    self.citaLabel?.text = aux_cita.valueForKey("texto") as? String
                    self.citaLabel?.numberOfLines = 0
                    self.citaLabel?.textColor = UIColor.whiteColor()
                    self.citaLabel?.font = UIFont(name: "Aleo-Regular", size: 13)
                    //self.citaLabel?.sizeToFit()
                    self.citaLabel?.hidden = true
                    self.citasView?.addSubview(self.citaLabel!)
                    self.citasView?.resizeToFitSubviews()
                    let aux_y = Int((self.citasView?.frame.origin.y)!) + Int((self.citasView?.frame.height)!) + 8
                    self.lineaView = UIView(frame: CGRect(x: 8, y: aux_y, width: Int(self.dentroScroll!.frame.width)-16, height: 1))
                    self.lineaView!.layer.borderWidth = 1.0
                    self.lineaView!.layer.borderColor = UIColor.whiteColor().CGColor
                    self.dentroScroll!.addSubview(self.lineaView!)
                }
            }
        }
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
            let normal = [ NSFontAttributeName: UIFont(name: "Aleo-Regular", size: 13)! ] as [String : AnyObject]
            let bold = [ NSFontAttributeName: UIFont(name: "Aleo-Bold", size: 13)! ] as [String : AnyObject]
            let italic = [ NSFontAttributeName: UIFont(name: "Aleo-Italic", size: 13)! ] as [String : AnyObject]
            for (musica) in aux_mus {
                if alto == 0 {
                    self.datosView = UIView(frame: CGRect(x: 0, y: alto, width: Int(self.dentroScroll!.frame.width), height: 0))
                    self.dentroScroll!.addSubview(self.datosView!)
                    self.datosView!.addSubview(self.iconoMusica!)
                }
                else {
                    self.datosView = UIView(frame: CGRect(x: 0, y: alto, width: Int(self.dentroScroll!.frame.width), height: 0))
                    self.dentroScroll!.addSubview(self.datosView!)
                }
                let cancion = musica.valueForKey("cancion")
                let coleccion = musica.valueForKey("coleccion")
                let permiso = musica.valueForKey("permiso")
                let titulo = cancion?.valueForKey("titulo")
                cadena1 = NSAttributedString(string: String(titulo!), attributes: bold)
                if (cancion?.valueForKey("autor") as! String == "" && cancion?.valueForKey("interprete") as! String != "") {
                    let interprete = cancion?.valueForKey("interprete")
                    cadena2 = NSAttributedString(string: " interpretado por \(interprete!). CD ", attributes: normal)
                }
                else if (cancion?.valueForKey("interprete") as! String == "" && cancion?.valueForKey("autor") as! String != "") {
                    let autor = cancion?.valueForKey("autor")
                    cadena2 = NSAttributedString(string: " de \(autor!). CD ", attributes: normal)
                }
                else if (cancion?.valueForKey("interprete") as! String != "" && cancion?.valueForKey("autor") as! String != "") {
                    let interprete = cancion?.valueForKey("interprete")
                    let autor = cancion?.valueForKey("autor")
                    cadena2 = NSAttributedString(string: " de \(autor!) interpretado por \(interprete!). CD ", attributes: normal)
                }
                let cd = coleccion?.valueForKey("nombre")
                cadena3 = NSAttributedString(string: "\(cd!) ", attributes: italic)
                let formula = permiso?.valueForKey("formula")
                let propietario = permiso?.valueForKey("propietario") as! String
                if propietario != "#" {
                    cadena4 = NSAttributedString(string: "\(formula!) \(propietario)", attributes: normal)
                }
                let cadenaMusica: NSMutableAttributedString = NSMutableAttributedString(string: "")
                cadenaMusica.appendAttributedString(cadena1!)
                if let _ : NSAttributedString = cadena2 {
                    cadenaMusica.appendAttributedString(cadena2!)
                }
                if let _ : NSAttributedString = cadena3 {
                    cadenaMusica.appendAttributedString(cadena3!)
                }
                if let _ : NSAttributedString = cadena4 {
                    cadenaMusica.appendAttributedString(cadena4!)
                }
                self.musicaLabel = UILabel(frame: CGRect(x: self.iconoMusica!.frame.origin.x+48, y: 8, width: self.dentroScroll!.frame.width-56, height: 0))
                self.musicaLabel?.attributedText = cadenaMusica
                self.musicaLabel?.numberOfLines = 0
                self.musicaLabel?.textColor = UIColor.whiteColor()
                self.musicaLabel?.sizeToFit()
                alto += Int(self.musicaLabel!.frame.height)+8
                self.datosView!.addSubview(self.musicaLabel!)
                self.datosView?.resizeToFitSubviews()
            }
            let aux_y = Int((self.datosView?.frame.origin.y)!) + Int((self.datosView?.frame.height)!) + 8
            self.lineaView = UIView(frame: CGRect(x: 8, y: aux_y, width: Int(self.dentroScroll!.frame.width)-16, height: 1))
            self.lineaView!.layer.borderWidth = 1.0
            self.lineaView!.layer.borderColor = UIColor.whiteColor().CGColor
            self.dentroScroll!.addSubview(self.lineaView!)
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
    
    // Recuperar el titulo y darle formato
    func recuperarTitulo(aux_titulo: String!)-> Void {
        dispatch_async(dispatch_get_main_queue()) {
            self.diaLabel = UILabel(frame: CGRectMake(0,self.hojaView.frame.size.height,self.hojaView.frame.size.width,0))
            self.diaLabel?.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.2)
            self.diaLabel?.textAlignment = NSTextAlignment.Center
            self.diaLabel?.textColor = UIColor.whiteColor()
            self.diaLabel?.font = UIFont(name: "Aleo-Regular", size: 13)
            self.diaLabel?.text = aux_titulo
            self.diaLabel?.numberOfLines = 0
            self.diaLabel?.sizeToFit()
            self.diaLabel?.frame = CGRectMake(CGFloat(0), self.hojaView.frame.size.height - self.diaLabel!.frame.size.height, self.hojaView.frame.size.width, self.diaLabel!.frame.size.height)
            self.hojaView.addSubview(self.diaLabel!)
            self.iconoLabel = UIImageView(frame: self.hojaView.bounds)
            self.iconoLabel?.image = UIImage(named: "ic_rvn_blanco")
            self.iconoLabel?.contentMode = UIViewContentMode.ScaleAspectFit
            self.iconoLabel?.contentMode = UIViewContentMode.Top
            self.hojaView.addSubview(self.iconoLabel!)
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
            let tapGesture = UITapGestureRecognizer(target: self, action: Selector("imageTap"))
            self.imageView!.image = images[self.index++]
            self.imageView?.contentMode = UIViewContentMode.ScaleAspectFill
            self.animateImageView(images)
            self.imageView?.userInteractionEnabled = true
            self.imageView?.addGestureRecognizer(tapGesture)
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
    
    // Crear el boton de compartir
    func compartir()-> Void {
        dispatch_async(dispatch_get_main_queue()) {
            let ultimo = self.dentroScroll!.subviews[self.dentroScroll!.subviews.count-1].frame
            let aux_y = Int(ultimo.origin.y) + Int(ultimo.height)
            self.compartirView = UIView(frame: CGRect(x: 0, y: aux_y+8, width: Int(self.dentroScroll!.frame.width), height: 0))
            self.dentroScroll!.addSubview(self.compartirView!)
            self.botonCompartir = UIButton(frame: CGRect(x: 8, y: 0, width: Int(self.dentroScroll!.frame.width)-8, height: 32))
            self.botonCompartir?.titleLabel?.font = UIFont(name: "Aleo-Regular", size: 13)
            self.botonCompartir?.setTitle("compartir", forState: UIControlState.Normal)
            self.botonCompartir?.setImage(UIImage(named: "ic_compartir"), forState: UIControlState.Normal)
            self.botonCompartir?.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
            self.botonCompartir?.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            self.botonCompartir?.titleEdgeInsets.left = 10.0
            self.botonCompartir?.addTarget(self, action: Selector("toggleCompartir"), forControlEvents: .TouchUpInside)
            self.compartirView?.addSubview(self.botonCompartir!)
            self.compartirView?.resizeToFitSubviews()
            
            // Llamada a la funcion para recalcular el alto y que funcione el scroll
            self.redimensionar()
        }
    }
    
    // Recolocar views cuando desplieges u ocultes informacion
    func recolocar()-> Void {
        let vista = self.dentroScroll!
        
        var aux_y = 0
        for (subvista) in vista.subviews {
            subvista.frame.origin = CGPoint(x: 0, y: aux_y)
            aux_y = 8 + Int(subvista.frame.origin.y) + Int(subvista.frame.height)
        }
    }
    
    // Redimensionar views para que el scroll vaya bien
    func redimensionar()-> Void {
        let ultimo = self.dentroScroll!.subviews.last
        self.vistaScroll.contentSize = CGSize(width: self.dentroScroll!.frame.width, height: ultimo!.frame.height+16.0+ultimo!.frame.origin.y)
        self.dentroScroll?.resizeToFitSubviews()
        
        // Funciona pero no tiene sentido
        self.dentroScroll.translatesAutoresizingMaskIntoConstraints = true
    }
    
    // Funciones de la clase delegate session download data
    func createDownloadTask() {
        let downloadRequest = NSMutableURLRequest(URL: NSURL(string: self.mp3Url!)!)
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        
        downloadTask = session.downloadTaskWithRequest(downloadRequest)
        downloadTask!.resume()
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        progressView.animateProgressViewToProgress(progress)
        progressView.updateProgressViewLabelWithProgress(progress * 100)
        progressView.updateProgressViewWith(Float(totalBytesWritten), totalFileSize: Float(totalBytesExpectedToWrite))
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        statusLabel.text = "Descarga finalizada"
        print(location)
        let audioUrl = NSURL(string: self.mp3Url!)
        let destinationUrl = self.documentsUrl.URLByAppendingPathComponent(audioUrl!.lastPathComponent!)
        print(destinationUrl.path)
        if NSFileManager().fileExistsAtPath(destinationUrl.path!) {
            print("file already exists [\(destinationUrl.path!)]")
        } else {
            do {
                try NSFileManager.defaultManager().moveItemAtURL(location, toURL: destinationUrl)
                print("Move successful")
                self.downloadButton.tintColor = UIColor.greenColor()
                let delay = 5.0 * Double(NSEC_PER_SEC)
                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(time, dispatch_get_main_queue(), {
                    self.modalView.hidden = true
                })
            } catch let error as NSError {
                print("Moved failed with error \(error)")
            }
        }
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if let _ = error {
            statusLabel.text = "Fallo al descargar"
        } else {
            statusLabel.text = "Descarga finalizada"
        }
    }
}
