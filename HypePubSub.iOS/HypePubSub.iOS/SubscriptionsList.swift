//
//  SubscriptionsList.swift
//  HypePubSub.iOS
//

import Foundation

class SubscriptionsList
{
    var subscriptions = [Subscription]()
    
    public func add(subscription: Subscription)
    {
        SyncUtils.lock(obj: self)
        {
            if(find(withKey: subscription.serviceKey) != nil){
                return ; // subscription already added
            }
            
            subscriptions.append(subscription);
        }
    }
    
    public func remove(subscription: Subscription)
    {
        SyncUtils.lock(obj: self)
        {
            if let index = subscriptions.index(where: {$0.serviceKey == subscription.serviceKey}) {
                subscriptions.remove(at: index);
            }
        }
    }
    
    public func find(withKey serviceKey: Data) -> Subscription?
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
