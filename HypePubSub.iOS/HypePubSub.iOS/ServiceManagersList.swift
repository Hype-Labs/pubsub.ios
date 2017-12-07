//
//  ServiceManagersList.swift
//  HypePubSub.iOS
//

import Foundation

public class ServiceManagersList
{
    private var serviceManagers = [ServiceManager]()
    
    func add(serviceManager: ServiceManager)
    {
        SyncUtils.lock(obj: self)
        {
            if(find(withKey: serviceManager.serviceKey) != nil){
                return ; // ServiceManager already added
            }
            
            serviceManagers.append(serviceManager);
        }
    }
    
    func remove(withKey serviceKey: Data)
    {
        SyncUtils.lock(obj: self)
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
        
        SyncUtils.lock(obj: self)
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
        
        SyncUtils.lock(obj: self){
            serviceManagersCount = serviceManagers.count;
        }
        
        return serviceManagersCount
    }
    
    func get(_ index: Int) -> ServiceManager?
    {
        var managedServiceAtIndex:ServiceManager? = nil
        
        SyncUtils.lock(obj: self)
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

