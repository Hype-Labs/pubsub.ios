//
//  HypePubSub.swift
//  HypePubSub.iOS
//

import Foundation
import UserNotifications


class HypePubSub
{
    // Members
    var ownSubscriptions: SubscriptionsList
    var managedServices: ServiceManagersList
    
    // Private
    private static let HYPE_PUB_SUB_LOG_PREFIX = HpsConstants.LOG_PREFIX + "<HypePubSub> "
    private let network = Network.getInstance()
    
    private static let hps = HypePubSub() // Early loading to avoid thread-safety issues
    public static func getInstance() -> HypePubSub {
        return hps
    }
    
    init()
    {
        self.ownSubscriptions = SubscriptionsList()
        self.managedServices = ServiceManagersList()
    }
    
    //////////////////////////////////////////////////////////////////////////////
    // Request Issuing
    //////////////////////////////////////////////////////////////////////////////
    
    func issueSubscribeReq(serviceName: String)
    {
        let serviceKey = HpsGenericUtils.hash(ofString: serviceName)
        let managerClient = network.determineClientResponsibleForService(withKey: serviceKey)
    
        let wasSubscriptionAdded = ownSubscriptions.addSubscription(Subscription(withName: serviceName, withManager: managerClient!))
        if(!wasSubscriptionAdded) {
            return
        }
        
        if(HpsGenericUtils.areClientsEqual(network.ownClient!, managerClient!)) {
            HypePubSub.printIssueReqToHostInstanceLog("Subscribe", serviceName)
            self.processSubscribeReq(serviceKey, network.ownClient!.instance) // bypass protocol manager
        }
        else{
            _ = Protocol.sendSubscribeMsg(serviceKey, (managerClient?.instance)!)
        }
    }
    
    func issueUnsubscribeReq(serviceName: String)
    {
        let serviceKey = HpsGenericUtils.hash(ofString: serviceName)
        let managerClient = network.determineClientResponsibleForService(withKey: serviceKey)

        let wasSubscriptionRemoved = ownSubscriptions.removeSubscription(withServiceName: serviceName)
        if(!wasSubscriptionRemoved) {
            return
        }

        if(HpsGenericUtils.areClientsEqual(network.ownClient!, managerClient!)) {
            HypePubSub.printIssueReqToHostInstanceLog("Unsubscribe", serviceName)
            self.processUnsubscribeReq(serviceKey, network.ownClient!.instance) // bypass protocol manager
        }
        else {
            _ = Protocol.sendUnsubscribeMsg(serviceKey, (managerClient?.instance)!)
        }
    }
    
