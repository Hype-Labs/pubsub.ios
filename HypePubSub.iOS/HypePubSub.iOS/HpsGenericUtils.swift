
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
        return hash(ofData: str.data(using: HpsConstants.ENCODING_STANDARD)!)
    }
    
    static func areClientsEqual(_ client1: Client, _ client2: Client) -> Bool
    {
        return (client1.instance.identifier == client2.instance.identifier)
    }
    
    static func getAnnouncementStr(fromHYPInstance instance: HYPInstance) -> String
    {
        if(instance.announcement == nil) {
            return "---";
        }
        return String(data: instance.announcement, encoding: HpsConstants.ENCODING_STANDARD)!
    }
    
    static func getLogStr(fromClient client: Client) -> String
    {
        return getLogStr(fromHYPInstance: client.instance)
    }
    
    static func getLogStr(fromHYPInstance instance: HYPInstance) -> String
    {
        return String(format: "%@ (%@)",
                      getAnnouncementStr(fromHYPInstance: instance),
                      getIdString(fromHYPInstance: instance))
    }
    
    static func getLogStr(fromSubscription subscription: Subscription) -> String
    {
        return String(format: "%@ (%@)",
                      subscription.serviceName,
                      getKeyString(fromSubscription: subscription))
    }
    
    static func getIdString(fromClient client: Client) -> String
    {
        return getIdString(fromHYPInstance: client.instance)
    }
    
    static func getIdString(fromHYPInstance instance: HYPInstance) -> String
    {
        return String(format: "ID: 0x%@", BinaryUtils.toHexString(data: instance.identifier))
    }
    
    static func getKeyString(fromClient client: Client) -> String
    {
        return String(format: "Key: 0x%@", BinaryUtils.toHexString(data: client.key))
    }
    
    static func getKeyString(fromSubscription subscription: Subscription) -> String
    {
        return String(format: "Key: 0x%@", BinaryUtils.toHexString(data: subscription.serviceKey))
    }
    
    static func getKeyString(fromServiceManager serviceManager: ServiceManager) -> String
    {
        return String(format: "Key: 0x%@", BinaryUtils.toHexString(data: serviceManager.serviceKey))
    }
}
