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


var format = DateFormatter()

extension UIView {
    
    func resizeToFitSubviews() {
        
        let subviewsRect = subviews.reduce(CGRect.zero) {
            $0.union($1.frame)
        }
        
        let fix = subviewsRect.origin
        subviews.forEach {
            $0.frame.offsetBy(dx: -fix.x, dy: -fix.y)
        }
        
        frame.offsetBy(dx: fix.x, dy: fix.y)
        frame.size = subviewsRect.size
    }
}

class ProgressHUD: UIVisualEffectView {
    
    var text: String? {
        didSet {
            label.text = text
        }
    }
    
    let activityIndictor: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    let label: UILabel = UILabel()
    let blurEffect = UIBlurEffect(style: .dark)
    let vibrancyView: UIVisualEffectView
    
    init(text: String) {
        self.text = text
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        super.init(effect: blurEffect)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.text = ""
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        contentView.addSubview(vibrancyView)
        contentView.addSubview(activityIndictor)
        contentView.addSubview(label)
        activityIndictor.startAnimating()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if let superview = self.superview {
            
            let width = superview.frame.size.width / 1.5
            let height: CGFloat = 50.0
            self.frame = CGRect(x: superview.frame.size.width / 2 - width / 2,
                                y: superview.frame.height / 2 - height / 2,
                                width: width,
                                height: height)
            vibrancyView.frame = self.bounds
            
            let activityIndicatorSize: CGFloat = 40
            activityIndictor.frame = CGRect(x: 5,
                                            y: height / 2 - activityIndicatorSize / 2,
                                            width: activityIndicatorSize,
                                            height: activityIndicatorSize)
            
            layer.cornerRadius = 8.0
            layer.masksToBounds = true
            label.text = text
            label.textAlignment = NSTextAlignment.center
            label.frame = CGRect(x: activityIndicatorSize + 5,
                                 y: 0,
                                 width: width - activityIndicatorSize - 15,
                                 height: height)
            label.textColor = UIColor.white
            label.font = UIFont.boldSystemFont(ofSize: 16)
        }
    }
    
    func show() {
        self.isHidden = false
    }
    
    func hide() {
        self.isHidden = true
    }
}


class audioViewController: UIViewController, AVAudioPlayerDelegate, URLSessionDownloadDelegate {
    
    var audioPlayer: AVPlayer?
    var imageView: UIImageView?
    var index = 0
    var offline = 0
    let animationDuration: TimeInterval = 1
    let switchingInterval: TimeInterval = 240
    let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as URL
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
    var iconoUrl: URL?
    var downloadTask: URLSessionDownloadTask?
    var oracion: Oracion = Oracion(auxId: id, auxTipo: tipo)
    var progressHUD: ProgressHUD?
    var temporizador: Timer?
    var audioItem: AVPlayerItem?
    
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
    @IBOutlet var cancelDownload: UIButton!
    
