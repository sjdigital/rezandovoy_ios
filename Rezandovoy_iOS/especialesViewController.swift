//
//  especialesViewController.swift
//  Rezandovoy_iOS
//
//  Created by Rodrigo on 23/12/15.
//  Copyright © 2015 sjdigital. All rights reserved.
//

import UIKit

class especialesViewController: UIViewController, UIWebViewDelegate {
    
    var url: String?
    
    @IBOutlet var webView: UIWebView!
    @IBOutlet weak var especialesIndicator: UIActivityIndicatorView!
    
    @IBAction func donativos(sender: UIBarButtonItem) {
        let donativosUrl = NSURL(string: "http://rezandovoy.org/appsdonativos.php");
        UIApplication.sharedApplication().openURL(donativosUrl!)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked {
            let oracionUrl = "\(request.URL!)"
            tipo = 2
            let oracionArray = oracionUrl.characters.split{$0 == "="}.map(String.init)
            id = Int(oracionArray[1])!
            let nextViewControlles = storyboard!.instantiateViewControllerWithIdentifier("especialViewController") as UIViewController
            self.showViewController(nextViewControlles, sender: self)
            return false
        }
        else {
            return true
        }
    }
    
    func cargaPagina() {
        url = "http://iosrv.rezandovoy.org/especiales.php"
        let requestURL = NSURL(string: url!)
        let request = NSURLRequest(URL: requestURL!)
        webView.loadRequest(request)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self
        
        cargaPagina()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let lastTimeTheUserAnsweredTimestamp = defaults.objectForKey("LastRun") as! NSDate
        if (lastTimeTheUserAnsweredTimestamp.timeIntervalSinceNow <= DAY_IN_SECONDS) {
            defaults.setObject(NSDate(), forKey: "LastRun")
            conexion = 0
        }
        
        if Reachability.isConnectedToNetwork() == true && conexion == 0 {
            cargaPagina()
            conexion = 1
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webViewDidStartLoad(_: UIWebView){
        especialesIndicator.hidden = false
        especialesIndicator.startAnimating()
    }
    func webViewDidFinishLoad(_: UIWebView){
        especialesIndicator.hidden = true
        especialesIndicator.stopAnimating()
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
