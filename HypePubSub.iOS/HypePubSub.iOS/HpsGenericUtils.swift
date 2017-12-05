//
//  HpbGenericUtils.swift
//  HypePubSub.iOS
//

import Foundation

class HpsGenericUtils
{
    static func byteArrayHash(data: Data) -> Data
    {
        var hashData = Data(count: Int(HpsConstants.HASH_ALGORITHM_DIGEST_LENGTH))
        
        _ = hashData.withUnsafeMutableBytes {digestBytes in
            data.withUnsafeBytes {messageBytes in
                HpsConstants.HASH_ALGORITHM(messageBytes, CC_LONG(data.count), digestBytes)
            }
        }
        return hashData
    }
    
    static func stringHash(str: String) -> Data
    {
        var data: Data = str.data(using: .utf8)!
        var hashData = Data(count: Int(HpsConstants.HASH_ALGORITHM_DIGEST_LENGTH))
        
        _ = hashData.withUnsafeMutableBytes {digestBytes in
            data.withUnsafeBytes {messageBytes in
                HpsConstants.HASH_ALGORITHM(messageBytes, CC_LONG(data.count), digestBytes)
            }
        }
        return hashData
    }
    
    static func getInstanceLogIdStr(_ instance: HYPInstance) -> String
    {
        let logStr = String(data: instance.announcement, encoding: HpsConstants.ENCODING_STANDARD)!
            + " (0x" + BinaryUtils.byteArrayToHexString(instance.identifier) + ")"
        return logStr
    }
    
}
