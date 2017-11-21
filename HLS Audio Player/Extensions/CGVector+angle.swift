//
//  CGVector+angle.swift
//  HLS Audio Player
//
//  Created by Nikita Gromadskyi on 11/21/17.
//  Copyright © 2017 Nikita Gromadskyi. All rights reserved.
//

import UIKit

extension CGVector {
    /**
     * Returns the angle in degrees of the vector described by the CGVector.
     * The range of the angle is -π to π; an angle of 0 points to the right.
     */
    public var angle: CGFloat {
        return atan2(dy, dx) * 180 / CGFloat.pi
    }
}
