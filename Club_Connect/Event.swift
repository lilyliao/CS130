//
//  Event.swift
//  Club_Connect
//
//  Created by Li-Wei Tseng on 10/29/16.
//  Copyright © 2016 Li-Wei Tseng. All rights reserved.
//

import Foundation

struct Event {
    var id: String?
    var name: String?
    var description: String?
    
    var start_time: String?
    var end_time: String?
    
    var rsvp_status: String?
    
    
    init(id: String?, name: String?, description: String?, start_time: String?, end_time: String?, rsvp_status: String?) {
        self.id = id
        self.name = name
        self.description = description
        self.start_time = start_time
        self.end_time = end_time
        self.rsvp_status = rsvp_status
    }
}
