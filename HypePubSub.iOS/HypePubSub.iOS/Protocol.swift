//
//  Protocol.swift
//  HypePubSub.iOS
//

import Foundation
import os


class Protocol
{
    private static let PROTOCOL_LOG_PREFIX = HpsConstants.LOG_PREFIX + "<Protocol> "
    
    static let MESSAGE_TYPE_BYTE_SIZE = 1
    
    ///////////////////////////////////////////////////////////////////////////////////////////
    // Message Sending Processing Methods
    ///////////////////////////////////////////////////////////////////////////////////////////
    
    static func sendSubscribeMsg(_ serviceKey: Data, _ destInstance: HYPInstance) -> Data
    {
        let hpsMsg = HpsMessage(HpsMessageType.SUBSCRIBE_SERVICE, serviceKey)
        printMsgSendLog(hpsMsg, destInstance)
        HypeSdkInterface.getInstance().sendMsg(hpsMsg, destInstance)
        return hpsMsg.toByteArray()
    }
    
    static func sendUnsubscribeMsg(_ serviceKey: Data, _ destInstance: HYPInstance) -> Data
    {
        let hpsMsg = HpsMessage(HpsMessageType.UNSUBSCRIBE_SERVICE, serviceKey)
        printMsgSendLog(hpsMsg, destInstance)
        HypeSdkInterface.getInstance().sendMsg(hpsMsg, destInstance)
        return hpsMsg.toByteArray()
    }
    
    static func sendPublishMsg(_ serviceKey: Data, _ destInstance: HYPInstance, _ info: String) -> Data
    {
        let hpsMsg = HpsMessage(HpsMessageType.PUBLISH, serviceKey, info)
        printMsgSendLog(hpsMsg, destInstance)
        HypeSdkInterface.getInstance().sendMsg(hpsMsg, destInstance)
        return hpsMsg.toByteArray()
    }
    
