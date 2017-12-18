
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
            showHypeNotReadyDialog()
            return
        }
        
        displayServicesNamesList(serviceNames: unsubscribedServices,
                                  listTitle: "Subscribe",
                                  listMsg: "Select a service to subscribe",
                                  subscribeServiceAction,
                                  isNewServiceSelectionAllowed: true)
    }
    
    @IBAction func UnsubscribeButton(_ sender: UIButton)
    {
        if( !isHypeSdkStateValid()){
            showHypeNotReadyDialog()
            return
        }

        if( isNoServiceSubscribed()){
            showNoServicesSubscribedDialog()
            return
        }
        
        displayServicesNamesList(serviceNames: subscribedServices,
                                  listTitle: "Unsubscribe",
                                  listMsg: "Select a service to unsubscribe",
                                  unsubscribeServiceAction,
                                  isNewServiceSelectionAllowed: false)
    }
    
    @IBAction func PublishButton(_ sender: UIButton)
    {
        if( !isHypeSdkStateValid()){
            showHypeNotReadyDialog()
            return
        }
        
        displayServicesNamesList(serviceNames: availableServices,
                                    listTitle: "Publish",
                                    listMsg: "Select a service in which to publish",
                                    publishServiceAction,
                                    isNewServiceSelectionAllowed: true)
    }
    
    @IBAction func CheckId(_ sender: UIButton)
    {
        if(!isHypeSdkStateValid()){
            showHypeNotReadyDialog()
            return
        }
        
        AlertControllerUtils.showInfoAlertController(viewController: self,
                                        title: "Own Device",
                                        msg: HpsGenericUtils.getAnnouncementStr(fromHYPInstance: network.ownClient!.instance) + "\n"
                                            + HpsGenericUtils.getIdString(fromClient: network.ownClient!) + "\n"
                                            + HpsGenericUtils.getKeyString(fromClient: network.ownClient!) + "\n")
    }
    
    @IBAction func HypeDevicesButton(_ sender: UIButton) {
        if(!isHypeSdkStateValid()){
            showHypeNotReadyDialog()
            return
        }
    }
    
    @IBAction func SubscriptionsButton(_ sender: UIButton) {
        if(!isHypeSdkStateValid()){
            showHypeNotReadyDialog()
            return
        }
        
        if( isNoServiceSubscribed()){
            showNoServicesSubscribedDialog()
            return
        }
    }
    
    @IBAction func ManagedServicesButton(_ sender: UIButton) {
        if(!isHypeSdkStateValid()){
            showHypeNotReadyDialog()
            return
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
                                                        self.processNewServiceSelection(onServiceSelection)
                                                    }))
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func subscribeServiceAction(userInput: String)
    {
        let serviceName = MainViewController.processUserServiceNameInput(userInput)
        
        if(hps.ownSubscriptions.containsSubscription(withServiceName: serviceName))
        {
            AlertControllerUtils.showInfoAlertController(viewController: self,
                                            title: "INFO", msg: "Service already subscribed")
        }
        else {
            let wasSubscribed = hps.issueSubscribeReq(serviceName: serviceName)
            if(wasSubscribed) {
                addSubscribedService(serviceName)
                removeUnsubscribedService(serviceName)
            }
        }
    }
    
    func unsubscribeServiceAction(userInput: String)
    {
        let serviceName = MainViewController.processUserServiceNameInput(userInput)
        let wasUnsubscribed = hps.issueUnsubscribeReq(serviceName: serviceName)
        if(wasUnsubscribed) {
            addUnsubscribedService(serviceName)
            removeSubscribedService(serviceName)
        }
    }
    
    func publishServiceAction(userInput: String)
    {
        let serviceName = MainViewController.processUserServiceNameInput(userInput)
        
        struct MsgInput: SingleInputAlertController
        {
            var serviceName: String
            func onOk(input: String)
            {
                HypePubSub.getInstance().issuePublishReq(serviceName: serviceName, msg: input)
            }
            func onCancel(){}
        }
        
        let msgInputDialog = MsgInput(serviceName: serviceName)
        AlertControllerUtils.showSingleInputAlertController(viewController: self,
                                               title: "Publish",
                                               msg: "Insert message to publish in the service: " + serviceName,
                                               hint: "message",
                                               onSingleInputAlertController: msgInputDialog)
    }
    
    func processNewServiceSelection(_ onNewService: @escaping (_ serviceName: String)->())
    {
        struct ServiceNameInput: SingleInputAlertController
        {
            var mainViewController: MainViewController
            var onNewService: (_ serviceName: String)->()
            func onOk(input: String) {
                let serviceName = MainViewController.processUserServiceNameInput(input)
                mainViewController.addAvailableService(serviceName)
                mainViewController.addUnsubscribedService(serviceName)
                onNewService(input)
            }
            func onCancel(){}
        }
        
        let newServiceInputDialog = ServiceNameInput(mainViewController: self, onNewService: onNewService)
        AlertControllerUtils.showSingleInputAlertController(viewController: self,
                                               title: "New Service",
                                               msg: "Specify new service" ,
                                               hint: "service",
                                               onSingleInputAlertController: newServiceInputDialog)
    }
    
    //////////////////////////////////////////////////////////////////////////////
    // Utilities
    //////////////////////////////////////////////////////////////////////////////
    
    private func isHypeSdkStateValid() -> Bool
    {
        if(!hypeSdk.hasHypeFailed && !hypeSdk.hasHypeStopped && hypeSdk.hasHypeStarted)
        {
            return true
        }
        
        return false
    }
    
    private func showHypeNotReadyDialog()
    {
        if(hypeSdk.hasHypeFailed)
        {
            AlertControllerUtils.showInfoAlertController(viewController: self,
                                          title: "Error",
                                          msg: "Hype SDK could not be started.\n" + hypeSdk.hypeFailedMsg)
        }
        else if(hypeSdk.hasHypeStopped)
        {
            AlertControllerUtils.showInfoAlertController(viewController: self,
                                          title: "Error",
                                          msg: "Hype SDK has stopped.\n" + hypeSdk.hypeStoppedMsg)
        }
        if( !hypeSdk.hasHypeStarted)
        {
            AlertControllerUtils.showInfoAlertController(viewController: self,
                                          title: "Info",
                                          msg: "Hype SDK is starting")
        }
    }
    
    private func isNoServiceSubscribed() -> Bool
    {
        return (subscribedServices.count == 0);
    }
    
    private func showNoServicesSubscribedDialog()
    {
        AlertControllerUtils.showInfoAlertController(viewController: self,
                                        title: "Info",
                                        msg: "No services subscribed")
    
    }
    
    func addAvailableService(_ serviceName: String)
    {
        if !availableServices.contains(serviceName) {
            availableServices.append(serviceName)
        }
    }
    
    func removeAvailableService(_ serviceName: String)
    {
        availableServices = availableServices.filter{$0 != serviceName}
    }
    
    func addSubscribedService(_ serviceName: String)
    {
        if !subscribedServices.contains(serviceName) {
            subscribedServices.append(serviceName)
        }
    }
    
    func removeSubscribedService(_ serviceName: String)
    {
        subscribedServices = subscribedServices.filter{$0 != serviceName}
    }
    
    func addUnsubscribedService(_ serviceName: String)
    {
        if !unsubscribedServices.contains(serviceName) {
            unsubscribedServices.append(serviceName)
        }
    }
    
    func removeUnsubscribedService(_ serviceName: String)
    {
        unsubscribedServices = unsubscribedServices.filter{$0 != serviceName}
    }
    
    static func processUserServiceNameInput(_ input: String) -> String
    {
        return input.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

