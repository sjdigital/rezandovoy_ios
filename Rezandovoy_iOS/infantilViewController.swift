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
