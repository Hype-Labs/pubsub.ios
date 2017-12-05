//
//  HypeSdkInterface.swift
//  HypePubSub.iOS
//

import Foundation
import UIKit
import os

class HypeSdkInterface: NSObject, HYPStateObserver, HYPNetworkObserver, HYPMessageObserver
{
    let HYPE_SDK_INTERFACE_LOG_PREFIX = HpbConstants.LOG_PREFIX + "<HypeSdkInterface> ";
    let network:Network = Network.getInstance()
    
    static private let hypeSdk = HypeSdkInterface() // Early loading to avoid thread-safety issues
    
    ///////////////////////////////////////////////////////////////////////////////////////////
    // Methods
    ///////////////////////////////////////////////////////////////////////////////////////////
    
    static func getInstance() -> HypeSdkInterface{
        return hypeSdk;
    }
    
    internal func requestHypeToStart()
    {
        HYP.setUserIdentifier(0);
        HYP.setAppIdentifier(HpbConstants.APP_IDENTIFIER);
        HYP.setAnnouncement(UIDevice.current.name.data(using: HpbConstants.ENCODING_STANDARD))
        HYP.add(self as HYPStateObserver)
        HYP.add(self as HYPNetworkObserver)
        HYP.add(self as HYPMessageObserver)
        HYP.start();
        
        os_log("%@ Requested Hype SDK start.", log: OSLog.default, type: .info, HYPE_SDK_INTERFACE_LOG_PREFIX)
    }
    
