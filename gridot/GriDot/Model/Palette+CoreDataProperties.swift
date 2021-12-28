//
//  Palette+CoreDataProperties.swift
//  GriDot
//
//  Created by 박찬울 on 2021/12/28.
//
//

import Foundation
import CoreData


extension Palette {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Palette> {
        return NSFetchRequest<Palette>(entityName: "Palette")
    }

    @NSManaged public var colors: [String]?
    @NSManaged public var name: String?

}

extension Palette : Identifiable {

}
