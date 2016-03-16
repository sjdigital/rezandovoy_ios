//
//  infoViewController.swift
//  Rezandovoy_iOS
//
//  Created by Rodrigo on 23/12/15.
//  Copyright © 2015 sjdigital. All rights reserved.
//

import UIKit

class infoViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet var webView: UIWebView!
    @IBOutlet weak var infoIndicator: UIActivityIndicatorView!
    
    let url = "http://iosrv.rezandovoy.org/quienes.php"

    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked {
            let aux_url = "\(request.URL!)"
            let url = NSURL(string: aux_url);
            UIApplication.sharedApplication().openURL(url!)
            return false
        }
        else {
            return true
        }
    }
    
    func cargaPagina(){
        let requestURL = NSURL(string: url)
        let request = NSURLRequest(URL: requestURL!)
        webView.loadRequest(request)
    }    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self
        
        cargaPagina()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
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
        infoIndicator.hidden = false
        infoIndicator.startAnimating()
    }
    func webViewDidFinishLoad(_: UIWebView){
        infoIndicator.hidden = true
        infoIndicator.stopAnimating()
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