    internal func requestHypeToStop()
    {
        HYP.stop();
        os_log("%@ Requested Hype SDK stop.", log: OSLog.default, type: .info, HYPE_SDK_INTERFACE_LOG_PREFIX)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////
    //  HYPStateObserver methods
    ///////////////////////////////////////////////////////////////////////////////////////////
    
    func hypeDidStart()
    {
        os_log("%@ Hype SDK started! Host Instance: %@", log: OSLog.default, type: .info,
               HYPE_SDK_INTERFACE_LOG_PREFIX,
               HpbGenericUtils.getInstanceLogIdStr(HYP.hostInstance()))
        
        network.setOwnClient(ownInstance: HYP.hostInstance())
    }
    
    func hypeDidStopWithError(_ error: HYPError)
    {
        os_log("%@ Hype SDK stopped with error. Error description: %@", log: OSLog.default, type: .error,
               HYPE_SDK_INTERFACE_LOG_PREFIX,
               error.description)
    }
    
    func hypeDidFailStartingWithError(_ error: HYPError)
    {
        os_log("%@ Hype SDK start failed. Suggestion %@", log: OSLog.default, type: .error,
               HYPE_SDK_INTERFACE_LOG_PREFIX, error.suggestion)
        os_log("%@ Hype SDK start failed. Description %@", log: OSLog.default, type: .error,
               HYPE_SDK_INTERFACE_LOG_PREFIX, error.description)
        os_log("%@ Hype SDK start failed. Reason %@", log: OSLog.default, type: .error,
               HYPE_SDK_INTERFACE_LOG_PREFIX, error.reason)
    }
    
    func hypeDidBecomeReady()
    {
        os_log("%@ Hype SDK is ready", log: OSLog.default, type: .info,
               HYPE_SDK_INTERFACE_LOG_PREFIX)
    }
    
    func hypeDidChangeState()
    {
        os_log("%@ Hype SDK state has changed to %@", log: OSLog.default, type: .info,
               HYPE_SDK_INTERFACE_LOG_PREFIX,
               HYP.state().rawValue)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////
    //  HYPNetworkObserver methods
    ///////////////////////////////////////////////////////////////////////////////////////////
    
    func hypeDidFind(_ instance: HYPInstance)
    {
        let instanceLogIdStr = HpbGenericUtils.getInstanceLogIdStr(instance)
        
        if(!instance.isResolved)
        {
            os_log("%@ Hype SDK unresolved instance found: %@", log: OSLog.default, type: .info,
                   HYPE_SDK_INTERFACE_LOG_PREFIX, instanceLogIdStr)
            os_log("%@ Resolving Hype SDK instance: %@", log: OSLog.default, type: .info,
                   HYPE_SDK_INTERFACE_LOG_PREFIX, instanceLogIdStr)
            HYP.resolve(instance);
        }
        else
        {
            os_log("%@ Hype SDK resolved instance found: %@", log: OSLog.default, type: .info,
                   HYPE_SDK_INTERFACE_LOG_PREFIX, instanceLogIdStr)
            
            /*
            // Add the instance found in a separate thread to release the lock of the
            // Hype instance object preventing possible deadlock
            final Instance instanceFound = var1;
            Thread t = new Thread(new Runnable() {
                @Override
                public void run() {
                    addInstanceAlreadyResolved(instanceFound);
                }
            });
            t.start();
             */
        }
    }
    
    func hypeDidLose(_ instance: HYPInstance, error: HYPError)
    {
        os_log("%@ Hype SDK instance lost: %@", log: OSLog.default, type: .info,
               HYPE_SDK_INTERFACE_LOG_PREFIX, HpbGenericUtils.getInstanceLogIdStr(instance))
        
        /*
        // Remove the instance lost in a separate thread to release the lock of the
        // Hype instance object preventing possible deadlock
        final Instance instanceToRemove = var1;
        Thread t = new Thread(new Runnable() {
            @Override
            public void run() {
                try
            {
                removeInstance(instanceToRemove);
                } catch (IOException e)
                {
                e.printStackTrace();
                } catch (NoSuchAlgorithmException e)
                {
                e.printStackTrace();
                }
            }
        });
        t.start();
         */
    }
    
    func hypeDidResolve(_ instance: HYPInstance)
    {
        os_log("%@ Hype SDK instance resolved: %@", log: OSLog.default, type: .info,
               HYPE_SDK_INTERFACE_LOG_PREFIX, HpbGenericUtils.getInstanceLogIdStr(instance))
        /*
        // Add instance in a separate thread to prevent deadlock
        final Instance instanceFound = var1;
        Thread t = new Thread(new Runnable() {
            @Override
            public void run() {
                addInstanceAlreadyResolved(instanceFound);
            }
        });
        t.start();
         */
    }
    
    func hypeDidFailResolving(_ instance: HYPInstance, error: HYPError)
    {
        os_log("%@ Hype SDK instance fail resolving: %@", log: OSLog.default, type: .info,
               HYPE_SDK_INTERFACE_LOG_PREFIX, HpbGenericUtils.getInstanceLogIdStr(instance))
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////
    //  HYPMessageObserver methods
    ///////////////////////////////////////////////////////////////////////////////////////////

    func hypeDidReceive(_ message: HYPMessage!, from fromInstance: HYPInstance!) {
        
    }

    
    func hypeDidFailSendingMessage(_ messageInfo: HYPMessageInfo, to toInstance: HYPInstance, error: HYPError)
    {
        os_log("%@ Hype SDK message failed sending to: %@", log: OSLog.default, type: .info,
               HYPE_SDK_INTERFACE_LOG_PREFIX, HpbGenericUtils.getInstanceLogIdStr(toInstance))
        os_log("%@ Hype SDK message failed sending error. Suggestion: %@", log: OSLog.default, type: .info,
               HYPE_SDK_INTERFACE_LOG_PREFIX, error.suggestion)
        os_log("%@ Hype SDK message failed sending error. Description: %@", log: OSLog.default, type: .info,
               HYPE_SDK_INTERFACE_LOG_PREFIX, error.description)
        os_log("%@ Hype SDK message failed sending error. Reason: %@", log: OSLog.default, type: .info,
               HYPE_SDK_INTERFACE_LOG_PREFIX, error.reason)
    }
    
    func hypeDidSendMessage(_ messageInfo: HYPMessageInfo, to toInstance: HYPInstance, progress: Float, complete: Bool)
    {
        if(!complete) {
            os_log("%@ Hype SDK message %@ sendinf percentage %@", log: OSLog.default, type: .info,
                   HYPE_SDK_INTERFACE_LOG_PREFIX, messageInfo.identifier, (progress*100))
        }
        else {
            os_log("%@ Hype SDK message %@ fully sent", log: OSLog.default, type: .info,
                   HYPE_SDK_INTERFACE_LOG_PREFIX, messageInfo.identifier)
        }
    }
    
    func hypeDidDeliverMessage(_ messageInfo: HYPMessageInfo, to toInstance: HYPInstance, progress: Float, complete: Bool)
    {
        if(!complete) {
            os_log("%@ Hype SDK message %@ delivered percentage %@", log: OSLog.default, type: .info,
                   HYPE_SDK_INTERFACE_LOG_PREFIX, messageInfo.identifier, (progress*100))
        }
        else {
            os_log("%@ Hype SDK message %@ fully delivered", log: OSLog.default, type: .info,
                   HYPE_SDK_INTERFACE_LOG_PREFIX, messageInfo.identifier)
        }
    }
}
