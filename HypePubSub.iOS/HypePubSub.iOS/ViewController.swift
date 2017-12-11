
import UIKit

class ViewController: UIViewController {
    
    let hps = HypePubSub.getInstance()
    let hypeSdk = HypeSdkInterface.getInstance()
    
    @IBAction func SubscribeButton(_ sender: UIButton)
    {
        if( !isHypeSdkReady()){
            return;
        }
        
        struct SubscribeServiceInputDialog: SingleInputDialog
        {
            var hps: HypePubSub
            func onOk(input: String){
                _ = hps.issueSubscribeReq(serviceName: ViewController.processServiceName(nameInput: input))
            }
            func onCancel(){}
        }
        
        let subscribeInputDialog = SubscribeServiceInputDialog(hps: hps)
        AlertDialogUtils.showSingleInputDialog(viewController: self, title: "Subscribe Service", msg: "" , hint: "Service", onSingleInputDialog: subscribeInputDialog)
    }
    
    @IBAction func UnsubscribeButton(_ sender: UIButton)
    {
        if( !isHypeSdkReady()){
            return;
        }
        struct UnsubscribeServiceInputDialog: SingleInputDialog
        {
            var hps: HypePubSub
            func onOk(input: String){
                _ = hps.issueUnsubscribeReq(serviceName: ViewController.processServiceName(nameInput: input))
            }
            func onCancel(){}
        }
        
        let unsubscribeInputDialog = UnsubscribeServiceInputDialog(hps: hps)
        AlertDialogUtils.showSingleInputDialog(viewController: self, title: "Unsubscribe Service", msg: "" , hint: "Service", onSingleInputDialog: unsubscribeInputDialog)
    }
    
    @IBAction func PublishButton(_ sender: UIButton)
    {
        if( !isHypeSdkReady()){
            return;
        }
        
        struct PublishInputDialog: DoubleInputDialog
        {
            var hps: HypePubSub
            func onOk(input1: String, input2: String){
                _ = hps.issuePublishReq(serviceName: ViewController.processServiceName(nameInput: input1), msg: input2)
            }
            func onCancel(){}
        }
        
        let publishInputDialog = PublishInputDialog(hps: hps)
        AlertDialogUtils.showDoubleInputDialog(viewController: self, title: "Publish Message", msg: "" , hint1: "Service", hint2: "Message", onDoubleInputDialog: publishInputDialog)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        hypeSdk.requestHypeToStart()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func isHypeSdkReady() -> Bool
    {
        if(hypeSdk.isHypeFail){
            AlertDialogUtils.showOkDialog(viewController: self, title: "Warning",
                                          msg: "Hype SDK could not be started.\n" + hypeSdk.hypeFailedMsg)
            return false
        }
        else if( !hypeSdk.isHypeReady){
            AlertDialogUtils.showOkDialog(viewController: self, title: "Warning", msg: "Hype SDK is not ready yet");
            return false;
        }
    
        return true;
    }
    
    static func processServiceName(nameInput: String) -> String
    {
        return nameInput.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

