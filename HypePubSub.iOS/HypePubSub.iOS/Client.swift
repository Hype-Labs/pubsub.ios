//
//  Client.swift
//  HypePubSub.iOS
//

import Foundation


class Client
{
    var instance: HYPInstance
    var key: Data
    
    init(instance: HYPInstance)
    {
        self.instance = instance
        self.key = HpsGenericUtils.byteArrayHash(data: (instance.identifier))
    }
}

