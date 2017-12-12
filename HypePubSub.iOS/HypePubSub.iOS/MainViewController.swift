
import UIKit
import UserNotifications

class MainViewController: UIViewController, UNUserNotificationCenterDelegate
{
    let hps = HypePubSub.getInstance()
    let network = Network.getInstance()
    let hypeSdk = HypeSdkInterface.getInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Configure User Notification Center
        UNUserNotificationCenter.current().delegate = self
        
        hypeSdk.requestHypeToStart()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    @IBAction func SubscribeButton(_ sender: UIButton)
    {
        if( !isHypeSdkReady()){
            return;
        }
        
        struct SubscribeServiceInputDialog: SingleInputDialog
        {
            var hps: HypePubSub
            var viewController: MainViewController
            
            func onOk(input: String){
                let serviceName = MainViewController.processServiceName(nameInput: input)
                if(hps.ownSubscriptions.findSubscription(withServiceKey: HpsGenericUtils.hash(ofString: serviceName)) == nil) {
                    _ = hps.issueSubscribeReq(serviceName: serviceName)
                }
                else {
                    AlertDialogUtils.showOkDialog(viewController: viewController, title: "INFO", msg: "Service already subscribed");
                }
            }
            func onCancel(){}
        }
        
        let subscribeInputDialog = SubscribeServiceInputDialog(hps: hps, viewController: self)
        AlertDialogUtils.showSingleInputDialog(viewController: self, title: "Subscribe Service", msg: "" , hint: "Service", onSingleInputDialog: subscribeInputDialog)
    }
    
    @IBAction func UnsubscribeButton(_ sender: UIButton)
    {
        if( !isHypeSdkReady()){
            return;
        }
        
        if(hps.ownSubscriptions.count() == 0){
            AlertDialogUtils.showOkDialog(viewController: self, title: "INFO", msg: "No services subscribed");
            return;
        }

        let alertController = UIAlertController(title: "Unsubscribe Service", message: "", preferredStyle: .actionSheet)
        for i in 0..<HypePubSub.getInstance().ownSubscriptions.count(){
            alertController.addAction(UIAlertAction(title: HypePubSub.getInstance().ownSubscriptions.get(i)?.serviceName,
                                                    style: .default, handler: { (action) in
                                                        let serviceName = HypePubSub.getInstance().ownSubscriptions.get(i)?.serviceName
                                                        HypePubSub.getInstance().issueUnsubscribeReq(serviceName: serviceName!)
            }))
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
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
                _ = hps.issuePublishReq(serviceName: MainViewController.processServiceName(nameInput: input1), msg: input2)
            }
            func onCancel(){}
        }
        
        let publishInputDialog = PublishInputDialog(hps: hps)
        AlertDialogUtils.showDoubleInputDialog(viewController: self, title: "Publish Message", msg: "" , hint1: "Service", hint2: "Message", onDoubleInputDialog: publishInputDialog)
    }
    
    @IBAction func CheckId(_ sender: UIButton)
    {
        if(!isHypeSdkReady()){
            return;
        }
        
        AlertDialogUtils.showOkDialog(viewController: self, title: "Own Device", msg:
            HpsGenericUtils.getAnnouncementStr(fromHYPInstance: network.ownClient!.instance) + "\n"
                + "Id: 0x" + BinaryUtils.toHexString(data: network.ownClient!.instance.identifier) + "\n"
                + "Key: 0x" + BinaryUtils.toHexString(data: network.ownClient!.key));
    }
    
    private func isHypeSdkReady() -> Bool
    {
        if(hypeSdk.isHypeFail){
            AlertDialogUtils.showOkDialog(viewController: self, title: "Error",
                                          msg: "Hype SDK could not be started.\n" + hypeSdk.hypeFailedMsg)
            return false
        }
        else if(hypeSdk.hasHypeStopped){
            AlertDialogUtils.showOkDialog(viewController: self, title: "Error",
                                          msg: "Hype SDK has stopped.\n" + hypeSdk.hypeStoppedMsg)
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

