//
//  LogUtils.swift
//  HypePubSub.iOS
//
//  Created by Xavier Araújo on 07/12/2017.
//  Copyright © 2017 Xavier Araújo. All rights reserved.
//

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
