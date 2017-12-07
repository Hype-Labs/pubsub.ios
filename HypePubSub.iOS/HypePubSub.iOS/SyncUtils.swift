//
//  SyncUtils.swift
//  HypePubSub.iOS
//
//  Created by Xavier Araújo on 07/12/2017.
//  Copyright © 2017 Xavier Araújo. All rights reserved.
//

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
