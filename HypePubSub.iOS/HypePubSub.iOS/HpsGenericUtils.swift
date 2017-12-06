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
    
    static func areInstancesEqual(_ instance1: HYPInstance, _ instance2: HYPInstance) -> Bool
    {
        return (instance1.identifier == instance2.identifier)
    }
    
    static func getLogStr(fromHYPInstance instance: HYPInstance) -> String
    {
        return String(data: instance.announcement, encoding: HpsConstants.ENCODING_STANDARD)!
            + " (0x" + BinaryUtils.byteArrayToHexString(instance.identifier) + ")"
    }
    
    static func getLogStr(fromSubscription subscription: Subscription) -> String
    {
        return subscription.serviceName + " (0x" + BinaryUtils.byteArrayToHexString(subscription.serviceKey) + ")";
    }
    
}
