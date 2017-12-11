//
//  SubscriptionsList.swift
//  HypePubSub.iOS
//

import Foundation

class SubscriptionsList
{
    var subscriptions = [Subscription]()
    
    public func addSubscription(_ subscription: Subscription) -> Bool
    {
        var wasSubscriptionAdded = false
        
        SyncUtils.lock(obj: self)
        {
            if(containsSubscription(withServiceKey: subscription.serviceKey)){
                return ; // subscription already added
            }
            
            subscriptions.append(subscription);
            wasSubscriptionAdded = true
        }
        
        return wasSubscriptionAdded
    }
    
    public func removeSubscription(withServiceName name: String) -> Bool
    {
        var wasSubscriptionRemoved = false
        
        SyncUtils.lock(obj: self)
        {
            if let index = subscriptions.index(where: {$0.serviceName == name}) {
                subscriptions.remove(at: index);
                wasSubscriptionRemoved = true
            }
        }
        return wasSubscriptionRemoved
    }
    
    public func findSubscription(withServiceKey serviceKey: Data) -> Subscription?
    {
        var subscription : Subscription?
        subscription = nil
        
        SyncUtils.lock(obj: self)
        {
            if let index = subscriptions.index(where: {$0.serviceKey == serviceKey}) {
                subscription = subscriptions[index]
            }
        }
    
        return subscription
    }
    
    public func containsSubscription(withServiceKey key: Data) -> Bool
    {
        var isSubscriptionFound = false
        SyncUtils.lock(obj: self)
        {
            if (findSubscription(withServiceKey: key) != nil){
                isSubscriptionFound = true
            }
        }
        return isSubscriptionFound
    }
    
    // Methods from Array that we want to enable.
    
    public func count() -> Int
    {
        var subscriptionsCount:Int = 0
        
        SyncUtils.lock(obj: self)
        {
            subscriptionsCount = subscriptions.count;
        }
        
        return subscriptionsCount
    }
    
    public func get(_ index: Int) -> Subscription?
    {
        var subscriptionAtIndex:Subscription? = nil
        
        SyncUtils.lock(obj: self)
        {
            if (index < subscriptions.count){
                subscriptionAtIndex = subscriptions[index]
            }
        }
        
        return subscriptionAtIndex
    }
}
