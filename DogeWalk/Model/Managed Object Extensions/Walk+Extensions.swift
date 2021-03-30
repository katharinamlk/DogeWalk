//
//  Walk+Extensions.swift
//  DogeWalk
//
//  Created by Katharina Müllek on 23.03.21.
//

import Foundation
import CoreData

extension Walk {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        date = Date()
    }
}
