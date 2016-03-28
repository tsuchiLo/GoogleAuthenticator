//
//  ViewController.swift
//  GoogleAuthenticatorExample
//
//  Created by Fabio Milano on 28/03/16.
//  Copyright © 2016 Touchwonders. All rights reserved.
//

import UIKit
import GoogleAuthenticator

class ViewController: UIViewController {

    let authenticator = GoogleAuthenticator(consumerKey: "YOUR-CONSUMER-KEY", consumerSecret:"YOUR-SECRET-KEY", scope: GoogleServiceScope.GoogleAnalyticsRead)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

