//
//  Dog.swift
//  DogeWalk
//
//  Created by Katharina Müllek on 04.05.21.
//

import Foundation
import RealmSwift

class Dog: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var profile = Data()
    @objc dynamic var age: Date?
    @objc dynamic var breed: String?
    @objc dynamic var isFemale: Bool = true
    @objc dynamic var favouriteToy: String?
    @objc dynamic var favouriteTreat: String?
    @objc dynamic var chipID: String?
    var participatedWalks = List<Walk>()
}
