//
//  ServiceManagersList.swift
//  HypePubSub.iOS
//

import Foundation

public class ServiceManagersList
{
    private var serviceManagers = [ServiceManager]()
    
    private let serviceManagersListSyncQueue = DispatchQueue(label: "com.hypelabs.hypepubsub.clientslist.servicemanagerslistsyncqueue")
    
    func add(serviceManager: ServiceManager)
    {
        serviceManagersListSyncQueue.sync
        {
            if(find(withKey: serviceManager.serviceKey) != nil){
                return ; // ServiceManager already added
            }
            
            serviceManagers.append(serviceManager);
        }
    }
    
    func remove(withKey serviceKey: Data)
    {
        serviceManagersListSyncQueue.sync
        {
            if let index = serviceManagers.index(where: {$0.serviceKey == serviceKey}) {
                serviceManagers.remove(at: index);
            }
        }
    }
    
    func find(withKey serviceKey: Data)-> ServiceManager?
    {
        var managedService:ServiceManager?
        managedService = nil
        
        serviceManagersListSyncQueue.sync
        {
            if let index = serviceManagers.index(where: {$0.serviceKey == serviceKey}) {
                managedService = serviceManagers[index]
            }
        }
        
        return managedService
    }
    
    // Methods from Array that we want to enable.
    
    func count() -> Int!
    {
        var serviceManagersCount:Int = 0
        serviceManagersListSyncQueue.sync{
            serviceManagersCount = serviceManagers.count;
        }
        return serviceManagersCount
    }
    
    func get(_ index: Int) -> ServiceManager?
    {
        var managedServiceAtIndex:ServiceManager? = nil
        
        serviceManagersListSyncQueue.sync
        {
            if (index < serviceManagers.count){
                managedServiceAtIndex = serviceManagers[index]
            }
        }
        
        return managedServiceAtIndex
    }
    
    func getLast() -> ServiceManager?
    {
        return serviceManagers.last
    }
}

