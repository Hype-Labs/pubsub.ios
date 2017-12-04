//
//  HpbMessage.swift
//  HypePubSub.iOS
//

import Foundation


class HpbMessage
{
    private var type: HpbMessageType
    private var serviceKey: Data
    private var info: String?
    
    public init(type: HpbMessageType, serviceKey: Data, info: String)
    {
        self.type = type
        self.serviceKey = serviceKey
        self.info = info;
    }
    
    public init(type: HpbMessageType, serviceKey: Data)
    {
        self.type = type
        self.serviceKey = serviceKey
        self.info = nil
    }
    
    /*
    public func toByteArray() -> Data
    {
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream( );
        outputStream.write((byte) type.ordinal());
        outputStream.write(serviceKey);
        if(info != null)
        {
            outputStream.write(info.getBytes(HpbConstants.ENCODING_STANDARD));
        }
        return outputStream.toByteArray();
    }
    */
    
    /*
    public func toLogString() -> String
    {
        var logString: String = type.toString() + " message for service 0x"
        + BinaryUtils.byteArrayToHexString(serviceKey) + ".";
        if(info != nil) {
            logString += " Info: " + info + ".";
        }
    }
     */
    
    public func getType() -> HpbMessageType
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
