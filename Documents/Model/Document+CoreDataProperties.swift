//
//  Document+CoreDataProperties.swift
//  Documents
//
//  Created by Dominic Pilla on 7/2/18.
//  Copyright © 2018 Dominic Pilla. All rights reserved.
//
//

import Foundation
import CoreData


extension Document {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Document> {
        return NSFetchRequest<Document>(entityName: "Document")
    }

    @NSManaged public var title: String?
    @NSManaged public var size: Double
    @NSManaged public var rawDate: NSDate?
    @NSManaged public var contents: String?

}
