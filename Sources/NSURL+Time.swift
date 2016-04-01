//
//  NSURL+Time.swift
//  Chompy
//
//  Created by Jasdev Singh on 3/17/16.
//  Copyright © 2016 Jasdev Singh. All rights reserved.
//

import Foundation

extension NSURL {
    /// Appends the current epoch time in milliseconds to the path
    var pathWithAppendedTimestamp: NSURL {
        return appendingPathComponent("\(Int(NSDate().timeIntervalSince1970*1000))")
    }
}
