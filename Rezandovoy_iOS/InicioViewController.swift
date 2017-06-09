//
//  FirstViewController.swift
//  Rezandovoy_iOS
//
//  Created by Rodrigo on 9/11/15.
//  Copyright © 2015 sjdigital. All rights reserved.
//

import UIKit

// Id de la oración
var id: Int = 0

// Comprobacion de conexion
var conexion: Int = 0

// Variables globales stores
let defaults = UserDefaults.standard
let DAY_IN_SECONDS = Double(-24*60*60)

// Distintos tipos de oración:
//      1 - Oración periodica adulto
//      2 - Oración especial adulto
//      3 - Oración periodica infantil
//      4 - Oración especial infantil
var tipo: Int = 0

extension Array {
    mutating func shuffle() {
        for i in 0 ..< (count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
            //self.swapAt(i, j)
        }
    }
}

class InicioViewController: UIViewController, UIWebViewDelegate {
    
    let url = "https://iosrv.rezandovoy.org"

    @IBOutlet weak var loaderIndicator: UIActivityIndicatorView!
    @IBOutlet var webView: UIWebView!
    
    @IBAction func donativos(_ sender: UIBarButtonItem) {
        let donativosUrl = URL(string: "https://rezandovoy.org/appsdonativos.php");
        UIApplication.shared.openURL(donativosUrl!)
    }
    
    func cargaPagina() {
        let requestURL = URL(string: url)
        let request = URLRequest(url: requestURL!)
        webView.loadRequest(request)
    }
    
    // Abrir el reproductor segun la id de la oración
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.linkClicked {
            let oracionUrl = "\(request.url!)"
            if oracionUrl.range(of: ".php") == nil {
                let oracionArray = oracionUrl.characters.split{$0 == "#"}.map(String.init)
                id = Int(oracionArray[1])!
                if oracionArray[0].range(of: "adultos") != nil {
                    tipo = 1
                }
                else if oracionArray[0].range(of: "especial") != nil {
                    tipo = 2
                }
                else if oracionArray[0].range(of: "infantil") != nil {
                    tipo = 3
                }
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "audioPlayer") as UIViewController
                self.show(nextViewController, sender: self)
                return false
            }
            else {
                if oracionUrl.range(of: "especial.php") != nil {
                    tipo = 2
                    let oracionArray = oracionUrl.characters.split{$0 == "="}.map(String.init)
                    id = Int(oracionArray[1])!
                }
                let nextViewControlles = storyboard!.instantiateViewController(withIdentifier: "especialViewController") as UIViewController
                self.show(nextViewControlles, sender: self)
                return false
            }
        }
        return true
    }
    
    func cerrar() {
        self.tabBarController!.selectedIndex = 2;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaults.set(Date(), forKey: "LastRun")
        if Reachability.isConnectedToNetwork() == true {
            print("Internet connection OK")
            conexion = 1
        } else {
            print("Internet connection FAILED")
            let alert = UIAlertController(title: "Sin conexión a Internet", message: "Le redirigiremos a sus oraciones descargadas.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Cerrar", style: .default, handler: { (alert: UIAlertAction!) in self.cerrar() }))
            self.present(alert, animated: true, completion: nil)
            conexion = 0
        }
        
        webView.delegate = self
        
        cargaPagina()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let lastTimeTheUserAnsweredTimestamp = defaults.object(forKey: "LastRun") as! Date
        if (lastTimeTheUserAnsweredTimestamp.timeIntervalSinceNow <= DAY_IN_SECONDS) {
            defaults.set(Date(), forKey: "LastRun")
            conexion = 0
        }
        
        if Reachability.isConnectedToNetwork() == true && conexion == 0 {
            cargaPagina()
            conexion = 1
        } else if Reachability.isConnectedToNetwork() == false {
            conexion = 0
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webViewDidStartLoad(_: UIWebView){
        loaderIndicator.isHidden = false
        loaderIndicator.startAnimating()
    }
    func webViewDidFinishLoad(_: UIWebView){
        loaderIndicator.isHidden = true
        loaderIndicator.stopAnimating()
    }
    
}
