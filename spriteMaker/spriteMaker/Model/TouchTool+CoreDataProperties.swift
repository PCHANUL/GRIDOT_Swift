//
//  TouchTool+CoreDataProperties.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/12/12.
//
//

import Foundation
import CoreData


extension TouchTool {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TouchTool> {
        return NSFetchRequest<TouchTool>(entityName: "TouchTool")
    }

    @NSManaged public var main: String?
    @NSManaged public var sub: String?

}

extension TouchTool : Identifiable {

}
