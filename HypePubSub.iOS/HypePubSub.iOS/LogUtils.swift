
import Foundation

class LogUtils
{
    static func log(prefix: String, logMsg: String)
    {
        #if DEBUG
            NSLog(prefix + logMsg)
        #endif
    }
}
