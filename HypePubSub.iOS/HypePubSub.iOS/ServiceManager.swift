
import Foundation

class ServiceManager
{
    var serviceKey: Data
    var subscribers: ClientsList
    
    init(fromServiceKey serviceKey: Data)
    {
        self.serviceKey = serviceKey;
        self.subscribers = ClientsList()
    }
}
