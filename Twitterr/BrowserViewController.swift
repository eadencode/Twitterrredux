//
//  BrowserViewController.swift
//  Twitterr
//
//  Created by CK on 4/23/17.
//  Copyright © 2017 CK. All rights reserved.
//

import UIKit
import WebKit

class BrowserViewController: UIViewController ,WKNavigationDelegate{

    
    var urlToLoad:String?
    var url:URL?
    
    var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoad()
        webView = WKWebView(frame: CGRect( x: 0, y: -130, width: self.view.frame.width, height: self.view.frame.height - 20 ), configuration: WKWebViewConfiguration() )
        self.view.addSubview(webView)
        let req = URLRequest(url:url!)
        webView.load(req)
        self.webView.allowsBackForwardNavigationGestures = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var back: UIBarButtonItem!

    @IBAction func onBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
