
import Foundation
import UIKit
import NotificationCenter

class HypeSdkInterface: NSObject, HYPStateObserver, HYPNetworkObserver, HYPMessageObserver
{
    // Members
    var hasHypeStarted = false
    var hasHypeFailed = false
    var hasHypeStopped = false
    var hypeFailedMsg = ""
    var hypeStoppedMsg = ""
    
    // Private
    private let HYPE_SDK_INTERFACE_LOG_PREFIX = HpsConstants.LOG_PREFIX + "<HypeSdkInterface> "
    private let network:Network = Network.getInstance()
    private let hps:HypePubSub = HypePubSub.getInstance()
    
    private static let hypeSdk = HypeSdkInterface() // Early loading to avoid thread-safety issues
    static func getInstance() -> HypeSdkInterface{
        return hypeSdk
    }
    
    internal func requestHypeToStart()
    {
        HYP.setAppIdentifier(HpsConstants.APP_IDENTIFIER)
        HYP.setAnnouncement(UIDevice.current.name.data(using: HpsConstants.ENCODING_STANDARD))
        HYP.add(self as HYPStateObserver)
        HYP.add(self as HYPNetworkObserver)
        HYP.add(self as HYPMessageObserver)
        HYP.start()

        LogUtils.log(prefix: HYPE_SDK_INTERFACE_LOG_PREFIX, logMsg: "Requested Hype SDK start.")
    }
    
