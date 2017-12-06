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
    
    private let hpsSyncQueue = DispatchQueue(label: "com.hypelabs.hypepubsub.hypepubsub.hpssyncqueue")
    
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
        let managerInstance = network.determineInstanceResponsibleForService(serviceKey)
    
        // Add subscription to the list of own subscriptions. Only adds if it doesn't exist yet.
        ownSubscriptions.add(serviceName, managerInstance!)
    
        // if this client is the manager of the service we don't need to send the subscribe message to
        // the protocol manager
        if(HpsGenericUtils.areInstancesEqual(network.ownClient!.instance, managerInstance!))
        {
            HypePubSub.printIssueReqToHostInstanceLog("Subscribe", serviceName)
            self.processSubscribeReq(serviceKey, network.ownClient!.instance)
            return 1
        }
        else
        {
            _ = Protocol.sendSubscribeMsg(serviceKey, managerInstance!)
        }

        return 0
    }
    
    func issueUnsubscribeReq(_ serviceName: String) -> Int
    {
         let serviceKey = HpsGenericUtils.hash(ofString: serviceName)
         let managerInstance = network.determineInstanceResponsibleForService(serviceKey)
    
        let (subscription, _) = ownSubscriptions.find(serviceKey)
        if(subscription == nil){
            return -2
        }
    
        // Remove the subscription from the list of own subscriptions
        ownSubscriptions.remove(serviceName)
    
        // if this client is the manager of the service we don't need to send the unsubscribe message
        // to the protocol manager
        if(HpsGenericUtils.areInstancesEqual(network.ownClient!.instance, managerInstance!))
        {
            HypePubSub.printIssueReqToHostInstanceLog("Unsubscribe", serviceName)
            self.processUnsubscribeReq(serviceKey, network.ownClient!.instance)
        }
        else {
            _ = Protocol.sendUnsubscribeMsg(serviceKey, managerInstance!)
        }

        return 0
    }
    
    func issuePublishReq(_ serviceName: String, _ msg: String) -> Int
    {
        let serviceKey = HpsGenericUtils.hash(ofString: serviceName)
        let managerInstance = network.determineInstanceResponsibleForService(serviceKey)
        
        // if this client is the manager of the service we don't need to send the publish message
        // to the protocol manager
        if(HpsGenericUtils.areInstancesEqual(network.ownClient!.instance, managerInstance!))
        {
            HypePubSub.printIssueReqToHostInstanceLog("Publish", serviceName)
            self.processPublishReq(serviceKey, msg)
            return 1
        }
        else
        {
            _ = Protocol.sendPublishMsg(serviceKey, managerInstance!, msg)
        }
        
        return 0
    }
    
    func processSubscribeReq(_ serviceKey: Data, _ requesterInstance: HYPInstance)
    {
        hpsSyncQueue.sync
        {
            let managerInstance = network.determineInstanceResponsibleForService(serviceKey)
            if( !HpsGenericUtils.areInstancesEqual(managerInstance!, network.ownClient!.instance))
            {
                
                os_log("%@ Another instance should be responsible for the service 0x%@: %@", log: OSLog.default, type: .info,
                       HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                       BinaryUtils.byteArrayToHexString(serviceKey),
                       HpsGenericUtils.getLogStr(fromHYPInstance: managerInstance!))
                
                return
            }
        
            var (serviceManager, _) = self.managedServices.find(serviceKey)
            if(serviceManager == nil ) // If the service does not exist we create it.
            {
                os_log("%@ Processing Subscribe request for non-existent ServiceManager 0x%@ ServiceManager will be created.",
                       log: OSLog.default, type: .info,
                       HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                       BinaryUtils.byteArrayToHexString(serviceKey))
                
                self.managedServices.add(serviceKey)
                serviceManager = self.managedServices.getLast()
            }
        
            os_log("Adding instance %@ to the list of subscribers of the service 0x%@",
                   log: OSLog.default, type: .info,
                   HpsGenericUtils.getLogStr(fromHYPInstance: requesterInstance),
                   BinaryUtils.byteArrayToHexString(serviceKey))

            serviceManager!.subscribers.add(requesterInstance)
        }
    }
    
    func processUnsubscribeReq(_ serviceKey: Data, _ requesterInstance: HYPInstance)
    {
        hpsSyncQueue.sync
        {
            let (serviceManager, _) = self.managedServices.find(serviceKey)
            
            if(serviceManager == nil) // If the service does not exist nothing is done
            {
                os_log("%@ Processing Unsubscribe request for non-existent ServiceManager 0x%@. Nothing will be done",
                       log: OSLog.default, type: .info,
                       HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                       BinaryUtils.byteArrayToHexString(serviceKey))
                
                return
            }
            
            os_log("%@ Removing instance %@ from the list of subscribers of the service 0x%@",
                   log: OSLog.default, type: .info,
                   HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                   HpsGenericUtils.getLogStr(fromHYPInstance: requesterInstance),
                   BinaryUtils.byteArrayToHexString(serviceKey))
            
            serviceManager!.subscribers.remove(requesterInstance)
            
            if(serviceManager!.subscribers.count() == 0)
            { // Remove the service if there is no subscribers
                self.managedServices.remove(serviceKey)
            }
        }
    }
    
    func processPublishReq(_ serviceKey: Data, _ msg: String)
    {
        hpsSyncQueue.sync
        {
            let (serviceManager, _) = self.managedServices.find(serviceKey)
            if(serviceManager == nil)
            {
                os_log("%@ Processing Publish request for non-existent ServiceManager 0x%@. Nothing will be done",
                       log: OSLog.default, type: .info,
                       HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                       BinaryUtils.byteArrayToHexString(serviceKey))
                
                return
            }
            
            for i in 0..<serviceManager!.subscribers.count()
            {
                let client = serviceManager?.subscribers.get(i)
                if(client == nil){
                    continue
                }
             
                if(HpsGenericUtils.areInstancesEqual(network.ownClient!.instance, client!.instance))
                {
                    os_log("%@ Publishing info from service 0x%@ to Host instance",
                           log: OSLog.default, type: .info,
                           HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                           BinaryUtils.byteArrayToHexString(serviceKey))

                    self.processInfoMsg(serviceKey, msg)
                }
                else
                {
                    os_log("%@ Publishing info from service 0x%@ to %@",
                           log: OSLog.default, type: .info,
                           HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                           BinaryUtils.byteArrayToHexString(serviceKey),
                           HpsGenericUtils.getLogStr(fromHYPInstance: client!.instance))
             
                    _ = Protocol.sendInfoMsg(serviceKey, client!.instance, msg)
                }
            }
        }
    }
    
    func processInfoMsg(_ serviceKey: Data, _ msg: String)
    {
        let (subscription, _) = ownSubscriptions.find(serviceKey)
        
        if(subscription == nil){
            os_log("%@ Info received from the unsubscribed service%@: %@",
                   log: OSLog.default, type: .info,
                   HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                   BinaryUtils.byteArrayToHexString(serviceKey),
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
        hpsSyncQueue.sync
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
                let newManagerInstance = network.determineInstanceResponsibleForService(managedService!.serviceKey)
            
                os_log("%@ Analyzing ServiceManager from service 0x%@",
                       log: OSLog.default, type: .info,
                       HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                       BinaryUtils.byteArrayToHexString(managedService!.serviceKey))
                
                if( !HpsGenericUtils.areInstancesEqual(newManagerInstance!, network.ownClient!.instance))
                {
                    os_log("%@ The service 0x%@ will be managed by %@. ServiceManager will be removed",
                           log: OSLog.default, type: .info,
                           HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                           BinaryUtils.byteArrayToHexString(managedService!.serviceKey),
                           HpsGenericUtils.getLogStr(fromHYPInstance: newManagerInstance!))
                    
                    toRemove.append((managedService?.serviceKey)!)
                }
            }
            
            for i in 0..<toRemove.count{
                self.managedServices.remove(toRemove[i])
            }
        }
    }
    
    func updateOwnSubscriptions()
    {
        hpsSyncQueue.sync
        {
             os_log("%@ Executing updateOwnSubscriptions (%@ subscriptions)",
             log: OSLog.default, type: .info,
             HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
             self.ownSubscriptions.count())
        
            for i in 0..<self.ownSubscriptions.count()
            {
                let subscription = ownSubscriptions.get(i)
        
                let newManagerInstance = network.determineInstanceResponsibleForService(subscription!.serviceKey)
        
                
                os_log("%@ Analyzing subscription ",
                       log: OSLog.default, type: .info,
                       HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                       HpsGenericUtils.getLogStr(fromSubscription: subscription!))
        
                // If there is a node with a closer key to the service key we change the manager
                if( !HpsGenericUtils.areInstancesEqual(newManagerInstance!, subscription!.manager))
                {
                    
                    os_log("%@ The manager of the subscribed service %@ has changed: %@. A new Subscribe message will be issued)",
                           log: OSLog.default, type: .info,
                           HypePubSub.HYPE_PUB_SUB_LOG_PREFIX,
                           subscription!.serviceName,
                           HpsGenericUtils.getLogStr(fromHYPInstance: newManagerInstance!))
                    
                    subscription!.manager = newManagerInstance!
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
