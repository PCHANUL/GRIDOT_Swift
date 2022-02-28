//
//  User+CoreDataProperties.swift
//  
//
//  Created by 박찬울 on 2022/02/28.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var authCode: String?
    @NSManaged public var email: String?
    @NSManaged public var fullName: String?
    @NSManaged public var idToken: String?
    @NSManaged public var userId: String?

}
