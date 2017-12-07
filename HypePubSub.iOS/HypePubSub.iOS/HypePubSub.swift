//
//  HypePubSub.swift
//  HypePubSub.iOS
//

import Foundation
import os


class HypePubSub
{
    private static let HYPE_PUB_SUB_LOG_PREFIX = HpsConstants.LOG_PREFIX + "<HypePubSub> "
    
    private static let hps = HypePubSub() // Early loading to avoid thread-safety issues

    var ownSubscriptions: SubscriptionsList
    var managedServices: ServiceManagersList
    
    private let network = Network.getInstance()
    
    public static func getInstance() -> HypePubSub
    {
        return hps
    }
    
    init()
    {
        self.ownSubscriptions = SubscriptionsList()
        self.managedServices = ServiceManagersList()
    }
    
    func issueSubscribeReq(_ serviceName: String) -> Int
    {
        let serviceKey = HpsGenericUtils.hash(ofString: serviceName)
        let managerClient = network.determineManagerClientOfService(withKey: serviceKey)
    
        // Add subscription to the list of own subscriptions. Only adds if it doesn't exist yet.
        ownSubscriptions.add(subscription: Subscription(withName: serviceName, withManager: managerClient!))
    
        // if this client is the manager of the service we don't need to send the subscribe message to
        // the protocol manager
        if(HpsGenericUtils.areClientsEqual(network.ownClient!, managerClient!))
        {
            HypePubSub.printIssueReqToHostInstanceLog("Subscribe", serviceName)
            self.processSubscribeReq(serviceKey, network.ownClient!.instance)
            return 1
        }
        else
        {
            _ = Protocol.sendSubscribeMsg(serviceKey, (managerClient?.instance)!)
        }

        return 0
    }
    
    func issueUnsubscribeReq(_ serviceName: String) -> Int
    {
        let serviceKey = HpsGenericUtils.hash(ofString: serviceName)
        let managerClient = network.determineManagerClientOfService(withKey: serviceKey)

        let serviceSubscription = ownSubscriptions.find(withKey: serviceKey)
        if(serviceSubscription == nil){
            return -2
        }

        // Remove the subscription from the list of own subscriptions
        ownSubscriptions.remove(subscription: serviceSubscription!)

        // if this client is the manager of the service we don't need to send the unsubscribe message
        // to the protocol manager
        if(HpsGenericUtils.areClientsEqual(network.ownClient!, managerClient!))
        {
            HypePubSub.printIssueReqToHostInstanceLog("Unsubscribe", serviceName)
            self.processUnsubscribeReq(serviceKey, network.ownClient!.instance)
        }
        else {
            _ = Protocol.sendUnsubscribeMsg(serviceKey, (managerClient?.instance)!)
        }

        return 0
    }
    
    func issuePublishReq(_ serviceName: String, _ msg: String) -> Int
    {
        let serviceKey = HpsGenericUtils.hash(ofString: serviceName)
        let managerClient = network.determineManagerClientOfService(withKey: serviceKey)
        
        // if this client is the manager of the service we don't need to send the publish message
        // to the protocol manager
        if(HpsGenericUtils.areClientsEqual(network.ownClient!, managerClient!))
        {
            HypePubSub.printIssueReqToHostInstanceLog("Publish", serviceName)
            self.processPublishReq(serviceKey, msg)
            return 1
        }
        else
        {
            _ = Protocol.sendPublishMsg(serviceKey, (managerClient?.instance)!, msg)
        }
        
        return 0
    }
    