    func issuePublishReq(serviceName: String, msg: String)
    {
        let serviceKey = HpsGenericUtils.hash(ofString: serviceName)
        let managerClient = network.determineClientResponsibleForService(withKey: serviceKey)
        
        if(HpsGenericUtils.areClientsEqual(network.ownClient!, managerClient!)) {
            HypePubSub.printIssueReqToHostInstanceLog("Publish", serviceName)
            self.processPublishReq(serviceKey, msg) // bypass protocol manager
        }
        else {
            _ = Protocol.sendPublishMsg(serviceKey, (managerClient?.instance)!, msg)
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////
    // Request Processing
    //////////////////////////////////////////////////////////////////////////////
    
    func processSubscribeReq(_ serviceKey: Data, _ requesterInstance: HYPInstance)
    {
        SyncUtils.lock(obj: self)
        {
            let managerClient = network.determineClientResponsibleForService(withKey: serviceKey)
            if( !HpsGenericUtils.areClientsEqual(managerClient!, network.ownClient!))
            {
                LogUtils.log(prefix: HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                             logMsg: String(format: "Another instance should be responsible for the service 0x%@: %@",
                                            BinaryUtils.toHexString(data: serviceKey),
                                            HpsGenericUtils.getLogStr(fromClient: managerClient!)))
                
                return
            }
        
            var serviceManager = self.managedServices.findServiceManager(withKey: serviceKey)
            if(serviceManager == nil ) // If the service does not exist we create it.
            {
                LogUtils.log(prefix: HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                             logMsg: String(format: "Processing Subscribe request for non-existent ServiceManager 0x%@ ServiceManager will be created.",
                                            BinaryUtils.toHexString(data: serviceKey)))
                
                _ = self.managedServices.addServiceManager(ServiceManager(fromServiceKey: serviceKey))
                serviceManager = self.managedServices.getLast()
            }
            
            LogUtils.log(prefix: HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                         logMsg: String(format: "Adding instance %@ to the list of subscribers of the service 0x%@",
                                       HpsGenericUtils.getLogStr(fromHYPInstance: requesterInstance),
                                       BinaryUtils.toHexString(data: serviceKey)))

            _ = serviceManager!.subscribers.addClient(Client(fromHYPInstance:requesterInstance))
        }
    }
    
    func processUnsubscribeReq(_ serviceKey: Data, _ requesterInstance: HYPInstance)
    {
        SyncUtils.lock(obj: self)
        {
            let serviceManager = self.managedServices.findServiceManager(withKey: serviceKey)
            
            if(serviceManager == nil) // If the service does not exist nothing is done
            {
                LogUtils.log(prefix: HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                             logMsg: String(format: "Processing Unsubscribe request for non-existent ServiceManager 0x%@. Nothing will be done",
                                            BinaryUtils.toHexString(data: serviceKey)))
                
                return
            }
            
            LogUtils.log(prefix: HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                         logMsg: String(format: "Removing instance %@ from the list of subscribers of the service 0x%@",
                                       HpsGenericUtils.getLogStr(fromHYPInstance: requesterInstance),
                                       BinaryUtils.toHexString(data: serviceKey)))
            
            _ = serviceManager!.subscribers.removeClient(withHYPInstance: requesterInstance)
            
            if(serviceManager!.subscribers.count() == 0) { // Remove the service if there is no subscribers
                _ = self.managedServices.removeServiceManager(withKey: serviceKey)
            }
        }
    }
    
    func processPublishReq(_ serviceKey: Data, _ msg: String)
    {
        SyncUtils.lock(obj: self)
        {
            let serviceManager = self.managedServices.findServiceManager(withKey: serviceKey)
            
            if(serviceManager == nil)
            {
                LogUtils.log(prefix: HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                             logMsg: String(format: "Processing Publish request for non-existent ServiceManager 0x%@. Nothing will be done",
                                            BinaryUtils.toHexString(data: serviceKey)))
                
                return
            }
            
            for i in 0..<serviceManager!.subscribers.count()
            {
                let client = serviceManager?.subscribers.get(i)
                if(client == nil){
                    continue
                }
             
                if(HpsGenericUtils.areClientsEqual(network.ownClient!, client!))
                {
                    LogUtils.log(prefix: HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                                 logMsg: String(format: "Publishing info from service 0x%@ to Host instance",
                                                BinaryUtils.toHexString(data: serviceKey)))

                    self.processInfoMsg(serviceKey, msg)
                }
                else
                {
                    LogUtils.log(prefix: HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                                 logMsg: String(format: "Publishing info from service 0x%@ to %@",
                                               BinaryUtils.toHexString(data: serviceKey),
                                               HpsGenericUtils.getLogStr(fromHYPInstance: client!.instance)))
             
                    _ = Protocol.sendInfoMsg(serviceKey, client!.instance, msg)
                }
            }
        }
    }
    
    func processInfoMsg(_ serviceKey: Data, _ msg: String)
    {
        let subscription = ownSubscriptions.findSubscription(withServiceKey: serviceKey)
        
        if(subscription == nil){
            LogUtils.log(prefix: HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                         logMsg: String(format: "Info received from the unsubscribed service 0x%@: %@",
                                       BinaryUtils.toHexString(data: serviceKey), msg))
            return
        }
        
        /*
        Date now = new Date()
        SimpleDateFormat sdf = new SimpleDateFormat("k'h'mm", Locale.getDefault())
        String timestamp = sdf.format(now)
        String msgWithTimeStamp = timestamp + ": " + msg
        */
        subscription!.receivedMsg.append(msg) // timeStampedMsg
        /*
        updateMessagesUI()
        String notificationText = subscription.serviceName + ": " + msg
        displayNotification(MainActivity.getContext(), HpsConstants.NOTIFICATIONS_CHANNEL, HpsConstants.NOTIFICATIONS_TITLE, notificationText, notificationID)
        notificationID++
        */

        LogUtils.log(prefix: HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                     logMsg: String(format: "Info received from the subscribed service '%@': %@",
                                   subscription!.serviceName, msg))
    }
    
    func updateManagedServices()
    {
        SyncUtils.lock(obj: self)
        {
            var toRemove = [Data]()
            
            LogUtils.log(prefix: HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                         logMsg: String(format: "Executing updateManagedServices (%i services managed)",
                                        self.managedServices.count()))
        
            for i in 0..<self.managedServices.count()
            {
                let managedService = managedServices.get(i)
            
                // Check if a new Hype client with a closer key to this service key has appeared. If this happens
                // we remove the service from the list of managed services of this Hype client.
                let newManagerClient = network.determineClientResponsibleForService(withKey: managedService!.serviceKey)
            
                LogUtils.log(prefix: HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                             logMsg: String(format: "Analyzing ServiceManager from service 0x%@",
                                            BinaryUtils.toHexString(data: managedService!.serviceKey)))
                
                if( !HpsGenericUtils.areClientsEqual(newManagerClient!, network.ownClient!))
                {
                    LogUtils.log(prefix: HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                                 logMsg: String(format: "The service 0x%@ will be managed by %@. ServiceManager will be removed",
                                               BinaryUtils.toHexString(data: managedService!.serviceKey),
                                               HpsGenericUtils.getLogStr(fromClient: newManagerClient!)))
                    
                    toRemove.append((managedService?.serviceKey)!)
                }
            }
            
            for i in 0..<toRemove.count{
                _ = self.managedServices.removeServiceManager(withKey: toRemove[i])
            }
        }
    }
    
    func updateOwnSubscriptions()
    {
        SyncUtils.lock(obj: self)
        {
            LogUtils.log(prefix: HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                         logMsg: String(format: "Executing updateOwnSubscriptions (%i subscriptions)",
                                        self.ownSubscriptions.count()))
        
            for i in 0..<self.ownSubscriptions.count()
            {
                let subscription = ownSubscriptions.get(i)
                let newManagerClient = network.determineClientResponsibleForService(withKey: subscription!.serviceKey)
        
                LogUtils.log(prefix: HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                             logMsg: String(format: "Analyzing subscription ",
                                            HpsGenericUtils.getLogStr(fromSubscription: subscription!)))
        
                // If there is a node with a closer key to the service key we change the subscription manager
                if( !HpsGenericUtils.areClientsEqual(newManagerClient!, subscription!.manager))
                {
                    LogUtils.log(prefix: HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                                 logMsg: String(format: "The manager of the subscribed service '%@' has changed: %@. A new Subscribe message will be issued)",
                                               subscription!.serviceName,
                                               HpsGenericUtils.getLogStr(fromClient: newManagerClient!)))
                    
                    subscription!.manager = newManagerClient!
                    
                    if(HpsGenericUtils.areClientsEqual(network.ownClient!, newManagerClient!)) {
                        self.processSubscribeReq((subscription?.serviceKey)!, network.ownClient!.instance) // bypass protocol manager
                    }
                    else {
                        _ = Protocol.sendSubscribeMsg((subscription?.serviceKey)!, (newManagerClient?.instance)!)
                    }
                }
            }
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////
    // Logging Methods
    //////////////////////////////////////////////////////////////////////////////
    
    static func printIssueReqToHostInstanceLog(_ reqType: String, _ serviceName: String)
    {
        LogUtils.log(prefix: HYPE_PUB_SUB_LOG_PREFIX,
                     logMsg: String(format: "Issuing %@ for service '%@' to HOST instance", reqType, serviceName))
    }
}
