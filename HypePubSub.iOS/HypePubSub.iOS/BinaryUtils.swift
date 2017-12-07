//
//  BinaryUtils.swift
//  HypePubSub.iOS
//

import Foundation

class BinaryUtils
{
    public static func xor(data1: Data, data2: Data) -> Data?
    {
        if((data1.count == 0) || (data1.count != data2.count)){
            return nil
        }
        
        var xorArray:Data = Data(count: data1.count)
        for i in 0..<data2.count {
            xorArray[i] = data1[i] ^ data2[i]
        }
        
        return xorArray
    }
    
    public static func determineHigherBigEndianData(data1: Data, data2: Data) -> Int
    {
        if((data1.count == 0) || (data1.count != data2.count)){
            return -1
        }
        
        for i in 0..<data1.count
        {
            let val1: UInt8 = UInt8 (data1[i]);
            let val2: UInt8 = UInt8 (data2[i])
            
            if(val1 == val2){
                continue;
            }
                
            // The array which has the largest most significant byte is the higher one
            if(val1 > val2) {
                return 1;
            }
            else {
                return 2;
            }
        }
    
        return  0;
    }
    
    public static func toHexString(data: Data) -> String
    {
        var hexStr: String = String()
        for i in 0..<data.count{
            hexStr.append(String(format:"%02x", data[i]))
        }
        return hexStr
    }
}
