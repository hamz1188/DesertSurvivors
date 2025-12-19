//
//  Extensions.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import Foundation
import SpriteKit

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let dx = x - point.x
        let dy = y - point.y
        return sqrt(dx * dx + dy * dy)
    }
    
    func normalized() -> CGPoint {
        let length = sqrt(x * x + y * y)
        guard length > 0 else { return CGPoint.zero }
        return CGPoint(x: x / length, y: y / length)
    }
    
    func length() -> CGFloat {
        return sqrt(x * x + y * y)
    }
    
    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }
    
    static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }
    
    static func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
        return CGPoint(x: point.x * scalar, y: point.y * scalar)
    }
}

extension SKNode {
    func distance(to node: SKNode) -> CGFloat {
        return position.distance(to: node.position)
    }
}

extension Float {
    func clamped(min: Float, max: Float) -> Float {
        return Swift.max(min, Swift.min(max, self))
    }
}

extension CGFloat {
    func clamped(min: CGFloat, max: CGFloat) -> CGFloat {
        return Swift.max(min, Swift.min(max, self))
    }
}

// MARK: - SKColor Extensions

extension SKColor {
    /// Returns a darker version of the color
    func darker(by percentage: CGFloat = 0.2) -> SKColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        #if os(iOS)
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #else
        if let rgbColor = self.usingColorSpace(.sRGB) {
            rgbColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        }
        #endif

        return SKColor(
            red: max(red - percentage, 0),
            green: max(green - percentage, 0),
            blue: max(blue - percentage, 0),
            alpha: alpha
        )
    }

    /// Returns a lighter version of the color
    func lighter(by percentage: CGFloat = 0.2) -> SKColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        #if os(iOS)
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #else
        if let rgbColor = self.usingColorSpace(.sRGB) {
            rgbColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        }
        #endif

        return SKColor(
            red: min(red + percentage, 1),
            green: min(green + percentage, 1),
            blue: min(blue + percentage, 1),
            alpha: alpha
        )
    }
}