    func processSubscribeReq(_ serviceKey: Data, _ requesterInstance: HYPInstance)
    {
        SyncUtils.lock(obj: self)
        {
            let managerClient = network.determineManagerClientOfService(withKey: serviceKey)
            if( !HpsGenericUtils.areClientsEqual(managerClient!, network.ownClient!))
            {
                os_log("%@ Another instance should be responsible for the service 0x%@: %@", log: OSLog.default, type: .info,
                       HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                       BinaryUtils.toHexString(data: serviceKey),
                       HpsGenericUtils.getLogStr(fromClient: managerClient!))
                
                return
            }
        
            var serviceManager = self.managedServices.find(withKey: serviceKey)
            if(serviceManager == nil ) // If the service does not exist we create it.
            {
                os_log("%@ Processing Subscribe request for non-existent ServiceManager 0x%@ ServiceManager will be created.",
                       log: OSLog.default, type: .info,
                       HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                       BinaryUtils.toHexString(data: serviceKey))
                
                self.managedServices.add(serviceManager: ServiceManager(fromServiceKey: serviceKey))
                serviceManager = self.managedServices.getLast()
            }
        
            os_log("Adding instance %@ to the list of subscribers of the service 0x%@",
                   log: OSLog.default, type: .info,
                   HpsGenericUtils.getLogStr(fromHYPInstance: requesterInstance),
                   BinaryUtils.toHexString(data: serviceKey))

            serviceManager!.subscribers.add(client: Client(fromHYPInstance:requesterInstance))
        }
    }
    
    func processUnsubscribeReq(_ serviceKey: Data, _ requesterInstance: HYPInstance)
    {
        SyncUtils.lock(obj: self)
        {
            let serviceManager = self.managedServices.find(withKey: serviceKey)
            
            if(serviceManager == nil) // If the service does not exist nothing is done
            {
                os_log("%@ Processing Unsubscribe request for non-existent ServiceManager 0x%@. Nothing will be done",
                       log: OSLog.default, type: .info,
                       HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                       BinaryUtils.toHexString(data: serviceKey))
                
                return
            }
            
            os_log("%@ Removing instance %@ from the list of subscribers of the service 0x%@",
                   log: OSLog.default, type: .info,
                   HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                   HpsGenericUtils.getLogStr(fromHYPInstance: requesterInstance),
                   BinaryUtils.toHexString(data: serviceKey))
            
            serviceManager!.subscribers.remove(client: Client(fromHYPInstance: requesterInstance))
            
            if(serviceManager!.subscribers.count() == 0)
            { // Remove the service if there is no subscribers
                self.managedServices.remove(withKey: serviceKey)
            }
        }
    }
    
