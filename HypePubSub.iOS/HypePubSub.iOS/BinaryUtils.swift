//
//  BinaryUtils.swift
//  HypePubSub.iOS
//

import Foundation


class BinaryUtils
{
    public static func xor(array1: Data, array2: Data) -> Data?
    {
        if((array1.count == 0) || (array1.count != array2.count)){
            return nil
        }
        
        var xorArray:Data = Data(count: array1.count)
        for i in 0..<array1.count {
            xorArray[i] = array1[i] ^ array2[i]
        }
        
        return xorArray
    }
    
    public static func getHigherByteArray(array1: Data, array2: Data) -> Int
    {
        if((array1.count == 0) || (array1.count != array2.count)){
            return -1
        }
        
        for i in 0..<array1.count
        {
            let val1: UInt8 = UInt8 (array1[i]);
            let val2: UInt8 = UInt8 (array2[i])
            
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
    
    public static func byteArrayToHexString(array: Data) -> String
    {
        let hexStr: String = String()

        for i in 0..<array.count{
            let _ = hexStr.appendingFormat("%02x", array[i])
        }
        return hexStr
    }
}
