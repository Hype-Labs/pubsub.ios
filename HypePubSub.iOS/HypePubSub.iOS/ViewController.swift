//
//  ViewController.swift
//  HypePubSub.iOS
//
//  Created by Xavier Araújo on 04/12/2017.
//  Copyright © 2017 Xavier Araújo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let hpsSdk = HypeSdkInterface.getInstance()
    
    @IBAction func SubscribeButton(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        hpsSdk.requestHypeToStart()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

