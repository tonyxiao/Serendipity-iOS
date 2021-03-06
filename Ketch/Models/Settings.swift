//
//  Settings.swift
//  Ketch
//
//  Created by Tony Xiao on 4/19/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import Meteor

class Settings {
    enum Key : String {
        case SoftMinBuild = "softMinBuild"
        case HardMinBuild = "hardMinBuild"
        case EdgePanEnabled = "edgePanEnabled"
        case CrabUserId = "crabUserId"
        case Vetted = "vetted"
        case Email = "email"
        case GenderPref = "genderPref"
        case DebugLoginMode = "debugLoginMode"
    }
    enum GenderPref : String {
        case Men = "men"
        case Women = "women"
        case Both = "both"
    }
    let collection : METCollection
    
    var softMinBuild : Int? { return getValue(.SoftMinBuild) as? Int }
    var hardMinBuild : Int? { return getValue(.HardMinBuild) as? Int }
    var edgePanEnabled: Bool? { return getValue(.EdgePanEnabled) as? Bool }
    var crabUserId : String? { return getValue(.CrabUserId) as? String }
    var vetted : Bool? { return getValue(.Vetted) as? Bool }
    var email : String? { return getValue(.Email) as? String }
    var genderPref : GenderPref? {
        return (getValue(.GenderPref) as? String).map { GenderPref(rawValue: $0) }?
    }
    var debugLoginMode: Bool { return getValue(.DebugLoginMode) as? Bool ?? devAudience }
    var devAudience: Bool { return Globals.env.audience == .Dev }
    
    init(collection: METCollection) {
        self.collection = collection
    }
    
    func getValue(key: String) -> AnyObject? {
        return collection.documentWithID(key)?.fields["value"]
    }
    
    func getValue(key: Key) -> AnyObject? {
        return getValue(key.rawValue)
    }
}
