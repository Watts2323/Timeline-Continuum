//
//  SeacrhableRecord.swift
//  Timeline
//
//  Created by Xavier on 11/8/18.
//  Copyright © 2018 Xavier ios dev. All rights reserved.
//

import Foundation
protocol SearchableRecord {
    
    func matches(searchTerm: String) -> Bool
    
}
