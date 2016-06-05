//
//  MapPin+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Andy Xu on 16/6/3.
//  Copyright © 2016年 Andy Xu. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension MapPin {

    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var images: NSMutableOrderedSet

}
