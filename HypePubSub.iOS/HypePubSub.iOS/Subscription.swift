//
//  Subscription.swift
//  HypePubSub.iOS
//

import Foundation


class Subscription
{
    
    var serviceName: String
    var serviceKey: Data
    var manager: HYPInstance
    var receivedMsg: [String]
    
    init(_ serviceName: String, _ manager: HYPInstance)
    {
        self.serviceName = serviceName;
        self.serviceKey = HpsGenericUtils.hash(ofString: serviceName)
        self.manager = manager;
        self.receivedMsg = [String]();
    }
}
