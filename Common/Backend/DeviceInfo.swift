//
//  DeviceInfo.swift
//  Ketch
//
//  Created by Tony Xiao on 4/15/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import SimpleKeychain

extension UIDevice {
    
    // TODO: This is not thread-safe. Make thread-safe
    func getPersistentIdentifier() -> String {
        let keychain = A0SimpleKeychain(service: NSBundle.mainBundle().bundleIdentifier)
        let kDeviceId = "deviceId"
        var identifier = keychain.stringForKey(kDeviceId)
        if identifier == nil {
            identifier = identifierForVendor?.UUIDString ?? "r-\(NSUUID().UUIDString)"
            keychain.setString(identifier, forKey: kDeviceId)
        }
        return identifier
    }
    
}
