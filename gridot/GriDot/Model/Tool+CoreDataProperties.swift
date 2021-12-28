//
//  Tool+CoreDataProperties.swift
//  GriDot
//
//  Created by 박찬울 on 2021/12/28.
//
//

import Foundation
import CoreData


extension Tool {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tool> {
        return NSFetchRequest<Tool>(entityName: "Tool")
    }

    @NSManaged public var ext: [String]?
    @NSManaged public var main: String?
    @NSManaged public var sub: String?

}

extension Tool : Identifiable {

}