    @IBAction func reproductor(_ sender: UIButton) {
        if (audioPlayer?.rate != 0.0) {
            audioPlayer?.pause()
            sender.setImage(UIImage(named: "ic_play"), for: UIControlState())
            self.infoView.isHidden = false
        } else {
            if #available(iOS 10, *) {
                audioPlayer?.playImmediately(atRate: 1.0)
            } else {
                audioPlayer?.play()
            }
            sender.setImage(UIImage(named: "ic_pause"), for: UIControlState())
            self.infoView.isHidden = true
        }
    }
    
    @IBAction func forward(_ sender: AnyObject?) {
        var auxTime = audioPlayer?.currentItem?.currentTime()
        auxTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(auxTime!) + 15, (auxTime?.timescale)!)
        audioPlayer?.currentItem?.seek(to: auxTime!)
    }
    
    @IBAction func backward(_ sender: AnyObject?) {
        var auxTime = audioPlayer?.currentItem?.currentTime()
        auxTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(auxTime!) - 15, (auxTime?.timescale)!)
        audioPlayer?.currentItem?.seek(to: auxTime!)
    }
    
    @IBAction func sliderValue(_ sender: UISlider) {
        var tiempoSegs = Float64(sender.value)
        tiempoSegs /= 100.0
        let duracion = CMTimeGetSeconds((self.audioPlayer?.currentItem!.duration)!)
        let normalizedTime = tiempoSegs * duracion
        let tiempo = CMTimeMakeWithSeconds(normalizedTime, 1000)
        audioPlayer?.currentItem?.seek(to: tiempo)
    }
    
    @IBAction func sliderPlay(_ sender: UISlider) {
        if (audioPlayer!.rate == 0.0) {
            reproductor(botonPlay)
        }
        else {
            reproductor(botonPlay)
        }
    }
    
    @IBAction func toggleInfo(_ sender: UIButton) {
        if (self.infoView.isHidden == true) {
            self.infoView.isHidden = false
        }
        else {
            self.infoView.isHidden = true
        }
    }
    
    @IBAction func descargar(_ sender: UIBarButtonItem) {
        self.modalView.isHidden = false
        self.view.bringSubview(toFront: self.modalView)
        statusLabel.text = "Descargando oración"
        createDownloadTask()
        sender.isEnabled = false
    }
    
    @IBAction func downloadButtonPressed() {
        self.downloadTask!.cancel()
        self.modalView.isHidden = true
        self.downloadButton.isEnabled = true
    }

    func imageTap() {
        if (self.infoView.isHidden == true) {
            self.infoView.isHidden = false
        }
        else {
            self.infoView.isHidden = true
        }
    }
    
    func toggleCita(_ sender: UIButton) {
        let supervista = sender.superview
        if (supervista?.subviews.last!.isHidden == true) {
            supervista?.subviews.last!.sizeToFit()
            supervista?.subviews.last!.isHidden = false
        }
        else {
            supervista?.subviews.last!.frame.size = CGSize(width: self.citaLabel!.frame.width, height: 0.0)
            supervista?.subviews.last!.isHidden = true
        }
        supervista!.resizeToFitSubviews()
        self.recolocar()
        self.redimensionar()
    }
    
    func toggleDocs(_ sender: UIButton) {
        let supervista = sender.superview
        if (supervista?.subviews.last!.isHidden == true) {
            supervista?.subviews.last!.sizeToFit()
            supervista?.subviews.last!.isHidden = false
        }
        else {
            supervista?.subviews.last!.frame.size = CGSize(width: self.citaLabel!.frame.width, height: 0.0)
            supervista?.subviews.last!.isHidden = true
        }
        supervista!.resizeToFitSubviews()
        self.recolocar()
        self.redimensionar()
    }
    
    func toggleCompartir() {
        var url: String?
        let miTexto = "Rezandovoy - Una oración diaria en mp3"
        if tipo == 1 {
            url = "https://www.rezandovoy.org/reproductor/adulta/\(id)"
        }
        else if tipo == 2 {
            url = "https://www.rezandovoy.org/reproductor/especial-adulta/\(id)"
        }
        else if tipo == 3 {
            url = "https://www.rezandovoy.org/reproductor/infantil/\(id)"
        }
        else if tipo == 4 {
            url = "https://www.rezandovoy.org/reproductor/especial-infantil/\(id)"
        }
        let miSitio = URL(string: url!)
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [miTexto, miSitio!], applicationActivities: nil)
        
        // This lines is for the popover you need to show in iPad
        activityViewController.popoverPresentationController?.sourceView = self.controles
        
        // This line remove the arrow of the popover to show in iPad
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [
            UIActivityType.postToWeibo,
            UIActivityType.print,
            UIActivityType.assignToContact,
            UIActivityType.saveToCameraRoll,
            UIActivityType.addToReadingList,
            UIActivityType.postToFlickr,
            UIActivityType.postToVimeo,
            UIActivityType.postToTencentWeibo
        ]
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if #available(iOS 10.0, *) {
            self.temporizador = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
                _ in
                if (self.audioItem?.isPlaybackLikelyToKeepUp==true) {
                    if (self.progressHUD?.isHidden == false) {
                        self.progressHUD?.hide()
                    } else {
                        self.temporizador?.invalidate()
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Ocultar la vista de informacion
        self.infoView.isHidden = true
        
        //Deshabilitar el gesto de ir hacia atras
        self.navigationController!.interactivePopGestureRecognizer!.isEnabled = false
        
        //Ocultar Tab Bar y cambio de colores de la barra de navegacion.
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 10/255, green: 50/255, blue: 66/255, alpha: 0.7)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        //Recibir eventos bloqueado
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        //Poner borde a la hoja de calendario
        self.hojaView.layer.borderWidth = 1.0
        self.hojaView.layer.borderColor = UIColor.white.cgColor
        
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
        
        do {
            let items = try FileManager.default.contentsOfDirectory(atPath: "\(self.documentsUrl.path)")
            for item in items {
                if item.hasSuffix("mp3") {
                    print(item)
                } else {
                    if (item == "\(id)") {
                        self.downloadButton.isEnabled = false
                        offline = 1
                    }
                }
            }
        } catch let error as NSError {
            print("Fallo al leer el directorio \(error)")
        }
        
        if (offline == 1) {
            print("Offline")
            getOracionGuardada()
        } else {
            if tipo == 1 {
                getOracionPeriodicaAdultoById()
            } else if tipo == 2 {
                getOracionEspecialAdultaById()
            } else if tipo == 3 {
                getOracionPeriodicaInfantilById()
            } else if tipo == 4 {
                getOracionEspecialInfantilById()
            }
        }
        
        self.imageView = UIImageView(frame: self.view.bounds)
        
        statusLabel.text = ""
        modalView.frame = view.bounds
        modalView.backgroundColor = UIColor(red: 10/255, green: 50/255, blue: 66/255, alpha: 0.7)
        
        self.progressHUD = ProgressHUD(text: "Cargando oración")
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        if (event?.subtype == UIEventSubtype.remoteControlPause) {
            self.reproductor(botonPlay)
        }
        else if (event?.subtype == UIEventSubtype.remoteControlNextTrack) {
            forward(event)
        }
        else if (event?.subtype == UIEventSubtype.remoteControlPreviousTrack) {
            backward(event)
        }
        else if (event?.subtype == UIEventSubtype.remoteControlPlay) {
            self.reproductor(botonPlay)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if (self.isMovingFromParentViewController) {
            if let _ = self.downloadTask {
                 self.downloadTask!.cancel()
            }
            self.audioPlayer?.pause()
            self.tabBarController?.tabBar.isHidden = false
            self.navigationController?.navigationBar.barTintColor = nil
            self.navigationController?.navigationBar.tintColor = self.view.tintColor
            let atributos: NSDictionary = [NSForegroundColorAttributeName: UIColor.black, NSFontAttributeName: UIFont(name: "Aleo-Regular", size: 15)!]
            self.navigationController?.navigationBar.titleTextAttributes = atributos as? [String : AnyObject]
            UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
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
    
    // Cargar oración guardada en el telefono 
    func getOracionGuardada() -> AnyObject {
        let oracionGuardada = self.loadOracion(id)
        
        
        // Si es oracion periodica normal
        if (oracionGuardada!.tipo == 1) {
            
            // Recuperar el link de la oración
            var aux_mp3 = "\(self.documentsUrl)"
            aux_mp3 += oracionGuardada!.mp3! as String
            print(aux_mp3)
            self.reproductorInit(aux_mp3)
        
            // LLamada a la funcion para poner el titulo
            self.cambiaTitulo(oracionGuardada!.titulo! as String)
        
            // LLamada a la funcion para recuperar imagenes
            self.recuperarImagenes(oracionGuardada!.images! as String)
        
            // LLamada a la funcion para recuperar fecha
            self.recuperarFecha(oracionGuardada!.fecha! as String)
        
            // LLamada a la funcion para recuperar musicas
            self.recuperarMusica((oracionGuardada!.musicas! as NSArray))
        
            // LLamada a la funcion para recuperar la cita
            self.recuperaCita((oracionGuardada!.lectura! as NSArray))
        
            // LLamada a la funcion para recuperar los documentos
            self.recuperaDocs((oracionGuardada!.documentos! as NSArray))
            
        } else if (oracionGuardada!.tipo == 2) {
            
            // Recuperar el link de la oración
            var aux_mp3 = "\(self.documentsUrl)"
            aux_mp3 += oracionGuardada!.mp3! as String
            print(aux_mp3)
            self.reproductorInit(aux_mp3)
            
            // LLamada a la funcion para poner el titulo
            self.cambiaTitulo(oracionGuardada!.titulo! as String)
            
            // LLamada a la funcion para recuperar imagenes
            self.recuperarImagenes(oracionGuardada!.images! as String)
            
            // LLamada a la funcion para recuperar fecha
            var aux_icono = "\(self.documentsUrl)"
            aux_icono += oracionGuardada!.icono! as String
            self.recuperarIcono(aux_icono as String)
            
            // LLamada a la funcion para recuperar musicas
            self.recuperarMusica((oracionGuardada!.musicas! as NSArray))
            
            // LLamada a la funcion para recuperar la cita
            if let _ : AnyObject = oracionGuardada!.lectura {
                self.recuperaCita((oracionGuardada!.lectura! as NSArray))
            }
            
            // LLamada a la funcion para recuperar los documentos
            self.recuperaDocs((oracionGuardada!.documentos! as NSArray))
            
        } else if (oracionGuardada!.tipo == 3) {
            
            // Recuperar el link de la oración
            var aux_mp3 = "\(self.documentsUrl)"
            aux_mp3 += oracionGuardada!.mp3! as String
            print(aux_mp3)
            self.reproductorInit(aux_mp3)
            
            // LLamada a la funcion para poner el titulo
            self.cambiaTitulo(oracionGuardada!.titulo! as String)
            
            // LLamada a la funcion para recuperar imagenes
            self.recuperarImagenes(oracionGuardada!.images! as String)
            
            // LLamada a la funcion para recuperar musicas
            self.recuperarMusica((oracionGuardada!.musicas! as NSArray))
            
            // LLamada a la funcion para recuperar el titulo y maquetarlo
            self.recuperarTitulo(oracionGuardada!.titulo! as String)
            
            // LLamada a la funcion para recuperar la cita
            self.recuperaCita((oracionGuardada!.lectura! as NSArray))
            
            // LLamada a la funcion para recuperar los documentos
            self.recuperaDocs((oracionGuardada!.documentos! as NSArray))
            
        } else if (oracionGuardada!.tipo == 4) {
            
            // Recuperar el link de la oración
            var aux_mp3 = "\(self.documentsUrl)"
            aux_mp3 += oracionGuardada!.mp3! as String
            print(aux_mp3)
            self.reproductorInit(aux_mp3)
            
            // LLamada a la funcion para poner el titulo
            self.cambiaTitulo(oracionGuardada!.titulo! as String)
            
            // LLamada a la funcion para recuperar imagenes
            self.recuperarImagenes(oracionGuardada!.images! as String)
            
            // LLamada a la funcion para recuperar musicas
            self.recuperarMusica((oracionGuardada!.musicas! as NSArray))
            
            // LLamada a la funcion para recuperar el titulo y maquetarlo
            self.recuperarTitulo(oracionGuardada!.titulo! as String)
            
            // LLamada a la funcion para recuperar la cita
            self.recuperaCita((oracionGuardada!.lectura! as NSArray))
            
            // LLamada a la funcion para recuperar los documentos
            self.recuperaDocs((oracionGuardada!.documentos! as NSArray))
            
        }
        
        // LLamada a la funcion para crear el boton de compartir
        self.compartir()
        
        return true as AnyObject
    }
    
    
    // Llamada al servidor REST para recibir la periodica
    func getOracionPeriodicaAdultoById() -> AnyObject {
        // Variables peticion JSON
        let session = Foundation.URLSession.shared
        let postEndpoint: String = "http://rezandovoy.ovh:8080/Rezandovoy_server/api/publica/getPeriodicaAdultaById"
        let postParams: NSDictionary = ["id": "\(id)"]
        let url = URL(string: postEndpoint)!
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postParams, options: JSONSerialization.WritingOptions())
            print("Funca by id")
        } catch {
            print("No funca by id")
        }
        
        //session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: NSError?) -> Void in
        
        
        session.dataTask(with: request as URLRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            guard let realResponse = response as? HTTPURLResponse, realResponse.statusCode == 200 else {
                let respuesta = response as? HTTPURLResponse
                print("Not a 200 response is:\n \(respuesta)")
                return
            }
            do {
                if let jsonDict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? NSDictionary {
                    
                    // Guardar datos
                    self.oracion.settitulo(jsonDict.value(forKey: "titulo") as! String)
                    self.oracion.setimages(jsonDict.value(forKey: "ficheroImagenes") as! String)
                    self.oracion.setfecha(jsonDict.value(forKey: "fecha") as? String)
                    self.oracion.setmusicas(jsonDict.value(forKey: "musicas") as? NSArray)
                    self.oracion.setlectura(jsonDict.value(forKey: "lectura") as? NSArray)
                    self.oracion.setdocumentos(jsonDict.value(forKey: "documentos") as? NSArray)
                    
                    // Recuperar el link de la oración
                    var aux_mp3 = "https://rezandovoy.ovh/"
                    aux_mp3 += jsonDict.value(forKey: "oracion_link") as! String
                    self.reproductorInit(aux_mp3)
                    
                    // LLamada a la funcion para poner el titulo
                    self.cambiaTitulo(jsonDict.value(forKey: "titulo") as! String)
                    
                    // LLamada a la funcion para recuperar imagenes
                    self.recuperarImagenes(jsonDict.value(forKey: "ficheroImagenes") as! String)
                
                    // LLamada a la funcion para recuperar fecha
                    self.recuperarFecha(jsonDict.value(forKey: "fecha") as? String)
                    
                    // LLamada a la funcion para recuperar musicas
                    self.recuperarMusica((jsonDict.value(forKey: "musicas") as? NSArray)!)
                    
                    // LLamada a la funcion para recuperar la cita
                    self.recuperaCita((jsonDict.value(forKey: "lectura") as? NSArray)!)
                    
                    // LLamada a la funcion para recuperar los documentos
                    self.recuperaDocs((jsonDict.value(forKey: "documentos") as? NSArray)!)
                    
                    // LLamada a la funcion para crear el boton de compartir
                    self.compartir()
                    
                } else {
                    print("Error")
                }
            } catch let error as NSError {
                print(error)
            }
        }).resume()
        return true as AnyObject
    }
    
    // Llamada al servidor REST para recibir la infantil
    func getOracionPeriodicaInfantilById() -> AnyObject {
        // Variables peticion JSON
        let session = Foundation.URLSession.shared
        let postEndpoint: String = "http://rezandovoy.ovh:8080/Rezandovoy_server/api/publica/getPeriodicaInfantilById"
        let postParams: NSDictionary = ["id": "\(id)"]
        let url = URL(string: postEndpoint)!
        let request = NSMutableURLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postParams, options: JSONSerialization.WritingOptions())
            print("Funca by id")
        } catch {
            print("No funca by id")
        }
        
        session.dataTask(with: request as URLRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            guard let realResponse = response as? HTTPURLResponse, realResponse.statusCode == 200 else {
                let respuesta = response as? HTTPURLResponse
                print("Not a 200 response is:\n \(respuesta)")
                return
            }
            do {
                if let jsonDict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? NSDictionary {
                    
                    // Guardar datos
                    self.oracion.settitulo(jsonDict.value(forKey: "titulo") as! String)
                    self.oracion.setimages(jsonDict.value(forKey: "ficheroImagenes") as! String)
                    self.oracion.setfecha(jsonDict.value(forKey: "fecha") as? String)
                    self.oracion.setmusicas(jsonDict.value(forKey: "musicas") as? NSArray)
                    self.oracion.setlectura(jsonDict.value(forKey: "lectura") as? NSArray)
                    self.oracion.setdocumentos(jsonDict.value(forKey: "documentos") as? NSArray)
                    
                    // Recuperar el link de la oración
                    var aux_mp3 = "http://rezandovoy.ovh/"
                    aux_mp3 += jsonDict.value(forKey: "oracion_link") as! String
                    self.reproductorInit(aux_mp3)
                    
                    // LLamada a la funcion para poner el titulo
                    self.cambiaTitulo(jsonDict.value(forKey: "titulo") as! String)
                    
                    // LLamada a la funcion para recuperar imagenes
                    self.recuperarImagenes(jsonDict.value(forKey: "ficheroImagenes") as! String)
                    
                    // LLamada a la funcion para recuperar el titulo y maquetarlo
                    self.recuperarTitulo(jsonDict.value(forKey: "titulo") as? String)
                    
                    // LLamada a la funcion para recuperar musicas
                    self.recuperarMusica((jsonDict.value(forKey: "musicas") as? NSArray)!)
                    
                    // LLamada a la funcion para recuperar la cita
                    self.recuperaCita((jsonDict.value(forKey: "lectura") as? NSArray)!)
                    
                    // LLamada a la funcion para recuperar los documentos
                    self.recuperaDocs((jsonDict.value(forKey: "documentos") as? NSArray)!)
                    
                    // LLamada a la funcion para crear el boton de compartir
                    self.compartir()
                    
                } else {
                    print("Error")
                }
            } catch let error as NSError {
                print(error)
            }
        }).resume()
        return true as AnyObject
    }
    
    // Llamada al servidor REST para recibir la especial infantil
    func getOracionEspecialInfantilById() -> AnyObject {
        // Variables peticion JSON
        let session = Foundation.URLSession.shared
        let postEndpoint: String = "http://rezandovoy.ovh:8080/Rezandovoy_server/api/publica/getEspecialInfantilById"
        let postParams: NSDictionary = ["id": "\(id)"]
        let url = URL(string: postEndpoint)!
        let request = NSMutableURLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postParams, options: JSONSerialization.WritingOptions())
            print("Funca by id")
        } catch {
            print("No funca by id")
        }
        
        session.dataTask(with: request as URLRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            guard let realResponse = response as? HTTPURLResponse, realResponse.statusCode == 200 else {
                let respuesta = response as? HTTPURLResponse
                print("Not a 200 response is:\n \(respuesta)")
                return
            }
            do {
                if let jsonDict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? NSDictionary {
                    
                    // Guardar datos
                    self.oracion.settitulo(jsonDict.value(forKey: "titulo") as! String)
                    self.oracion.setimages(jsonDict.value(forKey: "ficheroImagenes") as! String)
                    self.oracion.setmusicas(jsonDict.value(forKey: "musicas") as? NSArray)
                    self.oracion.setlectura(jsonDict.value(forKey: "lectura") as? NSArray)
                    self.oracion.setdocumentos(jsonDict.value(forKey: "documentos") as? NSArray)
                    
                    // Recuperar el link de la oración
                    var aux_mp3 = "http://rezandovoy.ovh/"
                    aux_mp3 += jsonDict.value(forKey: "oracion_link") as! String
                    self.reproductorInit(aux_mp3)
                    
                    // LLamada a la funcion para poner el titulo
                    self.cambiaTitulo(jsonDict.value(forKey: "titulo") as! String)
                    
                    // LLamada a la funcion para recuperar imagenes
                    self.recuperarImagenes(jsonDict.value(forKey: "ficheroImagenes") as! String)
                    
                    // LLamada a la funcion para recuperar fecha
                    self.recuperarTitulo(jsonDict.value(forKey: "titulo") as? String)
                    
                    // LLamada a la funcion para recuperar musicas
                    self.recuperarMusica((jsonDict.value(forKey: "musicas") as? NSArray)!)
                    
                    // LLamada a la funcion para recuperar la cita
                    self.recuperaCita((jsonDict.value(forKey: "lectura") as? NSArray)!)
                    
                    // LLamada a la funcion para recuperar los documentos
                    self.recuperaDocs((jsonDict.value(forKey: "documentos") as? NSArray)!)
                    
                    // LLamada a la funcion para crear el boton de compartir
                    self.compartir()
                    
                } else {
                    print("Error")
                }
            } catch let error as NSError {
                print(error)
            }
        }).resume()
        return true as AnyObject
    }

    
    // Llamada al servidor REST para recibir la especial
    func getOracionEspecialAdultaById() -> AnyObject {
        // Variables peticion JSON
        let session = Foundation.URLSession.shared
        let postEndpoint: String = "http://rezandovoy.ovh:8080/Rezandovoy_server/api/publica/getEspecialAdultaById"
        let postParams: NSDictionary = ["id": "\(id)"]
        let url = URL(string: postEndpoint)!
        let request = NSMutableURLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postParams, options: JSONSerialization.WritingOptions())
            print("Funca by id")
        } catch {
            print("No funca by id")
        }
        
        session.dataTask(with: request as URLRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            guard let realResponse = response as? HTTPURLResponse, realResponse.statusCode == 200 else {
                let respuesta = response as? HTTPURLResponse
                print("Not a 200 response is:\n \(respuesta)")
                return
            }
            do {
                if let jsonDict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? NSDictionary {
                    
                    // Guardar datos
                    self.oracion.settitulo(jsonDict.value(forKey: "titulo") as! String)
                    self.oracion.setimages(jsonDict.value(forKey: "ficheroImagenes") as! String)
                    self.oracion.setmusicas(jsonDict.value(forKey: "musicas") as? NSArray)
                    self.oracion.setlectura(jsonDict.value(forKey: "lectura") as? NSArray)
                    self.oracion.setdocumentos(jsonDict.value(forKey: "documentos") as? NSArray)
                    
                    // Recuperar el link de la oración
                    var aux_mp3 = "http://rezandovoy.ovh/"
                    aux_mp3 += jsonDict.value(forKey: "oracion_link") as! String
                    self.reproductorInit(aux_mp3)
                    
                    // LLamada a la funcion para poner el titulo
                    self.cambiaTitulo(jsonDict.value(forKey: "titulo") as! String)
                    
                    // LLamada a la funcion para recuperar imagenes
                    self.recuperarImagenes(jsonDict.value(forKey: "ficheroImagenes") as! String)
                    
                    // LLamada a la funcion para recuperar fecha
                    var aux = "http://rezandovoy.ovh/"
                    aux += jsonDict.value(forKey: "icono_link") as!  String
                    self.recuperarIcono(aux)
                    
                    // LLamada a la funcion para recuperar musicas
                    self.recuperarMusica((jsonDict.value(forKey: "musicas") as? NSArray)!)
                    
                    // LLamada a la funcion para recuperar la cita
                    if let _ : AnyObject = jsonDict.value(forKey: "lectura") as AnyObject? {
                        self.recuperaCita((jsonDict.value(forKey: "lectura") as? NSArray)!)
                    }
                    
                    // LLamada a la funcion para recuperar los documentos
                    self.recuperaDocs((jsonDict.value(forKey: "documentos") as? NSArray)!)
                    
                    // LLamada a la funcion para crear el boton de compartir
                    self.compartir()
                    
                } else {
                    print("Error")
                }
            } catch let error as NSError {
                print(error)
            }
        }).resume()
        return true as AnyObject
    }
    
    // Inicializar reproductor
    func reproductorInit( _ auxiliar: String)->Void {
        var aux = auxiliar
        aux = aux.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        self.mp3Url = aux
        //let assetmp3 = AVURLAsset(url: URL(string:aux)!)
        //let localmp3 = AVPlayerItem(asset: assetmp3)
        self.audioItem = AVPlayerItem(url: URL(string: self.mp3Url!)!)
        self.audioPlayer = AVPlayer(playerItem: audioItem)
        self.audioPlayer?.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 10), queue: DispatchQueue.main) {
            time in
            if ((self.audioPlayer?.currentItem!.currentTime())! < (self.audioPlayer?.currentItem!.duration)!) {
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
                if (UIApplication.shared.applicationState == .active) {
                    self.timeLabel.text = timeString
                }
                
                //Actualizar la posicion del slider
                if (self.audioSlider.isTouchInside == false) {
                    let tiempoActual = CMTimeGetSeconds((self.audioPlayer?.currentItem!.currentTime())!)
                    let duracion = CMTimeGetSeconds((self.audioPlayer?.currentItem!.duration)!)
                    let normalizedTime = Float(tiempoActual * 100.0 / duracion)
                    self.audioSlider.value = normalizedTime
                }
            }
            else {
                self.audioPlayer?.pause()
                self.botonPlay.setImage(UIImage(named: "ic_play"), for: UIControlState())
                self.audioSlider.value = 0.0
                self.audioPlayer?.seek(to: CMTimeMake(0, 1))
                self.infoView.isHidden = false
            }
        }
        self.reproductor(self.botonPlay)
    }

    
    // Recuperar los documentos y darles formato, puede estar vacio
    func recuperaDocs(_ aux_docs: NSArray?)->Void {
        DispatchQueue.main.async {
            if aux_docs!.count > 0 {
                for (doc) in aux_docs! {
                    self.docsView = UIView(frame: CGRect(x: 0, y: Int(self.lineaView!.frame.origin.y)+9, width: Int(self.dentroScroll!.frame.width), height: 0))
                    self.dentroScroll!.addSubview(self.docsView!)
                    self.bottonDocs = UIButton(frame: CGRect(x: 8, y: 0, width: Int(self.dentroScroll!.frame.width)-8, height: 32))
                    self.bottonDocs?.titleLabel?.font = UIFont(name: "Aleo-Regular", size: 13)
                    self.bottonDocs?.setTitle((doc as AnyObject).value(forKey: "nombre") as? String, for: UIControlState())
                    self.bottonDocs?.setImage(UIImage(named: "ic_docs"), for: UIControlState())
                    self.bottonDocs?.imageView?.contentMode = UIViewContentMode.scaleAspectFit
                    self.bottonDocs?.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
                    self.bottonDocs?.titleEdgeInsets.left = 10.0
                    self.bottonDocs?.addTarget(self, action: #selector(audioViewController.toggleDocs(_:)), for: .touchUpInside)
                    self.docsView?.addSubview(self.bottonDocs!)
                    self.docsLabel = UILabel(frame: CGRect(x: 8, y: 40, width: Int(self.dentroScroll!.frame.width)-8, height: 0))
                    self.docsLabel?.text = (doc as AnyObject).value(forKey: "texto") as? String
                    self.docsLabel?.numberOfLines = 0
                    self.docsLabel?.textColor = UIColor.white
                    self.docsLabel?.font = UIFont(name: "Aleo-Regular", size: 13)
                    //self.docsLabel?.sizeToFit()
                    self.docsLabel?.isHidden = true
                    self.docsView?.addSubview(self.docsLabel!)
                    self.docsView?.resizeToFitSubviews()
                    let aux_y = Int((self.docsView?.frame.origin.y)!) + Int((self.docsView?.frame.height)!) + 8
                    self.lineaView = UIView(frame: CGRect(x: 8, y: aux_y, width: Int(self.dentroScroll!.frame.width)-16, height: 1))
                    self.lineaView!.layer.borderWidth = 1.0
                    self.lineaView!.layer.borderColor = UIColor.white.cgColor
                    self.dentroScroll!.addSubview(self.lineaView!)
                }
            }
        }
    }
    
    // Recuperar la cita y darla formato
    func recuperaCita(_ aux_citas: NSArray?)-> Void {
        DispatchQueue.main.async {
            if aux_citas!.count > 0 {
                for (aux_cita) in aux_citas! {
                    self.citasView = UIView(frame: CGRect(x: 0, y: Int(self.dentroScroll!.subviews.last!.frame.origin.y)+8+Int(self.dentroScroll!.subviews.last!.frame.height), width: Int(self.datosView!.frame.width), height: 0))
                    self.dentroScroll!.addSubview(self.citasView!)
                    self.botonCita = UIButton(frame: CGRect(x: 8, y: 0, width: Int(self.dentroScroll!.frame.width)-8, height: 32))
                    self.botonCita?.titleLabel?.font = UIFont(name: "Aleo-Regular", size: 13)
                    self.botonCita?.setTitle((aux_cita as AnyObject).value(forKey: "cita") as? String, for: UIControlState())
                    self.botonCita?.setImage(UIImage(named: "ic_lectura"), for: UIControlState())
                    self.botonCita?.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
                    self.botonCita?.imageView?.contentMode = UIViewContentMode.scaleAspectFit
                    self.botonCita?.titleEdgeInsets.left = 10.0
                    self.botonCita?.addTarget(self, action: #selector(audioViewController.toggleCita(_:)), for: .touchUpInside)
                    self.citasView?.addSubview(self.botonCita!)
                    self.citaLabel = UILabel(frame: CGRect(x: 8, y: 40, width: Int(self.dentroScroll!.frame.width)-8, height: 0))
                    self.citaLabel?.text = (aux_cita as AnyObject).value(forKey: "texto") as? String
                    self.citaLabel?.numberOfLines = 0
                    self.citaLabel?.textColor = UIColor.white
                    self.citaLabel?.font = UIFont(name: "Aleo-Regular", size: 13)
                    //self.citaLabel?.sizeToFit()
                    self.citaLabel?.isHidden = true
                    self.citasView?.addSubview(self.citaLabel!)
                    self.citasView?.resizeToFitSubviews()
                    let aux_y = Int((self.citasView?.frame.origin.y)!) + Int((self.citasView?.frame.height)!) + 8
                    self.lineaView = UIView(frame: CGRect(x: 8, y: aux_y, width: Int(self.dentroScroll!.frame.width)-16, height: 1))
                    self.lineaView!.layer.borderWidth = 1.0
                    self.lineaView!.layer.borderColor = UIColor.white.cgColor
                    self.dentroScroll!.addSubview(self.lineaView!)
                }
            }
        }
    }
    
    // Recuperar las músicas y darlas formato
    func recuperarMusica(_ aux_mus: NSArray)-> Void {
        DispatchQueue.main.async {
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
                let cancion = (musica as AnyObject).value(forKey: "cancion")
                let coleccion = (musica as AnyObject).value(forKey: "coleccion")
                let permiso = (musica as AnyObject).value(forKey: "permiso")
                let titulo = (cancion as AnyObject).value(forKey: "titulo")
                cadena1 = NSAttributedString(string: String(describing: titulo!), attributes: bold)
                if ((cancion as AnyObject).value(forKey: "autor") as! String == "" && (cancion as AnyObject).value(forKey: "interprete") as! String != "") {
                    let interprete = (cancion as AnyObject).value(forKey: "interprete")
                    cadena2 = NSAttributedString(string: " interpretado por \(interprete!). CD ", attributes: normal)
                }
                else if ((cancion as AnyObject).value(forKey: "interprete") as! String == "" && (cancion as AnyObject).value(forKey: "autor") as! String != "") {
                    let autor = (cancion as AnyObject).value(forKey: "autor")
                    cadena2 = NSAttributedString(string: " de \(autor!). CD ", attributes: normal)
                }
                else if ((cancion as AnyObject).value(forKey: "interprete") as! String != "" && (cancion as AnyObject).value(forKey: "autor") as! String != "") {
                    let interprete = (cancion as AnyObject).value(forKey: "interprete")
                    let autor = (cancion as AnyObject).value(forKey: "autor")
                    cadena2 = NSAttributedString(string: " de \(autor!) interpretado por \(interprete!). CD ", attributes: normal)
                }
                else{
                    cadena2 = NSAttributedString(string: " ",attributes:normal)
                }
                let cd = (coleccion as AnyObject).value(forKey: "nombre")
                cadena3 = NSAttributedString(string: "\(cd!) ", attributes: italic)
                let formula = (permiso as AnyObject).value(forKey: "formula")
                let propietario = (permiso as AnyObject).value(forKey: "propietario") as! String
                if propietario != "#" {
                    cadena4 = NSAttributedString(string: "\(formula!) \(propietario)", attributes: normal)
                }
                let cadenaMusica: NSMutableAttributedString = NSMutableAttributedString(string: "")
                cadenaMusica.append(cadena1!)
                if let _ : NSAttributedString = cadena2 {
                    cadenaMusica.append(cadena2!)
                }
                if let _ : NSAttributedString = cadena3 {
                    cadenaMusica.append(cadena3!)
                }
                if let _ : NSAttributedString = cadena4 {
                    cadenaMusica.append(cadena4!)
                }
                self.musicaLabel = UILabel(frame: CGRect(x: self.iconoMusica!.frame.origin.x+48, y: 8, width: self.dentroScroll!.frame.width-56, height: 0))
                self.musicaLabel?.attributedText = cadenaMusica
                self.musicaLabel?.numberOfLines = 0
                self.musicaLabel?.textColor = UIColor.white
                self.musicaLabel?.sizeToFit()
                alto += Int(self.musicaLabel!.frame.height)+8
                self.datosView!.addSubview(self.musicaLabel!)
                self.datosView?.resizeToFitSubviews()
            }
            let aux_y = Int((self.datosView?.frame.origin.y)!) + Int((self.datosView?.frame.height)!) + 8
            self.lineaView = UIView(frame: CGRect(x: 8, y: aux_y, width: Int(self.dentroScroll!.frame.width)-16, height: 1))
            self.lineaView!.layer.borderWidth = 1.0
            self.lineaView!.layer.borderColor = UIColor.white.cgColor
            self.dentroScroll!.addSubview(self.lineaView!)
        }
    }
    
    // Cambiar el titulo de la barra de navegacion
    func cambiaTitulo(_ auxiliar_titulo: String!)-> Void {
        var aux_titulo = auxiliar_titulo
        DispatchQueue.main.async {
            aux_titulo = aux_titulo?.uppercased()
            let atributos: NSDictionary = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "Aleo-Regular", size: 12)!]
            self.navigationController?.navigationBar.titleTextAttributes = atributos as? [String : AnyObject]
            self.navigationController?.navigationBar.topItem!.title = aux_titulo
        }
    }
    
    // Recuperar el titulo y darle formato
    func recuperarTitulo(_ aux_titulo: String!)-> Void {
        DispatchQueue.main.async {
            self.diaLabel = UILabel(frame: CGRect(x: 0,y: self.hojaView.frame.size.height,width: self.hojaView.frame.size.width,height: 0))
            self.diaLabel?.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.2)
            self.diaLabel?.textAlignment = NSTextAlignment.center
            self.diaLabel?.textColor = UIColor.white
            self.diaLabel?.font = UIFont(name: "Aleo-Regular", size: 13)
            self.diaLabel?.text = aux_titulo
            self.diaLabel?.numberOfLines = 0
            self.diaLabel?.sizeToFit()
            self.diaLabel?.frame = CGRect(x: CGFloat(0), y: self.hojaView.frame.size.height - self.diaLabel!.frame.size.height, width: self.hojaView.frame.size.width, height: self.diaLabel!.frame.size.height)
            self.hojaView.addSubview(self.diaLabel!)
            self.iconoLabel = UIImageView(frame: self.hojaView.bounds)
            self.iconoLabel?.image = UIImage(named: "ic_rvn_blanco")
            self.iconoLabel?.contentMode = UIViewContentMode.scaleAspectFit
            self.iconoLabel?.contentMode = UIViewContentMode.top
            self.hojaView.addSubview(self.iconoLabel!)
        }
    }
    
    // Recuperar el icono y darle formato.
    func recuperarIcono(_ aux_icono: String!)-> Void {
        DispatchQueue.main.async {
            self.hojaView.layer.borderWidth = 0.0
            var aux = aux_icono
            aux = aux_icono.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            let filePath = URL(string: aux!)
            self.iconoUrl = filePath
            let icono = try? Data(contentsOf: filePath!)
            self.iconoLabel = UIImageView(frame: self.hojaView.bounds)
            self.iconoLabel?.image = UIImage(data: icono!)
            self.hojaView.addSubview(self.iconoLabel!)
        }
    }
    
    // Recuperar la fecha y darle formato
    func recuperarFecha(_ aux_fecha: String!)-> Void {
        format.locale = Locale(identifier: "en_GB")
        format.dateFormat = "MMM d, yyyy"
        let fecha_aux = format.date(from: aux_fecha!)!
        var esp = Calendar(identifier: Calendar.Identifier.gregorian)
        esp.timeZone = TimeZone(identifier: "Europe/Madrid")!
        let requestedDateComponents: NSCalendar.Unit = [.year,.month,.day]
        let fecha = (esp as NSCalendar).components(requestedDateComponents, from: fecha_aux)
        let calendario = Calendar.current.date(from: fecha)
        format.locale = Locale(identifier: "es_ES")
        format.dateFormat = "MMMM"
        let mes = format.string(from: calendario!)
        format.dateFormat = "EEEE"
        let dia = format.string(from: calendario!)
        let aux_aux = String(describing: fecha.day!) as NSString?
        self.datosFecha(mes as NSString?, aux_diaNum: aux_aux, aux_dia: dia as NSString?)
    }
    
    
    // Maqueta la hoja del calendario
    func datosFecha(_ aux_mes: NSString?, aux_diaNum: NSString?, aux_dia: NSString?)->Void {
        DispatchQueue.main.async {
            
            // Etiqueta para poner el número del día
            self.numLabel = UILabel(frame: CGRect(x: 0,y: 21,width: self.hojaView.frame.size.width,height: 60))
            self.numLabel?.textAlignment = NSTextAlignment.center
            self.numLabel?.textColor = UIColor.white
            self.numLabel?.font = UIFont(name: "Aleo-Regular", size: 50)
            self.numLabel?.text = aux_diaNum as? String
            self.hojaView.addSubview(self.numLabel!)

            // Etiqueta para poner el nombre del mes
            self.mesLabel = UILabel(frame: CGRect(x: 0,y: 0,width: self.hojaView.frame.size.width,height: 21))
            self.mesLabel?.textAlignment = NSTextAlignment.center
            self.mesLabel?.textColor = UIColor.white
            self.mesLabel?.font = UIFont(name: "Aleo-Regular", size: 17)
            self.mesLabel?.text = aux_mes as? String
            self.hojaView.addSubview(self.mesLabel!)
            
            // Etiqueta para poner el dia en texto
            self.diaLabel = UILabel(frame: CGRect(x: 0,y: self.hojaView.frame.size.height-21,width: self.hojaView.frame.size.width,height: 21))
            self.diaLabel?.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.2)
            self.diaLabel?.textAlignment = NSTextAlignment.center
            self.diaLabel?.textColor = UIColor.white
            self.diaLabel?.font = UIFont(name: "Aleo-Regular", size: 17)
            self.diaLabel?.text = aux_dia as? String
            self.hojaView.addSubview(self.diaLabel!)
        }
    }
    
    // Recuperar el fichero de imagenes y comprobar si esta cargado en la APP, si no usar default.
    func recuperarImagenes(_ ficheroImagenes: String!)-> Void {
        let nombreImagenes = ficheroImagenes.characters.split{$0 == "/"}.map(String.init)
        var imagenes = ["\(nombreImagenes[2])_1","\(nombreImagenes[2])_2","\(nombreImagenes[2])_3","\(nombreImagenes[2])_4"]
        let pruebaImg: UIImage? = UIImage(named: "\(nombreImagenes[2])_1")
        if pruebaImg != nil {
            imagenes.shuffle()
            self.fotoFondo(imagenes as NSArray)
        }
        else {
            imagenes = ["default_1","default_2","default_3","default_4"]
            imagenes.shuffle()
            self.fotoFondo(imagenes as NSArray)
        }
    }
    
    // Cargar las imagenes en el fondo
    func fotoFondo(_ nombre: NSArray)-> Void {
        DispatchQueue.main.async {
            let images = [
                UIImage(named: nombre[0] as! String)!,
                UIImage(named: nombre[1] as! String)!,
                UIImage(named: nombre[2] as! String)!,
                UIImage(named: nombre[3] as! String)!
            ]
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(audioViewController.imageTap))
            self.imageView!.image = images[self.index+1] //JCM sustituido ++ por +1
            self.imageView?.contentMode = UIViewContentMode.scaleAspectFill
            self.animateImageView(images as NSArray)
            self.imageView?.isUserInteractionEnabled = true
            self.imageView?.addGestureRecognizer(tapGesture)
            self.view.addSubview(self.imageView!)
            self.view.bringSubview(toFront: self.controles)
            self.view.bringSubview(toFront: self.infoView)
            self.view.addSubview(self.progressHUD!)
            self.progressHUD?.show()
        }
    }
    
    // Crear slider de las imagenes de fondo
    func animateImageView (_ imagenes: NSArray) {
        CATransaction.begin()
        
        CATransaction.setAnimationDuration(animationDuration)
        CATransaction.setCompletionBlock {
            let delay = DispatchTime.now() + Double(Int64(self.switchingInterval * TimeInterval(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delay) {
                self.animateImageView(imagenes)
            }
        }
        
        let transition = CATransition()
        transition.type = kCATransitionFade
    
        self.imageView?.layer.add(transition, forKey: kCATransition)
        self.imageView?.image = imagenes[index] as? UIImage
        
        CATransaction.commit()
        
        index = index < imagenes.count - 1 ? index + 1 : 0
    }
    
    // Crear el boton de compartir
    func compartir()-> Void {
        DispatchQueue.main.async {
            let ultimo = self.dentroScroll!.subviews[self.dentroScroll!.subviews.count-1].frame
            let aux_y = Int(ultimo.origin.y) + Int(ultimo.height)
            self.compartirView = UIView(frame: CGRect(x: 0, y: aux_y+8, width: Int(self.dentroScroll!.frame.width), height: 0))
            self.dentroScroll!.addSubview(self.compartirView!)
            self.botonCompartir = UIButton(frame: CGRect(x: 8, y: 0, width: Int(self.dentroScroll!.frame.width)-8, height: 32))
            self.botonCompartir?.titleLabel?.font = UIFont(name: "Aleo-Regular", size: 13)
            self.botonCompartir?.setTitle("compartir", for: UIControlState())
            self.botonCompartir?.setImage(UIImage(named: "ic_compartir"), for: UIControlState())
            self.botonCompartir?.imageView?.contentMode = UIViewContentMode.scaleAspectFit
            self.botonCompartir?.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
            self.botonCompartir?.titleEdgeInsets.left = 10.0
            self.botonCompartir?.addTarget(self, action: #selector(audioViewController.toggleCompartir), for: .touchUpInside)
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
        let downloadRequest = NSMutableURLRequest(url: URL(string: self.mp3Url!)!)
        let session = Foundation.URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        
        downloadTask = session.downloadTask(with: downloadRequest as URLRequest)
        downloadTask!.resume()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        progressView.animateProgressViewToProgress(progress)
        progressView.updateProgressViewLabelWithProgress(progress * 100)
        progressView.updateProgressViewWith(Float(totalBytesWritten), totalFileSize: Float(totalBytesExpectedToWrite))
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        statusLabel.text = "Descarga finalizada"
        print(location)
        let audioUrl = URL(string: self.mp3Url!)
        let destinationUrl = self.documentsUrl.appendingPathComponent(audioUrl!.lastPathComponent)
        print(destinationUrl.path)
        if FileManager().fileExists(atPath: destinationUrl.path) {
            print("file already exists [\(destinationUrl.path)]")
        } else {
            do {
                try FileManager.default.moveItem(at: location, to: destinationUrl)
                print("Move successful")
                self.cancelDownload.isHidden = true
                
                // Descargar y guardar icono en caso de que lo haya
                if let _ = self.iconoUrl {
                    let filePath = self.iconoUrl
                    let icono = try? Data(contentsOf: filePath!)
                    try? icono?.write(to: URL(fileURLWithPath: self.documentsUrl.appendingPathComponent(filePath!.lastPathComponent).path), options: [.atomic])
                    self.oracion.seticono("\(filePath!.lastPathComponent)")
                }
                
                // Guardar datos
                oracion.setmp3(audioUrl!.lastPathComponent)
                self.saveOracion()
                
                let delay = 3.0 * Double(NSEC_PER_SEC)
                let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time, execute: {
                    self.modalView.isHidden = true
                })
            } catch let error as NSError {
                print("Moved failed with error \(error)")
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let _ = error {
            statusLabel.text = "Fallo al descargar"
        } else {
            statusLabel.text = "Descarga finalizada"
        }
    }
    
    func saveOracion() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(oracion, toFile: Oracion.DocumentsDirectory.appendingPathComponent("\(oracion.id)").path)
        if !isSuccessfulSave {
            print("Failed to save oracion...")
        }
    }
    
    func loadOracion(_ aux_id: Int) -> Oracion? {
        let aux = NSKeyedUnarchiver.unarchiveObject(withFile: Oracion.DocumentsDirectory.appendingPathComponent("\(aux_id)").path) as? Oracion
        print(aux!.id)
        return aux
    }
}
