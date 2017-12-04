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
    
    init(serviceName: String, manager: HYPInstance)
    {
        self.serviceName = serviceName;
        self.serviceKey = HpbGenericUtils.stringHash(str: serviceName)
        self.manager = manager;
        self.receivedMsg = [String]();
    }
}
