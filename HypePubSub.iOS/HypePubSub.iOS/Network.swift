//
//  Network.swift
//  HypePubSub.iOS
//

import Foundation

class Network
{
    private static let network = Network() // Early loading to avoid thread-safety issues
    
    var ownClient: Client?
    var networkClients: ClientsList
    
    let networkSyncQueue = DispatchQueue(label: "com.hypelabs.hypepubsub.clientslist.networksyncqueue")
    
    static func getInstance() -> Network
    {
        return network;
    }
    
    init()
    {
        self.ownClient = nil
        self.networkClients = ClientsList()
    }
    
    internal func determineInstanceResponsibleForService(_ serviceKey: Data) -> HYPInstance?
    {
        var managerInstance = ownClient?.instance
        var lowestDist = BinaryUtils.xor(serviceKey, ownClient!.key);

        networkSyncQueue.sync // Add thread safety to iteration procedure
        {
            for i in 0..<networkClients.count()
            {
                let client = networkClients.get(i);

                let dist = BinaryUtils.xor(serviceKey, client!.key);
                if (BinaryUtils.getHigherByteArray(lowestDist!, dist!) == 1)
                {
                    lowestDist = dist;
                    managerInstance = client!.instance;
                }
            }
        }

        return managerInstance
    }
    
    internal func setOwnClient(ownInstance: HYPInstance)
    {
        self.ownClient = Client(ownInstance)
    }
}
