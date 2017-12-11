//
//  Network.swift
//  HypePubSub.iOS
//

import Foundation

class Network
{
    // Members
    var ownClient: Client?
    var networkClients: ClientsList
    
    private static let network = Network() // Early loading to avoid thread-safety issues
    static func getInstance() -> Network
    {
        return network;
    }
    
    init()
    {
        self.ownClient = nil
        self.networkClients = ClientsList()
    }
    
    internal func determineClientResponsibleForService(withKey serviceKey: Data) -> Client!
    {
        var managerClient = ownClient // if no clients were found in the network, the own client if the one responsible for the service
        var lowestDist = BinaryUtils.xor(data1: serviceKey, data2: ownClient!.key);

        SyncUtils.lock(obj: self) // Add thread safety to iteration procedure
        {
            for i in 0..<networkClients.count()
            {
                let currentClient = networkClients.get(i)!;
                let dist = BinaryUtils.xor(data1: serviceKey, data2: currentClient.key);
                
                if (BinaryUtils.determineHigherBigEndianData(data1: lowestDist!, data2: dist!) == 1)
                {
                    lowestDist = dist;
                    managerClient = currentClient;
                }
            }
        }

        return managerClient
    }
    
    internal func setOwnClient(hostInstance: HYPInstance)
    {
        self.ownClient = Client(fromHYPInstance: hostInstance)
    }
}
