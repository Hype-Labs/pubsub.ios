//
//  SubscriptionsList.swift
//  HypePubSub.iOS
//

import Foundation

class SubscriptionsList
{
    var subscriptions = [Subscription]()
    
    private let subscriptionsListSyncQueue = DispatchQueue(label: "com.hypelabs.hypepubsub.clientslist.subscriptionslistsyncqueue")
    
    public func add(subscription: Subscription)
    {
        subscriptionsListSyncQueue.sync
        {
            if(find(withKey: subscription.serviceKey) != nil){
                return ; // subscription already added
            }
            
            subscriptions.append(subscription);
        }
    }
    
    public func remove(subscription: Subscription)
    {
        subscriptionsListSyncQueue.sync
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
        
        subscriptionsListSyncQueue.sync
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
