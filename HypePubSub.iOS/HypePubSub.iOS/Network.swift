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
    
    static func getInstance() -> Network
    {
        return network;
    }
    
    init()
    {
        self.ownClient = nil
        self.networkClients = ClientsList()
    }
    
    internal func determineInstanceResponsibleForService(serviceKey: Data) -> HYPInstance?
    {
        let managerInstance = ownClient?.instance
        
        /*
        Data lowestDist = BinaryUtils.xor(serviceKey, ownClient.key);

        synchronized (network) // Add thread safety to iteration procedure
        {
            ListIterator<Client> it = networkClients.listIterator();
            while (it.hasNext())
            {
                Client client = it.next();

                byte dist[] = BinaryUtils.xor(serviceKey, client.key);
                if (BinaryUtils.getHigherByteArray(lowestDist, dist) == 1)
                {
                    lowestDist = dist;
                    managerInstance = client.instance;
                }
            }
        }
        */
        return managerInstance
    }
    
    internal func setOwnClient(ownInstance: HYPInstance)
    {
        self.ownClient = Client(instance: ownInstance)
    }
}
