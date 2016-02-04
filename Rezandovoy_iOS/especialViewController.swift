//
//  especialViewController.swift
//  Rezandovoy_iOS
//
//  Created by Rodrigo on 4/2/16.
//  Copyright © 2016 sjdigital. All rights reserved.
//

import UIKit

class especialViewController: UIViewController, UIWebViewDelegate {
    
    var url: String?
    
    @IBOutlet var webView: UIWebView!
    @IBOutlet var especialIndicator: UIActivityIndicatorView!
    
    @IBAction func donativos(sender: UIBarButtonItem) {
        let donativosUrl = NSURL(string: "http://rezandovoy.org/appsdonativos.php");
        UIApplication.sharedApplication().openURL(donativosUrl!)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked {
            let oracionUrl = "\(request.URL!)"
            tipo = 2
            let oracionArray = oracionUrl.characters.split{$0 == "#"}.map(String.init)
            id = Int(oracionArray[1])!
            let nextViewControlles = storyboard!.instantiateViewControllerWithIdentifier("audioPlayer") as UIViewController
            self.showViewController(nextViewControlles, sender: self)
            return false
        }
        return true
    }
    
    func cargaPagina() {
        url = "http://iosrv.rezandovoy.org/especial.php?id=\(id)"
        let requestURL = NSURL(string: url!)
        let request = NSURLRequest(URL: requestURL!)
        webView.loadRequest(request)
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
        especialIndicator.hidden = false
        especialIndicator.startAnimating()
    }
    func webViewDidFinishLoad(_: UIWebView){
        especialIndicator.hidden = true
        especialIndicator.stopAnimating()
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
