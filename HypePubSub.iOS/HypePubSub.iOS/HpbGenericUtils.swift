//
//  HpbGenericUtils.swift
//  HypePubSub.iOS
//

import Foundation

class HpbGenericUtils
{
    static func byteArrayHash(data: Data) -> Data
    {
        var hashData = Data(count: Int(Constants.HPB_HASH_ALGORITHM_DIGEST_LENGTH))
        
        _ = hashData.withUnsafeMutableBytes {digestBytes in
            data.withUnsafeBytes {messageBytes in
                Constants.HPB_HASH_ALGORITHM(messageBytes, CC_LONG(data.count), digestBytes)
            }
        }
        return hashData
    }
    
    static func stringHash(str: String) -> Data
    {
        var data: Data = str.data(using: .utf8)!
        var hashData = Data(count: Int(Constants.HPB_HASH_ALGORITHM_DIGEST_LENGTH))
        
        _ = hashData.withUnsafeMutableBytes {digestBytes in
            data.withUnsafeBytes {messageBytes in
                Constants.HPB_HASH_ALGORITHM(messageBytes, CC_LONG(data.count), digestBytes)
            }
        }
        return hashData
    }
    
}
