
import Foundation

class Subscription
{
    var serviceName: String
    var serviceKey: Data
    var manager: Client
    var receivedMsg: [String]
    
    init(withName serviceName: String, withManager manager: Client)
    {
        self.serviceName = serviceName;
        self.serviceKey = HpsGenericUtils.hash(ofString: serviceName)
        self.manager = manager;
        self.receivedMsg = [String]();
    }
}
