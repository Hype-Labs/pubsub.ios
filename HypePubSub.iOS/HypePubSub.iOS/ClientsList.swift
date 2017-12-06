//
//  ClientsList.swift
//  HypePubSub.iOS
//

import Foundation


class ClientsList
{
    private var clients = [Client]()
    
    private let clientsListSyncQueue = DispatchQueue(label: "com.hypelabs.hypepubsub.clientslist.clientslistsyncqueue")
    
    public func add(_ instance: HYPInstance)
    {
        clientsListSyncQueue.sync
        {
            let (client, _) = find(instance)
            if(client != nil){ // do not add the client if it is already present
                return ;
            }
    
            let newClient = Client(fromHYPInstance: instance)
            clients.append(newClient);
        }
    }
    
    public func remove(_ instance: HYPInstance)
    {
        clientsListSyncQueue.sync{
            let (client, clientArrayPosition) = find(instance);
            if(client == nil){
                return;
            }
    
            clients.remove(at: clientArrayPosition);
        }
    }
    
    public func find(_ instance: HYPInstance) -> (Client?, Int)
    {
        var client:Client?
        var clientArrayPosition = -1;
        
        clientsListSyncQueue.sync{
            
            for i in 0..<clients.count
            {
                let currentClient = clients[i]
                if(HpsGenericUtils.areInstancesEqual(currentClient.instance, instance)) {
                    client = currentClient
                    clientArrayPosition = i
                    return
                }
            }
            client = nil
        }
        return (client, clientArrayPosition)
    }
    
    // Methods from Array that we want to enable.
    public func count() -> Int!
    {
        var clientsCount:Int = 0
        clientsListSyncQueue.sync{
            clientsCount = clients.count;
        }
        return clientsCount
    }
    
    public func get(_ index: Int) -> Client?
    {
        var clientAtIndex:Client? = nil
        
        clientsListSyncQueue.sync{
            if (index < clients.count){
                clientAtIndex = clients[index]
            }
        }
        
        return clientAtIndex
    }

}
