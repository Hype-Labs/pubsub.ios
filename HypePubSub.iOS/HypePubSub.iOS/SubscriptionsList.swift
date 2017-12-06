//
//  SubscriptionsList.swift
//  HypePubSub.iOS
//

import Foundation

class SubscriptionsList
{
    var subscriptions = [Subscription]()
    
    private let subscriptionsListSyncQueue = DispatchQueue(label: "com.hypelabs.hypepubsub.clientslist.subscriptionslistsyncqueue")
    
    public func add(_ serviceName: String, _ managerInstance: HYPInstance)
    {
        let serviceKey = HpsGenericUtils.hash(ofString: serviceName)
        subscriptionsListSyncQueue.sync
        {
            let (subscription, _) = find(serviceKey)
            if(subscription != nil){ // do not add the client if it is already present
                return ;
            }
            
            subscriptions.append(Subscription(serviceName, managerInstance));
        }
    }
    
    public func remove(_ serviceName: String)
    {
        let serviceKey = HpsGenericUtils.hash(ofString: serviceName)
        subscriptionsListSyncQueue.sync
        {
            let (subscription, subscriptionArrayPosition) = find(serviceKey);
            if(subscription == nil){
                return;
            }
        
            subscriptions.remove(at: subscriptionArrayPosition);
        }
    }
    
    public func find(_ serviceKey: Data) -> (Subscription?, Int)
    {
        var subscription:Subscription?
        var subscriptionArrayPosition = -1;
        
        subscriptionsListSyncQueue.sync
        {
            for i in 0..<subscriptions.count
            {
                let currentSubscription = subscriptions[i]
                if(currentSubscription.serviceKey == serviceKey)
                {
                    subscription = currentSubscription
                    subscriptionArrayPosition = i
                    return
                }
            }
            subscription = nil
        }
        return (subscription, subscriptionArrayPosition)
    }
    
    // Methods from Array that we want to enable.
    
    public func count() -> Int
    {
        var subscriptionsCount:Int = 0
        subscriptionsListSyncQueue.sync{
            subscriptionsCount = subscriptions.count;
        }
        return subscriptionsCount
    }
    
    public func get(_ index: Int) -> Subscription?
    {
        var subscriptionAtIndex:Subscription? = nil
        
        subscriptionsListSyncQueue.sync{
            if (index < subscriptions.count){
                subscriptionAtIndex = subscriptions[index]
            }
        }
        
        return subscriptionAtIndex
    }
    
}
