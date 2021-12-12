//
//  Tool+CoreDataProperties.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/12/13.
//
//

import Foundation
import CoreData


extension Tool {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tool> {
        return NSFetchRequest<Tool>(entityName: "Tool")
    }

    @NSManaged public var main: String?
    @NSManaged public var sub: String?
    @NSManaged public var ext: [String]?

}

extension Tool : Identifiable {

}
