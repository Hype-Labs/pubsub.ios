//
//  HpbMessageType.swift
//  HypePubSub.iOS
//

import Foundation


enum HpsMessageType
{
    case SUBSCRIBE_SERVICE
    case UNSUBSCRIBE_SERVICE
    case PUBLISH
    case INFO
    case INVALID
    
    func toString() -> String
    {
        switch self {
        case .SUBSCRIBE_SERVICE:
            return "SUBSCRIBE_SERVICE"
        case .UNSUBSCRIBE_SERVICE:
            return "UNSUBSCRIBE_SERVICE"
        case .PUBLISH:
            return "PUBLISH"
        case .INFO:
            return "INFO"
        default:
            return "INVALID"
        }
    }
    
    func toOrdinal() -> UInt8
    {
        switch self {
        case .SUBSCRIBE_SERVICE:
            return 0
        case .UNSUBSCRIBE_SERVICE:
            return 1
        case .PUBLISH:
            return 2
        case .INFO:
            return 3
        default:
            return 4
        }
    }
    
}
