//
//  DrawingView.swift
//  minimapp
//
//  Created by Austin Riopelle on 8/2/15.
//  Copyright (c) 2015 acerio. All rights reserved.
//

import Foundation
import UIKit

class DrawingView: UIView {
    
    var dotArray = [[CGFloat]]()
    var toDraw = false
    
    override func drawRect(rect: CGRect) {
        UIColor.clearColor().setFill()
        UIRectFill(rect)
        println("drawdraw")
        if toDraw{
            println("fillclear")
            for(var i = 0; i < dotArray.count; i++){
                var path = UIBezierPath(ovalInRect: CGRectMake(dotArray[i][0]-5.0, dotArray[i][1]-5.0, 20.0, 20.0))
                UIColor.greenColor().setFill()
                path.fill()
            }
            dotArray.removeAll(keepCapacity: false)
        }
    }
}