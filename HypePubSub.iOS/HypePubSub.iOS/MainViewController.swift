
import UIKit
import UserNotifications

class MainViewController: UIViewController, UNUserNotificationCenterDelegate
{
    let hps = HypePubSub.getInstance()
    let network = Network.getInstance()
    let hypeSdk = HypeSdkInterface.getInstance()
    
    var availableServices = HpsConstants.STANDARD_HYPE_SERVICES
    var unsubscribedServices = HpsConstants.STANDARD_HYPE_SERVICES
    var subscribedServices = [String]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        UNUserNotificationCenter.current().delegate = self
        hypeSdk.requestHypeToStart()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.alert, .sound])
    }
    
    //////////////////////////////////////////////////////////////////////////////
    // Button Action Methods
    //////////////////////////////////////////////////////////////////////////////
    
    @IBAction func SubscribeButton(_ sender: UIButton)
    {
        if( !isHypeSdkStateValid()){
            return;
        }
        
        displayServicesNamesList(serviceNames: unsubscribedServices,
                                  listTitle: "Subscribe",
                                  listMsg: "Select a service to subscribe",
                                  processUserSubscribeAction,
                                  isNewServiceSelectionAllowed: true)
    }
    
    @IBAction func UnsubscribeButton(_ sender: UIButton)
    {
        if( !isHypeSdkStateValid()){
            return;
        }
        
        displayServicesNamesList(serviceNames: subscribedServices,
                                  listTitle: "Unsubscribe",
                                  listMsg: "Select a service to unsubscribe",
                                  processUserUnsubscribeAction,
                                  isNewServiceSelectionAllowed: false)
    }
    
    @IBAction func PublishButton(_ sender: UIButton)
    {
        if( !isHypeSdkStateValid()){
            return;
        }
        
        displayServicesNamesList(serviceNames: availableServices,
                                    listTitle: "Publish",
                                    listMsg: "Select a service in which to publish",
                                    processUserPublishAction,
                                    isNewServiceSelectionAllowed: true)
    }
    
    @IBAction func CheckId(_ sender: UIButton)
    {
        if(!isHypeSdkStateValid()){
            return;
        }
        
        AlertDialogUtils.showInfoDialog(viewController: self,
                                        title: "Own Device",
                                        msg: HpsGenericUtils.getAnnouncementStr(fromHYPInstance: network.ownClient!.instance) + "\n"
                                            + HpsGenericUtils.getIdString(fromClient: network.ownClient!) + "\n"
                                            + HpsGenericUtils.getKeyString(fromClient: network.ownClient!) + "\n")
    }
    
    @IBAction func HypeDevicesButton(_ sender: UIButton) {
        if(!isHypeSdkStateValid()){
            return;
        }
    }
    
    @IBAction func SubscriptionsButton(_ sender: UIButton) {
        if(!isHypeSdkStateValid()){
            return;
        }
    }
    
    @IBAction func ManagedServicesButton(_ sender: UIButton) {
        if(!isHypeSdkStateValid()){
            return;
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////
    // User Action Processing Methods
    //////////////////////////////////////////////////////////////////////////////
    
    func displayServicesNamesList(serviceNames: [String],
                                  listTitle: String,
                                  listMsg: String,
                                  _ onServiceSelection: @escaping (_ serviceName: String)->(),
                                  isNewServiceSelectionAllowed: Bool)
    {
        let alertController = UIAlertController(title: listTitle, message: listMsg, preferredStyle: .actionSheet)
        
        for i in 0..<serviceNames.count
        {
            alertController.addAction(UIAlertAction(title: serviceNames[i],
                                                    style: .default,
                                                    handler: { (action) in
                                                        onServiceSelection(serviceNames[i])
                                                    }))
        }
        
        if(isNewServiceSelectionAllowed)
        {
            alertController.addAction(UIAlertAction(title: "New Service",
                                                    style: .destructive,
                                                    handler: { (action) in
                                                        self.processUserNewServiceSelection(onServiceSelection)
                                                    }))
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func processUserSubscribeAction(userInput: String)
    {
        let serviceName = MainViewController.processUserInput(userInput)
        
        if(hps.ownSubscriptions.containsSubscription(withServiceName: serviceName))
        {
            AlertDialogUtils.showInfoDialog(viewController: self,
                                            title: "INFO",
                                            msg: "Service already subscribed");
        }
        else {
            let wasSubscribed = hps.issueSubscribeReq(serviceName: serviceName)
            
            if(wasSubscribed) {
                if !subscribedServices.contains(serviceName) { subscribedServices.append(serviceName) }
                unsubscribedServices = unsubscribedServices.filter{$0 != serviceName}
            }
        }
    }
    
    func processUserUnsubscribeAction(userInput: String)
    {
        let serviceName = MainViewController.processUserInput(userInput)
        let wasUnsubscribed = hps.issueUnsubscribeReq(serviceName: serviceName)
        
        if(wasUnsubscribed) {
            if !unsubscribedServices.contains(serviceName) { unsubscribedServices.append(serviceName) }
            subscribedServices = subscribedServices.filter{$0 != serviceName}
        }
    }
    
    func processUserPublishAction(userInput: String)
    {
        let serviceName = MainViewController.processUserInput(userInput)
        
        struct MsgInput: SingleInputDialog
        {
            var serviceName: String
            func onOk(input: String)
            {
                HypePubSub.getInstance().issuePublishReq(serviceName: serviceName, msg: input)
            }
            func onCancel(){}
        }
        
        let msgInputDialog = MsgInput(serviceName: serviceName)
        AlertDialogUtils.showSingleInputDialog(viewController: self,
                                               title: "Publish",
                                               msg: "Insert message to publish in the service: " + serviceName,
                                               hint: "message",
                                               onSingleInputDialog: msgInputDialog)
    }
    
    func processUserNewServiceSelection(_ onNewService: @escaping (_ serviceName: String)->())
    {
        struct ServiceNameInput: SingleInputDialog
        {
            var mainViewController: MainViewController
            var onNewService: (_ serviceName: String)->()
            func onOk(input: String) {
                let serviceName = MainViewController.processUserInput(input)
                if !mainViewController.availableServices.contains(serviceName) { mainViewController.availableServices.append(serviceName) }
                onNewService(input)
            }
            func onCancel(){}
        }
        
        let newServiceInputDialog = ServiceNameInput(mainViewController: self, onNewService: onNewService)
        AlertDialogUtils.showSingleInputDialog(viewController: self,
                                               title: "New Service",
                                               msg: "Specify new service" ,
                                               hint: "service",
                                               onSingleInputDialog: newServiceInputDialog)
    }
    
    //////////////////////////////////////////////////////////////////////////////
    // Utilities
    //////////////////////////////////////////////////////////////////////////////
    
    private func isHypeSdkStateValid() -> Bool
    {
        if(hypeSdk.hasHypeFailed)
        {
            AlertDialogUtils.showInfoDialog(viewController: self,
                                          title: "Error",
                                          msg: "Hype SDK could not be started.\n" + hypeSdk.hypeFailedMsg)
            return false
        }
        if(hypeSdk.hasHypeStopped)
        {
            AlertDialogUtils.showInfoDialog(viewController: self,
                                          title: "Error",
                                          msg: "Hype SDK has stopped.\n" + hypeSdk.hypeStoppedMsg)
            return false
        }
        if( !hypeSdk.hasHypeStarted)
        {
            AlertDialogUtils.showInfoDialog(viewController: self,
                                          title: "Info",
                                          msg: "Hype SDK is starting");
            return false;
        }
    
        return true;
    }
    
    static func processUserInput(_ input: String) -> String
    {
        return input.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

