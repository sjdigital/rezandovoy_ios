//
//  FirstViewController.swift
//  Rezandovoy_iOS
//
//  Created by Rodrigo on 9/11/15.
//  Copyright © 2015 sjdigital. All rights reserved.
//

import UIKit

var id: Int = 0

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
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked {
            let oracionUrl = "\(request.URL!)"
            let oracionArray = oracionUrl.characters.split{$0 == "#"}.map(String.init)
            id = Int(oracionArray[1])!
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("audioPlayer") as UIViewController
            // self.presentViewController(nextViewController, animated:true, completion:nil)
            self.showViewController(nextViewController, sender: self)
            return false
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
