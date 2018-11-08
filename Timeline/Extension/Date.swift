//
//  Date.swift
//  Timeline
//
//  Created by Xavier on 11/8/18.
//  Copyright © 2018 Xavier ios dev. All rights reserved.
//

import Foundation
extension Date{
    
    var dateAsString: String{
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}