    internal func requestHypeToStop()
    {
        HYP.stop()
        LogUtils.log(prefix: HYPE_SDK_INTERFACE_LOG_PREFIX, logMsg: "Requested Hype SDK stop.")
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////
    //  HYPStateObserver methods
    ///////////////////////////////////////////////////////////////////////////////////////////
    
    func hypeDidStart()
    {
        LogUtils.log(prefix: HYPE_SDK_INTERFACE_LOG_PREFIX,
                     logMsg: String(format: "Hype SDK started! Host Instance: %@",
                                    HpsGenericUtils.getLogStr(fromHYPInstance: HYP.hostInstance())))
        hasHypeStarted = true
        network.setOwnClient(hostInstance: HYP.hostInstance())
    }
    
    func hypeDidStopWithError(_ error: HYPError)
    {
        hasHypeStopped = true
        hypeStoppedMsg = String(format: "Suggestion: %@\nDescription: %@\nReason: %@",
                               error.suggestion, error.description, error.reason)
        
        LogUtils.log(prefix: HYPE_SDK_INTERFACE_LOG_PREFIX,
                     logMsg: String(format: "Hype SDK stopped with error. Error description: %@", error.description))
    }
    
    func hypeDidFailStartingWithError(_ error: HYPError)
    {
        hasHypeFailed = true
        hypeFailedMsg = String(format: "Suggestion: %@\nDescription: %@\nReason: %@",
                                    error.suggestion, error.description, error.reason)
        
        LogUtils.log(prefix: HYPE_SDK_INTERFACE_LOG_PREFIX,
                     logMsg: String(format: "Hype SDK start failed. Suggestion: %@", error.suggestion))
        LogUtils.log(prefix: HYPE_SDK_INTERFACE_LOG_PREFIX,
                     logMsg: String(format: "Hype SDK start failed. Description: %@", error.description))
        LogUtils.log(prefix: HYPE_SDK_INTERFACE_LOG_PREFIX,
                     logMsg: String(format: "Hype SDK start failed. Reason: %@", error.reason))
    }
    
    func hypeDidBecomeReady()
    {
        LogUtils.log(prefix: HYPE_SDK_INTERFACE_LOG_PREFIX,
                     logMsg: "Hype SDK is ready")
    }
    
    func hypeDidChangeState()
    {
        LogUtils.log(prefix: HYPE_SDK_INTERFACE_LOG_PREFIX,
                     logMsg: String(format: "Hype SDK state has changed to %i", HYP.state().rawValue))
    }
    
    func hypeDidRequestAccessToken(withUserIdentifier userIdentifier: UInt) -> String!
    {
        return "3f07c41b53c9e753ca8d610b4147e3"
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////
    //  HYPNetworkObserver methods
    ///////////////////////////////////////////////////////////////////////////////////////////
    
    func hypeDidFind(_ instance: HYPInstance)
    {
        let instanceLogIdStr = HpsGenericUtils.getLogStr(fromHYPInstance: instance)
        
        if(!instance.isResolved)
        {
            LogUtils.log(prefix: HYPE_SDK_INTERFACE_LOG_PREFIX,
                         logMsg: String(format: "Hype SDK unresolved instance found: %@", instanceLogIdStr))
            LogUtils.log(prefix: HYPE_SDK_INTERFACE_LOG_PREFIX,
                         logMsg: String(format: "Resolving Hype SDK instance: %@", instanceLogIdStr))
            HYP.resolve(instance)
        }
        else
        {
            LogUtils.log(prefix: HYPE_SDK_INTERFACE_LOG_PREFIX,
                         logMsg: String(format: "Hype SDK resolved instance found: %@", instanceLogIdStr))
            
            // Add the instance found in a separate thread to release the lock of the
            // Hype instance object preventing possible deadlock
            DispatchQueue.global().async {
                self.addInstanceAlreadyResolved(instance: instance)
            }
        }
    }
    
    func hypeDidLose(_ instance: HYPInstance, error: HYPError)
    {
        LogUtils.log(prefix: HYPE_SDK_INTERFACE_LOG_PREFIX,
                     logMsg: String(format: "Hype SDK instance lost: %@", HpsGenericUtils.getLogStr(fromHYPInstance: instance)))
        
        // Remove the instance lost in a separate thread to release the lock of the
        // Hype instance object preventing possible deadlock
        DispatchQueue.global().async {
            self.removeInstanceLost(instance: instance)
        }
    }
    
    func hypeDidResolve(_ instance: HYPInstance)
    {
        LogUtils.log(prefix: HYPE_SDK_INTERFACE_LOG_PREFIX,
                     logMsg: String(format: "Hype SDK instance resolved: %@", HpsGenericUtils.getLogStr(fromHYPInstance: instance)))
        
        // Add instance in a separate thread to prevent deadlock
        DispatchQueue.global().async {
            self.addInstanceAlreadyResolved(instance: instance)
        }
    }
    
    func hypeDidFailResolving(_ instance: HYPInstance, error: HYPError)
    {
        LogUtils.log(prefix: HYPE_SDK_INTERFACE_LOG_PREFIX,
                     logMsg: String(format: "Hype SDK instance fail resolving: %@", HpsGenericUtils.getLogStr(fromHYPInstance: instance)))
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////
    //  HYPMessageObserver methods
    ///////////////////////////////////////////////////////////////////////////////////////////

    func hypeDidReceive(_ message: HYPMessage!, from fromInstance: HYPInstance!)
    {
        // Add instance in a separate thread to prevent deadlock
        DispatchQueue.global().async {
            _ = Protocol.receiveMsg(originInstance: fromInstance, packet: message.data)
        }
    }
    
    func hypeDidFailSendingMessage(_ messageInfo: HYPMessageInfo, to toInstance: HYPInstance, error: HYPError)
    {
        LogUtils.log(prefix: HYPE_SDK_INTERFACE_LOG_PREFIX,
                     logMsg: String(format: "Hype SDK message failed sending to: %@", HpsGenericUtils.getLogStr(fromHYPInstance: toInstance)))
        LogUtils.log(prefix: HYPE_SDK_INTERFACE_LOG_PREFIX,
                     logMsg: String(format: "Hype SDK message failed sending error. Suggestion: %@", error.suggestion))
        LogUtils.log(prefix: HYPE_SDK_INTERFACE_LOG_PREFIX,
                     logMsg: String(format: "Hype SDK message failed sending error. Description: %@", error.description))
        LogUtils.log(prefix: HYPE_SDK_INTERFACE_LOG_PREFIX,
                     logMsg: String(format: "Hype SDK message failed sending error. Reason: %@", error.reason))
    }
    
    func hypeDidSendMessage(_ messageInfo: HYPMessageInfo, to toInstance: HYPInstance, progress: Float, complete: Bool)
    {
        if(!complete) {
            LogUtils.log(prefix: HYPE_SDK_INTERFACE_LOG_PREFIX,
                         logMsg: String(format: "Hype SDK message %i sending percentage: %i%", messageInfo.identifier, progress*100))
        }
        else {
            LogUtils.log(prefix: HYPE_SDK_INTERFACE_LOG_PREFIX,
                         logMsg: String(format: "Hype SDK message %i fully sent", messageInfo.identifier))
        }
    }
    
    func hypeDidDeliverMessage(_ messageInfo: HYPMessageInfo, to toInstance: HYPInstance, progress: Float, complete: Bool)
    {
        if(!complete) {
            LogUtils.log(prefix: HYPE_SDK_INTERFACE_LOG_PREFIX,
                         logMsg: String(format: "Hype SDK message %i delivered percentage: %i%", messageInfo.identifier, progress*100))
        }
        else {
            LogUtils.log(prefix: HYPE_SDK_INTERFACE_LOG_PREFIX,
                         logMsg: String(format: "Hype SDK message %i fully delivered", messageInfo.identifier))
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////
    // Add and Remove Instances on Founds, Resolved and Losts
    ///////////////////////////////////////////////////////////////////////////////////////////
    
    func addInstanceAlreadyResolved(instance: HYPInstance)
    {
        LogUtils.log(prefix: HYPE_SDK_INTERFACE_LOG_PREFIX,
                     logMsg: String(format: "Adding Hype SDK instance already resolved: %@", HpsGenericUtils.getLogStr(fromHYPInstance: instance)))
        
        SyncUtils.lock(obj: network.networkClients) // Add thread safety to adding procedure
        {
            _ = network.networkClients.addClient(Client(fromHYPInstance: instance))
            hps.updateManagedServices()
            hps.updateOwnSubscriptions()
            updateClientsUI()
        }
    }
    
    func removeInstanceLost(instance: HYPInstance)
    {
        LogUtils.log(prefix: HYPE_SDK_INTERFACE_LOG_PREFIX,
                     logMsg: String(format: "Removing Hype SDK instance already lost: %@", HpsGenericUtils.getLogStr(fromHYPInstance: instance)))

        SyncUtils.lock(obj: network.networkClients) // Add thread safety to removal procedure
        {
            _ = network.networkClients.removeClient(withHYPInstance: instance)
            hps.removeSubscriptionsFromLostInstance(fromHYPInstance: instance)
            hps.updateOwnSubscriptions()
            updateClientsUI()
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////
    // Calls to Hype Send
    ///////////////////////////////////////////////////////////////////////////////////////////
    
    func sendMsg(_ hpsMsg: HpsMessage, _ destInstance: HYPInstance)
    {
        let sdkMsg = HYP.send(hpsMsg.toByteArray(), to: destInstance, trackProgress: true)
        LogUtils.log(prefix: HYPE_SDK_INTERFACE_LOG_PREFIX,
                     logMsg: String(format: "Hype SDK sent message with ID: %i", sdkMsg!.identifier))
    }
    
    //////////////////////////////////////////////////////////////////////////////
    // UI methods
    //////////////////////////////////////////////////////////////////////////////
    
    private func updateClientsUI()
    {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: HpsConstants.NOTIFICATION_CLIENTS_VIEW_CONTROLLER), object: nil, userInfo: nil)
    }
}
