//
//  Analytics.swift
//  SWTOR HoloNet
//
//  Created by Ivan Fabijanovic on 17/02/2017.
//  Copyright © 2017 Ivan Fabijanović. All rights reserved.
//

import Foundation
#if !TEST
import Firebase
#endif

protocol Analytics {
    func track(event: String)
    func track(event: String, properties: [AnyHashable: Any])
}

struct DefaultAnalytics: Analytics {
    func track(event: String) {
        #if !TEST
        FIRAnalytics.logEvent(withName: event, parameters: nil)
        #endif
    }
    
    func track(event: String, properties: [AnyHashable : Any]) {
        #if !TEST
        let parameters = properties as? [String: NSObject]
        FIRAnalytics.logEvent(withName: event, parameters: parameters)
        #endif
    }
}
