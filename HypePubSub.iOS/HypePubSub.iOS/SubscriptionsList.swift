//
//  SubscriptionsList.swift
//  HypePubSub.iOS
//

import Foundation

class SubscriptionsList
{
    var subscriptions = [Subscription]()
    
    /*
    private SubscriptionsAdapter subscriptionsAdapter = null;
    
    public synchronized int add(String serviceName, Instance managerInstance) throws NoSuchAlgorithmException
{
    MessageDigest md = MessageDigest.getInstance(HpsConstants.HASH_ALGORITHM);
    byte serviceKey[] = md.digest(serviceName.getBytes());
    
    if(find(serviceKey) != null) {
    return -1;
    }
    
    subscriptions.add(new Subscription(serviceName, managerInstance));
    return 0;
    }
    
    public synchronized int remove(String serviceName) throws NoSuchAlgorithmException
{
    MessageDigest md = MessageDigest.getInstance(HpsConstants.HASH_ALGORITHM);
    byte serviceKey[] = md.digest(serviceName.getBytes());
    
    Subscription subscription = find(serviceKey);
    if(subscription == null) {
    return -1;
    }
    
    subscriptions.remove(subscription);
    return 0;
    }
    
    public synchronized Subscription find(byte serviceKey[])
{
    ListIterator<Subscription> it = listIterator();
    while(it.hasNext())
    {
    Subscription currentSubs = it.next();
    if(Arrays.equals(currentSubs.serviceKey, serviceKey)) {
    return currentSubs;
    }
    }
    return null;
    }
    
    // Methods from LinkedList that we want to enable.
    public synchronized ListIterator<Subscription> listIterator()
{
    return subscriptions.listIterator();
    }
    
    public synchronized int size()
{
    return subscriptions.size();
    }
    
    public synchronized Subscription get(int index)
{
    return subscriptions.get(index);
    }
    
    public synchronized SubscriptionsAdapter getSubscriptionsAdapter(Context context)
{
    if(subscriptionsAdapter == null){
    subscriptionsAdapter = new SubscriptionsAdapter(context, subscriptions);
    }
    
    return  subscriptionsAdapter;
    }
    */
}