    func processPublishReq(_ serviceKey: Data, _ msg: String)
    {
        SyncUtils.lock(obj: self)
        {
            let serviceManager = self.managedServices.find(withKey: serviceKey)
            
            if(serviceManager == nil)
            {
                os_log("%@ Processing Publish request for non-existent ServiceManager 0x%@. Nothing will be done",
                       log: OSLog.default, type: .info,
                       HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                       BinaryUtils.toHexString(data: serviceKey))
                
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
                    os_log("%@ Publishing info from service 0x%@ to Host instance",
                           log: OSLog.default, type: .info,
                           HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                           BinaryUtils.toHexString(data: serviceKey))

                    self.processInfoMsg(serviceKey, msg)
                }
                else
                {
                    os_log("%@ Publishing info from service 0x%@ to %@",
                           log: OSLog.default, type: .info,
                           HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                           BinaryUtils.toHexString(data: serviceKey),
                           HpsGenericUtils.getLogStr(fromHYPInstance: client!.instance))
             
                    _ = Protocol.sendInfoMsg(serviceKey, client!.instance, msg)
                }
            }
        }
    }
    
    func processInfoMsg(_ serviceKey: Data, _ msg: String)
    {
        let subscription = ownSubscriptions.find(withKey: serviceKey)
        
        if(subscription == nil){
            os_log("%@ Info received from the unsubscribed service%@: %@",
                   log: OSLog.default, type: .info,
                   HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                   BinaryUtils.toHexString(data: serviceKey),
                   msg)

            return
        }
        /*
        Date now = new Date()
        SimpleDateFormat sdf = new SimpleDateFormat("k'h'mm", Locale.getDefault())
        String timestamp = sdf.format(now)
        String msgWithTimeStamp = timestamp + ": " + msg
        
        subscription.receivedMsg.add(0, msgWithTimeStamp)
        updateMessagesUI()
        String notificationText = subscription.serviceName + ": " + msg
        displayNotification(MainActivity.getContext(), HpsConstants.NOTIFICATIONS_CHANNEL, HpsConstants.NOTIFICATIONS_TITLE, notificationText, notificationID)
        notificationID++
        */
        
        os_log("%@ Info received from the unsubscribed service %@: %@",
               log: OSLog.default, type: .info,
               HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
               subscription!.serviceName,
               msg)
        
    }
    
    func updateManagedServices()
    {
        SyncUtils.lock(obj: self)
        {
            var toRemove = [Data]()
            os_log("%@ Executing updateManagedServices (%@ services managed)",
                   log: OSLog.default, type: .info,
                   HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                   self.managedServices.count())
        
            for i in 0..<self.managedServices.count()
            {
                let managedService = managedServices.get(i)
            
                // Check if a new Hype client with a closer key to this service key has appeared. If this happens
                // we remove the service from the list of managed services of this Hype client.
                let newManagerClient = network.determineManagerClientOfService(withKey: managedService!.serviceKey)
            
                os_log("%@ Analyzing ServiceManager from service 0x%@",
                       log: OSLog.default, type: .info,
                       HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                       BinaryUtils.toHexString(data: managedService!.serviceKey))
                
                if( !HpsGenericUtils.areClientsEqual(newManagerClient!, network.ownClient!))
                {
                    os_log("%@ The service 0x%@ will be managed by %@. ServiceManager will be removed",
                           log: OSLog.default, type: .info,
                           HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                           BinaryUtils.toHexString(data: managedService!.serviceKey),
                           HpsGenericUtils.getLogStr(fromClient: newManagerClient!))
                    
                    toRemove.append((managedService?.serviceKey)!)
                }
            }
            
            for i in 0..<toRemove.count{
                self.managedServices.remove(withKey: toRemove[i])
            }
        }
    }
    
    func updateOwnSubscriptions()
    {
        SyncUtils.lock(obj: self)
        {
             os_log("%@ Executing updateOwnSubscriptions (%@ subscriptions)",
             log: OSLog.default, type: .info,
             HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
             self.ownSubscriptions.count())
        
            for i in 0..<self.ownSubscriptions.count()
            {
                let subscription = ownSubscriptions.get(i)
        
                let newManagerClient = network.determineManagerClientOfService(withKey: subscription!.serviceKey)
        
                
                os_log("%@ Analyzing subscription ",
                       log: OSLog.default, type: .info,
                       HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                       HpsGenericUtils.getLogStr(fromSubscription: subscription!))
        
                // If there is a node with a closer key to the service key we change the manager
                if( !HpsGenericUtils.areClientsEqual(newManagerClient!, subscription!.manager))
                {
                    
                    os_log("%@ The manager of the subscribed service %@ has changed: %@. A new Subscribe message will be issued)",
                           log: OSLog.default, type: .info,
                           HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                           subscription!.serviceName,
                           HpsGenericUtils.getLogStr(fromClient: newManagerClient!))
                    
                    subscription!.manager = newManagerClient!
                    _ = self.issueSubscribeReq(subscription!.serviceName) // re-send the subscribe request to the new manager
                }
            }
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////
    // Logging Methods
    //////////////////////////////////////////////////////////////////////////////
    
    static func printIssueReqToHostInstanceLog(_ msgType: String, _ serviceName: String)
    {
        os_log("%@ Issuing %@ for service %@", log: OSLog.default, type: .info,
               HYPE_PUB_SUB_LOG_PREFIX, msgType, serviceName)
    }
}
