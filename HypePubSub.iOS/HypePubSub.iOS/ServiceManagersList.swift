
import Foundation

public class ServiceManagersList
{
    private var serviceManagers = [ServiceManager]()
    
    func addServiceManager(_ serviceManager: ServiceManager) -> Bool
    {
        var wasServiceManagerAdded = false
        
        SyncUtils.lock(obj: self)
        {
            if(containsServiceManager(withKey: serviceManager.serviceKey)){
                return ;
            }
            
            serviceManagers.append(serviceManager);
            wasServiceManagerAdded = true
        }
        return wasServiceManagerAdded
    }
    
    func removeServiceManager(withKey serviceKey: Data) -> Bool
    {
        var wasServiceManagerRemoved = false
        
        SyncUtils.lock(obj: self)
        {
            if let index = serviceManagers.index(where: {$0.serviceKey == serviceKey}) {
                serviceManagers.remove(at: index);
                wasServiceManagerRemoved = true
            }
        }
        
        return wasServiceManagerRemoved
    }
    
    func findServiceManager(withKey serviceKey: Data)-> ServiceManager?
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
    
    public func containsServiceManager(withKey key: Data) -> Bool
    {
        var isServiceManagerFound = false
        SyncUtils.lock(obj: self)
        {
            if (findServiceManager(withKey: key) != nil){
                isServiceManagerFound = true
            }
        }
        return isServiceManagerFound
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

