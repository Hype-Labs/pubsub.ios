
import Foundation

class ClientsList
{
    private var clients = [Client]()
    
    public func addClient(_ client: Client) -> Bool
    {
        var wasClientAdded = false
        SyncUtils.lock(obj: self)
        {
            if(containsClient(withHYPInstance: client.instance)){
                return;
            }
    
            clients.append(client);
            wasClientAdded = true
        }
        return wasClientAdded
    }
    
    public func removeClient(withHYPInstance instance: HYPInstance) -> Bool
    {
        var wasClientRemoved = false
        SyncUtils.lock(obj: self)
        {
            if let index = clients.index(where: {$0.instance.identifier == instance.identifier}) {
                clients.remove(at: index);
                wasClientRemoved = true
            }
        }
        return wasClientRemoved
    }
    
    public func findClient(withHYPInstance instance: HYPInstance) -> Client?
    {
        var clientFound : Client?
        clientFound = nil
        
        SyncUtils.lock(obj: self)
        {
            if let index = clients.index(where: {$0.instance.identifier == instance.identifier}) {
                clientFound = clients[index]
            }
        }
        
        return clientFound
    }
    
    public func containsClient(withHYPInstance instance: HYPInstance) -> Bool
    {
        var isClientFound = false
        SyncUtils.lock(obj: self)
        {
            if (findClient(withHYPInstance: instance) != nil){
                isClientFound = true
            }
        }
        return isClientFound
    }
    
    // Methods from Array that we want to enable.
    public func count() -> Int!
    {
        var clientsCount:Int = 0
        SyncUtils.lock(obj: self){
            clientsCount = clients.count;
        }
        return clientsCount
    }
    
    public func get(_ index: Int) -> Client?
    {
        var clientAtIndex:Client? = nil
        
        SyncUtils.lock(obj: self){
            if (index < clients.count){
                clientAtIndex = clients[index]
            }
        }
        
        return clientAtIndex
    }

}
