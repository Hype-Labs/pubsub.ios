
import Foundation

enum HpsMessageType
{
    case SUBSCRIBE_SERVICE
    case UNSUBSCRIBE_SERVICE
    case PUBLISH
    case INFO
    case INVALID
    
    static let SUBSCRIBE_SERVICE_ORDINAL:UInt8 = 0
    static let UNSUBSCRIBE_SERVICE_ORDINAL:UInt8 = 1
    static let PUBLISH_ORDINAL:UInt8 = 2
    static let INFO_ORDINAL:UInt8 = 3
    static let INVALID_ORDINAL:UInt8 = 4
    
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
            return HpsMessageType.SUBSCRIBE_SERVICE_ORDINAL
        case .UNSUBSCRIBE_SERVICE:
            return HpsMessageType.UNSUBSCRIBE_SERVICE_ORDINAL
        case .PUBLISH:
            return HpsMessageType.PUBLISH_ORDINAL
        case .INFO:
            return HpsMessageType.INFO_ORDINAL
        default:
            return HpsMessageType.INVALID_ORDINAL
        }
    }
    
}
