//
//  Annotation.swift
//  minimapp
//
//  Created by Austin Riopelle on 8/1/15.
//  Copyright (c) 2015 acerio. All rights reserved.
//

import Foundation
import MapKit

class Annotation : NSObject, MKAnnotation {
    var coordinate = CLLocationCoordinate2D()
    var title = ""
    var subtitle = ""
    var url = NSURL()
}