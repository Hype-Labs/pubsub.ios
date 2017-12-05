//
//  HpbMessage.swift
//  HypePubSub.iOS
//

import Foundation


class HpsMessage
{
    private var type: HpsMessageType
    private var serviceKey: Data
    private var info: String?
    
    public init(type: HpsMessageType, serviceKey: Data, info: String)
    {
        self.type = type
        self.serviceKey = serviceKey
        self.info = info;
    }
    
    public init(type: HpsMessageType, serviceKey: Data)
    {
        self.type = type
        self.serviceKey = serviceKey
        self.info = nil
    }
    
    public func toByteArray() -> Data
    {
        var msgData = Data()
        msgData.append(type.toOrdinal())
        msgData.append(serviceKey)
        
        if(info != nil){
            msgData.append(info!.data(using: HpsConstants.ENCODING_STANDARD)!)
        }

        return msgData
    }
    
    public func toLogString() -> String
    {
        var logString: String = type.toString() + " message for service 0x"
        + BinaryUtils.byteArrayToHexString(serviceKey) + ".";
        if(info != nil) {
            logString += " Info: " + info! + ".";
        }
        
        return logString
    }
    
    public func getType() -> HpsMessageType
    {
        return type;
    }
    
    public func getServiceKey() -> Data
    {
        return serviceKey;
    }
    
    public func getInfo() -> String?
    {
        return info;
    }

}
