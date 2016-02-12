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
        }
    }
}

class InicioViewController: UIViewController, UIWebViewDelegate {
    
    let url = "http://iosrv.rezandovoy.org"

    @IBOutlet weak var loaderIndicator: UIActivityIndicatorView!
    @IBOutlet var webView: UIWebView!
    
    @IBAction func donativos(sender: UIBarButtonItem) {
        let donativosUrl = NSURL(string: "http://rezandovoy.org/appsdonativos.php");
        UIApplication.sharedApplication().openURL(donativosUrl!)
    }
    
    func cargaPagina(){
        let requestURL = NSURL(string: url)
        let request = NSURLRequest(URL: requestURL!)
        webView.loadRequest(request)
    }
    
    // Abrir el reproductor segun la id de la oración
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked {
            let oracionUrl = "\(request.URL!)"
            if oracionUrl.rangeOfString(".php") == nil {
                let oracionArray = oracionUrl.characters.split{$0 == "#"}.map(String.init)
                id = Int(oracionArray[1])!
                if oracionArray[0].rangeOfString("adultos") != nil {
                    tipo = 1
                }
                else if oracionArray[0].rangeOfString("especial") != nil {
                    tipo = 2
                }
                else if oracionArray[0].rangeOfString("infantil") != nil {
                    tipo = 3
                }
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("audioPlayer") as UIViewController
                self.showViewController(nextViewController, sender: self)
                return false
            }
            else {
                if oracionUrl.rangeOfString("especial.php") != nil {
                    tipo = 2
                    let oracionArray = oracionUrl.characters.split{$0 == "="}.map(String.init)
                    id = Int(oracionArray[1])!
                }
                let nextViewControlles = storyboard!.instantiateViewControllerWithIdentifier("especialViewController") as UIViewController
                self.showViewController(nextViewControlles, sender: self)
                return false
            }
        }
        return true
    }
    
    func cerrar() {
        UIControl().sendAction(Selector("suspend"), to: UIApplication.sharedApplication(), forEvent: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Reachability.isConnectedToNetwork() == true {
            print("Internet connection OK")
        } else {
            print("Internet connection FAILED")
            let alert = UIAlertController(title: "Sin conexión a Internet", message: "Esta aplicación necesita una conexión activa a internet para funcionar.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Cerrar", style: .Default, handler: { (alert: UIAlertAction!) in self.cerrar() }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        webView.delegate = self
        
        cargaPagina()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webViewDidStartLoad(_: UIWebView){
        loaderIndicator.hidden = false
        loaderIndicator.startAnimating()
    }
    func webViewDidFinishLoad(_: UIWebView){
        loaderIndicator.hidden = true
        loaderIndicator.stopAnimating()
    }
    
}
