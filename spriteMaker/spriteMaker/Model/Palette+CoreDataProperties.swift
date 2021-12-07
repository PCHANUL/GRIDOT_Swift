//
//  Palette+CoreDataProperties.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/12/07.
//
//

import Foundation
import CoreData


extension Palette {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Palette> {
        return NSFetchRequest<Palette>(entityName: "Palette")
    }

    @NSManaged public var name: String?
    @NSManaged public var colors: [String]?

}

extension Palette : Identifiable {

}
