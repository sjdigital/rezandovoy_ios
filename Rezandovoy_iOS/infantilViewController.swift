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
    
    @IBAction func donativos(_ sender: UIBarButtonItem) {
        let donativosUrl = URL(string: "https://rezandovoy.org/appsdonativos.php");
        UIApplication.shared.openURL(donativosUrl!)
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.linkClicked {
            let oracionUrl = "\(request.url!)"
            let oracionArray = oracionUrl.characters.split{$0 == "#"}.map(String.init)
            if oracionArray[0].range(of: "infantil") != nil {
                tipo = 3
            }
            else if oracionArray[0].range(of: "especial") != nil {
                tipo = 4
            }
            id = Int(oracionArray[1])!
            let nextViewControlles = storyboard!.instantiateViewController(withIdentifier: "audioPlayer") as UIViewController
            self.show(nextViewControlles, sender: self)
            return false
        }
        return true
    }
    
    
    let url = "https://iosrv.rezandovoy.org/infantil.php"

    func cargaPagina(){
        let requestURL = URL(string: url)
        let request = URLRequest(url: requestURL!)
        webView.loadRequest(request)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