    static func sendInfoMsg(_ serviceKey: Data, _ destInstance: HYPInstance, _ info: String) -> Data
    {
        let hpsMsg = HpsMessage(HpsMessageType.INFO, serviceKey, info)
        printMsgSendLog(hpsMsg, destInstance)
        HypeSdkInterface.getInstance().sendMsg(hpsMsg, destInstance)
        return hpsMsg.toByteArray()
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////
    // Received Message Processing Methods
    ///////////////////////////////////////////////////////////////////////////////////////////
    
    static func receiveMsg(originInstance: HYPInstance, packet: Data) -> Int
    {
        if(packet.count <= 0) {
            os_log("%@ Received message has an invalid length", log: OSLog.default, type: .error,
                   PROTOCOL_LOG_PREFIX)
            return -1
        }
    
        switch (extractHpsMessageTypeFromReceivedPacket(packet))
        {
            case HpsMessageType.SUBSCRIBE_SERVICE:
                _ = receiveSubscribeMsg(originInstance, packet)
                break
            case HpsMessageType.UNSUBSCRIBE_SERVICE:
                _ = receiveUnsubscribeMsg(originInstance, packet)
                break
            case HpsMessageType.PUBLISH:
                _ = receivePublishMsg(originInstance, packet)
                break
            case HpsMessageType.INFO:
                _ = receiveInfoMsg(originInstance, packet)
                break
            case HpsMessageType.INVALID:
                os_log("%@ Received message has an invalid MessageType", log: OSLog.default, type: .error,
                       PROTOCOL_LOG_PREFIX)
            return -2 // HpsMessage type not recognized. Discard
        }
    
        return 0
    }
    
    private static func receiveSubscribeMsg(_ originInstance: HYPInstance, _ packet: Data) -> Int
    {
        if(packet.count != (MESSAGE_TYPE_BYTE_SIZE + Int(HpsConstants.HASH_ALGORITHM_DIGEST_LENGTH))) {
            os_log("%@ Received Subscribe message has an invalid length", log: OSLog.default, type: .error,
                   PROTOCOL_LOG_PREFIX)
            return -1
        }
    
        let hpsMsg = HpsMessage(HpsMessageType.SUBSCRIBE_SERVICE, extractServiceKeyFromReceivedPacket(packet))
        printMsgReceivedLog(hpsMsg, originInstance)
        let hps = HypePubSub.getInstance()
        hps.processSubscribeReq(hpsMsg.getServiceKey(), originInstance)
        return 0
    }
    
    private static func receiveUnsubscribeMsg(_ originInstance: HYPInstance, _ packet: Data) -> Int
    {
        if(packet.count != (MESSAGE_TYPE_BYTE_SIZE + Int(HpsConstants.HASH_ALGORITHM_DIGEST_LENGTH))) {
            os_log("%@ Received Unsubscribe message has an invalid length", log: OSLog.default, type: .error,
                   PROTOCOL_LOG_PREFIX)
            return -1
        }
    
        let hpsMsg = HpsMessage(HpsMessageType.UNSUBSCRIBE_SERVICE, extractServiceKeyFromReceivedPacket(packet))
        printMsgReceivedLog(hpsMsg, originInstance)
        let hps = HypePubSub.getInstance()
        hps.processUnsubscribeReq(hpsMsg.getServiceKey(), originInstance)
        return 0
    }
    
    private static func receivePublishMsg(_ originInstance: HYPInstance, _ packet: Data) -> Int
    {
        if(packet.count <= (MESSAGE_TYPE_BYTE_SIZE + Int(HpsConstants.HASH_ALGORITHM_DIGEST_LENGTH))) {
            os_log("%@ Received Publish message has an invalid length", log: OSLog.default, type: .error,
                   PROTOCOL_LOG_PREFIX)
            return -1
        }
    
        let hpsMsg = HpsMessage(HpsMessageType.PUBLISH, extractServiceKeyFromReceivedPacket(packet), String(data: extractInfoFromReceivedPacket(packet), encoding: HpsConstants.ENCODING_STANDARD)!)
        printMsgReceivedLog(hpsMsg, originInstance)
        let hps = HypePubSub.getInstance()
        hps.processPublishReq(hpsMsg.getServiceKey(), hpsMsg.getInfo()!)
        return 0
    }
    
    private static func receiveInfoMsg(_ originInstance: HYPInstance, _ packet: Data) -> Int
    {
        if(packet.count <= (MESSAGE_TYPE_BYTE_SIZE + Int(HpsConstants.HASH_ALGORITHM_DIGEST_LENGTH))) {
            os_log("%@ Received Info message has an invalid length", log: OSLog.default, type: .error,
                   PROTOCOL_LOG_PREFIX)
            return -1
        }
    
        let hpsMsg = HpsMessage(HpsMessageType.INFO, extractServiceKeyFromReceivedPacket(packet), String(data: extractInfoFromReceivedPacket(packet), encoding: HpsConstants.ENCODING_STANDARD)!)
        printMsgReceivedLog(hpsMsg, originInstance)
        let hps = HypePubSub.getInstance()
        hps.processInfoMsg(hpsMsg.getServiceKey(), hpsMsg.getInfo()!)
        return 0
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////
    // Received Message Data Extraction Methods
    ///////////////////////////////////////////////////////////////////////////////////////////
    
    static func extractHpsMessageTypeFromReceivedPacket(_ packet: Data) -> HpsMessageType
    {
        if(packet.count <= 0) {
            return HpsMessageType.INVALID
        }
    
        if(packet.first == HpsMessageType.SUBSCRIBE_SERVICE_ORDINAL) {
            return HpsMessageType.SUBSCRIBE_SERVICE
        }
        else if(packet.first == HpsMessageType.UNSUBSCRIBE_SERVICE_ORDINAL) {
            return HpsMessageType.UNSUBSCRIBE_SERVICE
        }
        else if(packet.first == HpsMessageType.PUBLISH_ORDINAL) {
            return HpsMessageType.PUBLISH
        }
        else if(packet.first == HpsMessageType.INFO_ORDINAL) {
            return HpsMessageType.INFO
        }
    
        return HpsMessageType.INVALID
    }
 
    static func extractServiceKeyFromReceivedPacket(_ packet: Data) -> Data
    {
         let begin = MESSAGE_TYPE_BYTE_SIZE
         let end = Int(HpsConstants.HASH_ALGORITHM_DIGEST_LENGTH)
         let serviceKeyRange: Range<Int> = begin..<end
         return packet.subdata(in: serviceKeyRange)
    }

    static func extractInfoFromReceivedPacket(_ packet: Data) -> Data
    {
        let begin = Int(HpsConstants.HASH_ALGORITHM_DIGEST_LENGTH) + MESSAGE_TYPE_BYTE_SIZE
        let end = (packet.count)
        let infoRange: Range<Int> = begin..<end
        return packet.subdata(in: infoRange)
    }

    
    ///////////////////////////////////////////////////////////////////////////////////////////
    // Logging Methods
    ///////////////////////////////////////////////////////////////////////////////////////////
    
    static func printMsgSendLog(_ hpsMsg: HpsMessage, _ destination: HYPInstance)
    {
        os_log("%@ Sending %@ Destination %@", log: OSLog.default, type: .info,
               PROTOCOL_LOG_PREFIX, hpsMsg.toLogString(), HpsGenericUtils.getLogStr(fromHYPInstance: destination))
    }
    
    static func printMsgReceivedLog(_ hpsMsg: HpsMessage, _ originator: HYPInstance)
    {
        os_log("%@ Received %@ Originator %@", log: OSLog.default, type: .info,
               PROTOCOL_LOG_PREFIX, hpsMsg.toLogString(), HpsGenericUtils.getLogStr(fromHYPInstance: originator))
    }
}
