//
//  ViewController.swift
//  HypePubSub.iOS
//
//  Created by Xavier Araújo on 04/12/2017.
//  Copyright © 2017 Xavier Araújo. All rights reserved.
//

import UIKit

/*
extension subscribeServiceInputDialog: showSingleInputDialog
{
        on
}
*/

class ViewController: UIViewController {

    let hps = HypePubSub.getInstance()
    let hpsSdk = HypeSdkInterface.getInstance()
    
    @IBAction func SubscribeButton(_ sender: UIButton)
    {
        struct SubscribeServiceInputDialog: SingleInputDialog {
            
            var hps: HypePubSub
            
            func onOk(str: String){
                _ = hps.issueSubscribeReq(str)
            }
            func onCancel(){}
        }
        
        let subscribeInputDialog:SubscribeServiceInputDialog = SubscribeServiceInputDialog(hps: hps)

        AlertDialogUtils.showSingleInputDialog(viewController: self, title: "Subscribe Service", msg: "" , hint: "Service", onSingleInputDialog: subscribeInputDialog)
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

