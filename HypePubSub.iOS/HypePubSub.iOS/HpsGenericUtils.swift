//
//  HpbGenericUtils.swift
//  HypePubSub.iOS
//

import Foundation

class HpsGenericUtils
{
    static func hash(ofData data: Data) -> Data
    {
        var hashData = Data(count: Int(HpsConstants.HASH_ALGORITHM_DIGEST_LENGTH))
        
        _ = hashData.withUnsafeMutableBytes {digestBytes in
            data.withUnsafeBytes {messageBytes in
                HpsConstants.HASH_ALGORITHM(messageBytes, CC_LONG(data.count), digestBytes)
            }
        }
        return hashData
    }
    
    static func hash(ofString str: String) -> Data
    {
        let data: Data = str.data(using: .utf8)!
        return hash(ofData: data)
    }
    
    static func areClientsEqual(_ client1: Client, _ client2: Client) -> Bool
    {
        return (client1.instance.identifier == client2.instance.identifier)
    }
    
    static func getLogStr(fromClient client: Client) -> String
    {
        return getLogStr(fromHYPInstance: client.instance)
    }
    
    static func getLogStr(fromHYPInstance instance: HYPInstance) -> String
    {
        return String(data: instance.announcement, encoding: HpsConstants.ENCODING_STANDARD)!
            + " (0x" + BinaryUtils.toHexString(data: instance.identifier) + ")"
    }
    
    static func getLogStr(fromSubscription subscription: Subscription) -> String
    {
        return subscription.serviceName + " (0x" + BinaryUtils.toHexString(data: subscription.serviceKey) + ")";
    }
    
}
