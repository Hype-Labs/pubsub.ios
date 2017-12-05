//
//  ServiceManagersList.swift
//  HypePubSub.iOS
//

import Foundation

public class ServiceManagersList
{
    private var serviceManagers = [ServiceManager]()
    
    private let serviceManagersListSyncQueue = DispatchQueue(label: "com.hypelabs.hypepubsub.clientslist.servicemanagerslistsyncqueue")
    
    public func add(serviceKey: Data)
    {
        serviceManagersListSyncQueue.sync
        {
            let (managedService, _) = find(serviceKey)
            if(managedService != nil){ // do not add the client if it is already present
                return ;
            }
            
            serviceManagers.append(ServiceManager(serviceKey));
        }
    }
    
    func remove(serviceKey: Data)
    {
        serviceManagersListSyncQueue.sync
        {
            let (managedService, managedServiceArrayPosition) = find(serviceKey);
            if(managedService == nil){
                return;
            }
            
            serviceManagers.remove(at: managedServiceArrayPosition);
        }
    }
    
    func find(_ serviceKey: Data)-> (ServiceManager?, Int)
    {
        var managedService:ServiceManager?
        var managedServiceArrayPosition = -1;
        
        serviceManagersListSyncQueue.sync
        {
            for i in 0..<serviceManagers.count
            {
                let currentManagedService = serviceManagers[i]
                if(currentManagedService.serviceKey == serviceKey)
                {
                    managedService = currentManagedService
                    managedServiceArrayPosition = i
                    return
                }
            }
            managedService = nil
        }
        return (managedService, managedServiceArrayPosition)
    }
    
    // Methods from Array that we want to enable.
    
    func get(index: Int) -> ServiceManager?
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

