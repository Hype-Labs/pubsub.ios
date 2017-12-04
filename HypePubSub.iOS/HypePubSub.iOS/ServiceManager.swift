//
//  ServiceManager.swift
//  HypePubSub.iOS
//

import Foundation


class ServiceManager
{
    var serviceKey: Data
    var subscribers: ClientsList
    
    init(serviceKey: Data)
    {
        self.serviceKey = serviceKey;
        self.subscribers = ClientsList()
    }
}
