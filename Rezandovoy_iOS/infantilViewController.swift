//
//  infantilViewController.swift
//  Rezandovoy_iOS
//
//  Created by Rodrigo on 23/12/15.
//  Copyright © 2015 sjdigital. All rights reserved.
//

import UIKit

class infantilViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet var webView: UIWebView!
    @IBOutlet weak var loaderIndicator: UIActivityIndicatorView!
    
    @IBAction func donativos(sender: UIBarButtonItem) {
        let donativosUrl = NSURL(string: "http://rezandovoy.org/appsdonativos.php");
        UIApplication.sharedApplication().openURL(donativosUrl!)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked {
            let oracionUrl = "\(request.URL!)"
            let oracionArray = oracionUrl.characters.split{$0 == "#"}.map(String.init)
            if oracionArray[0].rangeOfString("infantil") != nil {
                tipo = 3
            }
            else if oracionArray[0].rangeOfString("especial") != nil {
                tipo = 4
            }
            id = Int(oracionArray[1])!
            let nextViewControlles = storyboard!.instantiateViewControllerWithIdentifier("audioPlayer") as UIViewController
            self.showViewController(nextViewControlles, sender: self)
            return false
        }
        return true
    }
    
    
    let url = "http://iosrv.rezandovoy.org/infantil.php"

    func cargaPagina(){
        let requestURL = NSURL(string: url)
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
        } else if Reachability.isConnectedToNetwork() == false {
            conexion = 0
        }
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
    

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
