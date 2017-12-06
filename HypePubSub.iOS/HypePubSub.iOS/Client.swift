//
//  Client.swift
//  HypePubSub.iOS
//

import Foundation


class Client
{
    var instance: HYPInstance
    var key: Data
    
    init(fromHYPInstance instance: HYPInstance)
    {
        self.instance = instance
        self.key = HpsGenericUtils.hash(ofData: instance.identifier)
    }
}

