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
    
    @IBOutlet var controles: UIView!
    @IBOutlet var botonPlay: UIButton!
    @IBOutlet var audioSlider: UISlider!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var mesLabel: UILabel!
    @IBOutlet var vistaScroll: UIScrollView!
    @IBOutlet var hojaView: UIView!
    
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
        
        self.imageView = UIImageView(frame: self.view.bounds)
        getOracionById()
        // Do any additional setup after loading the view.
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
    
    func getOracionById() -> AnyObject {
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
                    var aux = "http://rezandovoy.ovh/"
                    aux += jsonDict.valueForKey("oracion_link") as! String
                    
                    // Recuperar el fichero de imagenes y comprobar si esta cargado en la APP, si no usar default.
                    let ficheroImagenes = jsonDict.valueForKey("ficheroImagenes") as! String
                    let nombreImagenes = ficheroImagenes.characters.split{$0 == "/"}.map(String.init)
                    var imagenes = ["\(nombreImagenes[2])_1","\(nombreImagenes[2])_2","\(nombreImagenes[2])_3","\(nombreImagenes[2])_4"]
                    let pruebaImg: UIImage? = UIImage(named: "\(nombreImagenes[2])_1")
                    if pruebaImg != nil {
                        imagenes.shuffle()
                        print(imagenes)
                        self.fotoFondo(imagenes)
                    }
                    else {
                        imagenes = ["default_1","default_2","default_3","default_4"]
                        imagenes.shuffle()
                        print(imagenes)
                        self.fotoFondo(imagenes)
                    }
                    
                    // Recuperar la fecha y darla formato
                    format.dateFormat = "MMM d, yyyy"
                    let aux_fecha = jsonDict.valueForKey("fecha") as! String
                    let fecha_aux = format.dateFromString(aux_fecha)!
                    let esp = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
                    esp.timeZone = NSTimeZone(name: "Europe/Madrid")!
                    let requestedDateComponents: NSCalendarUnit = [.Year,.Month,.Day]
                    let fecha = esp.components(requestedDateComponents, fromDate: fecha_aux)
                    let calendario = NSCalendar.currentCalendar().dateFromComponents(fecha)
                    format.dateFormat = "MMMM"
                    let mes = format.stringFromDate(calendario!)
                    self.datos(mes)
                    
                    // Inicialización del reproductor con la url de la oración
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
                } else {
                    print("Error")
                }
            } catch let error as NSError {
                print(error)
            }
        }).resume()
        return true
    }
    
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
            self.view.bringSubviewToFront(self.vistaScroll)
        }
    }
    
    func datos(aux_mes: NSString)->Void {
        dispatch_async(dispatch_get_main_queue()) {
            self.mesLabel.text = aux_mes as String
        }
    }
    
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
