//
//  Asset+CoreDataProperties.swift
//  GriDot
//
//  Created by 박찬울 on 2022/01/25.
//
//

import Foundation
import CoreData


extension Asset {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Asset> {
        return NSFetchRequest<Asset>(entityName: "Asset")
    }

    @NSManaged public var data: String?
    @NSManaged public var thumbnail: Data?
    @NSManaged public var title: String?
    @NSManaged public var uint_data: [UInt32]?

}

extension Asset : Identifiable {

}
