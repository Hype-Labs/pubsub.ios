//
//  ClientsList.swift
//  HypePubSub.iOS
//

import Foundation


class ClientsList
{
    private var clients = [Client]()
    
    public func add(client: Client)
    {
        SyncUtils.lock(obj: self)
        {
            if(find(client: client) != nil){
                return ; // Client already added
            }
    
            clients.append(client);
        }
    }
    
    public func remove(client: Client)
    {
        SyncUtils.lock(obj: self)
        {
            if let index = clients.index(where: {$0.key == client.key}) {
                clients.remove(at: index);
            }
        }
    }
    
    public func find(client: Client) -> Client?
    {
        var clientFound : Client?
        clientFound = nil
        
        SyncUtils.lock(obj: self)
        {
            if let index = clients.index(where: {$0.key == client.key}) {
                clientFound = clients[index]
            }
        }
        
        return clientFound
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
