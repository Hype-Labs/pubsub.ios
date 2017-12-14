
import Foundation

class SyncUtils
{
    static func lock(obj: AnyObject, blk:() -> ())
    {
        objc_sync_enter(obj)
        blk()
        objc_sync_exit(obj)
    }
}
